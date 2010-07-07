Object subclass: A [
    | a b c |
]

TestCase subclass: BehaviorScopeTest [

    testBehaviorScope [
	<category: 'testing'>

	| scope |
	scope := A scope.
	self assert: (scope lookup: 'a') scope == scope.
	self assert: (scope lookup: 'b') scope == scope.
	self assert: (scope lookup: 'c') scope == scope
    ]
]

TestCase subclass: ScopeTest [

]

TestCase subclass: ScopeCheckerTest [

    testSimpleScope [
	<category: 'testing'>

	| checker |
	checker := ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo a send: b') in: A.
	self assert: (checker scope hasSlotNamed: 'a').
	self assert: (checker scope hasSlotNamed: 'b').
	self assert: (checker scope hasSlotNamed: 'c').

	checker := ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo: d a send: b') in: A.
	self assert: (checker scope hasSlotNamed: 'a').
	self assert: (checker scope hasSlotNamed: 'b').
	self assert: (checker scope hasSlotNamed: 'c').
	self assert: (checker scope hasSlotNamed: 'd').

        checker := ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo: d | e f | a send: b') in: A.
        self assert: (checker scope hasSlotNamed: 'a').
        self assert: (checker scope hasSlotNamed: 'b').
        self assert: (checker scope hasSlotNamed: 'c').
        self assert: (checker scope hasSlotNamed: 'd').
        self assert: (checker scope hasSlotNamed: 'e').
        self assert: (checker scope hasSlotNamed: 'f').

	checker := ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo: d | e f | a send: b. [ :x :y | | l s | ] ') in: A.
    ]
]

