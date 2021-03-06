" Hey Emacs, I want -*- tab-width: 8; -*- "

Object subclass: Interpreter [
    "I am an abstract interpreter.
     I interpret low level instruction like push pop ..."

    methodProlog [
    ]

    methodEpilog [
    ]

    jumpTo: label [
    ]

    jumpIfTrue: label [
	
    ]

    jumpTo: label if: aBool [
	
    ]

    label: aSymbol [
	
    ]

    dup [
    ]

    pop [
    ]

    pushReceiver [
    ]

    pushInstanceVariable: anIndex [
    ]

    popIntoInstanceVariable: anIndex [

    ]

    pushTemp: anOffset [
	self subclassResponssability
    ]

    pushTemp: offset fromScopeAt: envParentCount [
	
    ]

    makeDirtyBlock [
	
    ]

    pushLiteral: index [

    ]

    popIntoTemp: anOffset [
    ]

    send: literalIndex numArg: argCount [
    ]

    storeIntoInstance: anIndex [
	self subclassResponssability
    ]

    storeIntoTemp: anOffset [
	self subclassResponssability
    ]

    returnTop [
    ]

    returnBlockTop [
    ]
]

Interpreter subclass: LightningInterpreter [

    "R0 designate the MethodContext"
    | numTemp numArg state method stackCount currentStackCount uniqueLabel isSpInitialize  jitCompiledClass |

    LightningInterpreter class >> onClass: aJitCompiledClass [
	^(super new)
	    jitCompiledClass: aJitCompiledClass;
	    stackCount: 0;
	    yourself
    ]

    jitCompiledClass: aBehavior [
	jitCompiledClass := aBehavior
    ]

    isSpInitialize [
	^isSpInitialize ifNil: [isSpInitialize := false]
    ]

    isSpInitilize: aBool [
	isSpInitialize := aBool
    ]

    uniqueLabel [
	^uniqueLabel ifNil: [uniqueLabel := OrderedCollection new: 10].
    ]

    uniqueLabel: aSymbol [
	| currentSymbol prefix |
	currentSymbol := aSymbol asString.
	prefix := 0.
	
	[self uniqueLabel includes: currentSymbol]
	    whileTrue: [
		currentSymbol := aSymbol asString, prefix asString.
		prefix := prefix + 1.
	    ].
	self uniqueLabel add: currentSymbol.
	^currentSymbol asSymbol
    ]

    numArg: anInteger [
	numArg := anInteger
    ]

    numTemp: anInteger [
	numTemp := anInteger
    ]

    method [
	^method ifNil: [method := jitCompiledClass new: 0]
    ]

    literals: anArray [
	self method
	    literals: anArray asArray
    ]

    stackCount [
	<category: 'accessing'>
	^stackCount
    ]

    stackCount: size [
	<category: 'accessing'>
	stackCount := size
    ]

    currentStackCount [
	^currentStackCount ifNil: [currentStackCount := 0]
    ]

    currentStackCount: size [
	currentStackCount := self currentStackCount max: size
    ]

    state [
	^state ifNil: [state := Lightning.CJitState new]
    ]

    prolog [
	self state
	    prolog.
	self loadGstThisContextOop: Lightning.R0
    ]

    methodEpilog [
	self state assemble.
	self method
	    buildHeaderDepth: self stackCount numArg: numArg numTemp: numTemp;
	    jitState: self state
    ]

    blockEpilog: cleanFlag [
	self state assemble.
	self method
	    buildHeaderDepth: self stackCount numArg: numArg numTemp: numTemp cleanFlag: cleanFlag;
	    jitState: self state
    ]

    pop [
	self loadSp: Lightning.R1.
	self state subI: Lightning.R1 to: Lightning.R1 ulong: 1.
	self storeSp: Lightning.R1.
	self popCount
    ]

    makeDirtyBlock [
	self loadStackTop: Lightning.V1.
	self state
	    finishUL: self primGstSyncSpAddr;
	    prepare: 1;
	    pushargPtr: Lightning.V1;
	    finishUL: self primGstMakeBlockClosureAddr;
	    retval: Lightning.R1.
	self loadGstThisContextOop: Lightning.R0.
	self storeStackTop: Lightning.R1
    ]

    dup [
	self loadStackTop: Lightning.R1.
	self privatePushReg: Lightning.R1
    ]

    sendSpecialPlus [
	| isNotInt isNotFloat |
	"is a and b int"
	isNotInt := self uniqueLabel: #isNotInt.
	isNotFloat := self uniqueLabel: #isNotFloat.
	self loadStackAt: 1 into: Lightning.R1.
	self loadStackAt: 0 into: Lightning.R2.
	self state 
	    andR: Lightning.V1 to: Lightning.R1 ulong: Lightning.R2;
	    andI: Lightning.V1 to: Lightning.V1 ulong: 1;
	    jumpTo: isNotInt if: Lightning.R1 imEqualUL: 0;
	    subI: Lightning.R2 to: Lightning.R2 ulong: 1;
	    jumpLabel: isNotInt;
	    "Take care int + float or float + int"
	    jumpLabel: isNotFloat.
	"..."
    ]
    
    send: literalIndex numArgs: argCount [

	self sendNumArg: argCount usingSelector: [:reg | 
	    self loadLiteral: literalIndex into: reg
	]
    ]

    sendNumArg: argCount usingSelector: aBlock [
	| return isInt isIntEnd |
	return := self uniqueLabel: #sendReturn.
	isInt := self uniqueLabel: #isInt.
	isIntEnd := self uniqueLabel: #isIntEnd.
	self state
	    finishUL: self primGstSyncSpAddr.
	self loadGstThisContextOop: Lightning.R0.
	self state
	    movI: Lightning.R1 fromIp: return.

	self loadSp: Lightning.V0.

	"FIXME: Make the interpreter not override the sp if we are in a jitcontext"
	self state movR: Lightning.V1 fromUL: Lightning.R0.
	self state subI: Lightning.V0 to: Lightning.V0 ulong: argCount.
	self state
	    storeImUL: self nativeIpDisplacement
	    and: Lightning.R0
	    fromReg: Lightning.R1;
	    prepare: 4.

	"method_class"	
	self loadStackAt: argCount into: Lightning.R1.
	self state
	    "IS_INT(receiver)? _gst_small_integer_oop : OOP_CLASS(receiver)"
	    andI: Lightning.R2 to: Lightning.R1 ulong: 1;
	    jumpTo: isInt if: Lightning.R2 imEqualUL: 1;
	    fetchClassOop: Lightning.R2 fromOopReg: Lightning.R1;
	    pushargPtr: Lightning.R2;
	    jumpTo: isIntEnd;
	    jumpLabel: isInt;
	    movI: Lightning.R2 fromObjectP: SmallInteger;
	    pushargPtr: Lightning.R2;
	    jumpLabel: isIntEnd.

	"receiver"
	self state pushargPtr: Lightning.R1.

	"sendArgs"
	self state movI: Lightning.R1 fromUL: argCount.
	self state pushargUL: Lightning.R1.

	"sendSelector"
	aBlock value: Lightning.R1.
	self state pushargPtr: Lightning.R1.
	
	self state
	    finishUL: self primGstSendmessageInternalAddr.

	"FIXME: Make the interpreter not override the sp if we are in a jitcontext"
	self state movR: Lightning.R0 fromUL: Lightning.V1.
	self storeSp: Lightning.V0.
	self state
	    ret.
	"return to the interpreter"

	self state jumpLabel: return.
	self state prolog.
	self loadGstThisContextOop: Lightning.R0
    ]

    pushTemp: anOffset [
	self state
	    loadUL: Lightning.R2
	    fromReg: Lightning.R0
	    im: (self tempDisplacement: anOffset).
	self privatePushReg: Lightning.R2
    ]

    pushTemp: offset fromScopeAt: envParentCount [
	self loadParentEnvIn: Lightning.R1 distance: envParentCount.
	self state
	    loadUL: Lightning.R2
	    fromReg: Lightning.R1
	    im: (self tempDisplacement: offset).
	self privatePushReg: Lightning.R2
    ]

    storeIntoTemp: offset fromScopeAt:envParentCount [
	self loadParentEnvIn: Lightning.R1 distance: envParentCount.
	self loadStackTop: Lightning.R2.
	self state
	    storeImP: (self tempDisplacement: offset)
	    and: Lightning.R1
	    fromReg: Lightning.R2
    ]

    pushLiteral: index [
	self loadLiteral: index into: Lightning.R1.
	self privatePushReg: Lightning.R1
    ]

    pushReceiver [
	self state
	    loadUL: Lightning.R1
	    fromReg: Lightning.R0
	    im: self receiverDisplacement.
	self privatePushReg: Lightning.R1
    ]

    privatePushReg: reg [
	"Push the content of a register in the stack"
	| sp offset |
	self pushCount.
	sp := reg = Lightning.R1 ifTrue:[ Lightning.R2 ] ifFalse: [ Lightning.R1 ].
	self loadSpForPush: sp.
	self state
	    mulI: sp to: sp uint: self state sizeOfOop;
	    addI: sp to: sp ulong: self stackDisplacementBase;
	    storeRegP: sp and: Lightning.R0 fromReg: reg.
	
    ]

    loadParentEnvIn: reg distance: anInt [
	self state movR: reg fromUL: Lightning.R0.
	1 to: anInt do: [:index | self loadOuterObjectCxt: reg startingAt: reg].
    ]

    loadSpForPush: spReg [
	self isSpInitialize 
            ifFalse:[
		self state movI: spReg fromUL: numTemp.
		self storeSp: spReg.
		self isSpInitilize: true.
	    ]
	    ifTrue: [
		self loadSp: spReg.
		self state addI: spReg to: spReg ulong: 1.
		self storeSp: spReg
	    ]
    ]

    popIntoTemp: anOffset [
	self popCount
    ]

    pushInstanceVariable: anIndex [
	self pushCount
    ]

    popIntoInstanceVariable: anIndex [
	self popCount

    ]

    pushCount [
	"Used to count the stack size"
	self stackCount: self stackCount + 1.
	self currentStackCount: self stackCount
    ]

    popCount [
	self stackCount: self stackCount - 1
    ]

    storeIntoTemp: anOffset [
	self loadStackTop: Lightning.R1.
	self state
	    storeImP: (self tempDisplacement: anOffset)
	    and: Lightning.R0
	    fromReg: Lightning.R1
    ]

    returnTop [
	self loadStackTop: Lightning.V0.
	self state 
	    prepare: 0;
	    finishUL: self primGstUnwindContextAddr.
	"We reaload the context since we unwind it"
	self loadGstThisContextOop: Lightning.R0.
	self storeStackTop: Lightning.V0.
	self state ret.

	" 
	 if UNCOMMON (!unwind_method ())
	 {
	 SEND_MESSAGE (_gst_bad_return_error_symbol, 0);
	 }
	 "
    ]

    jumpTo: label if: aBool [
	self loadStackTop: Lightning.R2.
	aBool 
           ifTrue: [self loadTrue: Lightning.R1]
	   ifFalse: [self loadFalse: Lightning.R1].
	
	self state jumpTo: label if: Lightning.R2 equal: Lightning.R1.
	
    ]

    jumpTo: label [
	self state jumpTo: label
    ]

    label: aSymbol [
	self state jumpLabel: aSymbol
    ]

    loadTrue: reg [
	self state movI: reg fromObjectP: true
    ]

    loadFalse: reg [
	self state movI: reg fromObjectP: false
    ]

    loadLiteral: index into: reg [
	self state
	    fetchOop: reg
	    fromObjectReg: Lightning.R0
	    at: (MethodContext indexOfInstVar: 'method');
	    fetchOop: reg
	    fromOopReg: reg
	    at: (JitMethod indexOfInstVar: 'literals');
	    fetchOop: reg
	    fromOopReg: reg
	    at: index.
    ]

    loadStackTop: reg [
	self loadStackAt: 0 into: reg
    ]

    loadStackAt: index into: reg [
	self loadSp: reg.
	index > 0 ifTrue: [self state subI: reg to: reg ulong: index].
	self state
	    mulI: reg to: reg uint: self state sizeOfOop;
	    addI: reg to: reg ulong: self stackDisplacementBase;
	    loadUL: reg
	    fromReg: reg
	    and: Lightning.R0
    ]

    storeStackTop: reg [
	| spReg |
	spReg := reg = Lightning.R1 ifTrue: [Lightning.R2] ifFalse: [Lightning.R1].
	self loadSp: spReg.
	self state
	    mulI: spReg to: spReg uint: self state sizeOfOop;
	    addI: spReg to: spReg ulong: self stackDisplacementBase;
	    storeRegUL: spReg
	    and: Lightning.R0
	    fromReg: reg
    ]

    loadSp: reg [
	self state
	    loadUL: reg
	    fromReg: Lightning.R0
	    im: self spDisplacement;
	    toInt: reg
    ]

    storeSp: reg [
	self state
	    fromInt: reg;
	    storeImUL: self spDisplacement
	    and: Lightning.R0
	    fromReg: reg;
	    toInt: reg
    ]

    loadGstThisContextOop: reg [
	self state
	    movI: reg fromUL: Lightning.CJitState primGstThisContextOOP;
	    loadP: reg fromReg: reg;
	    loadP: reg fromReg: reg
    ]

    loadOuterObjectCxt: regDst startingAt: regSrc [
	self state fetchOop: regDst fromObjectReg: regSrc at: (BlockContext indexOfInstVar: 'outerContext').
	self state loadP: regDst fromReg:regDst
	
    ]

    outerContextDisplacement [
	^(((BlockContext indexOfInstVar: 'outerContext') - 1) * self state sizeOfOop) + self state sizeOfHeader.
    ]

    tempDisplacement: offset [
	^((MethodContext allInstVarNames size + offset) * self state sizeOfOop) + self state sizeOfHeader
    ]

    spDisplacement [
	^(((ContextPart indexOfInstVar: 'sp') - 1) * self state sizeOfOop) + self state sizeOfHeader
    ]

    nativeIpDisplacement [
	^(((ContextPart indexOfInstVar: 'nativeIP') - 1) * self state sizeOfOop) + self state sizeOfHeader
    ]

    receiverDisplacement [
	^(((ContextPart indexOfInstVar: 'receiver') - 1) * self state sizeOfOop) + self state sizeOfHeader
    ]

    stackDisplacementBase [
	^((MethodContext allInstVarNames size + numArg) * self state sizeOfOop) + self state sizeOfHeader
    ]

    primGstUnwindContextAddr [
	<category: 'primitive'>

	<primitive: VMpr_GstUnwindContextAddr_ptr>
    ]

    primGstUnwindMethodAddr [
	<category: 'primitive'>

	<primitive: VMpr_GstUnwindMethodAddr_ptr>
    ]

    primGstSyncSpAddr [
	<category: 'primitive'>
	<primitive: VMpr_GstSyncSpAddr_ptr>
    ]

    primGstSendmessageInternalAddr [
	<category: 'primitive'>
	<primitive: VMpr_GstSendMessageInternalAddr_ptr>
    ]

    
    primGstMakeBlockClosureAddr [
	<category: 'primitive'>
	<primitive: VMpr_GstMakeBlockClosureAddr_ptr>
    ]
]
