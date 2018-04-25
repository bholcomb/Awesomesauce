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
   
   const char *clang_getCString(CXString string);
   void clang_disposeString(CXString string);

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
   
   enum CXChildVisitResult {
      CXChildVisit_Break,
      CXChildVisit_Continue,
      CXChildVisit_Recurse
   };
   typedef void *CXClientData;
   typedef enum CXChildVisitResult (*CXCursorVisitor)(CXCursor cursor, CXCursor parent, CXClientData client_data);
   typedef enum CXChildVisitResult (*CXCursorVisitor2)(void* cursor, void* parent, CXClientData client_data);
   unsigned clang_visitChildren(CXCursor parent, CXCursorVisitor visitor, CXClientData client_data);
   CXString clang_getCursorSpelling(CXCursor);
   CXString clang_getCursorDisplayName(CXCursor);
   CXCursor clang_getCursorSemanticParent(CXCursor cursor);
   int clang_Cursor_getNumArguments(CXCursor C);
   CXCursor clang_Cursor_getArgument(CXCursor C, unsigned i);
   
   enum CXTypeKind {
      CXType_Invalid = 0,
      CXType_Unexposed = 1,
      CXType_Void = 2,
      CXType_Bool = 3,
      CXType_Char_U = 4,
      CXType_UChar = 5,
      CXType_Char16 = 6,
      CXType_Char32 = 7,
      CXType_UShort = 8,
      CXType_UInt = 9,
      CXType_ULong = 10,
      CXType_ULongLong = 11,
      CXType_UInt128 = 12,
      CXType_Char_S = 13,
      CXType_SChar = 14,
      CXType_WChar = 15,
      CXType_Short = 16,
      CXType_Int = 17,
      CXType_Long = 18,
      CXType_LongLong = 19,
      CXType_Int128 = 20,
      CXType_Float = 21,
      CXType_Double = 22,
      CXType_LongDouble = 23,
      CXType_NullPtr = 24,
      CXType_Overload = 25,
      CXType_Dependent = 26,
      CXType_ObjCId = 27,
      CXType_ObjCClass = 28,
      CXType_ObjCSel = 29,
      CXType_Float128 = 30,
      CXType_Half = 31,
      CXType_Float16 = 32,
      CXType_FirstBuiltin = CXType_Void,
      CXType_LastBuiltin  = CXType_Float16,
      CXType_Complex = 100,
      CXType_Pointer = 101,
      CXType_BlockPointer = 102,
      CXType_LValueReference = 103,
      CXType_RValueReference = 104,
      CXType_Record = 105,
      CXType_Enum = 106,
      CXType_Typedef = 107,
      CXType_ObjCInterface = 108,
      CXType_ObjCObjectPointer = 109,
      CXType_FunctionNoProto = 110,
      CXType_FunctionProto = 111,
      CXType_ConstantArray = 112,
      CXType_Vector = 113,
      CXType_IncompleteArray = 114,
      CXType_VariableArray = 115,
      CXType_DependentSizedArray = 116,
      CXType_MemberPointer = 117,
      CXType_Auto = 118,
      CXType_Elaborated = 119,
      CXType_Pipe = 120,
      CXType_OCLImage1dRO = 121,
      CXType_OCLImage1dArrayRO = 122,
      CXType_OCLImage1dBufferRO = 123,
      CXType_OCLImage2dRO = 124,
      CXType_OCLImage2dArrayRO = 125,
      CXType_OCLImage2dDepthRO = 126,
      CXType_OCLImage2dArrayDepthRO = 127,
      CXType_OCLImage2dMSAARO = 128,
      CXType_OCLImage2dArrayMSAARO = 129,
      CXType_OCLImage2dMSAADepthRO = 130,
      CXType_OCLImage2dArrayMSAADepthRO = 131,
      CXType_OCLImage3dRO = 132,
      CXType_OCLImage1dWO = 133,
      CXType_OCLImage1dArrayWO = 134,
      CXType_OCLImage1dBufferWO = 135,
      CXType_OCLImage2dWO = 136,
      CXType_OCLImage2dArrayWO = 137,
      CXType_OCLImage2dDepthWO = 138,
      CXType_OCLImage2dArrayDepthWO = 139,
      CXType_OCLImage2dMSAAWO = 140,
      CXType_OCLImage2dArrayMSAAWO = 141,
      CXType_OCLImage2dMSAADepthWO = 142,
      CXType_OCLImage2dArrayMSAADepthWO = 143,
      CXType_OCLImage3dWO = 144,
      CXType_OCLImage1dRW = 145,
      CXType_OCLImage1dArrayRW = 146,
      CXType_OCLImage1dBufferRW = 147,
      CXType_OCLImage2dRW = 148,
      CXType_OCLImage2dArrayRW = 149,
      CXType_OCLImage2dDepthRW = 150,
      CXType_OCLImage2dArrayDepthRW = 151,
      CXType_OCLImage2dMSAARW = 152,
      CXType_OCLImage2dArrayMSAARW = 153,
      CXType_OCLImage2dMSAADepthRW = 154,
      CXType_OCLImage2dArrayMSAADepthRW = 155,
      CXType_OCLImage3dRW = 156,
      CXType_OCLSampler = 157,
      CXType_OCLEvent = 158,
      CXType_OCLQueue = 159,
      CXType_OCLReserveID = 160
   };
   
   typedef struct {
     enum CXTypeKind kind;
     void *data[2];
   } CXType;
   CXType clang_getCursorType(CXCursor C);
   
   enum CX_CXXAccessSpecifier {
      CX_CXXInvalidAccessSpecifier,
      CX_CXXPublic,
      CX_CXXProtected,
      CX_CXXPrivate
   };
   
   enum CX_CXXAccessSpecifier clang_getCXXAccessSpecifier(CXCursor);
   
   typedef struct {
      const void *ptr_data[2];
      unsigned begin_int_data;
      unsigned end_int_data;
   } CXSourceRange;
   
   typedef struct {
      const void *ptr_data[2];
      unsigned int_data;
   } CXSourceLocation;
   
   CXSourceRange clang_getCursorExtent(CXCursor);
   CXSourceLocation clang_getRangeStart(CXSourceRange range);
   void clang_getSpellingLocation(CXSourceLocation location, CXFile *file, unsigned *line, unsigned *column, unsigned *offset);
   CXSourceLocation clang_getRangeEnd(CXSourceRange range);
   
   CXString clang_getCursorUSR(CXCursor);
   CXCursor clang_getCursorReferenced(CXCursor);
   CXCursor clang_getCursorDefinition(CXCursor);

   unsigned clang_CXXConstructor_isConvertingConstructor(CXCursor C);
   unsigned clang_CXXConstructor_isCopyConstructor(CXCursor C);
   unsigned clang_CXXConstructor_isDefaultConstructor(CXCursor C);
   unsigned clang_CXXConstructor_isMoveConstructor(CXCursor C);
   unsigned clang_CXXField_isMutable(CXCursor C);
   unsigned clang_CXXMethod_isDefaulted(CXCursor C);
   unsigned clang_CXXMethod_isPureVirtual(CXCursor C);
   unsigned clang_CXXMethod_isStatic(CXCursor C);
   unsigned clang_CXXMethod_isVirtual(CXCursor C);
   unsigned clang_CXXRecord_isAbstract(CXCursor C);
   unsigned clang_EnumDecl_isScoped(CXCursor C);
   unsigned clang_CXXMethod_isConst(CXCursor C);
   
   CXType clang_getCursorResultType(CXCursor C);
   
   CXString clang_getTypeKindSpelling(enum CXTypeKind K);
   CXType clang_getPointeeType(CXType T);
   CXType clang_getCanonicalType(CXType T);
   unsigned clang_isPODType(CXType T);
   unsigned clang_isConstQualifiedType(CXType T);
   unsigned clang_equalTypes(CXType A, CXType B);
   CXCursor clang_getTypeDeclaration(CXType T);
   CXType clang_getResultType(CXType T);
   int clang_getNumArgTypes(CXType T);
   CXType clang_getArgType(CXType T, unsigned i);
   
]]

