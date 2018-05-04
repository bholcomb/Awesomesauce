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
   typedef enum CXChildVisitResult (*CXCursorVisitor2)(CXCursor* cursor, CXCursor* parent, CXClientData client_data);
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

--setup enums
clang.cursor = {}
clang.cursor.UnexposedDecl = lib.CXCursor_UnexposedDecl
clang.cursor.StructDecl = lib.CXCursor_StructDecl
clang.cursor.UnionDecl = lib.CXCursor_UnionDecl
clang.cursor.ClassDecl = lib.CXCursor_ClassDecl
clang.cursor.EnumDecl = lib.CXCursor_EnumDecl
clang.cursor.FieldDecl = lib.CXCursor_FieldDecl
clang.cursor.EnumConstantDecl = lib.CXCursor_EnumConstantDecl
clang.cursor.FunctionDecl = lib.CXCursor_FunctionDecl
clang.cursor.VarDecl = lib.CXCursor_VarDecl
clang.cursor.ParmDecl = lib.CXCursor_ParmDecl
clang.cursor.ObjCInterfaceDecl = lib.CXCursor_ObjCInterfaceDecl
clang.cursor.ObjCCategoryDecl = lib.CXCursor_ObjCCategoryDecl
clang.cursor.ObjCProtocolDecl = lib.CXCursor_ObjCProtocolDecl
clang.cursor.ObjCPropertyDecl = lib.CXCursor_ObjCPropertyDecl
clang.cursor.ObjCIvarDecl = lib.CXCursor_ObjCIvarDecl
clang.cursor.ObjCInstanceMethodDecl = lib.CXCursor_ObjCInstanceMethodDecl
clang.cursor.ObjCClassMethodDecl = lib.CXCursor_ObjCClassMethodDecl
clang.cursor.ObjCImplementationDecl = lib.CXCursor_ObjCImplementationDecl
clang.cursor.ObjCCategoryImplDecl = lib.CXCursor_ObjCCategoryImplDecl
clang.cursor.TypedefDecl = lib.CXCursor_TypedefDecl
clang.cursor.CXXMethod = lib.CXCursor_CXXMethod
clang.cursor.Namespace = lib.CXCursor_Namespace
clang.cursor.LinkageSpec = lib.CXCursor_LinkageSpec
clang.cursor.Constructor = lib.CXCursor_Constructor
clang.cursor.Destructor = lib.CXCursor_Destructor
clang.cursor.ConversionFunction = lib.CXCursor_ConversionFunction
clang.cursor.TemplateTypeParameter = lib.CXCursor_TemplateTypeParameter
clang.cursor.NonTypeTemplateParameter = lib.CXCursor_NonTypeTemplateParameter
clang.cursor.TemplateTemplateParameter = lib.CXCursor_TemplateTemplateParameter
clang.cursor.FunctionTemplate = lib.CXCursor_FunctionTemplate
clang.cursor.ClassTemplate = lib.CXCursor_ClassTemplate
clang.cursor.ClassTemplatePartialSpecialization = lib.CXCursor_ClassTemplatePartialSpecialization
clang.cursor.NamespaceAlias = lib.CXCursor_NamespaceAlias
clang.cursor.UsingDirective = lib.CXCursor_UsingDirective
clang.cursor.UsingDeclaration = lib.CXCursor_UsingDeclaration
clang.cursor.TypeAliasDecl = lib.CXCursor_TypeAliasDecl
clang.cursor.ObjCSynthesizeDecl = lib.CXCursor_ObjCSynthesizeDecl
clang.cursor.ObjCDynamicDecl = lib.CXCursor_ObjCDynamicDecl
clang.cursor.CXXAccessSpecifier = lib.CXCursor_CXXAccessSpecifier
clang.cursor.FirstDecl = lib.CXCursor_FirstDecl
clang.cursor.LastDecl = lib.CXCursor_LastDecl
clang.cursor.FirstRef = lib.CXCursor_FirstRef
clang.cursor.ObjCSuperClassRef = lib.CXCursor_ObjCSuperClassRef
clang.cursor.ObjCProtocolRef = lib.CXCursor_ObjCProtocolRef
clang.cursor.ObjCClassRef = lib.CXCursor_ObjCClassRef
clang.cursor.TypeRef = lib.CXCursor_TypeRef
clang.cursor.CXXBaseSpecifier = lib.CXCursor_CXXBaseSpecifier
clang.cursor.TemplateRef = lib.CXCursor_TemplateRef
clang.cursor.NamespaceRef = lib.CXCursor_NamespaceRef
clang.cursor.MemberRef = lib.CXCursor_MemberRef
clang.cursor.LabelRef = lib.CXCursor_LabelRef
clang.cursor.OverloadedDeclRef = lib.CXCursor_OverloadedDeclRef
clang.cursor.VariableRef = lib.CXCursor_VariableRef
clang.cursor.LastRef = lib.CXCursor_LastRef
clang.cursor.FirstInvalid = lib.CXCursor_FirstInvalid
clang.cursor.InvalidFile = lib.CXCursor_InvalidFile
clang.cursor.NoDeclFound = lib.CXCursor_NoDeclFound
clang.cursor.NotImplemented = lib.CXCursor_NotImplemented
clang.cursor.InvalidCode = lib.CXCursor_InvalidCode
clang.cursor.LastInvalid = lib.CXCursor_LastInvalid
clang.cursor.FirstExpr = lib.CXCursor_FirstExpr
clang.cursor.UnexposedExpr = lib.CXCursor_UnexposedExpr
clang.cursor.DeclRefExpr = lib.CXCursor_DeclRefExpr
clang.cursor.MemberRefExpr = lib.CXCursor_MemberRefExpr
clang.cursor.CallExpr = lib.CXCursor_CallExpr
clang.cursor.ObjCMessageExpr = lib.CXCursor_ObjCMessageExpr
clang.cursor.BlockExpr = lib.CXCursor_BlockExpr
clang.cursor.IntegerLiteral = lib.CXCursor_IntegerLiteral
clang.cursor.FloatingLiteral = lib.CXCursor_FloatingLiteral
clang.cursor.ImaginaryLiteral = lib.CXCursor_ImaginaryLiteral
clang.cursor.StringLiteral = lib.CXCursor_StringLiteral
clang.cursor.CharacterLiteral = lib.CXCursor_CharacterLiteral
clang.cursor.ParenExpr = lib.CXCursor_ParenExpr
clang.cursor.UnaryOperator = lib.CXCursor_UnaryOperator
clang.cursor.ArraySubscriptExpr = lib.CXCursor_ArraySubscriptExpr
clang.cursor.BinaryOperator = lib.CXCursor_BinaryOperator
clang.cursor.CompoundAssignOperator = lib.CXCursor_CompoundAssignOperator
clang.cursor.ConditionalOperator = lib.CXCursor_ConditionalOperator
clang.cursor.CStyleCastExpr = lib.CXCursor_CStyleCastExpr
clang.cursor.CompoundLiteralExpr = lib.CXCursor_CompoundLiteralExpr
clang.cursor.InitListExpr = lib.CXCursor_InitListExpr
clang.cursor.AddrLabelExpr = lib.CXCursor_AddrLabelExpr
clang.cursor.StmtExpr = lib.CXCursor_StmtExpr
clang.cursor.GenericSelectionExpr = lib.CXCursor_GenericSelectionExpr
clang.cursor.GNUNullExpr = lib.CXCursor_GNUNullExpr
clang.cursor.CXXStaticCastExpr = lib.CXCursor_CXXStaticCastExpr
clang.cursor.CXXDynamicCastExpr = lib.CXCursor_CXXDynamicCastExpr
clang.cursor.CXXReinterpretCastExpr = lib.CXCursor_CXXReinterpretCastExpr
clang.cursor.CXXConstCastExpr = lib.CXCursor_CXXConstCastExpr
clang.cursor.CXXFunctionalCastExpr = lib.CXCursor_CXXFunctionalCastExpr
clang.cursor.CXXTypeidExpr = lib.CXCursor_CXXTypeidExpr
clang.cursor.CXXBoolLiteralExpr = lib.CXCursor_CXXBoolLiteralExpr
clang.cursor.CXXNullPtrLiteralExpr = lib.CXCursor_CXXNullPtrLiteralExpr
clang.cursor.CXXThisExpr = lib.CXCursor_CXXThisExpr
clang.cursor.CXXThrowExpr = lib.CXCursor_CXXThrowExpr
clang.cursor.CXXNewExpr = lib.CXCursor_CXXNewExpr
clang.cursor.CXXDeleteExpr = lib.CXCursor_CXXDeleteExpr
clang.cursor.UnaryExpr = lib.CXCursor_UnaryExpr
clang.cursor.ObjCStringLiteral = lib.CXCursor_ObjCStringLiteral
clang.cursor.ObjCEncodeExpr = lib.CXCursor_ObjCEncodeExpr
clang.cursor.ObjCSelectorExpr = lib.CXCursor_ObjCSelectorExpr
clang.cursor.ObjCProtocolExpr = lib.CXCursor_ObjCProtocolExpr
clang.cursor.ObjCBridgedCastExpr = lib.CXCursor_ObjCBridgedCastExpr
clang.cursor.PackExpansionExpr = lib.CXCursor_PackExpansionExpr
clang.cursor.SizeOfPackExpr = lib.CXCursor_SizeOfPackExpr
clang.cursor.LambdaExpr = lib.CXCursor_LambdaExpr
clang.cursor.ObjCBoolLiteralExpr = lib.CXCursor_ObjCBoolLiteralExpr
clang.cursor.ObjCSelfExpr = lib.CXCursor_ObjCSelfExpr
clang.cursor.OMPArraySectionExpr = lib.CXCursor_OMPArraySectionExpr
clang.cursor.ObjCAvailabilityCheckExpr = lib.CXCursor_ObjCAvailabilityCheckExpr
clang.cursor.LastExpr = lib.CXCursor_LastExpr
clang.cursor.FirstStmt = lib.CXCursor_FirstStmt
clang.cursor.UnexposedStmt = lib.CXCursor_UnexposedStmt
clang.cursor.LabelStmt = lib.CXCursor_LabelStmt
clang.cursor.CompoundStmt = lib.CXCursor_CompoundStmt
clang.cursor.CaseStmt = lib.CXCursor_CaseStmt
clang.cursor.DefaultStmt = lib.CXCursor_DefaultStmt
clang.cursor.IfStmt = lib.CXCursor_IfStmt
clang.cursor.SwitchStmt = lib.CXCursor_SwitchStmt
clang.cursor.WhileStmt = lib.CXCursor_WhileStmt
clang.cursor.DoStmt = lib.CXCursor_DoStmt
clang.cursor.ForStmt = lib.CXCursor_ForStmt
clang.cursor.GotoStmt = lib.CXCursor_GotoStmt
clang.cursor.IndirectGotoStmt = lib.CXCursor_IndirectGotoStmt
clang.cursor.ContinueStmt = lib.CXCursor_ContinueStmt
clang.cursor.BreakStmt = lib.CXCursor_BreakStmt
clang.cursor.ReturnStmt = lib.CXCursor_ReturnStmt
clang.cursor.GCCAsmStmt = lib.CXCursor_GCCAsmStmt
clang.cursor.AsmStmt = lib.CXCursor_AsmStmt
clang.cursor.ObjCAtTryStmt = lib.CXCursor_ObjCAtTryStmt
clang.cursor.ObjCAtCatchStmt = lib.CXCursor_ObjCAtCatchStmt
clang.cursor.ObjCAtFinallyStmt = lib.CXCursor_ObjCAtFinallyStmt
clang.cursor.ObjCAtThrowStmt = lib.CXCursor_ObjCAtThrowStmt
clang.cursor.ObjCAtSynchronizedStmt = lib.CXCursor_ObjCAtSynchronizedStmt
clang.cursor.ObjCAutoreleasePoolStmt = lib.CXCursor_ObjCAutoreleasePoolStmt
clang.cursor.ObjCForCollectionStmt = lib.CXCursor_ObjCForCollectionStmt
clang.cursor.CXXCatchStmt = lib.CXCursor_CXXCatchStmt
clang.cursor.CXXTryStmt = lib.CXCursor_CXXTryStmt
clang.cursor.CXXForRangeStmt = lib.CXCursor_CXXForRangeStmt
clang.cursor.SEHTryStmt = lib.CXCursor_SEHTryStmt
clang.cursor.SEHExceptStmt = lib.CXCursor_SEHExceptStmt
clang.cursor.SEHFinallyStmt = lib.CXCursor_SEHFinallyStmt
clang.cursor.MSAsmStmt = lib.CXCursor_MSAsmStmt
clang.cursor.NullStmt = lib.CXCursor_NullStmt
clang.cursor.DeclStmt = lib.CXCursor_DeclStmt
clang.cursor.OMPParallelDirective = lib.CXCursor_OMPParallelDirective
clang.cursor.OMPSimdDirective = lib.CXCursor_OMPSimdDirective
clang.cursor.OMPForDirective = lib.CXCursor_OMPForDirective
clang.cursor.OMPSectionsDirective = lib.CXCursor_OMPSectionsDirective
clang.cursor.OMPSectionDirective = lib.CXCursor_OMPSectionDirective
clang.cursor.OMPSingleDirective = lib.CXCursor_OMPSingleDirective
clang.cursor.OMPParallelForDirective = lib.CXCursor_OMPParallelForDirective
clang.cursor.OMPParallelSectionsDirective = lib.CXCursor_OMPParallelSectionsDirective
clang.cursor.OMPTaskDirective = lib.CXCursor_OMPTaskDirective
clang.cursor.OMPMasterDirective = lib.CXCursor_OMPMasterDirective
clang.cursor.OMPCriticalDirective = lib.CXCursor_OMPCriticalDirective
clang.cursor.OMPTaskyieldDirective = lib.CXCursor_OMPTaskyieldDirective
clang.cursor.OMPBarrierDirective = lib.CXCursor_OMPBarrierDirective
clang.cursor.OMPTaskwaitDirective = lib.CXCursor_OMPTaskwaitDirective
clang.cursor.OMPFlushDirective = lib.CXCursor_OMPFlushDirective
clang.cursor.SEHLeaveStmt = lib.CXCursor_SEHLeaveStmt
clang.cursor.OMPOrderedDirective = lib.CXCursor_OMPOrderedDirective
clang.cursor.OMPAtomicDirective = lib.CXCursor_OMPAtomicDirective
clang.cursor.OMPForSimdDirective = lib.CXCursor_OMPForSimdDirective
clang.cursor.OMPParallelForSimdDirective = lib.CXCursor_OMPParallelForSimdDirective
clang.cursor.OMPTargetDirective = lib.CXCursor_OMPTargetDirective
clang.cursor.OMPTeamsDirective = lib.CXCursor_OMPTeamsDirective
clang.cursor.OMPTaskgroupDirective = lib.CXCursor_OMPTaskgroupDirective
clang.cursor.OMPCancellationPointDirective = lib.CXCursor_OMPCancellationPointDirective
clang.cursor.OMPCancelDirective = lib.CXCursor_OMPCancelDirective
clang.cursor.OMPTargetDataDirective = lib.CXCursor_OMPTargetDataDirective
clang.cursor.OMPTaskLoopDirective = lib.CXCursor_OMPTaskLoopDirective
clang.cursor.OMPTaskLoopSimdDirective = lib.CXCursor_OMPTaskLoopSimdDirective
clang.cursor.OMPDistributeDirective = lib.CXCursor_OMPDistributeDirective
clang.cursor.OMPTargetEnterDataDirective = lib.CXCursor_OMPTargetEnterDataDirective
clang.cursor.OMPTargetExitDataDirective = lib.CXCursor_OMPTargetExitDataDirective
clang.cursor.OMPTargetParallelDirective = lib.CXCursor_OMPTargetParallelDirective
clang.cursor.OMPTargetParallelForDirective = lib.CXCursor_OMPTargetParallelForDirective
clang.cursor.OMPTargetUpdateDirective = lib.CXCursor_OMPTargetUpdateDirective
clang.cursor.OMPDistributeParallelForDirective = lib.CXCursor_OMPDistributeParallelForDirective
clang.cursor.OMPDistributeParallelForSimdDirective = lib.CXCursor_OMPDistributeParallelForSimdDirective
clang.cursor.OMPDistributeSimdDirective = lib.CXCursor_OMPDistributeSimdDirective
clang.cursor.OMPTargetParallelForSimdDirective = lib.CXCursor_OMPTargetParallelForSimdDirective
clang.cursor.OMPTargetSimdDirective = lib.CXCursor_OMPTargetSimdDirective
clang.cursor.OMPTeamsDistributeDirective = lib.CXCursor_OMPTeamsDistributeDirective
clang.cursor.OMPTeamsDistributeSimdDirective = lib.CXCursor_OMPTeamsDistributeSimdDirective
clang.cursor.OMPTeamsDistributeParallelForSimdDirective = lib.CXCursor_OMPTeamsDistributeParallelForSimdDirective
clang.cursor.OMPTeamsDistributeParallelForDirective = lib.CXCursor_OMPTeamsDistributeParallelForDirective
clang.cursor.OMPTargetTeamsDirective = lib.CXCursor_OMPTargetTeamsDirective
clang.cursor.OMPTargetTeamsDistributeDirective = lib.CXCursor_OMPTargetTeamsDistributeDirective
clang.cursor.OMPTargetTeamsDistributeParallelForDirective = lib.CXCursor_OMPTargetTeamsDistributeParallelForDirective
clang.cursor.OMPTargetTeamsDistributeParallelForSimdDirective = lib.CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective
clang.cursor.OMPTargetTeamsDistributeSimdDirective = lib.CXCursor_OMPTargetTeamsDistributeSimdDirective
clang.cursor.LastStmt = lib.CXCursor_LastStmt
clang.cursor.TranslationUnit = lib.CXCursor_TranslationUnit
clang.cursor.FirstAttr = lib.CXCursor_FirstAttr
clang.cursor.UnexposedAttr = lib.CXCursor_UnexposedAttr
clang.cursor.IBActionAttr = lib.CXCursor_IBActionAttr
clang.cursor.IBOutletAttr = lib.CXCursor_IBOutletAttr
clang.cursor.IBOutletCollectionAttr = lib.CXCursor_IBOutletCollectionAttr
clang.cursor.CXXFinalAttr = lib.CXCursor_CXXFinalAttr
clang.cursor.CXXOverrideAttr = lib.CXCursor_CXXOverrideAttr
clang.cursor.AnnotateAttr = lib.CXCursor_AnnotateAttr
clang.cursor.AsmLabelAttr = lib.CXCursor_AsmLabelAttr
clang.cursor.PackedAttr = lib.CXCursor_PackedAttr
clang.cursor.PureAttr = lib.CXCursor_PureAttr
clang.cursor.ConstAttr = lib.CXCursor_ConstAttr
clang.cursor.NoDuplicateAttr = lib.CXCursor_NoDuplicateAttr
clang.cursor.CUDAConstantAttr = lib.CXCursor_CUDAConstantAttr
clang.cursor.CUDADeviceAttr = lib.CXCursor_CUDADeviceAttr
clang.cursor.CUDAGlobalAttr = lib.CXCursor_CUDAGlobalAttr
clang.cursor.CUDAHostAttr = lib.CXCursor_CUDAHostAttr
clang.cursor.CUDASharedAttr = lib.CXCursor_CUDASharedAttr
clang.cursor.VisibilityAttr = lib.CXCursor_VisibilityAttr
clang.cursor.DLLExport = lib.CXCursor_DLLExport
clang.cursor.DLLImport = lib.CXCursor_DLLImport
clang.cursor.LastAttr = lib.CXCursor_LastAttr
clang.cursor.PreprocessingDirective = lib.CXCursor_PreprocessingDirective
clang.cursor.MacroDefinition = lib.CXCursor_MacroDefinition
clang.cursor.MacroExpansion = lib.CXCursor_MacroExpansion
clang.cursor.MacroInstantiation = lib.CXCursor_MacroInstantiation
clang.cursor.InclusionDirective = lib.CXCursor_InclusionDirective
clang.cursor.FirstPreprocessing = lib.CXCursor_FirstPreprocessing
clang.cursor.LastPreprocessing = lib.CXCursor_LastPreprocessing
clang.cursor.ModuleImportDecl = lib.CXCursor_ModuleImportDecl
clang.cursor.TypeAliasTemplateDecl = lib.CXCursor_TypeAliasTemplateDecl
clang.cursor.StaticAssert = lib.CXCursor_StaticAssert
clang.cursor.FriendDecl = lib.CXCursor_FriendDecl
clang.cursor.FirstExtraDecl = lib.CXCursor_FirstExtraDecl
clang.cursor.LastExtraDecl = lib.CXCursor_LastExtraDecl
clang.cursor.OverloadCandidate = lib.CXCursor_OverloadCandidate

