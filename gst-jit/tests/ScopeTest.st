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
	scope := (STInST.RBParser parseMethod: 'foo a send: b') checkScopeIn: A; scope.
	self assert: (scope hasSlotNamed: 'a').
	self assert: (scope hasSlotNamed: 'b').
	self assert: (scope hasSlotNamed: 'c').
	self shouldnt: [ scope hasSlotNamed: 'd' ] raise: MessageNotUnderstood.
	self should: [ scope lookup: 'd' ] raise: SystemExceptions.NotFound.

	scope := (STInST.RBParser parseMethod: 'foo: d a send: b') checkScopeIn: A; scope.
	self assert: (scope hasSlotNamed: 'a').
	self assert: (scope hasSlotNamed: 'b').
	self assert: (scope hasSlotNamed: 'c').
	self assert: (scope hasSlotNamed: 'd').

	scope := (STInST.RBParser parseMethod: 'foo: d | e f | a send: b') checkScopeIn: A; scope.
	self assert: (scope hasSlotNamed: 'a').
	self assert: (scope hasSlotNamed: 'b').
	self assert: (scope hasSlotNamed: 'c').
	self assert: (scope hasSlotNamed: 'd').
	self assert: (scope hasSlotNamed: 'e').
	self assert: (scope hasSlotNamed: 'f').

	scope := (STInST.RBParser parseMethod: 'foo: d | e f | 
	    a send: b.
	    [ :x :y | x msg. y msg ] ') checkScopeIn: A; scope.

	scope := (STInST.RBParser parseMethod: 'foo: d | e f | 
	    a send: b. 
	    [ :x :y | | l s | l msg. s msg. x msg. y msg ] ') checkScopeIn: A; scope.

	self should: [
	    (STInST.RBParser parseMethod: 'foo: d | e f | 
		a send: b. 
		[ :x :y | | l s | 
		    [ :l :s | l msg. s msg. x msg. y msg ]  ]. 
		[ x msg. l msg ]') checkScopeIn: A ] raise: Exception
    ]

    testTemparoary [
	<category: 'testing'>

	| scope |
	scope := (STInST.RBParser parseMethod: 'foo | e f | e := 9') checkScopeIn: A; scope.
	self assert: (scope hasSlotNamed: 'e').
	self assert: (scope hasSlotNamed: 'f').
	self assert: (scope lookup: 'e') offset = 0.
	self assert: (scope lookup: 'f') offset isNil
    ]

    testArgument [
	| scope |
	scope := (STInST.RBParser parseMethod: 'foo: arg1 bar: arg2 | e | e := 9') checkScopeIn: A; scope.
	self assert: (scope lookup: 'arg1') notNil.
	self assert: (scope lookup: 'arg2') notNil
    ]

    
    testInlineIf [
	| scope |
	scope := (STInST.RBParser parseMethod: 'foo true ifTrue: [ | foobar | false. ^foobar]') checkScopeIn: A; scope.
	self assert: (scope lookup: 'foobar') offset == 0.
	self assert: (scope lookup: 'foobar') notNil
    ]

    testBlock [
	| methodNode blockSlot |
	
	methodNode := (STInST.RBParser parseMethod: 'foo | i | [ | foobar | i := i + 1. ^foobar]') checkScopeIn: A.
	blockSlot := (methodNode body statements first body statements first variable slot).
	self assert: (methodNode scope lookup: 'i') notNil.
	self assert: (methodNode scope lookup: 'i') offset = 0.
	self assert: blockSlot isBlock.
	self assert: blockSlot offset = 0.
	self assert: (methodNode body statements first scope lookup: 'foobar') isContext.
	self assert: (methodNode body statements first scope lookup: 'foobar') notNil.
	self assert: (methodNode body statements first scope lookup: 'foobar') offset = 0
    ]
]

