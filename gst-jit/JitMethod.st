" Hey Emacs, I want -*- tab-width: 8; -*- "

CompiledMethod subclass: JitMethod [
    | jitState |

    <shape: #byte>

    buildHeaderDepth: depth numArgs: args numTemp: temps [
	| maxDepth|
	maxDepth := depth + args + temps
	args > 31 ifTrue: [self error: 'Method can''t take more than 31 parameter'].
	temps > 63 ifTrue: [self error: 'Method can''t have more than 63 temps'].
	maxDepth > 63 ifTrue: [self error: 'Method can''t have a call stack with more than 63 of depth'].
	
	header := 7 bitShift: 16.
	header := (header + temps) bitShift: 6.
	header := (header + maxDepth) bitShift: 5.
	header := header + args.
    ]


    valueWithReceiver: object withArguments: args [
	"Initialize the context with the receiver "
    ]
    
    activationRecord: context withArguments: args [
	"Primitive call"
    ]

    jitState: aState [
	jitState := aState
    ]

    literals: anArray [
	literals := anArray
    ]
    
    jitState [
	^jitState
    ]
]
