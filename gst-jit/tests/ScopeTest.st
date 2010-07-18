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
	self shouldnt: [ checker scope hasSlotNamed: 'd' ] raise: MessageNotUnderstood.
	self should: [ checker scope lookup: 'd' ] raise: SystemExceptions.NotFound.

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

	checker := ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo: d | e f | 
	    a send: b.
	    [ :x :y | x msg. y msg ] ') in: A.

	checker := ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo: d | e f | 
	    a send: b. 
	    [ :x :y | | l s | l msg. s msg. x msg. y msg ] ') in: A.

	self should: [
	    ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo: d | e f | 
		a send: b. 
		[ :x :y | | l s | 
		    [ :l :s | l msg. s msg. x msg. y msg ]  ]. 
		[ x msg. l msg ]') in: A ] raise: Exception
    ]

    testTemparoary [
	<category: 'testing'>

	| scope |
	scope := (ScopeChecker visitMethod: (STInST.RBParser parseMethod: 'foo | e f | e := 9') in: A) scope.
	self assert: (scope hasSlotNamed: 'e').
	self assert: (scope hasSlotNamed: 'f').
	self assert: (scope lookup: 'e') offset = 0.
	self assert: (scope lookup: 'f') offset isNil
    ]
]

