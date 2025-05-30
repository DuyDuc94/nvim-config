syntax sync fromstart

" Special characters
syntax region printTable start="{" end="}" fold transparent contains=ALL

" Table keys
syntax match printTableKey "\[\"\w\+\"\]" contained contains=printEqual
syntax match printEqual "=" contained

" Numbers
syntax match printNumber "\<\d\+\>"

" Booleans
syntax keyword printBoolean true false

" Strings
syntax region printString start=/"/ skip=/\\"/ end=/"/
syntax region printString start=/'/ skip=/\\'/ end=/'/

" Define highlighting
highlight default link printTableKey Identifier
highlight default link printEqual Operator
highlight default link printNumber Number
highlight default link printBoolean Boolean
highlight default link printString String
