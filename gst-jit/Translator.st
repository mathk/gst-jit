" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor subclass: Translater [
    | interpreter |

    Translater class >> visitNode: aNode interpret: anInterpreter [
	<category: 'instance-creation'>
	^(self new)
	     interpreter: anInterpreter;
	     visitNode: aNode;
	     yourself
    ]

    interpreter: anInterpreter [
	interpreter := anInterpreter
    ]

    initialize [
	<category: 'initialize-release'>
    ]

    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	
	" Prepare the context and initialize it:
	    - call activate_new_context
	    - call prepare_context "
	super acceptMethodNode: aMethodNode.

	jiState
	    activateNewContext;
	    prepareContext
    ]

    acceptAssignmentNode: aAssignmentNode [
	 <category: 'visitor-double dispatching'>
	 super acceptAssignmentNode: aAssignmentNode
    ]

    acceptSequenceNode: aSequenceNode [
	<category: 'visitor-double dispatching'>
	super acceptSequenceNode: aSequenceNode
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	"Store the variable into the tempSlot of the context"
	self visitNode: anAssignmentNode value
	anAssignmentNode variable slot emitStore: interpreter
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	"Push the variable on the stack context"
	aVariableNode slot emitPush: interpreter "Fix me how to get the slot"
    ]
 ]
