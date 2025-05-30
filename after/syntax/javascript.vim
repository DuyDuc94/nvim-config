syntax sync fromstart

" Special characters
syntax region consoleLogObject start="{" end="}" fold transparent contains=ALL

" Keywords
syntax match consoleLogSpecial "\V\([Promise]\|[Function]\|[Reference]\|[Circular]\)"
syntax match consoleLogSpecial "\[Array(\d\+)\]"
syntax match consoleLogSpecial "Symbol(.\+)"

" Object keys
syntax match consoleLogObjectKey "\<\w\+\>:" contained contains=consoleLogColon
syntax match consoleLogColon ":" contained

" Define highlighting
highlight default link consoleLogSpecial Type
highlight default link consoleLogObjectKey Identifier
highlight default link consoleLogColon Operator
