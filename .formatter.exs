# Used by "mix format"
[
  inputs: ["mix.exs", "{lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    defalias: 2,
    defclass: 2,
    definst: :*,
    extend: :*
  ],
  export: [
    locals_without_parens: [
      defalias: 2,
      defclass: 2,
      definst: :*,
      extend: :*
    ]
  ]
]
