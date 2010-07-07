" Hey Emacs, I want -*- tab-width: 8; -*- "

"This should be turn into unit test"

Object subclass: A [
	
	a [
		| foo bar |
		foo := 45.
		bar := 33.
	]
]

Eval [
    PackageLoader fileInPackage: 'Jit'.
    aNode := STInST.RBBracketedMethodParser parseMethod: (A >> #a) methodSourceString.
    aVisitor := Jit.ScopeChecker visitMethod: aNode in: A.
	(aVisitor scope bindings at: 'bar') inspect
]



