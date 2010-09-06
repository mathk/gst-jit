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

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aCascadeNode receiver.
	aCascadeNode messages allButLastDo: [:node |
	    interp dup.
	    self visitNode: node
	].
	self visitNode: aCascadeNode messages last
    ]

    acceptAssignmentNode: anAssignmentNode [
	<category: 'visitor-double dispatching'>
	"Store the variable into the tempSlot of the context"
	self visitNode: anAssignmentNode value.
	anAssignmentNode variable slot emitStore: interp.
	interp pop
    ]

    acceptArrayConstructorNode: anArrayNode [
	
	interp pushLiteral: anArrayNode literalArrayIndex.
	interp pushLiteral: anArrayNode literalSizeIndex.
	interp send: anArrayNode literalNewColonIndex numArg: 1.
	
	anArrayNode body statements doWithIndex: [:each :i |
	    self visitNode: each.
	    interp popIntoInstanceVariable: i
	]
    ]

    acceptSimpleMessageNode: aMessageNode [
	super acceptSimpleMessageNode: aMessageNode.
	interp send: aMessageNode literalSelectorIndex numArgs: aMessageNode selector numArgs
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
	self emitInlineIfOneArg: aMessageNode jumpIf: false
    ]

    acceptInlineIfFalseMessage: aMessageNode [
	self emitInlineIfOneArg: aMessageNode jumpIf: true
    ]

    acceptInlineIfFalseTrueMessage: aMessageNode [
	self emitInlineIfTwoArg: aMessageNode jumpIf: true
    ]

    acceptInlineIfTrueFalseMessage: aMessageNode [
	self emitInlineIfTwoArg: aMessageNode jumpIf: false
    ]

    emitInlineIfOneArg: aMessageNode jumpIf: bool [
	| end |
	self visitNode: aMessageNode receiver.
	end := interp uniqueLabel: #endIf.
	interp jumpTo: end if: bool.
	self visitNode: aMessageNode arguments first.
	interp label: end
    ]

    emitInlineIfTwoArg: aMessageNode jumpIf: bool [
	| end else |
	self visitNode: aMessageNode receiver.
	end := interp uniqueLabel: #endIf.
	else := interp uniqueLabel: #elseIf.
	interp jumpTo: else if: bool.
	self visitNode: aMessageNode arguments first.
	interp jumpTo: end.
	interp label: else.
	self visitNode: aMessageNode arguments second.
	interp label: end
    ]

    visitArgument: aVariableNode [
	<category: 'visiting'>
    ]
 ]
