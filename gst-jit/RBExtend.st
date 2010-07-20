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


STInST.RBProgramNode extend [
     | properties |

    <comment: 'Instance Variables:
    properties    <Dictionary>    the list of key value for annotation purpose'>

    properties [
	<category: 'accessing'>
	^properties ifNil: [properties := Dictionary new].
    ]
 ]

STInST.RBMethodNode extend [
    
    checkScopeIn: aBehavior [
	ScopeChecker visitMethod: self in: aBehavior.
    ]
]
