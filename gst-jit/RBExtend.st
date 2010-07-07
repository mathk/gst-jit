" Hey Emacs, I want -*- tab-width: 8; -*- "

STInST.RBVariableNode extend [
    slot [
	^self properties at: #slot ifAbsent:[
	    self error: 'You need to pass throw the ScopeChecker']
    ]

    slot: aSlot [
	self properties at: #slot put: aSlot
    ]
]