clang.type = {}
clang.type.Invalid = lib.CXType_Invalid
clang.type.Unexposed = lib.CXType_Unexposed
clang.type.Void = lib.CXType_Void
clang.type.Bool = lib.CXType_Bool
clang.type.Char_U = lib.CXType_Char_U
clang.type.UChar = lib.CXType_UChar
clang.type.Char16 = lib.CXType_Char16
clang.type.Char32 = lib.CXType_Char32
clang.type.UShort = lib.CXType_UShort
clang.type.UInt = lib.CXType_UInt
clang.type.ULong = lib.CXType_ULong
clang.type.ULongLong = lib.CXType_ULongLong
clang.type.UInt128 = lib.CXType_UInt128
clang.type.Char_S = lib.CXType_Char_S
clang.type.SChar = lib.CXType_SChar
clang.type.WChar = lib.CXType_WChar
clang.type.Short = lib.CXType_Short
clang.type.Int = lib.CXType_Int
clang.type.Long = lib.CXType_Long
clang.type.LongLong = lib.CXType_LongLong
clang.type.Int128 = lib.CXType_Int128
clang.type.Float = lib.CXType_Float
clang.type.Double = lib.CXType_Double
clang.type.LongDouble = lib.CXType_LongDouble
clang.type.NullPtr = lib.CXType_NullPtr
clang.type.Overload = lib.CXType_Overload
clang.type.Dependent = lib.CXType_Dependent
clang.type.ObjCId = lib.CXType_ObjCId
clang.type.ObjCClass = lib.CXType_ObjCClass
clang.type.ObjCSel = lib.CXType_ObjCSel
clang.type.Float128 = lib.CXType_Float128
clang.type.Half = lib.CXType_Half
clang.type.Float16 = lib.CXType_Float16
clang.type.FirstBuiltin = lib.CXType_FirstBuiltin
clang.type.LastBuiltin = lib.CXType_LastBuiltin
clang.type.Complex = lib.CXType_Complex
clang.type.Pointer = lib.CXType_Pointer
clang.type.BlockPointer = lib.CXType_BlockPointer
clang.type.LValueReference = lib.CXType_LValueReference
clang.type.RValueReference = lib.CXType_RValueReference
clang.type.Record = lib.CXType_Record
clang.type.Enum = lib.CXType_Enum
clang.type.Typedef = lib.CXType_Typedef
clang.type.ObjCInterface = lib.CXType_ObjCInterface
clang.type.ObjCObjectPointer = lib.CXType_ObjCObjectPointer
clang.type.FunctionNoProto = lib.CXType_FunctionNoProto
clang.type.FunctionProto = lib.CXType_FunctionProto
clang.type.ConstantArray = lib.CXType_ConstantArray
clang.type.Vector = lib.CXType_Vector
clang.type.IncompleteArray = lib.CXType_IncompleteArray
clang.type.VariableArray = lib.CXType_VariableArray
clang.type.DependentSizedArray = lib.CXType_DependentSizedArray
clang.type.MemberPointer = lib.CXType_MemberPointer
clang.type.Auto = lib.CXType_Auto
clang.type.Elaborated = lib.CXType_Elaborated
clang.type.Pipe = lib.CXType_Pipe
clang.type.OCLImage1dRO = lib.CXType_OCLImage1dRO
clang.type.OCLImage1dArrayRO = lib.CXType_OCLImage1dArrayRO
clang.type.OCLImage1dBufferRO = lib.CXType_OCLImage1dBufferRO
clang.type.OCLImage2dRO = lib.CXType_OCLImage2dRO
clang.type.OCLImage2dArrayRO = lib.CXType_OCLImage2dArrayRO
clang.type.OCLImage2dDepthRO = lib.CXType_OCLImage2dDepthRO
clang.type.OCLImage2dArrayDepthRO = lib.CXType_OCLImage2dArrayDepthRO
clang.type.OCLImage2dMSAARO = lib.CXType_OCLImage2dMSAARO
clang.type.OCLImage2dArrayMSAARO = lib.CXType_OCLImage2dArrayMSAARO
clang.type.OCLImage2dMSAADepthRO = lib.CXType_OCLImage2dMSAADepthRO
clang.type.OCLImage2dArrayMSAADepthRO = lib.CXType_OCLImage2dArrayMSAADepthRO
clang.type.OCLImage3dRO = lib.CXType_OCLImage3dRO
clang.type.OCLImage1dWO = lib.CXType_OCLImage1dWO
clang.type.OCLImage1dArrayWO = lib.CXType_OCLImage1dArrayWO
clang.type.OCLImage1dBufferWO = lib.CXType_OCLImage1dBufferWO
clang.type.OCLImage2dWO = lib.CXType_OCLImage2dWO
clang.type.OCLImage2dArrayWO = lib.CXType_OCLImage2dArrayWO
clang.type.OCLImage2dDepthWO = lib.CXType_OCLImage2dDepthWO
clang.type.OCLImage2dArrayDepthWO = lib.CXType_OCLImage2dArrayDepthWO
clang.type.OCLImage2dMSAAWO = lib.CXType_OCLImage2dMSAAWO
clang.type.OCLImage2dArrayMSAAWO = lib.CXType_OCLImage2dArrayMSAAWO
clang.type.OCLImage2dMSAADepthWO = lib.CXType_OCLImage2dMSAADepthWO
clang.type.OCLImage2dArrayMSAADepthWO = lib.CXType_OCLImage2dArrayMSAADepthWO
clang.type.OCLImage3dWO = lib.CXType_OCLImage3dWO
clang.type.OCLImage1dRW = lib.CXType_OCLImage1dRW
clang.type.OCLImage1dArrayRW = lib.CXType_OCLImage1dArrayRW
clang.type.OCLImage1dBufferRW = lib.CXType_OCLImage1dBufferRW
clang.type.OCLImage2dRW = lib.CXType_OCLImage2dRW
clang.type.OCLImage2dArrayRW = lib.CXType_OCLImage2dArrayRW
clang.type.OCLImage2dDepthRW = lib.CXType_OCLImage2dDepthRW
clang.type.OCLImage2dArrayDepthRW = lib.CXType_OCLImage2dArrayDepthRW
clang.type.OCLImage2dMSAARW = lib.CXType_OCLImage2dMSAARW
clang.type.OCLImage2dArrayMSAARW = lib.CXType_OCLImage2dArrayMSAARW
clang.type.OCLImage2dMSAADepthRW = lib.CXType_OCLImage2dMSAADepthRW
clang.type.OCLImage2dArrayMSAADepthRW = lib.CXType_OCLImage2dArrayMSAADepthRW
clang.type.OCLImage3dRW = lib.CXType_OCLImage3dRW
clang.type.OCLSampler = lib.CXType_OCLSampler
clang.type.OCLEvent = lib.CXType_OCLEvent
clang.type.OCLQueue = lib.CXType_OCLQueue
clang.type.OCLReserveID = lib.CXType_OCLReserveID

