" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor  subclass: ScopeChecker [
    | scope |

    ScopeChecker class >> visiteMethod: aNode in: aClass [
	
    ]

    initialize [
	<category: 'initialize-release'>
	"Initialize the scope. First binding should be self"
	scope ":= *continue here*" 
    ]

    acceptClassNode: aClass [
	<category: 'visitor-double dispatching'>
    ]
]
