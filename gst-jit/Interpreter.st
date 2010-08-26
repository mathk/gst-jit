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

    pop [
    ]

    pushReceiver [
    ]

    pushInstanceVariable: anIndex [
    ]

    popIntoInstanceVariable: anIndex [

    ]

    pushTemporary: anOffset [
	self subclassResponssability
    ]

    pushLiteral: index [

    ]

    popIntoTemporary: anOffset [

    ]

    send [
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
    | numTemp numArg state method stackCount currentStackCount |

    LightningInterpreter class >> new [
	^(super new)
	    stackCount: 0;
	    yourself
    ]

    numArg: anInteger [
	numArg := anInteger
    ]

    numTemp: anInteger [
	numTemp := anInteger
    ]

    method [
	^method ifNil: [method := JitMethod new: 0]
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

    methodProlog [
	self state
	    prolog.
	self loadGstThisContextOop: Lightning.R0.
	"spOffset is not lazily set for the time being"
	self state movI: Lightning.R1 fromUL: numTemp.
	self storeSp: Lightning.R1.
	
    ]

    methodEpilog [
	"Free context and return to the caller ..."
	self state
	    ret;
	    assemble.
	self method
	    buildHeaderDepth: self stackCount numArg: numArg numTemp: numTemp;
	    jitState: self state
    ]

    pop [
	self loadSp: Lightning.R1.
	self state subI: Lightning.R1 to: Lightning.R1 ulong: 1.
	self storeSp: Lightning.R1.
	self popCount
    ]

    pushTemp: anOffset [
	self state
	    loadUL: Lightning.R2
	    fromReg: Lightning.R0
	    im: (self tempDisplacement: anOffset).
	self privatePushReg: Lightning.R2
	"Here we:
	 1) fetch the context Normaly it is R0
	 2) fetch the object at TEMP_BASE + index offset in the context
	 3) push the object ins the context at sp of the context"
    ]

    pushLiteral: index [

	self state
	    fetchOop: Lightning.R1
	    fromObjectReg: Lightning.R0
	    at: (MethodContext indexOfInstVar: 'method');
	    fetchOop: Lightning.R1
	    fromOopReg: Lightning.R1
	    at: (JitMethod indexOfInstVar: 'literals');
	    fetchOop: Lightning.R1
	    fromOopReg: Lightning.R1
	    at: index.
	self privatePushReg: Lightning.R1
    ]

    pushReceiver [
    ]

    privatePushReg: reg [
	"Push the content of a register in the stack"
	| sp offset |
	self pushCount.
	sp := reg = Lightning.R1 ifTrue:[ Lightning.R2 ] ifFalse: [ Lightning.R1 ].
	self loadSp: sp.
	self state addI: sp to: sp ulong: 1.
	self storeSp: sp.
	self state
	    mulI: sp to: sp uint: self state sizeOfOop;
	    addI: sp to: sp ulong: self stackDisplacementBase;
	    storeRegP: sp and: Lightning.R0 fromReg: reg
    ]

    popIntoTemporary: anOffset [
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
	
	" 
	 if UNCOMMON (!unwind_method ())
	 {
	 SEND_MESSAGE (_gst_bad_return_error_symbol, 0);
	 }
	 "
    ]

    loadStackTop: reg [
	self loadSp: reg.
	self state
	    mulI: reg to: reg uint: self state sizeOfOop;
	    addI: reg
	    to: reg
	    ulong: self stackDisplacementBase;
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
	    addI: spReg
	    to: spReg
	    ulong: self stackDisplacementBase;
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
	    movI: reg fromP: Lightning.CJitState primGstThisContextOOP;
	    loadP: reg fromReg: reg;
	    loadP: reg fromReg: reg
    ]

    tempDisplacement: offset [
	^((MethodContext allInstVarNames size + offset) * self state sizeOfOop) + self state sizeOfHeader
    ]

    spDisplacement [
	^(((MethodContext indexOfInstVar: 'sp') - 1) * self state sizeOfOop) + self state sizeOfHeader
    ]

    stackDisplacementBase [
	^((MethodContext allInstVarNames size + numArg) * self state sizeOfOop) + self state sizeOfHeader
    ]

    primGstUnwindContextAddr [
	<category: 'primitive'>

	<primitive: VMpr_GstUnwindContextAddr_ptr>
    ]
]
