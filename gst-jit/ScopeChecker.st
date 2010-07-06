" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor  subclass: ScopeChecker [
    | bindings |

    initialize [
	<category: 'initialize-release'>
	"Initialize the scope. First binding should be self"
    ]

    acceptClassNode: aClass [
	<category: 'visitor-double dispatching'>
    ]
]
