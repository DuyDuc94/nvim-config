;; extends
(([
  (import_statement)
  (jsx_expression)
] @_start @_end)
(#make-range! "range" @_start @_end))

((variable_declarator
    value: (_) @_start @_end)
(#make-range! "range" @_start @_end))
