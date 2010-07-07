" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor  subclass: ScopeChecker [
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
        aBlockNode arguments do: [ :each |
            scope bind: each name ].
        scope := ContextScope attachedTo: scope.
        super acceptBlockNode: aBlockNode.
	scope := parentScope
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>

	scope := ContextScope attachedTo: scope.
	aMethodNode arguments do: [ :each |
	    scope bind: each name].
	super acceptMethodNode: aMethodNode
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>

	aSequenceNode temporaries do: [ :each |
	    scope bind: each name ].
	super acceptSequenceNode: aSequenceNode
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	scope assignOffset: aVariableNode
    ]
]
