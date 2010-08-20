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
	ligtningInterp state assemble; dump: 'assemblTest'
    ]

    testMethodTranslate [
	| method |
	method := (STInST.RBParser parseMethod: 'foo: r | e d | e := 12. d:= e').
	method jitMethodIn: A.
	self assert: method selector = #foo:.
	
    ]

    testCall [
	| method |
	method := (STInST.RBParser parseMethod: 'foo | e d | e := 12. d:= e') jitMethodIn: A.
	method jitState printAddr.
	A methodDictionary at: #foo put: method.
	A new foo
    ]
]
