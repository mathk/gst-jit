" Hey Emacs, I want -*- tab-width: 8; -*- "
AbstractVisitor subclass: Translator [
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
	    literals: aMethodNode literals;
	    numArg: aMethodNode numArg;
	    numTemp: aMethodNode numTemp;
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
    
    acceptReturnNode: aReturnNode [
	super acceptReturnNode: aReturnNode.
	aReturnNode scope emitReturn: interp
    ]

    acceptVariableNode: aVariableNode [
	<category: 'visitor-double dispatching'>
	"Push the variable on the stack context"
	aVariableNode slot emitPush: interp
    ]

    acceptInlineIfTrueMessage: aMessageNode [
	| endLabel |
	self visitNode: aMessageNode receiver.
	endLabel := interp uniqueLabel: #endIf.
	interp jumpTo: endLabel if: false.
	self visitNode: aMessageNode arguments.
	interp label: endLabel
	
    ]

    visitArgument: aVariableNode [
	<category: 'visiting'>
    ]
 ]
