" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor  subclass: ScopeChecker [
    | scope |

    ScopeChecker class >> visiteMethod: aNode in: aClass [
	^(self new) 
	    scope: aClass scope;
	    yourself
    ]

    scope: aScope [
	<category: 'accessing'>
	scope := aScope
    ]

    acceptClassNode: aClass [
	<category: 'visitor-double dispatching'>
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	scope := ContextScope attachedTo: scope.
	super acceptMethodNode: aMethodNode
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	aSequenceNode temporaries do: [:each |
	    scope bind: each name
	].
	super acceptSequenceNode: aSequenceNode
    ]
]
