local ffi = require "ffi"
local bit = require "bit"

ffi.cdef[[
   typedef void *CXIndex;
   typedef struct CXTranslationUnitImpl *CXTranslationUnit;
   
   CXIndex clang_createIndex(int excludeDeclarationsFromPCH, int displayDiagnostics);
   void clang_disposeIndex(CXIndex index);
   
   
]]

local lclang = ffi.load("libclang")

local clang = {}
local clang_index={}
local clang_tu = {}

function clang.createIndex()
   local idxPtr = ffi.typeof("CXIndex")
   idxPtr = lclang.clang_createIndex(0, 0)
   return setmetatable({
      idx = idxPtr
   }, clang_index)
end

function clang_index.loadTU()
   
end

function clang_index.parseTU()

end

function clang_tu.cursor()

end

function clang_tu.file()

end

function clang_tu.diagnostics()

end

function clang_tu.

function clang_tu.__gc = function

return clang