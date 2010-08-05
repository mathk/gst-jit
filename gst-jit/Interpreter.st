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
	self popCount
    ]

    pushTemp: anOffset [
	self state 
            loadUI: Lightning.R1
	    fromReg: Lightning.R0 
	    im: (MethodContext indexOfInstVar: 'sp') * self state sizeOfOop;
	    loadI: Lightning.R2 
	    fromReg: Lightning.R0 
	    im: (MethodContext allInstVarNames size + anOffset) * self state sizeOfOop;
	    addI: Lightning.R1 to: Lightning.R1 int: 1;
	    storeImUI: (MethodContext indexOfInstVar: 'sp') * self state sizeOfOop
	    and: Lightning.R0
	    fromReg: Lightning.R1;
	    addI: Lightning.R1 to: Lightning.R1 int: (MethodContext allInstVarNames size + self method argsAndTempsCount) * self state sizeOfOop;
	    storeRegP: Lightning.R1
	    and: Lightning.R0
	    fromReg: Lightning.R2.
	"Here we:
	 1) fetch the context Normaly it is R0
	 2) fetch the object at TEMP_BASE + index offset in the context
	 3) push the object ins the context at sp of the context"
    ]
    
    pushLiteral: index [
	self state
	    fetchOop: Lightning.R1 fromObjectReg: Lightning.R0 at: (MethodContext indexOfInstVar: 'method');
	    fetchOop: Lightning.R1 fromOopReg: Lightning.R1 at: (JitMethod indexOfInstVar: 'literals').
	"continue"
	    
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
