
" Hey Emacs, I want -*- tab-width: 8; -*- "

Object subclass: Scope [	
    "I am a abstract scope."
    | parentScope bindings |

    Scope class >> attachedTo: parentScope [
	"Instanciate a new scope"
	<category: 'instance-creation'>
	^(self new) 
	    parentScope: parentScope;
	    yourself
    ]
    
    Scope class >> defaultSlotClass [
	^self subclassResponsibility
    ]
    
    defaultSlotClass [
	^self class defaultSlotClass
    ]
    
    bindings [
	<category: 'accessing'>

	^ bindings ifNil: [ bindings := Dictionary new ].
    ]

    parentScope [
	<category: 'accessing'>

	^ parentScope
    ]
	
    parentScope: aScope [
	<category: 'accessing'>
	parentScope := aScope
    ]
   
    hasSlotNamed: aString [
	<category: 'testing'>

	(self bindings includesKey: aString) ifTrue: [ ^ true ].
	^ self parentScope hasSlotNamed: aString
    ]
 
    lookup: name [
	^ self bindings at: name ifAbsent: [ self parentScope lookup: name ]
    ]
    
    bind: name [
	self bindings at: name put: ((self createSlot) name: name; yourself)
    ]

    createSlot [
	^ self defaultSlotClass for: self
    ]
]

Scope subclass: ContextScope [
    | usedBinding |
    "I am a scope for every bindings that is inside a context.
     That is arguments and temporaries"

    ContextScope class >> defaultSlotClass [
	^ContextSlot
    ]

    usedBinding [
	^usedBinding ifNil: [usedBinding := Set new]
    ]

    assignOffset: aVariableNode [
	"We only assign an offset to temp that it is used"
	(self lookup: aVariableNode name) assignOffset.
	self usedBinding add: aVariableNode name
    ]

    nextOffset [
	^self usedBinding size
    ]
]

Scope subclass: BehaviorScope [
    "I am a scope for bindings inside the class.
     This is instance and class variables"

    | behavior |

    BehaviorScope class >> for: aBehavior [
	^ (self attachedTo: (GlobalScope for: aBehavior environment))
	    behavior: aBehavior;
	    yourself
    ]

    BehaviorScope class >> defaultSlotClass [

        ^ BehaviorSlot
    ]
   
    behavior: aBehavior [
	behavior := aBehavior.

	behavior allInstVarNames do: [ :each | 
				self  bind: each asString ]
    ]
]

Scope subclass: GlobalScope [
    "I am a scope for binding outside of the class.
     Manly for class name and other global variable"
    | namespace |
   

    GlobalScope class >> for: aNamespace [
	^(self new)
	    namespace: aNamespace;
	    yourself
    ]

    namespace: aNamespace [
	namespace := aNamespace
    ]

    hasSlotNamed: aString [
        <category: 'testing'>

        ^ self bindings includesKey: aString
    ]

    lookup: name [
	<category: 'accessing'>
	
	| start |
	start := Smalltalk.

        (name subStrings: $.) do: [ :each |
            start := start at: each asSymbol ifAbsent: [ ^self error: 'binding not found: ', name  ] ].
        ^start
    ]
]

Object subclass: Slot [
    | name scope |

    UndefinedSlot := Slot new.
	
    Slot class >> for: scope [
	^(self new)
	    scope: scope;
	    yourself
    ]
    
    name [
	<category: 'accessing'>
	^name
    ]
    
    name: aString [
	<category: 'accessing'>
	name := aString
    ]
    
    scope [
	<category: 'accessing'>
	^scope
    ]
    
    scope: aScope [
	<category: 'accessing'>
	scope := aScope
    ]

    assignOffset [
	"For those who need to capture an offset"
    ]
]
    
Slot subclass: ContextSlot [
    "I am a slote inside context scope"
    | offset |

    emitPush: anInterpreter [
	anInterpreter pushTemp: self index
    ]
    
    offset [
	offset
    ]
    
    assignOffset [
	offset := self scope nextOffset
    ]
]

Slot subclass: BehaviorSlot [
    | binding |

    binding [
	^binding
    ]

    binding: aBinding [
	binding := aBinding
    ]
]

Smalltalk.Behavior extend [
    scope [
	^ Jit.BehaviorScope for: self
    ]
]
