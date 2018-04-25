clang = require 'clang'

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
      print(space..k..":"..tostring(v))
      if(type(v)=="table") then
         if(v.n==0) then 
            print(space.."   ".."Empty table")
         else
            dump(v, i+1)
         end
      end
   end
  
end

print("dumping clang")
dump(clang)
print("-----")

print("dumping index")
index = clang.createIndex(false, true)
dump(index)
print("-----")

print("dumping translation unit")
tu = index:parse("testCode.h", {"-std=c++11"})
dump(tu)
print("-----")

function printCursor(cur, i)
   i = i or 0
   local space = string.rep(" ", i)
   print(space.."kind: "..tostring(cur:kind()))
   print(space.."name: "..tostring(cur:name()))
   print(space.."displayName: "..tostring(cur:displayName()))
   print(space.."location: ")
   dump(cur:location())
   local children = cur:children()
   for _, c in ipairs(children) do
      printCursor(c, i + 1)
   end
end

print("printing cursor")
printCursor(tu:cursor())
print("-----")