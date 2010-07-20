Object subclass: A [
    | a b c |
]

TestCase subclass: TranslatorTest [
	| node |
	
	setUp [
		node := (STInST.RBParser parseMethod: 'foo | e | e := 12')
		             checkScopeIn: A.
	]

	testStoreInTemp [
		
		| ligtningInterp |
		ligtningInterp := LightningInterpreter new.
		Translator visitNode: node interpret: ligtningInterp.
		ligtningInterp state assemble
		
	]
]
