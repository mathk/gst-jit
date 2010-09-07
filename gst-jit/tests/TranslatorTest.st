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
	A methodDictionary at: #foo put: method.
	A new foo
    ]

    testReturn [
	| method |
	method := (STInST.RBParser parseMethod: 'foo ^12') jitMethodIn: A.
	A methodDictionary at: #foo put: method.
	self assert: A new foo = 12
    ]

    testInlineIf [
	| method |
	method := (STInST.RBParser parseMethod: 'foo true ifTrue: [ ^12]. ^34') jitMethodIn: A.
	A methodDictionary at: #foo put: method.
	self assert: A new foo = 12.
	method := (STInST.RBParser parseMethod: 'foo false ifTrue: [ ^12]. ^34') jitMethodIn: A.
	A methodDictionary at: #foo put: method.
	self assert: A new foo = 34.
	method := (STInST.RBParser parseMethod: 'foo false ifFalse: [ ^12]. ^34') jitMethodIn: A.
	A methodDictionary at: #foo put: method.
	self assert: A new foo = 12.
	method := (STInST.RBParser parseMethod: 'foo false ifTrue: [ ^12 ] ifFalse: [^42]') jitMethodIn: A.
	A methodDictionary at: #foo put: method.
	self assert: A new foo = 42
    ]

    testSend [
	| method |
	method := (STInST.RBParser parseMethod: 'foo ^6 raisedTo: 2') jitMethodIn: A.
	A methodDictionary at: #foo put: method.
	method literals printNl.
	method jitState dump: 'assemblyTest'.
	A new foo printNl.
	"self assert: A new foo = 36 "" NEED the return code"
    ]
]
