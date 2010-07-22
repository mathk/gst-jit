Object subclass: A [
    | a b c |
]

TestCase subclass: TranslatorTest [
	| node |
	
	setUp [
		node := (STInST.RBParser parseMethod: 'foo | e d | e := 12. d:= e')
		             checkScopeIn: A.
	]

	testStoreInTemp [
		
		| ligtningInterp |
		Translator visitNode: node interpret: LightningInterpreter.
		ligtningInterp state assemble; dump: 'assemblTest'
	]
]