clang.tuFlags = {}
clang.tuFlags.None = lib.CXTranslationUnit_None
clang.tuFlags.DetailedPreprocessingRecord = lib.CXTranslationUnit_DetailedPreprocessingRecord
clang.tuFlags.Incomplete = lib.CXTranslationUnit_Incomplete
clang.tuFlags.PrecompiledPreamble = lib.CXTranslationUnit_PrecompiledPreamble
clang.tuFlags.CacheCompletionResults = lib.CXTranslationUnit_CacheCompletionResults
clang.tuFlags.ForSerialization = lib.CXTranslationUnit_ForSerialization
clang.tuFlags.CXXChainedPCH = lib.CXTranslationUnit_CXXChainedPCH
clang.tuFlags.SkipFunctionBodies = lib.CXTranslationUnit_SkipFunctionBodies
clang.tuFlags.IncludeBriefCommentsInCodeCompletion = lib.CXTranslationUnit_IncludeBriefCommentsInCodeCompletion
clang.tuFlags.CreatePreambleOnFirstParse = lib.CXTranslationUnit_CreatePreambleOnFirstParse
clang.tuFlags.KeepGoing = lib.CXTranslationUnit_KeepGoing
clang.tuFlags.SingleFileParse = lib.CXTranslationUnit_SingleFileParse


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
      local c = ffi.new("CXCursor", cursorPtr[0]) --create a copy from the passed in pointer
      local cursor = createCursor(c) --create a lua version
      table.insert(ret, cursor) --add to the list children to be returned at the end
      
      return lib.CXChildVisit_Continue
   end
end

function clang_cursor.children(self)
   local cptr = self.cursor
   local ret = {}
   local cursorVisitor = createCursorVisitor(ret)
   
   local cb = ffi.cast("CXCursorVisitor2", cursorVisitor) --this uses our bejanked function definition that uses CXCursor* instead of the actual structs.  In the callback we copy from the stack to a heap allocated object
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
   if(tptr.kind == lib.CXType_Invalid) then
      return nil
   else
      return createType(tptr)
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


--is this really the best way to provide this to the user?  Considering enums are part of lib.
clang.lib = lib

return clang