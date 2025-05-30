local ls = require("luasnip")
local s = ls.snippet
local d = ls.dynamic_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local t = ls.text_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

local function build_snippet(function_name)
  return s(
    function_name,
    d(1, function()
      local line = vim.fn.getline(".")

      if vim.trim(line):match("|>$") then
        -- Pipe version
        return sn(
          nil,
          fmt(
            string.format(
              [[
                Enum.%s(fn {} ->
                  {}
                end)
              ]],
              function_name
            ),
            { i(1, "item"), i(0) }
          )
        )
      else
        -- Non-pipe version
        return sn(
          nil,
          fmt(
            string.format(
              [[
                Enum.%s({}, fn {} ->
                  {}
                end)
              ]],
              function_name
            ),
            {
              i(1),
              f(function(args)
                local name = args[1][1]
                if name:match("s$") then
                  return string.sub(name, 1, -2)
                else
                  return "item"
                end
              end, { 1 }),
              i(0),
            }
          )
        )
      end
    end)
  )
end

ls.add_snippets("elixir", {
  s(
    "fn",
    c(1, {
      fmt(
        [[
          fn {} ->
           {}
          end
        ]],
        {
          i(1, "x"),
          i(0),
        }
      ),
      fmt("& &1{}", i(0)),
    })
  ),
})

local functions = { "map", "each", "filter", "flat_map", "find" }

for _, function_name in ipairs(functions) do
  ls.add_snippets("elixir", { build_snippet(function_name) })
end

ls.add_snippets("elixir", {
  s(
    "reduce",
    d(1, function()
      local line = vim.fn.getline(".")

      if vim.trim(line):match("|>$") then
        -- Pipe version
        return sn(
          nil,
          fmt(
            [[
              Enum.reduce(initial, fn {}, acc ->
                {}
              end)
            ]],
            {
              i(1, "item"),
              i(0),
            }
          )
        )
      else
        -- Non-pipe version
        return sn(
          nil,
          fmt(
            [[
              Enum.reduce({}, initial, fn {}, acc ->
               {}
              end)
            ]],
            {
              i(1),
              f(function(args)
                local name = args[1][1]
                if name:match("s$") then
                  return string.sub(name, 1, -2)
                else
                  return "item"
                end
              end, { 1 }),
              i(0),
            }
          )
        )
      end
    end)
  ),
})
