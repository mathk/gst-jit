" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor  subclass: ScopeChecker [
    | scope |

    ScopeChecker class >> visiteMethod: aNode in: aClass [
	^(self new) 
	    scope: aClass scope;
	    yourself
    ]

    initialize [
	<category: 'initialize-release'>
	"Initialize the scope. First binding should be self"
	scope ":= *continue here*" 
    ]

    scope: aScope [
	<category: 'accessing'>
	scope := aScope
    ]

    acceptClassNode: aClass [
	<category: 'visitor-double dispatching'>
    ]
]
