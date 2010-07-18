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
    | state method stackCount currentStackCount |

    LightningInterpreter class >> new [
	^(super new)
	    stackCount: 0;
	    yourself
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
	^state isNil ifTrue: [state := Lightning.CJitState new]
    ]

    methodProlog [
	state moveI: Lightning.R0 fromP: state primGstThisContextOOP
	
	"Fetch the JitMethod and put it in the R1 register"
    ]

    methodEpilog [
	state ret
	"Free context and return to the caller ..."
    ]

    pop [
	self popCount
    ]

    pushTemp: anOffset [
	self pushCount
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