local lib = ffi.load("libclang")


--metatables
local clang = {}
local clang_index={}
local clang_tu = {}
local clang_cursor = {}
local clang_type = {}

clang_index.__index = clang_index
clang_tu.__index = clang_tu
clang_cursor.__index = clang_cursor
clang_type.__index = clang_type

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
   local opts = options or {}
   if(#opts > 0) then
      args = ffi.new("const char*["..(#opts + 1).."]", opts)
   else
      args = nil
   end

   tuPtr = lib.clang_parseTranslationUnit(self.idx, filename, args, #opts, nil, 0, lib.CXTranslationUnit_SkipFunctionBodies)
   
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
   cuPtr = lib.clang_getTranslationUnitCursor(self.tu)
   if(lib.clang_Cursor_isNull(cuPtr) == true) then
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
function createCursor(cptr)
   return setmetatable(
      {
         cursor = cptr
      }, 
      clang_cursor)
end

function createCursorVisitor(storage)
   local ret = storage

   return function(cursorPtr, parentPtr, usr)
      local cptr =  ffi.cast("CXCursor *", ffi.new("char[?]", ffi.sizeof("CXCursor"))) --allocate some memory for the cursor
      ffi.copy(cptr, cursorPtr, ffi.sizeof("CXCursor")) --copy the memory from the first parameter to the chunk we just allocated
      local cursor = createCursor(cptr[0]) --create a cursor from the object pointed to by our pointer
      table.insert(ret, cursor)
   
      return lib.CXChildVisit_Continue
   end
end

function clang_cursor.children(self)
   local cptr = self.cursor
   local ret = {}
   local cursorVisitor = createCursorVisitor(ret)
   
   local cb = ffi.cast("CXCursorVisitor2", cursorVisitor) --this uses our bejanked function definition that uses void* instead of the structs.  We copy the memory to a struct in the callback
   lib.clang_visitChildren(cptr, cb, nil)
   cb:free()
   
   return ret
end

function clang_cursor.kind(self)
   local cptr = self.cursor
   return lib.clang_getCursorKind(cptr)
end

function clang_cursor.name(self)
   local cptr = self.cursor
   local name = lib.clang_getCursorSpelling(cptr)
   local ret = ffi.string(lib.clang_getCString(name))
   lib.clang_disposeString(name)
   return ret
end

function clang_cursor.__tostring(self)
   return self:name()
end

function clang_cursor.displayName(self)
   local cptr = self.cursor
   local name = lib.clang_getCursorDisplayName(cptr)
   local ret = ffi.string(lib.clang_getCString(name))
   lib.clang_disposeString(name)
   return ret
end

function clang_cursor.parent(self)
   local cptr = self.curosr
   local pptr = lib.clang_getCursorSemanticParent(cptr)
   if(lib.clang_Cursor_isNull(pptr) == true) then
      return nil
   else
      return createCursor(pptr)
   end
end

function clang_cursor.arguments(self)
   local cptr = self.cursor
   local nArgs = lib.clang_Cursor_getNumArguments(cptr);
   ret = {}
   for i in 0,nArgs do
      local ptr = lib.clang_Cursor_getArgument(cptr, i)
      table.insert(ret, createCursor(ptr))
   end
   
   return ret
end

function clang_cursor.type(self)
   local cptr = self.cursor
   local tptr = lib.clang_getCursorType(cptr)
   local ret = createType(tptr)
   if(ret:kind() == lib.CXType_Invalid) then
      return nil
   else
      return ret
   end
end

function clang_cursor.access(self)
    local cptr = self.cursor
    local spec = lib.clang_getCXXAccessSpecifier(cptr);
    return spec
end

function clang_cursor.location(self)
   local cptr = self.cursor
   local range = lib.clang_getCursorExtent(cptr)
   
   local file = ffi.new("CXFile[1]")
   local line = ffi.new("int[1]")
   local column = ffi.new("int[1]")
   
   local ret = {}
   
   local loc = lib.clang_getRangeStart(range)
   lib.clang_getSpellingLocation(loc, file, line, column, nil)
   local fn = lib.clang_getFileName(file[0])
   local filename = ffi.string(lib.clang_getCString(fn))
   lib.clang_disposeString(fn)
   ret["filename"] = filename
   ret["beginLine"] = line[0]
   ret["beginCol"] = column[0]
   
   loc = lib.clang_getRangeEnd(range)
   lib.clang_getSpellingLocation(loc, file, line, column, nil)
   ret["endLine"] = line[0]
   ret["endCol"] = column[0]
  
   return ret
end

function clang_cursor.usr(self)
   local cptr = self.cursor
   local str = lib.clang_getCursorUSR(cptr)
   local ret = ffi.string(lib.clang_getCString(str))
   lib.clang_disposeString(str)
   
   return ret
end

function clang_cursor.referenced(self)
   local cptr = self.cursor
   local res = lib.clang_getCursorReferenced(cptr)
   if(lib.clang_Cursor_isNull(res) == true) then
      return nil
   else
      return createCursor(res)
   end
end

function clang_cursor.isConvertingConstructor(self)
   local cptr = self.cursor
   return lib.clang_CXXConstructor_isConvertingConstructor(cptr) ~= 0
end

function clang_cursor.isCopyConstructor(self)
   local cptr = self.cursor
   return lib.clang_CXXConstructor_isCopyConstructor(cptr) ~= 0
end

function clang_cursor.isDefaultConstructor(self)
   local cptr = self.cursor
   return lib.clang_CXXConstructor_isDefaultConstructor(cptr) ~= 0
end

function clang_cursor.isMoveConstructor(self)
   local cptr = self.cursor
   return lib.clang_CXXConstructor_isMoveConstructor(cptr) ~= 0
end

function clang_cursor.isMutable(self)
   local cptr = self.cursor
   return lib.clang_CXXField_isMutable(cptr) ~= 0
end

function clang_cursor.isDefaulted(self)
   local cptr = self.cursor
   return lib.clang_CXXMethod_isDefaulted(cptr) ~= 0
end

function clang_cursor.isPureVirtual(self)
   local cptr = self.cursor
   return lib.clang_CXXMethod_isPureVirtual(cptr) ~= 0
end

function clang_cursor.isStatic(self)
   local cptr = self.cursor
   return lib.clang_CXXMethod_isStatic(cptr) ~= 0
end

function clang_cursor.isVirtual(self)
   local cptr = self.cursor
   return lib.clang_CXXMethod_isVirtual(cptr) ~= 0
end

function clang_cursor.isAbstract(self)
   local cptr = self.cursor
   return lib.clang_CXXRecord_isAbstract(cptr) ~= 0
end

function clang_cursor.isScoped(self)
   local cptr = self.cursor
   local ret = lib.clang_EnumDecl_isScoped(cptr)
   return ret ~= 0
end

function clang_cursor.isConst(self)
   local cptr = self.cursor
   local ret = lib.clang_CXXMethod_isConst(cptr)
   return ret ~= 0
end

function clang_cursor.resultType(self)
   local cptr = self.cursor
   local tptr = lib.clang_getCursorResultType(cptr)
   local ret = createType(tptr)
   if(ret:kind() == lib.CXType_Invalid) then
      return nil
   else
      return ret
   end
end

function clang_cursor.__eq(self, other)
   local cptr1 = self.cursor
   local cptr2 = other.cursor
   
   return lib.clang_equalCursors(cptr1, cptr2) ~= 0
end


--/******** TYPE ********/
function createType(tptr)
   return setmetatable(
      {
         Type = tptr
      }, 
      clang_type)
end

function clang_type.__tostring(self)
   return self:name()
end

function clang_type.name(self)
   local t = self.Type
   local kind = t.kind
   local str = lib.clang_getTypeKindSpelling(kind)
   local ret = ffi.string(lib.clang_getCString(str))
   lib.clang_disposeString(str)
   
   return ret
end

function clang_type.canonical(self)
   local t = self.Type
   local ret
   if(t.kind == lib.CXType_Pointer) then
      ret = lib.clang_getPointeeType(t)
   else
      ret = lib.clang_getCanonicalType(t)
   end
   
   if(ret.kind == lib.CXType_Invalid) then
      return nil
   else
      return createType(ret)
   end
end

function clang_type.pointee(self)
   local t = self.Type
   local ret = lib.clang_getPointeeType(t)
   
   if(ret.kind == lib.CXType_Invalid) then
      return nil
   else
      return createType(ret)
   end
end

function clang_type.isPod(self)
   local t = self.Type
   return lib.clang_isPODType(t) ~= 0
end

function clang_type.isConst(self)
   local t = self.Type
   return lib.clang_isConstQualifiedtype(t) ~= 0
end

function clang_type.declaration(self)
   local t = self.Type
   local cptr = lib.clang_getTypeDeclaration(t)
   if(lib.clang_Cursor_isNull(cptr) == true) then
      return nil
   else
      return createCursor(cptr)
   end
end

function clang_type.__eq(self, other)
   local t1 = self.Type
   local t2 = other.Type
   
   return lib.clang_equalTypes(t1, t2) ~= 0
end



clang.lib = lib

return clang