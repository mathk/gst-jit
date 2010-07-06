" Hey Emacs, I want -*- tab-width: 8; -*- "

Object subclass: Foo [

    | ivar |
    a [
	| tvar |
	tvar := 123
    ]

    b [
        | tvar |
        tvar := 'string'
    ]

    c: anArg [
        | tvar |
        tvar := anArg
    ]

    d [
        ^ 123
    ]

    e [
	ivar doSthg
    ]
]

