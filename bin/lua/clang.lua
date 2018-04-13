local ffi = require "ffi"
local bit = require "bit"

ffi.cdef[[
   typedef void *CXIndex;
   typedef struct CXTranslationUnitImpl *CXTranslationUnit;
   
   struct CXUnsavedFile 
   {
      const char *Filename;
      const char *Contents;
      unsigned long Length;
   };
   
   enum CXTranslationUnit_Flags {
      CXTranslationUnit_None = 0x0,
      CXTranslationUnit_DetailedPreprocessingRecord = 0x01,
      CXTranslationUnit_Incomplete = 0x02,
      CXTranslationUnit_PrecompiledPreamble = 0x04,
      CXTranslationUnit_CacheCompletionResults = 0x08,
      CXTranslationUnit_ForSerialization = 0x10,
      CXTranslationUnit_CXXChainedPCH = 0x20,
      CXTranslationUnit_SkipFunctionBodies = 0x40,
      CXTranslationUnit_IncludeBriefCommentsInCodeCompletion = 0x80,
      CXTranslationUnit_CreatePreambleOnFirstParse = 0x100,
      CXTranslationUnit_KeepGoing = 0x200,
      CXTranslationUnit_SingleFileParse = 0x400
   };
   
   enum CXCursorKind {
      CXCursor_UnexposedDecl                 = 1,
      CXCursor_StructDecl                    = 2,
      CXCursor_UnionDecl                     = 3,
      CXCursor_ClassDecl                     = 4,
      CXCursor_EnumDecl                      = 5,
      CXCursor_FieldDecl                     = 6,
      CXCursor_EnumConstantDecl              = 7,
      CXCursor_FunctionDecl                  = 8,
      CXCursor_VarDecl                       = 9,
      CXCursor_ParmDecl                      = 10,
      CXCursor_ObjCInterfaceDecl             = 11,
      CXCursor_ObjCCategoryDecl              = 12,
      CXCursor_ObjCProtocolDecl              = 13,
      CXCursor_ObjCPropertyDecl              = 14,
      CXCursor_ObjCIvarDecl                  = 15,
      CXCursor_ObjCInstanceMethodDecl        = 16,
      CXCursor_ObjCClassMethodDecl           = 17,
      CXCursor_ObjCImplementationDecl        = 18,
      CXCursor_ObjCCategoryImplDecl          = 19,
      CXCursor_TypedefDecl                   = 20,
      CXCursor_CXXMethod                     = 21,
      CXCursor_Namespace                     = 22,
      CXCursor_LinkageSpec                   = 23,
      CXCursor_Constructor                   = 24,
      CXCursor_Destructor                    = 25,
      CXCursor_ConversionFunction            = 26,
      CXCursor_TemplateTypeParameter         = 27,
      CXCursor_NonTypeTemplateParameter      = 28,
      CXCursor_TemplateTemplateParameter     = 29,
      CXCursor_FunctionTemplate              = 30,
      CXCursor_ClassTemplate                 = 31,
      CXCursor_ClassTemplatePartialSpecialization = 32,
      CXCursor_NamespaceAlias                = 33,
      CXCursor_UsingDirective                = 34,
      CXCursor_UsingDeclaration              = 35,
      CXCursor_TypeAliasDecl                 = 36,
      CXCursor_ObjCSynthesizeDecl            = 37,
      CXCursor_ObjCDynamicDecl               = 38,
      CXCursor_CXXAccessSpecifier            = 39,
      CXCursor_FirstDecl                     = CXCursor_UnexposedDecl,
      CXCursor_LastDecl                      = CXCursor_CXXAccessSpecifier,
      CXCursor_FirstRef                      = 40, /* Decl references */
      CXCursor_ObjCSuperClassRef             = 40,
      CXCursor_ObjCProtocolRef               = 41,
      CXCursor_ObjCClassRef                  = 42,
      CXCursor_TypeRef                       = 43,
      CXCursor_CXXBaseSpecifier              = 44,
      CXCursor_TemplateRef                   = 45,
      CXCursor_NamespaceRef                  = 46,
      CXCursor_MemberRef                     = 47,
      CXCursor_LabelRef                      = 48,
      CXCursor_OverloadedDeclRef             = 49,
      CXCursor_VariableRef                   = 50,
      CXCursor_LastRef                       = CXCursor_VariableRef,
      CXCursor_FirstInvalid                  = 70,
      CXCursor_InvalidFile                   = 70,
      CXCursor_NoDeclFound                   = 71,
      CXCursor_NotImplemented                = 72,
      CXCursor_InvalidCode                   = 73,
      CXCursor_LastInvalid                   = CXCursor_InvalidCode,
      CXCursor_FirstExpr                     = 100,
      CXCursor_UnexposedExpr                 = 100,
      CXCursor_DeclRefExpr                   = 101,
      CXCursor_MemberRefExpr                 = 102,
      CXCursor_CallExpr                      = 103,
      CXCursor_ObjCMessageExpr               = 104,
      CXCursor_BlockExpr                     = 105,
      CXCursor_IntegerLiteral                = 106,
      CXCursor_FloatingLiteral               = 107,
      CXCursor_ImaginaryLiteral              = 108,
      CXCursor_StringLiteral                 = 109,
      CXCursor_CharacterLiteral              = 110,
      CXCursor_ParenExpr                     = 111,
      CXCursor_UnaryOperator                 = 112,
      CXCursor_ArraySubscriptExpr            = 113,
      CXCursor_BinaryOperator                = 114,
      CXCursor_CompoundAssignOperator        = 115,
      CXCursor_ConditionalOperator           = 116,
      CXCursor_CStyleCastExpr                = 117,
      CXCursor_CompoundLiteralExpr           = 118,
      CXCursor_InitListExpr                  = 119,
      CXCursor_AddrLabelExpr                 = 120,
      CXCursor_StmtExpr                      = 121,
      CXCursor_GenericSelectionExpr          = 122,
      CXCursor_GNUNullExpr                   = 123,
      CXCursor_CXXStaticCastExpr             = 124,
      CXCursor_CXXDynamicCastExpr            = 125,
      CXCursor_CXXReinterpretCastExpr        = 126,
      CXCursor_CXXConstCastExpr              = 127,
      CXCursor_CXXFunctionalCastExpr         = 128,
      CXCursor_CXXTypeidExpr                 = 129,
      CXCursor_CXXBoolLiteralExpr            = 130,
      CXCursor_CXXNullPtrLiteralExpr         = 131,
      CXCursor_CXXThisExpr                   = 132,
      CXCursor_CXXThrowExpr                  = 133,
      CXCursor_CXXNewExpr                    = 134,
      CXCursor_CXXDeleteExpr                 = 135,
      CXCursor_UnaryExpr                     = 136,
      CXCursor_ObjCStringLiteral             = 137,
      CXCursor_ObjCEncodeExpr                = 138,
      CXCursor_ObjCSelectorExpr              = 139,
      CXCursor_ObjCProtocolExpr              = 140,
      CXCursor_ObjCBridgedCastExpr           = 141,
      CXCursor_PackExpansionExpr             = 142,
      CXCursor_SizeOfPackExpr                = 143,
      CXCursor_LambdaExpr                    = 144,
      CXCursor_ObjCBoolLiteralExpr           = 145,
      CXCursor_ObjCSelfExpr                  = 146,
      CXCursor_OMPArraySectionExpr           = 147,
      CXCursor_ObjCAvailabilityCheckExpr     = 148,
      CXCursor_LastExpr                      = CXCursor_ObjCAvailabilityCheckExpr,
      CXCursor_FirstStmt                     = 200,
      CXCursor_UnexposedStmt                 = 200,
      CXCursor_LabelStmt                     = 201,
      CXCursor_CompoundStmt                  = 202,
      CXCursor_CaseStmt                      = 203,
      CXCursor_DefaultStmt                   = 204,
      CXCursor_IfStmt                        = 205,
      CXCursor_SwitchStmt                    = 206,
      CXCursor_WhileStmt                     = 207,
      CXCursor_DoStmt                        = 208,
      CXCursor_ForStmt                       = 209,
      CXCursor_GotoStmt                      = 210,
      CXCursor_IndirectGotoStmt              = 211,
      CXCursor_ContinueStmt                  = 212,
      CXCursor_BreakStmt                     = 213,
      CXCursor_ReturnStmt                    = 214,
      CXCursor_GCCAsmStmt                    = 215,
      CXCursor_AsmStmt                       = CXCursor_GCCAsmStmt,
      CXCursor_ObjCAtTryStmt                 = 216,
      CXCursor_ObjCAtCatchStmt               = 217,
      CXCursor_ObjCAtFinallyStmt             = 218,
      CXCursor_ObjCAtThrowStmt               = 219,
      CXCursor_ObjCAtSynchronizedStmt        = 220,
      CXCursor_ObjCAutoreleasePoolStmt       = 221,
      CXCursor_ObjCForCollectionStmt         = 222,
      CXCursor_CXXCatchStmt                  = 223,
      CXCursor_CXXTryStmt                    = 224,
      CXCursor_CXXForRangeStmt               = 225,
      CXCursor_SEHTryStmt                    = 226,
      CXCursor_SEHExceptStmt                 = 227,
      CXCursor_SEHFinallyStmt                = 228,
      CXCursor_MSAsmStmt                     = 229,
      CXCursor_NullStmt                      = 230,
      CXCursor_DeclStmt                      = 231,
      CXCursor_OMPParallelDirective          = 232,
      CXCursor_OMPSimdDirective              = 233,
      CXCursor_OMPForDirective               = 234,
      CXCursor_OMPSectionsDirective          = 235,
      CXCursor_OMPSectionDirective           = 236,
      CXCursor_OMPSingleDirective            = 237,
      CXCursor_OMPParallelForDirective       = 238,
      CXCursor_OMPParallelSectionsDirective  = 239,
      CXCursor_OMPTaskDirective              = 240,
      CXCursor_OMPMasterDirective            = 241,
      CXCursor_OMPCriticalDirective          = 242,
      CXCursor_OMPTaskyieldDirective         = 243,
      CXCursor_OMPBarrierDirective           = 244,
      CXCursor_OMPTaskwaitDirective          = 245,
      CXCursor_OMPFlushDirective             = 246,
      CXCursor_SEHLeaveStmt                  = 247,
      CXCursor_OMPOrderedDirective           = 248,
      CXCursor_OMPAtomicDirective            = 249,
      CXCursor_OMPForSimdDirective           = 250,
      CXCursor_OMPParallelForSimdDirective   = 251,
      CXCursor_OMPTargetDirective            = 252,
      CXCursor_OMPTeamsDirective             = 253,
      CXCursor_OMPTaskgroupDirective         = 254,
      CXCursor_OMPCancellationPointDirective = 255,
      CXCursor_OMPCancelDirective            = 256,
      CXCursor_OMPTargetDataDirective        = 257,
      CXCursor_OMPTaskLoopDirective          = 258,
      CXCursor_OMPTaskLoopSimdDirective      = 259,
      CXCursor_OMPDistributeDirective        = 260,
      CXCursor_OMPTargetEnterDataDirective   = 261,
      CXCursor_OMPTargetExitDataDirective    = 262,
      CXCursor_OMPTargetParallelDirective    = 263,
      CXCursor_OMPTargetParallelForDirective = 264,
      CXCursor_OMPTargetUpdateDirective      = 265,
      CXCursor_OMPDistributeParallelForDirective = 266,
      CXCursor_OMPDistributeParallelForSimdDirective = 267,
      CXCursor_OMPDistributeSimdDirective = 268,
      CXCursor_OMPTargetParallelForSimdDirective = 269,
      CXCursor_OMPTargetSimdDirective = 270,
      CXCursor_OMPTeamsDistributeDirective = 271,
      CXCursor_OMPTeamsDistributeSimdDirective = 272,
      CXCursor_OMPTeamsDistributeParallelForSimdDirective = 273,
      CXCursor_OMPTeamsDistributeParallelForDirective = 274,
      CXCursor_OMPTargetTeamsDirective = 275,
      CXCursor_OMPTargetTeamsDistributeDirective = 276,
      CXCursor_OMPTargetTeamsDistributeParallelForDirective = 277,
      CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective = 278,
      CXCursor_OMPTargetTeamsDistributeSimdDirective = 279,
      CXCursor_LastStmt = CXCursor_OMPTargetTeamsDistributeSimdDirective,
      CXCursor_TranslationUnit               = 300,
      CXCursor_FirstAttr                     = 400,
      CXCursor_UnexposedAttr                 = 400,
      CXCursor_IBActionAttr                  = 401,
      CXCursor_IBOutletAttr                  = 402,
      CXCursor_IBOutletCollectionAttr        = 403,
      CXCursor_CXXFinalAttr                  = 404,
      CXCursor_CXXOverrideAttr               = 405,
      CXCursor_AnnotateAttr                  = 406,
      CXCursor_AsmLabelAttr                  = 407,
      CXCursor_PackedAttr                    = 408,
      CXCursor_PureAttr                      = 409,
      CXCursor_ConstAttr                     = 410,
      CXCursor_NoDuplicateAttr               = 411,
      CXCursor_CUDAConstantAttr              = 412,
      CXCursor_CUDADeviceAttr                = 413,
      CXCursor_CUDAGlobalAttr                = 414,
      CXCursor_CUDAHostAttr                  = 415,
      CXCursor_CUDASharedAttr                = 416,
      CXCursor_VisibilityAttr                = 417,
      CXCursor_DLLExport                     = 418,
      CXCursor_DLLImport                     = 419,
      CXCursor_LastAttr                      = CXCursor_DLLImport,
      CXCursor_PreprocessingDirective        = 500,
      CXCursor_MacroDefinition               = 501,
      CXCursor_MacroExpansion                = 502,
      CXCursor_MacroInstantiation            = CXCursor_MacroExpansion,
      CXCursor_InclusionDirective            = 503,
      CXCursor_FirstPreprocessing            = CXCursor_PreprocessingDirective,
      CXCursor_LastPreprocessing             = CXCursor_InclusionDirective,
      CXCursor_ModuleImportDecl              = 600,
      CXCursor_TypeAliasTemplateDecl         = 601,
      CXCursor_StaticAssert                  = 602,
      CXCursor_FriendDecl                    = 603,
      CXCursor_FirstExtraDecl                = CXCursor_ModuleImportDecl,
      CXCursor_LastExtraDecl                 = CXCursor_FriendDecl,
      CXCursor_OverloadCandidate             = 700
   };
   
   typedef struct {
      enum CXCursorKind kind;
      int xdata;
      const void *data[3];
   } CXCursor;
   
   typedef struct {
      const void *data;
      unsigned private_flags;
   } CXString;

   CXIndex clang_createIndex(int excludeDeclarationsFromPCH, int displayDiagnostics);
   void clang_disposeIndex(CXIndex index);
  
   CXTranslationUnit clang_createTranslationUnit(CXIndex CIdx, const char *ast_filename);
   void clang_disposeTranslationUnit(CXTranslationUnit);
   
   CXTranslationUnit clang_parseTranslationUnit(CXIndex CIdx,
                           const char *source_filename,
                           const char *const *command_line_args,
                           int num_command_line_args,
                           struct CXUnsavedFile *unsaved_files,
                           unsigned num_unsaved_files,
                           unsigned options);
                           
   CXCursor clang_getTranslationUnitCursor(CXTranslationUnit);
   unsigned clang_equalCursors(CXCursor, CXCursor);
   int clang_Cursor_isNull(CXCursor cursor);
   enum CXCursorKind clang_getCursorKind(CXCursor);
   
   typedef void *CXFile;
   typedef long int time_t;
   
   CXFile clang_getFile(CXTranslationUnit tu, const char *file_name);
   CXString clang_getFileName(CXFile SFile);
   time_t clang_getFileTime(CXFile SFile);
   
   typedef void *CXDiagnostic;
   CXDiagnostic clang_getDiagnostic(CXTranslationUnit Unit, unsigned Index);
   CXString clang_getDiagnosticCategoryText(CXDiagnostic);
   CXString clang_formatDiagnostic(CXDiagnostic Diagnostic, unsigned Options);
   unsigned clang_defaultDiagnosticDisplayOptions(void);
   void clang_disposeDiagnostic(CXDiagnostic Diagnostic);
]]

