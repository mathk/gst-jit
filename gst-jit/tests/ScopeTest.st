Object subclass: A [
    | a b c |
]

TestCase subclass: BehaviorScopeTest [

    testBehaviorScope [
	<category: 'testing'>

	| scope |
	scope := A scope.
	self assert: (scope lookup: 'a') isBehavior.
	self assert: (scope lookup: 'b') isBehavior.
	self assert: (scope lookup: 'c') isBehavior
    ]
]

TestCase subclass: ScopeTest [

]

TestCase subclass: ScopeCheckerTest [

    testSimpleScope [
	<category: 'testing'>

	| scope |
	scope := (STInST.RBParser parseMethod: 'foo a send: b') scopeCheckIn: A; scope.
	self assert: (scope hasSlotNamed: 'a').
	self assert: (scope hasSlotNamed: 'b').
	self assert: (scope hasSlotNamed: 'c').
	self shouldnt: [ scope hasSlotNamed: 'd' ] raise: MessageNotUnderstood.
	self should: [ scope lookup: 'd' ] raise: SystemExceptions.NotFound.

	scope := (STInST.RBParser parseMethod: 'foo: d a send: b') scopeCheckIn: A; scope.
	self assert: (scope hasSlotNamed: 'a').
	self assert: (scope hasSlotNamed: 'b').
	self assert: (scope hasSlotNamed: 'c').
	self assert: (scope hasSlotNamed: 'd').

	scope := (STInST.RBParser parseMethod: 'foo: d | e f | a send: b') scopeCheckIn: A; scope.
	self assert: (scope hasSlotNamed: 'a').
	self assert: (scope hasSlotNamed: 'b').
	self assert: (scope hasSlotNamed: 'c').
	self assert: (scope hasSlotNamed: 'd').
	self assert: (scope hasSlotNamed: 'e').
	self assert: (scope hasSlotNamed: 'f').

	scope := (STInST.RBParser parseMethod: 'foo: d | e f | 
	    a send: b.
	    [ :x :y | x msg. y msg ] ') scopeCheckIn: A; scope.

	scope := (STInST.RBParser parseMethod: 'foo: d | e f | 
	    a send: b. 
	    [ :x :y | | l s | l msg. s msg. x msg. y msg ] ') scopeCheckIn: A; scope.

	self should: [
	    (STInST.RBParser parseMethod: 'foo: d | e f | 
		a send: b. 
		[ :x :y | | l s | 
		    [ :l :s | l msg. s msg. x msg. y msg ]  ]. 
		[ x msg. l msg ]') scopeCheckIn: A ] raise: Exception
    ]

    testTemparoary [
	<category: 'testing'>

	| scope |
	scope := (STInST.RBParser parseMethod: 'foo | e f | e := 9') scopeCheckIn: A; scope.
	self assert: (scope hasSlotNamed: 'e').
	self assert: (scope hasSlotNamed: 'f').
	self assert: (scope lookup: 'e') offset = 0.
	self assert: (scope lookup: 'f') offset isNil
    ]
]

