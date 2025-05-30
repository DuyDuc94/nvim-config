;; extends
(
  (binary_operator
    left: (_)
    "="
    right: (_)
  ) @_start @_end
  (#make-range! "range" @_start @_end)
)

(arguments
  (_) @_start @_end
  (#make-range! "range" @_start @_end)
)

;; Match pair followed by comma
(keywords
  (pair) @_start
  .
  "," @_end
  (#make-range! "range" @_start @_end)
)

;; Fallback for pairs without comma
(
 (keywords
    (pair) @_start @_end
    .
  )
  (#make-range! "range" @_start @_end)
)
