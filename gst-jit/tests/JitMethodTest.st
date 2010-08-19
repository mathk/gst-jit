TestCase subclass: JitMethodTest [
    
    testHeader [
	| method |
	method := Jit.JitMethod new: 0.
	method buildHeaderDepth: 4 numArg: 4 numTemp: 3.
	self assert: method numArgs = 4.
	self assert: method numTemps = 3.
	self assert: method stackDepth = 16
    ]
]
