STInST.RBProgramNodeVisitor subclass: AbstractVisitor [
    
    acceptMessageNode: aMessageNode [
	<category: 'visitor-double dispatching'>
	aMessageNode isInlineIfTrue ifTrue: [^self acceptInlineIfTrueMessage: aMessageNode].
	aMessageNode isInlineIfFalse ifTrue: [^self acceptInlineIfFalseMessage: aMessageNode].
	aMessageNode isInlineIfTrueFalse ifTrue: [^self acceptInlineIfTrueFalseMessage: aMessageNode].
	aMessageNode isInlineIfFalseTrue ifTrue: [^self acceptInlineIfFalseTrueMessage: aMessageNode].
	super acceptMessageNode: aMessageNode 
    ]

    acceptInlineIfTrueMessage: aMessageNode [
	<category: 'visitor-double dispatching'>
	self acceptInlineIf: aMessageNode
    ]

    acceptInlineIfTrueFalseMessage: aMessageNode [
	<category: 'visitor-double dispatching'>
	self acceptInlineIf: aMessageNode
    ]

    acceptInlineIfFalseMessage: aMessageNode [
	<category: 'visitor-double dispatching'>
	self acceptInlineIf: aMessageNode
    ]

    acceptInlineIfFalseTrueMessage: aMessageNode [
	<category: 'visitor-double dispatching'>
	self acceptInlineIf: aMessageNode
    ]

    acceptInlineIf: aMessageNode [
	<category: 'visitor-double dispatching'>
	self visitNode: aMessageNode receiver.
	aMessageNode arguments do: [:each | self acceptInlineBlock: each]
    ]

    acceptInlineBlock: aBlockNode [
	<category: 'visitor-double dispatching'>
	self visitArguments: aBlockNode arguments.
	self visitNode: aBlockNode body
    ]

]
