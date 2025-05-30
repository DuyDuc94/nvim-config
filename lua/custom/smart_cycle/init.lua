-- Cycle through list of items like git hunks, quick fix list, diagnostic
-- It remembers your last command and acts on that
-- For example: ]d moves to the next diagnostic. After that, you can do ]]
-- to move the next one (it automatically move to the next diagnostic)
--
local utils = require("custom.utils")

local M = {}
local last_action = nil
local actions = nil

local function perform_action(action, nextOrPrev)
  last_action = action
  local action_config = actions[action]
  local cmd = nil
  if nextOrPrev == "next" then
    cmd = action_config["next_command"]
  elseif nextOrPrev == "prev" then
    cmd = action_config["prev_command"]
  end

  if type(cmd) == "function" then
    cmd()
  elseif type(cmd) == "string" then
    utils.safe_cmd(cmd)
  end
end

function M.last_action_next()
  if last_action then
    perform_action(last_action, "next")
  end
end

function M.last_action_prev()
  if last_action then
    perform_action(last_action, "prev")
  end
end

function M.has_last_action()
  return last_action ~= nil
end

function M.clear_last_action()
  last_action = nil
end

function M.set_last_action(action)
  last_action = action
end

function M.setup(config)
  actions = config["actions"]
  for name, action_config in pairs(actions) do
    local key = action_config["key"]

    vim.keymap.set("n", "]" .. key, utils.wrap(perform_action, name, "next"))
    vim.keymap.set("n", "[" .. key, utils.wrap(perform_action, name, "prev"))
  end
end

return M
