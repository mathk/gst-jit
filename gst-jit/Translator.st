" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBProgramNodeVisitor sublcass: Translater [
    | jitState |
    initialize [
	<category: 'initialize-release'>
	jitState := Lightning.CJitState new
    ]

    acceptMethodNode: aMethodNode [
	 <category: 'visitor-double dispatching'>
	 super acceptMethodNode: aMethodNode
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
	super acceptAssignmentNode: anAssignmentNode
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	"Push the variable on the stack context" 
    ]
 ]
