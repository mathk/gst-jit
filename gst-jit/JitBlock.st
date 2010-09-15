

CompiledBlock subclass: JitBlock [
    | jitState |
    <shape: #byte>

    buildHeaderDepth: depth numArg: args numTemp: temps cleanFlags: cleanFlags [
	maxDepth := depth + args + temps.
	"For detail see libgst/comp.c"
	maxDepth := maxDepth + (1 bitShift: 2"DEPTH_SCALE") - 1.
	maxDepth := maxDepth bitShift: -2"DEPTH_SCALE".
	maxDepth :=  maxDepth + 1.
	args > 31 ifTrue: [self error: 'Block can''t take more than 31 parameter'].
	temps > 31 ifTrue: [self error: 'Block can''t have more than 31 temps'].
	maxDepth > 63 ifTrue: [self error: 'Block can''t have a call stack with more than 63 of depth'].
	header := (((args bitShift: 5) + temps) bitShift: 6) + maxDepth.
	header := (header bitShift: 1) + 1.
	header := header bitShift: 8 + 5.
	header := header + cleanFlags
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

    parentMethod: aCompiledMethod [
	method := aCompiledMethod
    ]
]
