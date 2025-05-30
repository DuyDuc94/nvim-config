;; extends
(([
  (import_statement)
  (try_statement)
  (export_statement)
] @_start @_end)
(#make-range! "range" @_start @_end))

((variable_declarator
    value: (_) @_start @_end)
(#make-range! "range" @_start @_end))
