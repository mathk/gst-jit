" Hey Emacs, I want -*- tab-width: 8; -*- "
AbstractVisitor subclass: Translator [
    | interp interpClass literals |
		
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

    setupInterpFor: aNode [
	interp := (interpClass onClass: aNode jitCompiledClass)
	    literals: aNode literals;
	    numArg: aNode numArg;
	    numTemp: aNode numTemp;
	    yourself
    ]

    acceptBlockNode: aBlockNode [
	<category: 'visitor-double dispatching'>

	| previousLiterals blockMethod |
	previousLiterals := literals.
	aBlockNode properties at: #previousInterp put: interp.
	self setupInterpFor: aBlockNode.
	literals := aBlockNode literals.
	interp prolog.
	super acceptBlockNode: aBlockNode.
	interp blockEpilog: aBlockNode cleanFlag.
	literals := previousLiterals.
	blockMethod := interp method.
	blockMethod flags = 0 
            ifTrue: [
		| block |
		block := BlockClosure 
                    block: blockMethod 
	            receiver: aBlockNode scope scopeClass 
	            outerContext: nil.
		literals addLast: block.
		interp pushLiteral: (literals indexOf: block)
	    ]
	    ifFalse: [
		literals addLast: blockMethod.
		interp pushLiteral: (literals indexOf: blockMethod).
		interp makeDirtyBlock.
	    ].
	interp := aBlockNode properties at: #previousInterp
    ]
 
    acceptMethodNode: aMethodNode [
	<category: 'visitor-double dispatching'>
	self setupInterpFor: aMethodNode.
	literals := aMethodNode literals.
	interp prolog.
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
	self visitArguments: aSequenceNode temporaries.
	aSequenceNode statements 
            do: [:each | self visitNode: each]
	    separatedBy: [interp pop]

    ]

    acceptLiteralNode: aLiteralNode [
	<category: 'visitor-double dispatching'>
	interp pushLiteral: aLiteralNode literalIndex
    ]

    acceptCascadeNode: aCascadeNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aCascadeNode messages first receiver.
	aCascadeNode messages allButLast do: [:node |
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
	self acceptInlineBlock: aMessageNode arguments first.
	interp label: end
    ]

    emitInlineIfTwoArg: aMessageNode jumpIf: bool [
	| end else |
	self visitNode: aMessageNode receiver.
	end := interp uniqueLabel: #endIf.
	else := interp uniqueLabel: #elseIf.
	interp jumpTo: else if: bool.
	self acceptInlineBlock: aMessageNode arguments first.
	interp jumpTo: end.
	interp label: else.
	self acceptInlineBlock: aMessageNode arguments second.
	interp label: end
    ]

    visitArgument: aVariableNode [
	<category: 'visiting'>
    ]
 ]
