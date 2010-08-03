" Hey Emacs, I want -*- tab-width: 8; -*- "

Object subclass: JitMethod [
    | argsAndTempsCount jitState stackCount |
    
    valueWithReceiver: object withArguments: args [
	| context |
	context := MethodContext new: argsAndTempsCount + stackCount.
	"Initialize the context with the receiver "
    ]
    
    activationRecord: context withArguments: args [
	"Primitive call"
    ]
	
    argsAndTempsCount: aInt [
	argsAndTempsCount := aInt
    ]
    
    argsAndTempsCount [
	^argsAndTempsCount
    ]
    
]
