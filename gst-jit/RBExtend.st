" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBVariableNode extend [
    
    slot [
	^self properties at: #slot ifAbsent:[
	    self error: 'You need to pass throw the ScopeChecker']
    ]

    slot: aSlot [
	self properties at: #slot put: aSlot
    ]
]

STInST.RBMethodNode extend [

    scope [
	^self properties at: #scope ifAbsent:[
	    self error: 'You need to pass throw the ScopeChecker']
    ]

    scope: aScope [
	self properties at: #scope put: aScope
    ]

    literals [
	^self properties at: #literals ifAbsentPut:[OrderedSet new]
    ]
    
    checkScopeIn: aBehavior [
	Jit.ScopeChecker visitMethod: self in: aBehavior
    ]

    translate [
	^Jit.Translator visitNode: self interpretOn: LightningInterpreter.
    ]

    jitMethodIn: aBehavior [
	| method |
	self checkScopeIn: aBehavior.
	method := self translate interp method.
	method descriptor: MethodInfo new.
	method selector: self selector.
	"method methodClass: aBehavior."
	^method
    ]

    numTemp [
        ^self scope usedBinding size - self arguments size
    ]

    numArg [
        ^self arguments size
    ]

    isInline [
	
    ]
]


STInST.RBProgramNode extend [
     | properties |

    <comment: 'Instance Variables:
    properties    <Dictionary>    the list of key value for annotation purpose'>

    properties [
	<category: 'accessing'>
	^properties ifNil: [properties := Dictionary new].
    ]

    scope [
	^self parent scope
    ]
 ]

STInST.RBValueNode extend [
    
    literalIndex [
	^self properties at: #literalIndex ifAbsent:[
	    self error: 'You need to pass throw the ScopeChecker']
    ]

    literalIndex: i [
	self properties at: #literalIndex put: i
    ]
]

STInST.RBBlockNode extend [
    
    isInline [
	(parent isMessage and: [parent isInline]) ifTrue: [^ true].
	^ false
    ]
]

STInST.RBMessageNode extend [
    
    isInline [
	<category: 'testing'>
	self isInlineIfTrue ifTrue: [^true].
	self isInlineIfTrueFalse ifTrue: [^true].
	self isInlineIfFalse ifTrue: [^true].
	self isInlineIfFalseTrue ifTrue: [^true].
	^false
    ]
    
    isInlineIfTrue [
	<category: 'testing'>
	self selector = #ifTrue: ifFalse: [^false].
	^self isInlineIfOneArg
    ]

    isInlineIfFalse [
	<category: 'testing'>
	self selector = #ifFalse: ifFalse: [^false].
	^self isInlineIfOneArg
    ]

    isInlineIfTrueFalse [
	<category: 'testing'>
	self selector = #ifTrue:ifFalse: ifFalse: [^false].
	^self isInlineIfTwoArg
    ]

    isInlineIfFalseTrue [
	<category: 'testing'>
	self selector = #ifFalse:ifTrue: ifFalse: [^false].
	^self isInlineIfTwoArg
    ]

    isInlineIfOneArg [
	<category: 'private testing'>
	^self arguments first isBlock and: [
	    self arguments first arguments isEmpty ]
    ]

    isInlineIfTwoArg [
	<category: 'private testing'>
	^(self arguments allSatisfy: [:node | node isBlock and: [node arguments isEmpty]])

    ]
]
