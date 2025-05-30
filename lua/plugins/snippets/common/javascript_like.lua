local ls = require("luasnip")
local s = ls.snippet
local d = ls.dynamic_node
local i = ls.insert_node
local c = ls.choice_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local postfix = require("luasnip.extras.postfix").postfix

local function build_snippet(function_name)
  return postfix("." .. function_name, {
    d(1, function(_, parent)
      local name = parent.snippet.env.POSTFIX_MATCH
      local singular

      if name:match("s$") then
        singular = string.sub(name, 1, -2)
      else
        singular = "item"
      end

      return sn(
        nil,
        fmt(
          string.format(
            [[
              %s.%s((%s) => {{
                {}
              }})
            ]],
            name,
            function_name,
            singular
          ),
          {
            i(1),
          }
        )
      )
    end, {}),
  })
end

local all_langs = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

for _, lang in ipairs(all_langs) do
  for _, function_name in ipairs({ "map", "filter", "flatMap", "forEach" }) do
    ls.add_snippets(lang, { build_snippet(function_name) })
  end
end

for _, lang in ipairs(all_langs) do
  ls.add_snippets(lang, {
    s(
      "f",
      c(1, {
        fmt(
          [[
            () => {{
              {}
            }}
          ]],
          { i(1) }
        ),
        fmt("() => {}", { i(1) }),
      })
    ),
  })
  ls.add_snippets(lang, {
    s(
      "fa",
      c(1, {
        fmt(
          [[
            async () => {{
              {}
            }}
          ]],
          { i(1) }
        ),
        fmt("async () => {}", { i(1) }),
      })
    ),
  })
end
