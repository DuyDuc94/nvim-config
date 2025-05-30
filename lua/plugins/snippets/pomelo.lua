local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("elixir", {
  s(
    "r",
    fmt(
      [[
        rect do
          {}
        end
      ]],
      {
        i(0),
      }
    )
  ),
})

ls.add_snippets("elixir", {
  s(
    "r.style",
    fmt(
      [[
        rect style: [{}] do
          {}
        end
      ]],
      {
        i(1),
        i(0),
      }
    )
  ),
})

ls.add_snippets("elixir", {
  s(
    "r.text",
    fmt(
      [[
        rect do
          "{}"
        end
      ]],
      {
        i(0),
      }
    )
  ),
})

ls.add_snippets("elixir", {
  s(
    "r.row",
    fmt(
      [[
        rect style: [display: :flex, flex_direction: :row] do
          {}
        end
      ]],
      {
        i(0),
      }
    )
  ),
})

ls.add_snippets("elixir", {
  s(
    "r.col",
    fmt(
      [[
        rect style: [display: :flex, flex_direction: :column] do
          {}
        end
      ]],
      {
        i(0),
      }
    )
  ),
})
