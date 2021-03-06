" Hey Emacs, I want -*- tab-width: 8; -*- "

AbstractVisitor subclass: ScopeChecker [
    | scope literals |

    ScopeChecker class >> visitMethod: aNode in: aClass [
	^(self new) 
	    scope: aClass scope;
	    visitNode: aNode;
	    yourself
    ]
    
    scope [
	<category: 'accessing'>

	^ scope
    ]
    
    scope: aScope [
	<category: 'accessing'>

	scope := aScope
    ]

    acceptClassNode: aClass [
	<category: 'visitor-double dispatching'>
    ]

    accpetArrayConstructorNode: anArrayNode [
	literals addLast: #new:.
	literals addLast: Array binding.
	anArrayNode literalArrayIndex: (literals indexOf: Array binding)
	anArrayNode literalNewColonIndex: (literals indexOf: #new:).
	super accpetArrayConstructorNode: anArrayNode
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	scope := ContextScope attachedTo: scope.
	literals := aMethodNode literals.
	super acceptMethodNode: aMethodNode.
	aMethodNode scope: scope
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>

	scope assignOffset: aVariableNode
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	self visitTemporaries: aSequenceNode temporaries.
	aSequenceNode statements do: [:each | self visitNode: each]
    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	literals addLast: aLiteralNode value.
	aLiteralNode literalIndex: (literals indexOf: aLiteralNode value)
    ]

    acceptSimpleMessageNode: aMessageNode [
	literals addLast: aMessageNode selector.
	aMessageNode literalSelectorIndex: (literals indexOf: aMessageNode selector).
	super acceptSimpleMessageNode: aMessageNode
    ]

    acceptBlockNode: aBlockNode [
	scope := BlockScope attachedTo: scope.
	scope blockNode: aBlockNode.
	literals := aBlockNode literals.
	super acceptBlockNode: aBlockNode.
	aBlockNode scope: scope.
	scope := scope parentScope
    ]

    acceptInlineBlock: aBlockNode [
	<category: 'visitor-double dispatching'>
	aBlockNode scope: scope.
	self visitTemporaries: aBlockNode arguments.
	aBlockNode arguments do: [:each | self visitNode: each ].
	self visitNode: aBlockNode body
    ]

    visitArgument: aVariableNode [
	<category: 'visiting'>
	scope bindArgument: aVariableNode name.
	super visitArgument: aVariableNode
    ]
    
    visitTemporaries: aNodeCollection [
	<category: 'visiting'>
	aNodeCollection do: [:each | self visitTemporarie: each]
    ]

    visitTemporarie: aVariableNode [
	<category: 'visiting'>
	scope bind: aVariableNode name
    ]
    
]
