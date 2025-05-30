local ls = require("luasnip")
local s = ls.snippet
local d = ls.dynamic_node
local i = ls.insert_node
local f = ls.function_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

for _, tag in ipairs({ "div", "span", "p", "ul", "li", "h1", "h2", "h3", "h4", "h5", "h6" }) do
  local template = string.format(
    [[
      <%s>
       {}
      </%s>
    ]],
    tag,
    tag
  )

  ls.add_snippets("eruby", {
    s(
      tag,
      fmt(template, {
        i(0),
      })
    ),
  })
end

ls.add_snippets("eruby", {
  s(
    "each",
    fmt(
      [[
        <% {}.each do |{}| %>
          {}
        <% end %>
      ]],
      {
        i(1, "items"),
        i(2, "item"),
        i(0),
      }
    )
  ),
})

ls.add_snippets("eruby", {
  s(
    "expression",
    fmt(
      [[
        <%= {} %>
      ]],
      {
        i(0),
      }
    )
  ),
})
