" Hey Emacs, I want -*- tab-width: 8; -*- "

Object subclass: Interpreter [
    "I am an abstract interpreter.
     I interpret low level instruction like push pop ..."

    jumpTo: [
    ]
   
    popStackTop [
    ]
 
    pushLiteral [
    ]

    pushInstanceVariable: anIndex [
    ]

    pushTemporary: anIndex [
	self subclassResponssability
    ]

    returnFromContext [
    ]

    returnFromMethod [
    ]

    send [
    ]

    storeInstanceVariable: anIndex [
	self subclassResponssability
    ]

    storeTemporaryVariable: anIndex [
	self subclassResponssability
    ]
]

Interpreter subclass: LightningInterpreter [
    | state |

    state [
	^state isNil ifTrue: [state := Lightning.CJitState new]
    ]

    pushTemp: index [
	state move 
	"Here we:
	 1) fetch the context
	 2) fetch the object at TEMP_BASE + index offset in the context
	 3) push the object ins the context at sp of the context"
    ]
]
