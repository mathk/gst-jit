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

    scopeClass [
	^self parentScope scopeClass
    ]

    isGlobal [
	<category: 'testing'>
	^false
    ]

    isBlock [
	<category: 'testing'>
	^false
    ]
    
    isBehavior [
	<category: 'testing'>
	^false
    ]

    isContext [
	<category: 'testing'>
	^false
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

    distanceTo: aScope [
	self = aScope ifTrue: [^0].
	^(self parentScope distanceTo: aScope) + 1
    ]
]

Scope subclass: ContextScope [
    | usedBinding selfSlot |
    "I am a scope for every bindings that is inside a context.
     That is arguments and temporaries"

    ContextScope class >> defaultSlotClass [
	^ContextSlot
    ]

    selfSlot [
	^selfSlot ifNil: [selfSlot := SelfSlot for: self]
    ]

    usedBinding [
	^usedBinding ifNil: [usedBinding := Set new]
    ]

    bindArgument: name [
	self bindings at: name put: ((self createReadonlySlot) name: name; yourself)
    ]

    createReadonlySlot [
	^ (self defaultSlotClass for: self) readonly: true; yourself
    ]

    assignOffset: aVariableNode [
	| slot |
	"We only assign an offset to temp that it is used"
	slot := (self lookup: aVariableNode name)
	    assignOffset;
	    yourself.
	aVariableNode slot: slot.
	self = slot scope ifTrue: [
	    self usedBinding add: aVariableNode name ]
    ]

    emitPushSelf: anInterpreter [
	anInterpreter pushReceiver
    ]

    nextOffset [
	^self usedBinding size
    ]

    isContext [
	<category: 'testing'>
	^true
    ]

    emitReturn: anInterpreter [
	anInterpreter returnTop
    ]

    lookup: name [
	name = 'self' ifTrue: [^self selfSlot].
	^ super lookup: name
    ]
]

ContextScope subclass: BlockScope [
    | blockNode |

    emitReturn: anInterpreter [
	anInterpreter returnBlockTop
    ]

    blockNode: aBlockNode [
	blockNode := aBlockNode
    ]

    cleanFlag: anInteger [
	blockNode cleanFlag: anInteger.
	self parentScope isBlock ifTrue: [
	    self parentScope cleanFlag: anInteger - 1
	]
    ]

    isBlock [
	^true
    ]

    emitPushSelf: anInterpreter [
	super emitPushSelf: anInterpreter.
	self cleanFlag: 1
    ]

    assignOffset: aVariableNode [
	| slot |
	"We only assign an offset to temp that it is used"
	super assignOffset: aVariableNode.
	slot := (self lookup: aVariableNode name).
	(slot scope isContext and: [slot scope ~= self])
            ifTrue: [
	        slot := BlockSlot for: self outerSlot: slot
	    ].
	aVariableNode slot: slot.
	
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

    scopeClass [
	^behavior
    ]

    isBehavior [
	<category: 'testing'>
	^true
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

    isGlobal [
	<category: 'testing'>
	^true
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
            start := start at: each asSymbol ifAbsent: [ ^SystemExceptions.NotFound signalOn: name what: 'binding'  ] ].
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
    
    isBehavior [
	<category: 'testing'>
	^false
    ]

    isContext [
	<category: 'testing'>
	^false
    ]

    isBlock [
	<category: 'testing'>
	^false
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
    | offset readonly |

    readonly: aBool [
	<category: 'accessing'>
	readonly := aBool
    ]

    readonly [
	<category: 'accessing'>
	^readonly ifNil: [readonly := false]
    ]

    emitPush: anInterpreter [
	anInterpreter pushTemp: self offset
    ]

    emitStore: anInterpreter [
	self readonly ifTrue: [ SystemExceptions.ReadOnlyObject signalOn: self reason: 'arguments are readonly' ].
	anInterpreter storeIntoTemp: self offset
    ]
    
    offset [
	^offset
    ]
    
    assignOffset [
	offset ifNil: [
	    offset := self scope nextOffset]
    ]

    isContext [
	<category: 'testing'>
	^true
    ]
]

Slot subclass: SelfSlot [

    emitPush: anInterpreter [
	self scope emitPushSelf: anInterpreter
    ]
]

Slot subclass: BlockSlot [
    "I am a slot the designate an outer slot from the home context"
    | outerSlot |

    BlockSlot class >> for: scope outerSlot: aSlot [
	^(self for: scope) outerSlot: aSlot; yourself
    ]

    outerSlot: aSlot [
	outerSlot := aSlot
    ]

    scopeDistance [
	| distance |
	distance := (self scope distanceTo: outerSlot scope).
	self scope cleanFlag: distance + 1.
	^distance
    ]

    emitPush: anInterpreter [
	anInterpreter pushTemp: self offset fromScopeAt: self scopeDistance.
    ]

    emitStore: anInterpreter [
	self readonly ifTrue: [ SystemExceptions.ReadOnlyObject signalOn: self reason: 'arguments are readonly' ].
	anInterpreter storeIntoTemp: self offset fromScopeAt: self scopeDistance.
    ]
    
    isBlock [
	<category: 'testing'>
	^true
    ]

    offset [
	^outerSlot offset
    ]
]

Slot subclass: BehaviorSlot [
    | binding |

    binding [
	^binding
    ]

    isBehavior [
	<category: 'testing'>
	^true
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
