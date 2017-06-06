
do
local debugMT = {}
debugMT.__call = function(self, ...)
   if(self.enabled == false) then return end
   
   if(type(...) == "table") then 
      dump(...) 
   else
      print(tostring(...))
   end
end

DEBUG = {}
DEBUG.enabled = false

setmetatable(DEBUG, debugMT)
end

function dump(t, i)
   if(type(t)~="table") then 
      print(tostring(t)) 
      return
   end
   
   if(i==nil) then i=0 end
   if(i>5) then return end
   
   local space=""
   
   for j=0,i do
      space=space.."   "
   end
   
   for k,v in pairs(t) do
      print(space..tostring(k)..":"..tostring(v))
      if(type(v)=="table") then
         if(v.n==0) then 
            print(space.."   ".."Empty table")
         else
            dump(v, i+1)
         end
      end
   end
end

-- from http://stevedonovan.github.com/Penlight/api/modules/pl.text.html#format_operator
do
    local format = string.format

    -- a more forgiving version of string.format, which applies
    -- tostring() to any value with a %s format.
    local function formatx (fmt,...)
        local args = {...}
        local i = 1
        for p in fmt:gmatch('%%.') do
            if p == '%s' and type(args[i]) ~= 'string' then
                args[i] = tostring(args[i])
            end
            i = i + 1
        end
        return format(fmt,unpack(args))
    end

    -- Note this goes further than the original, and will allow these cases:
    -- 1. a single value
    -- 2. a list of values
    getmetatable("").__mod = function(a, b)
        if b == nil then
            return a
        elseif type(b) == "table" then
            return formatx(a,unpack(b))
        else
            return formatx(a,b)
        end
    end
end