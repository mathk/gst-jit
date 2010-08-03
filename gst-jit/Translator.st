" Hey Emacs, I want -*- tab-width: 8; -*- "
STInST.RBProgramNodeVisitor subclass: Translator [
    | interp interpClass |
		
    Translator class >> visitNode: aNode interpretOn: interpreterClass  [
	<category: 'instance-creation'>
	^(self new)
	     interpClass: interpreterClass;
	     visitNode: aNode;
	     yourself.
    ]

    interpClass: aClass [
	interpClass := aClass.
    ]

    initialize [
	<category: 'initialize-release'>
    ]

    interp [
	^interp
    ]
 
    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	interp := interpClass new
	    initArgsAnTempsCount: aMethodNode scope usedBinding size;
	    yourself.
	interp methodProlog.
	super acceptMethodNode: aMethodNode.
	interp methodEpilog
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
	self visitNode: anAssignmentNode value.
	anAssignmentNode variable slot emitStore: interp
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	"Push the variable on the stack context"
	aVariableNode slot emitPush: interp
    ]

    visitArgument: aVariableNode [
	<category: 'visiting'>
    ]
 ]
