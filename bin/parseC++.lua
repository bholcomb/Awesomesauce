local clang = require 'lua.clang-parser'
local sqlite3 = require 'lua.sqlite3'

dofile("util.lua")

DEBUG.enabled = true

local moduleName = "test"
local clangArgs = {}
local index = nil
local tu = nil
local FUNC = {}

local default_table_meta = {}
function new_default_table(t)
    return setmetatable(t or {}, default_table_meta)
end
function default_table_meta.__index(t,k)
    local v = {}
    rawset(t, k, v)
    return v
end

local DB = new_default_table()

   
do
    local cache = setmetatable({}, {__mode="k"})
    function getExtent(file, fromRow, fromCol, toRow, toCol)
        if not file then
            --DEBUG(file, fromRow, fromCol, toRow, toCol)
            return ''
        end
        if toRow - fromRow > 3 then
            return ('%s: %d:%d - %d:%d'):format(file, fromRow, fromCol, toRow, toCol)
        end
        if not cache[file] then
            local f = assert(io.open(file))
            local t, n = {}, 0
            for l in f:lines() do
                n = n + 1
                t[n] = l
            end
            cache[file] = t
        end
        local lines = cache[file]
        if not (lines and lines[fromRow] and lines[toRow]) then
            --DEBUG('!!! Missing lines '..fromRow..'-'..toRow..' in file '..file)
            return ''
        end
        if fromRow == toRow then
            return lines[fromRow]:sub(fromCol, toCol-1)
        else
            local res = {}
            for i=fromRow, toRow do
                if i==fromRow then
                    res[#res+1] = lines[i]:sub(fromCol)
                elseif i==toRow then
                    res[#res+1] = lines[i]:sub(1,toCol-1)
                else
                    res[#res+1] = lines[i]
                end
            end
            return table.concat(res, '\n')
        end
    end
end

function findChildrenByType(cursor, type, src)
    print("Looking for: "..type)
    local children, n = {}, 0
    local function finder(cur)
        for i,c in ipairs(cur:children()) do
            if c and (c:kind() == type and c:location() == src) then
                n = n + 1
                children[n] = c
            end
            finder(c)
        end
   end
   finder(cursor)
   return children
end

function translateType(cur, typ)
    if not typ then
        typ = cur:type()
    end

    local typeKind = tostring(typ)
    if typeKind == 'Typedef' or typeKind == 'Record' then
        return typ:declaration():name()
    elseif typeKind == 'Pointer' then
        return translateType(cur, typ:pointee()) .. '*'
    elseif typeKind == 'LValueReference' then
        return translateType(cur, typ:pointee()) .. '&'
    elseif typeKind == 'Unexposed' then
        local def = getExtent(cur:location())
        --DEBUG('!Unexposed!', def)
        return def
    else
        return typeKind
    end
end

local function trim(s)
   local from = s:match"^%s*()"
   local res = from > #s and "" or s:match(".*%S", from)
   return (res:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

function dumpXml(xml, cur, src)      
   if(cur:location() == src) then
      local tag = cur:kind()
      local name = trim(cur:name())
      local attr = ' name="' .. name .. '"'
      local dname = trim(cur:displayName())
      if dname ~= name then
         attr = attr .. ' display="' .. dname .. '"'
      end
      attr = attr ..' text="' .. trim(getExtent(cur:location())) .. '"' 
      local children = cur:children()
      if #children == 0 then
         xml:write('<', tag, attr, ' />\n')
      else
         xml:write('<', tag, attr, ' >\n')
         for _,c in ipairs(children) do
            dumpXml(xml, c, src)
         end
         xml:write('</',tag,'>\n')
      end
   end
end

function processArgument(idx, arg)
    local name = arg:name()
    local type = translateType(arg, arg:type())
    local kind = translateType(arg, arg:kind())
    
    local children = arg:children()

    local const, default
    
    if tostring(type) == 'LValueReference' then
        const = type:pointee():isConst()
    end

    if #children > 0 then
        if #children == 1 and children[1]:kind() ~= 'TypeRef' then
            default = getExtent(children[1]:location())
        else
            local newtype = {}
            for i,c in ipairs(children) do
                local kind = c:kind()
                if kind == 'NamespaceRef' or kind == 'TypeRef' then
                    newtype[#newtype+1] = c:referenced():name()
                elseif kind == 'DeclRef' then
                    default = getExtent(c:location())
                end
            end
            if #newtype > 0 then type = table.concat(newtype, '::') end
        end
    end

    --DEBUG('', '', idx, name, type)

    return {
        name = name,
        type = type,
        const = const,
        default = default,
    }
end

function processMethod(method, kind, access)
     -- process argument
    local argTable = {}
    local args = method:arguments()
    for i, arg in ipairs(args) do
        argTable[i] = processArgument(i, arg)
    end

    -- check for signal / slot, courtesy of qt4-qobjectdefs-injected.h
    local signal, slot
    for _, child in ipairs(method:children()) do
        if child:kind() == 'AnnotateAttr' then
            local name = child:name()
            if name == 'qt_signal' then
                signal = true
            elseif name == 'qt_slot' then
                slot = true
            end
        end
    end

    -- get return type
    local result
    if kind == 'CXXMethod' then
        result = translateType(method, method:resultType())
    end

    -- virtual / static
    local virtual, static
    if method:isVirtual() then
        virtual = true
    elseif method:isStatic() then
        static = true
    end

    return {
        name = method:name(),
        access = access,
        signature = method:displayName(),
        kind = kind,
        args = argTable,
        result = result,
        signal = signal,
        slot = slot,
        virtual = virtual,
        static = static
    }
end

function processFunction(func)
    -- process argument
    local argTable = {}
    local args = func:arguments()
    for i, arg in ipairs(args) do
        argTable[i] = processArgument(i, arg)
    end

    local result = translateType(func, func:resultType())

    return {
        name = func:name(),
        signature = func:displayName(),
        args = argTable,
        result = result,
    }
end

function parseCPPHeader(cargs)
   index = clang.createIndex(false, true)
   tu = assert(index:parse(cargs))
   
   local classes = findChildrenByType(tu:cursor(), 'ClassDecl', cargs[1])
   for _, class in ipairs(classes) do
      local name = class:name()
      local dname = class:displayName()

      local DBClass = DB[class:displayName()]
      DBClass.methods = DBClass.methods or {}

      local children = class:children()
      local access = 'private'
      for _, method in ipairs(children) do
        local kind = method:kind()
        if kind == 'CXXMethod' then
            table.insert(DBClass.methods, processMethod(method, kind, access))
        elseif kind == 'Constructor' then
            table.insert(DBClass.methods, processMethod(method, kind, access))    
        elseif kind == 'Destructor' then
            table.insert(DBClass.methods, processMethod(method, kind, access))
        elseif kind == 'CXXAccessSpecifier' then
            access = method:access()
        elseif kind == 'EnumDecl' then
            --DEBUG('', 'enum', method:displayName())
            for _,enum in ipairs(method:children()) do
                --DEBUG('', '->', enum:name())
            end
        elseif kind == 'VarDecl' or kind == 'FieldDecl' then
            --DEBUG(name, access, kind, method:name(), translateType(method))
        elseif kind == 'UnexposedDecl' then
            --DEBUG('!!!', name, getExtent(method:location()))
        elseif kind == 'CXXBaseSpecifier' then
            local parent = method:referenced()
            --DBClass.parent = parent:name()
        else
            --DEBUG('???', name, kind, getExtent(method:location()))
        end
      end
   end
    
   local functions = findChildrenByType(tu:cursor(), "FunctionDecl", cargs[1])
   for _, func in ipairs(functions) do
       local name = func:name()
       local dname = func:displayName()
       if not FUNC[dname] then
           --DEBUG(_, name, dname)
           for i,arg in ipairs(func:arguments()) do
               --DEBUG('', i, arg:name(), translateType(arg, arg:type()))
               FUNC[dname] = processFunction(func)
           end
       end
   end
end

function initializeDatabase()
   local db = sqlite3.open("code.db")
   for _,tab in ipairs{"modules", "classes", "methods", "functions", "args"} do
       db:exec("DROP TABLE IF EXISTS %s" % tab)
   end
   
   db:exec("CREATE TABLE modules (id INTEGER PRIMARY KEY, name TEXT NOT NULL)")
   db:exec("CREATE TABLE classes (id INTEGER PRIMARY KEY, module INTEGER, name TEXT NOT NULL, superclass INTEGER)")
   db:exec("CREATE TABLE methods (id INTEGER PRIMARY KEY, class INTEGER, name TEXT NOT NULL, kind, access, result, signature, static, virtual, signal, slot)")
   db:exec("CREATE TABLE functions (id INTEGER PRIMARY KEY, module INTEGER, name TEXT NOT NULL, result, signature)")
   db:exec("CREATE TABLE args (id INTEGER PRIMARY KEY, ismethod, parent INTEGER, name, idx, type, const, defval)")
   
   db:close()
end

function saveDatabase()
   local db = sqlite3.open("code.db")

   local E = function(s)
       if type(s) == 'nil' or (type(s) == "string" and #s == 0) then
           return 'NULL'
       elseif type(s) == 'string' then
           return "'"..s:gsub("'", "''").."'"
       else
           print('???', s, type(s))
           return 'NULL'
       end
   end
   local B = function(b) return b and '1' or '0' end

   db:exec("BEGIN")

   db:exec("INSERT INTO modules(name) VALUES ('"..moduleName.."')")
   local modId = db:last_insert_rowid()

   for name, class in pairs(DB) do
       db:exec("INSERT INTO classes(module, name, superclass) VALUES (%d, %s, %s)" % {modId, E(name), E(class.parent)})
       local cid = db:last_insert_rowid()

       for _, m in ipairs(class.methods) do
           db:exec(
               "INSERT INTO methods(class, name, kind, access, result, signature, static, virtual, signal, slot) VALUES (%d, %s, %s, %s, %s, %s, %s, %s, %s, %s)" % {
               cid, E(m.name), E(m.kind), E(m.access), E(m.result), E(m.signature),
               B(m.static), B(m.virtual), B(m.signal), B(m.slot)
           })
           local mid = db:last_insert_rowid()
           for i, a in ipairs(m.args) do
               local cmd = "INSERT INTO args(ismethod, parent, name, idx, type, const, defval) VALUES (1, %d, %s, %d, %s, %d, %s)" % {
                   mid, E(a.name), i, E(a.type), B(a.const), E(a.default)
               }
               db:exec(cmd)            
           end
       end
   end

   for _, f in pairs(FUNC) do
       db:exec(
           "INSERT INTO functions(module, name, result, signature) VALUES (%d, %s, %s, %s)" % {
           modId, E(f.name), E(f.result), E(f.signature)
       })
       local fid = db:last_insert_rowid()
       for i, a in ipairs(f.args) do
           local cmd = "INSERT INTO args(ismethod, parent, name, idx, type, const, defval) VALUES (0, %d, %s, %d, %s, %d, %s)" % {
               fid, E(a.name), i, E(a.type), B(a.const), E(a.default)
           }
           db:exec(cmd)
       end
   end


   db:exec("COMMIT")
   db:close()
end

--parse the command line arguments
for  i=1,#arg do
   if(arg[i]=='-db') then
      dbName=arg[i+1]
   end
   if(arg[i]=='-m') then
      moduleName = arg[i+1]
   end
   if(arg[i] == '--') then
      --remaining args are all to be passed on to libclang
      local ca = 1
      for k=i+1,#arg do
         clangArgs[ca] = arg[k]
         k = k + 1
         ca = ca + 1
      end
   end
end


parseCPPHeader(clangArgs)
if(DEBUG.enabled) then 
   local xml =  assert(io.open('code.xml', 'w'))
   dumpXml(xml, tu:cursor(), clangArgs[1]) 
   xml:close()
end

DEBUG("SQLite3 version: "..sqlite3.version())
initializeDatabase()
saveDatabase()
