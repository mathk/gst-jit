" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor subclass: ScopeChecker [
    | scope |

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

    acceptBlockNode: aBlockNode [
        <category: 'visitor-double dispatching'>
        
	| parentScope |
	parentScope := scope.
        scope := ContextScope attachedTo: scope.
        super acceptBlockNode: aBlockNode.
	scope := parentScope
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>

	scope := ContextScope attachedTo: scope.
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

    visitArgument: aVariableNode [
	<category: 'visiting'>

	scope bind: aVariableNode name
    ]
    
    visitTemporaries: aNodeCollection [
	<category: 'visiting'>
    ]
    
]
