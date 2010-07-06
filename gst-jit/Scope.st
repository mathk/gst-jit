" Hey Emacs, I want -*- tab-width: 8; -*- "

Object subclass: Scope [
	"I am a abstract scope."
	| parentScope bindings |

	Scope class >> attachedTo: parentScope [
		"Instanciate a new scope"
		<category: 'instance-creation'>
		^(self new) 
			parentScope: parentScope;
			yourself
	]

	Scope class >> defaultSlotClass [
		^self subclassResponsibility
	]

	defautlSlotClass [
		^self class defaultSlotClass
	]

	bindings [
		<category: 'accessing'>
		^bindings isNil ifTrue: [bindings := Dictionary new]
	]

	parentScope [
		<category: 'accessing'>
		^parentScope
	]
	
	parentScope: aScope [
		<category: 'accessing'>
		parentScope := aScope
	]

	lookup: name [
		^self bindings at: name 
					   ifAbsent: [self parentScope lookup: name]
	]
	
	bind: name [
		^self bindings at: name 
					   put: (self defaultSlotClass for: self)
	]
]

Scope subclass: ContextScope [
	"I am a scope for every bindings that is inside a context.
	 That is arguments and temporaries"

	ContextScope class >> defaultSlotClass [
		^ContextSlot
	]

]

Scope subclass: ClassScope [
	"I am a scope for bindings inside the class.
	 This is instance and class variables"
]

Object subclass: Slot [
	| name scope |

	UndefinedSlot := self new.
	
	Slot class >> for: scope [
		^(self new)
			scope: scope;
			yourself
	]

	name [
		<category: 'accessing'>
		^name
	]

	name: aString [
		<category: 'accessing'>
		name := aString
	]

	scope [
		<category: 'accessing'>
		^scope
	]

	scope: aScope [
		<category: 'accessing'>
		scope := aScope
	]
]

Slot subclass: ContextSlot [
	"I am a slote inside context scope"

	emitPush: aInterpreter [
		aInterpreter pushTemp: self index
	]

	index [
		self scope index: slef
	]
]
