Object subclass: A [
    | a b c |
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
	self assert: method selector = #foo:
	   
    ]
]
