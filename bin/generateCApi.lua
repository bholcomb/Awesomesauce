local sqlite3 = require 'lua.sqlite3'

dofile("util.lua")

DEBUG.enabled = true

templates = {
   header=[[
/*********************************************************************************
** Copyright (c) 2017 MAK Technologies, Inc.
** All rights reserved.
*********************************************************************************/

/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!This is an auto-generated file.  Any changes will be destroyed!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

#pragma once

INCLUDES

#define EXPORT __declspec ( dllexport )

extern "C"
{
	//CONSTANTS
	
	STRUCTS
   
   CONSTRUCTOR_DEFS
   
   DESTRUCTOR_DEFS
	
	FUNCTION_DEFS
}
   ]],
   
   source=[[
/*********************************************************************************
** Copyright (c) 2016 MAK Technologies, Inc.
** All rights reserved.
*********************************************************************************/

/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!This is an auto-generated file.  Any changes will be destroyed!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

#pragma once

INCLUDES

#define EXPORT __declspec ( dllexport )

extern "C"
{
	FUNCTION_IMPL
}   
   ]],
   
   struct = [[
typedef STRUCTNAME {
	ATTRIBUTES
} 
   ]], 
   
   constructor_def = [[   
EXPORT C_TYPE_NAME* CLASSNAME_new(PARAMS);
   ]],
   
   destructor_def = [[
EXPORT void CLASSNAME_delete(C_TYPE_NAME* obj);
   ]],
   
   function_def = [[
EXPORT RETURN_TYPE FUNCTION_NAME(C_TYPE_NAME* obj, PARAMS);
   ]],
   
   function_impl = [[
RETURN_TYPE FUNCTION_NAME(C_TYPE_NAME* obj, PARAMS)
{
   ((CLASSNAME)obj)->MEMBER_FUNCTION(PARAM_VALUES);
}
   ]],
   
   attribute="	ATTRIBUTE_TYPE ATTRIBUTE_NAME;",
   parameter = "PARAMETER_TYPE PARAMETER_NAME"
}

local dbName="code.db"
local className=""
local outputFilename=""
local db = nil
   
function writeFile(filename, text)
   print("Writing file: "..filename)
   local f = assert(io.open(filename, "w"))   
   f:write(text)
   f:close()
end

function getClassDefines(className)
   local class = {}
   class.name = className
   class.cname = className.."_C"
   class.constructors = {}
   class.destructor ={}
   class.methods = {}
   local classId = 0
   local stmt = nil
   local argStmt = nil
  
   --get the class id
   stmt = db:prepare('SELECT id FROM classes WHERE (name="'..className..'")')
   stmt:step()
   local ret = stmt:get_named_values()
   classId = ret.id
   stmt:finalize()
   --DEBUG("classID: "..tostring(classId))
  
   --setup the arg statement
   argStmt = db:prepare('SELECT * from args WHERE (parent=:id AND ismethod=1) ORDER BY idx')
      
   --Get the constructors
   stmt = db:prepare('SELECT * FROM methods WHERE (class=? AND access="public" AND kind="Constructor")')
   stmt:bind_values(classId)
   for row in stmt:nrows() do
      row.args={}
      argStmt:reset()
      argStmt:bind_values(row.id)
      for farg in argStmt:nrows() do
         --DEBUG(farg)
         table.insert(row.args, farg)
      end
      if(#row.args == 0) then
         table.insert(class.constructors, row)
      end
   end
   stmt:finalize()
   --DEBUG(class.constructors)
   
   --Get the destructor
   stmt = db:prepare('SELECT * FROM methods WHERE (class=? AND access="public" AND kind="Destructor")')
   stmt:bind_values(classId)
   for row in stmt:nrows() do
      table.insert(class.destructor, row)
   end
   stmt:finalize()
   --DEBUG(class.destructor)
   
   --get the methods
   stmt = db:prepare('SELECT * FROM methods WHERE (class=? AND access="public" AND static=0 AND kind="CXXMethod")')
   stmt:bind_values(classId)
   for row in stmt:nrows() do
      table.insert(class.methods, row)
      argStmt:reset()
      argStmt:bind_values(row.id)
      row.args={}
      for farg in argStmt:nrows() do
         table.insert(row.args, farg)
      end
   end
   stmt:finalize()
   --DEBUG(class.methods)
   --DEBUG(class.methods)
   
   --sql cleanup
   argStmt:finalize()
   
   return class
end

function writeHeader(def)
   --generate the header
   local temp = templates.header
   
   temp = string.gsub(temp, "INCLUDES", "#include <matrix/vlVector>")
   
   temp = string.gsub(temp, "STRUCTS", "struct "..def.cname..";")
   
   --get the constructors
   local ctors = ""
   for k,v in pairs(def.constructors) do
      local ctor = templates.constructor_def
      ctor = string.gsub(ctor, "CLASSNAME", def.name)
      ctor = string.gsub(ctor, "C_TYPE_NAME", def.cname)
      
      --get the parameters
      local params = ""
      for i=1,#v.args do
         local param = templates.parameter
         param = string.gsub(param, "PARAMETER_TYPE", v.args[i].type)
         param = string.gsub(param, "PARAMETER_NAME", v.args[i].name)
         if(i ~= #v.args) then
            param = param..", "
         end
         params = params .. param
      end
      ctor = string.gsub(ctor, "PARAMS", params)
      
      --update the list
      ctors = ctors .. ctor.."\n"
   end
   temp = string.gsub(temp, "CONSTRUCTOR_DEFS", ctors)
   
   --get the destructors
   local dtors = ""
   for k,v in pairs(def.destructor) do
      local dtor = templates.destructor_def
      dtor = string.gsub(dtor, "CLASSNAME", def.name)
      dtor = string.gsub(dtor, "C_TYPE_NAME", def.cname)
      
      dtors = dtors .. dtor
   end
   temp = string.gsub(temp, "DESTRUCTOR_DEFS", dtors)
   
   --get the methods
   local funcs = ""
   for k,v in pairs(def.methods) do
      dump(v)
      local func = templates.function_def
      func = string.gsub(func, "RETURN_TYPE", v.result)
      func = string.gsub(func, "FUNCTION_NAME", def.name.."_"..v.name)
      func = string.gsub(func, "C_TYPE_NAME", def.cname)
      
       --get the parameters
      local params = ""
      for i=1,#v.args do
         local param = templates.parameter
         param = string.gsub(param, "PARAMETER_TYPE", v.args[i].type)
         param = string.gsub(param, "PARAMETER_NAME", v.args[i].name)
         if(i ~= #v.args) then
            param = param..", "
         end
         params = params .. param
      end
      func = string.gsub(func, "PARAMS", params)
      
      funcs = funcs..func
   end
   temp = string.gsub(temp, "FUNCTION_DEFS", funcs)
   
   --write the header
   local filename = outputFilename..".hpp"
   writeFile(filename, temp)
end

function writeSource(def)
   --write the source
   local temp = templates.source
   
   --write the header
   filename = outputFilename..".cpp"
   writeFile(filename, temp)
end

function generateClassApi(className)
   local class = getClassDefines(className)
   
   writeHeader(class)
   writeSource(class)
end

for  i=1,#arg do
   if(arg[i]=='-db') then
      dbName=arg[i+1]
   end
   if(arg[i]=='-c') then
      className = arg[i+1]
   end
   
   if(arg[i] == '-o') then
      outputFilename = arg[i+1]
   end
end

if(outputFilename == "") then
   outputFilename = className.."-C"
end

print("Using code database: "..dbName)
print("Generating class: ".. className)

db = sqlite3.open(dbName)
generateClassApi(className)
db:close()
