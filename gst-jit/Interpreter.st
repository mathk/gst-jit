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

    returnFromContext [
    ]

    returnFromMethod [
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
]

Interpreter subclass: LightningInterpreter [

    "R0 designate the MethodContext"
    | state method stackCount currentStackCount |

    LightningInterpreter class >> new [
	^(super new)
	    stackCount: 0;
	    yourself
    ]

    method [
	^method ifNil: [method := JitMethod new]
    ]

    initArgsAnTempsCount: count  [
	self method
	    argsAndTempsCount: count.
    ]

    literals: anArray [
	self method
	    literals: anArray
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
	    movI: Lightning.R0 fromP: Lightning.CJitState primGstThisContextOOP;
	    loadP: Lightning.R0 fromReg: Lightning.R0

	"Fetch the JitMethod and put it in the R1 register"
    ]

    methodEpilog [
	"Free context and return to the caller ..."
	
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

	self state 
	    prepare: 0;
	    finishUL: self primGstUnwindContextAddr
	" 
	 if UNCOMMON (!unwind_method ())
	 {
	 SEND_MESSAGE (_gst_bad_return_error_symbol, 0);
	 }
	 else
	 {
	 SET_STACKTOP (val);
	 }
	 FETCH;
	 "
    ]

    loadStackTop: reg [
	self loadSp: reg.
	self state
	    addI: reg
	    to: reg
	    ulong: self stackDisplacementBase;
	    loadUL: reg
	    fromReg: reg
    ]

    loadSp: reg [
	self state
	    loadUL: reg
	    fromReg: Lightning.R0
	    im: self spDisplacement
    ]

    storeSp: reg [
	self state
	    storeImUL: self spDisplacement
	    and: Lightning.R0
	    fromReg: reg
    ]


    tempDisplacement: offset [
	^(MethodContext allInstVarNames size + offset) * self state sizeOfOop
    ]

    spDisplacement [
	^(MethodContext indexOfInstVar: 'sp') * self state sizeOfOop
    ]

    stackDisplacementBase [
	^(MethodContext allInstVarNames size + self method argsAndTempsCount) * self state sizeOfOop
    ]

    primGstUnwindContextAddr [
	<category: 'primitive'>

	<primitive: VMpr_GstUnwindContextAddr_ptr>
    ]
]
