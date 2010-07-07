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
	^ self bindings at: name put: self createSlot
    ]

    createSlot [
	^ self defaultSlotClass for: self
    ]
]

Scope subclass: ContextScope [
    "I am a scope for every bindings that is inside a context.
     That is arguments and temporaries"

    ContextScope class >> defaultSlotClass [
	^ContextSlot
    ]
    
    createSlot [
	<category: 'private creation'>
	^self defaultSlotClass for: self 
			       at: self bindings size
    ]
]

Scope subclass: BehaviorScope [
    "I am a scope for bindings inside the class.
     This is instance and class variables"

    | behavior |

    BehaviorScope class >> for: aBehavior [
	^ (self attachedTo: GlobalScope uniqueInstance)
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

    uniqueInstance := nil.

    GlobalScope class >> new [
	self error: 'This is a singleton use #uniqueInstance'
    ]

    GlobalScope class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := GlobalScope basicNew ]
    ]

    hasSlotNamed: aString [
        <category: 'testing'>

        ^ self bindings includesKey: aString
    ]

    lookup: name [
	<category: 'accessing'>

        ^ self bindings at: name
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
]
    
Slot subclass: ContextSlot [
    "I am a slote inside context scope"
    | offset |

    ContextSlot class >> for: aScope at: anOffset [
	^(self for: aScope)
	    offset: anOffset
    ]

    emitPush: anInterpreter [
	anInterpreter pushTemp: self index
    ]
    
    offset [
	offset
    ]

    offset: anOffset [
	offset := anOffset
    ]
]

Slot subclass: BehaviorSlot [
]

Smalltalk.Behavior extend [
    scope [
	^ Jit.BehaviorScope for: self
    ]
]
