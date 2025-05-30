local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function from_clipboard()
  return f(function(_, _)
    return vim.trim(vim.fn.getreg("+"))
  end, {})
end

ls.add_snippets("mdx", {
  s(
    "link.project",
    fmt(
      [[
        <a
          href="{}"
          rel="noopener noreferrer"
          target="_blank"
          class="link inline"
        >{}</a>
      ]],
      {
        from_clipboard(),
        i(0),
      }
    )
  ),
})

ls.add_snippets("mdx", {
  s(
    "ul.project",
    fmt(
      [[
        <ul class="list-disc pl-10">
          <li>{}</li>
        </ul>
      ]],
      {
        i(0),
      }
    )
  ),
})

ls.add_snippets("mdx", {
  s(
    "ol.project",
    fmt(
      [[
        <ol class="list-decimal pl-10">
          <li>{}</li>
        </ol>
      ]],
      {
        i(0),
      }
    )
  ),
})
