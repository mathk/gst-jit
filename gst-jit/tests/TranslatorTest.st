Object subclass: A [
    | a b c |
    
    test []
]

TestCase subclass: TranslatorTest [
    | node |
	
    setUp [
	node := (STInST.RBParser parseMethod: 'foo: r | e d | e := 12. d:= e')
	    checkScopeIn: A.
    ]

    testStoreInTemp [
	    
	| ligtningInterp |
	ligtningInterp := (Translator visitNode: node interpretOn: LightningInterpreter) interp.
	ligtningInterp state assemble
    ]

    testMethodTranslate [
	| method jitMethod |
	method := (STInST.RBParser parseMethod: 'foo: r | e d | e := 12. d:= e').
	jitMethod := method jitMethodIn: A.
	self assert: method selector = #foo:.
	self assert: jitMethod selector = #foo:.
	self assert: jitMethod literals = #(12)
	
    ]

    testCall [
	| method |
	method := (STInST.RBParser parseMethod: 'foo | e d | e := 12. d:= e') jitMethodIn: A.
	method jitState dump: 'assemblyTest'.
	A methodDictionary at: #foo put: method.
	A new foo
    ]

    testReturn [
	| method |
	method := (STInST.RBParser parseMethod: 'foo ^12') jitMethodIn: A.
	A methodDictionary at: #foo put: method.
	A new foo printNl
    ]

]
