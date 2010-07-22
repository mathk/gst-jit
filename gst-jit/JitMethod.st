" Hey Emacs, I want -*- tab-width: 8; -*- "

Object subclass: JitMethod [
    | argsCount tempCount jitState stackCount |
	
    valueWithReceiver: object withArguments: args [
	args size ~= argsCount ifTrue:[
	    self error: 'Wrong number of argument'
	].
	context := MethodContext new: argsCount + tempCount + stackCount.
	"Initialize the context with the receiver "
    ]
    
    activationRecord: context withArguments: args [
	"Primitive call".
    ]

    argsCount: aInt [
	argsCount := aInt
    ]

    argsCount [
	^argsCount
    ]

    tempCount: aInt [
	tempCount := aInt
    ]

    tempCount [
	^tempCount
    ]
]
