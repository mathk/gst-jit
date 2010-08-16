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
	    literals: aMethodNode literals;
	    yourself.
	interp methodProlog.
	super acceptMethodNode: aMethodNode.
	aMethodNode lastIsReturn ifFalse: [interp pushReceiver; returnTop].
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

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	interp pushLiteral: aLiteralNode literalIndex
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	"Store the variable into the tempSlot of the context"
	self visitNode: anAssignmentNode value.
	anAssignmentNode variable slot emitStore: interp.
	interp pop.
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
