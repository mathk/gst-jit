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
 
    pushLiteral [
    ]

    pushInstanceVariable: anIndex [
    ]

    popIntoInstanceVariable: anIndex [
	
    ]

    pushTemporary: anOffset [
	self subclassResponssability
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
]

Interpreter subclass: LightningInterpreter [

    "R0 designate the MethodContext
     R1 is the JitMethod
     R2 can be the Stack Pointer"
    | state method stackCount currentStackCount |

    LightningInterpreter class >> new [
	^(super new)
	    stackCount: 0;
	    yourself
    ]

    method [
	^method ifNil: [method := JitMethod new]
    ]

    initArgsCount: args tempsCount: temps [
	self method 
	    argsCount: args;
	    tempCount: temps
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
	self state movI: Lightning.R0 fromUI: Lightning.CJitState primGstThisContextOOP
	
	"Fetch the JitMethod and put it in the R1 register"
    ]

    methodEpilog [
	"Free context and return to the caller ..."
    ]

    pop [
	self popCount
    ]

    pushTemp: anOffset [
	self state 
            loadUI: Lightning.R1 "SP"
	    fromReg: Lightning.R0 
	    im: 4;
	    loadI: Lightning.R2 
	    fromReg: Lightning.R0 
	    im: 5"(method tempOffset: anOffset)";
	    addI: Lightning.R1 to: Lightning.R1 int: 1.
	    "store sp"
	    " TEST loadC: Lightning.R1 fromReg: Lightning.R0 and: Lightning.R2;
	    loadD: Lightning.R0 im: 1.0;
	    loadUI: Lightning.R0 im: 42;
	    loadUS: Lightning.R0 fromReg: Lightning.R1 im: 1;
	    movI: Lightning.R0 fromUI: 4;
	    loadUI: Lightning.R0 im: 4."
	    
	    "store R2 in stack *(R0 + R1)"

	"Here we:
	 1) fetch the context Normaly it is R0
	 2) fetch the object at TEMP_BASE + index offset in the context
	 3) push the object ins the context at sp of the context"
    ]

    popIntoTemporary: anOffset [
	self popCount
    ]

    pushLiteral [
	self pushCount
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
	self stackCount: self stackCount - 1.
    ]

    storeIntoTemp: anOffset [
	
    ]
]