local lib = ffi.load("libclang")


--metatables
local clang = {}
local clang_index={}
local clang_tu = {}
local clang_cursor = {}
local clang_type = {}

--/****** CLANG ******/
function clang.createIndex(excludePch, diagnostics)
   local idxPtr = ffi.typeof("CXIndex")
   ex = excludePch or 0
   diag = diagnostics or 0
   idxPtr = lib.clang_createIndex(ex, diag)
   return setmetatable(
   {
      idx = idxPtr
   },
   clang_index)
end

--/****** INDEX ******/
function clang_index.load(self, filename)
   local tuPtr = ffi.typeof("CXTranslationUnit")
   
   tuPtr = lib.clang_createTranslationUnit(self.idx, filename)
   if(tuPtr == nil) then
      print("Error creating translation unit from filename "..filename)
      return nil
   else   
      return setmetatable(
      {
         tu = tuPtr
      }, 
      clang_tu)
   end
end

function clang_index.parse(self, filename, options)
   local tuPtr = ffi.typeof("CXTranslationUnit")
   
   local args
   if(#options > 0) then
      args = ffi.new("const char*["..(#options + 1).."]", options)
   else
      args = 0
   end

   tuPtr = lib.clang_parseTranslationUnit(self.idx, filename, args, #options,0, 0, lib.CXTranslationUnit_SkipFunctionBodies)
   
   if(tuPtr == nil) then
      print("Error parsing translation unit from filename "..filename)
      return nil
   else   
      return setmetatable(
      {
         tu = tuPtr
      }, 
      clang_tu)
   end
end

function clang_index.__gc(self)
   lib.clang_disposeIndex(self.idx)
end


--/****** TRANSLATION UNIT ******/
function clang_tu.cursor(self)
   local cuPtr = ffi.typeof("CXCursor")
   cuPtr = lib.clang_getTranslationUnitcursor(self.tu)
   if(lib.clang_Cursor_isNull(cuPtr) then
      print("Failed to find cursor")
      return nil
   else
      return setmetatable(
      {
         cursor = cuPtr
      }, 
      clang_cursor)
   end
end

function clang_tu.file(self, filename)
   local fPtr = ffi.typeof("CXFile")
   fPtr = lib.clang_getFile(self.tu, filename)
   fname = lib.clang_getFileName(fPtr)
   ftime = lib.clang_getFileTime(fPtr)
   return fname, ftime
end

function clang_tu.diagnostics(self)
   nDiag = lib.clang_getNumDiagnostics(self.tu)
   ret = {}
   for i in 0,nDiag do
      local diagPtr = lib.clang_getDiagnostic(self.tu, i-1)
      local cat = lib.clang_getDiagnosticCategoryText(diagPtr)
      local txt = lib.clang_formatDiagnostic(diagPtr, lib.clang_defaultDiagnosticDisplayOptions())
      
      ret[i] = {
         category = cat,
         text = txt
      }
   end
   
   return ret
end

function clang_tu.codeCompleteAt(self)
   --todo once I understand why
end

function clang_tu.__gc(self)
   lib.clang_disposeTranslationUnit(self.tu)
end

--/****** CURSOR ******/
function clang_cursor.children(self)

end

function clang_cursor.kind(self)

end

function clang_cursor.name(self)

end

function clang_cursor.__tostring(self)

end

function clang_cursor.displayName(self)

end

function clang_cursor.parent(self)

end

function clang_cursor.arguments(self)

end

function clang_cursor.type(self)

end

function clang_cursor.access(self)

end

function clang_cursor.location(self)

end

function clang_cursor.usr(self)

end

function clang_cursor.referenced(self)

end

function clang_cursor.isStatic(self)

end

function clang_cursor.isVirtual(self)

end

function clang_cursor.resultType(self)

end

function clang_cursor.__eq(self)

end

--/******** TYPE ********/
function clang_type.__tostring(self)

end

function clang_type.name(self)

end

function clang_type.canonical(self)

end

function clang_type.pointee(self)

end

function clang_type.isPod(self)

end

function clang_type.isConst(self)

end

function clang_type.declaration(self)

end

function clang_type.__eq(self)

end




return clang