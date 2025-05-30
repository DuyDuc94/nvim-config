local overseer = require("overseer")

local function is_gt_project()
  local cwd = vim.fn.getcwd()
  local project = vim.fn.fnamemodify(cwd, ":t")
  return project == "jfc-global-templates-web"
end

local function is_jb_project()
  local cwd = vim.fn.getcwd()
  local project = vim.fn.fnamemodify(cwd, ":t")
  return project == "jollibee-apollo-web"
end

local ERROR_FORMATS = {
  next_build = table.concat({
    -- src/lib/ServiceHours/index.ts:12:54 - error TS2304: Cannot find name 'ServiceHours'.
    [[%f:%l:%c\ \-\ %trror\ %m]],
    -- src/lib/ServiceHours/index.ts:12:54 - warning TS2304: Cannot find name 'ServiceHours'.
    [[%f:%l:%c\ \-\ %tarning\ %m]],
    -- src/lib/ServiceHours/index.ts(12,54): error TS2304: Cannot find name 'ServiceHours'.
    [[%f(%l\,%c): %trror\ %m]],
    -- src/lib/ServiceHours/index.ts(12,54): warning TS2304: Cannot find name 'ServiceHours'.
    [[%f(%l\,%c): %tarning\ %m]],
    -- ./src/actions/utils/apiOauthCredentials.ts:13:3
    -- Type error: Property 'tokenExpiredTime' is missing in type '{ authToken: string; idToken: string; }' but required in type 'Required<OauthCredentials>'.
    [[%E%f:%l:%c,%Z%m]],
  }, ","),
  -- /Users/goose/Documents/workspace/nimblehq/jfc-global-templates-web/packages/jfc-global-config/src/lib/ServiceHours/index.ts
  --   2:1  error  There should be at least one empty line between import groups  import/order
  --   3:1  error  `dayjs` import should occur before import of `./types`         import/order
  --
  --%P%f: will push the file name to the stack
  --%Q: will pop the file name from the stack
  eslint = [[%P%f,%*[\ ]%l:%c%*[\ ]%trror%*[\ ]%m,%Q]],
}

-- BEGIN: jfc-global-templates-web tasks

local build_components = {
  "default",
  -- Parse the output and put the errors/warnings in the quickfix list
  {
    "on_output_quickfix",
    items_only = true,
    open_on_match = true,
    errorformat = ERROR_FORMATS.next_build,
  },
}

local lint_components = {
  "default",
  {
    "on_output_quickfix",
    items_only = true,
    open_on_match = true,
    set_diagnostics = true,
    errorformat = ERROR_FORMATS.eslint,
    tail = false,
  },
  { "on_result_diagnostics", remove_on_restart = false },
}

overseer.register_template({
  name = "build:all",
  builder = function()
    return {
      cmd = { "npm" },
      args = { "run", "build" },
      name = "build:all",
      components = build_components,
    }
  end,
  desc = "Build all packages",
  condition = {
    callback = is_gt_project,
  },
})

overseer.register_template({
  name = "type_check:template",
  builder = function()
    return {
      cmd = { "npx" },
      args = { "tsc" },
      cwd = "packages/jfc-global-template/template",
      name = "type_check:template",
      components = build_components,
    }
  end,
  desc = "Build template project",
  condition = {
    callback = is_gt_project,
  },
})

overseer.register_template({
  name = "lint:all",
  builder = function()
    return {
      cmd = { "npm" },
      args = { "run", "lint" },
      name = "lint:all",
      components = lint_components,
    }
  end,
  desc = "Lint all packages",
  condition = {
    callback = is_gt_project,
  },
})

local packages = { "auth", "config", "ecommerce", "sdk", "ui" }

for _, package in ipairs(packages) do
  local full = "jfc-global-" .. package
  overseer.register_template({
    name = "build:" .. package,
    builder = function()
      return {
        cmd = { "npm" },
        args = { "run", "build" },
        cwd = "packages/" .. full,
        name = "build:" .. package,
        components = build_components,
      }
    end,
    desc = string.format("Build %s package", full),
    condition = {
      callback = is_gt_project,
    },
  })

  overseer.register_template({
    name = "lint:" .. package,
    builder = function()
      return {
        cmd = { "npm" },
        args = { "run", "lint" },
        cwd = "packages/" .. full,
        name = "lint:" .. package,
        components = lint_components,
      }
    end,
    desc = string.format("Lint %s package", full),
    condition = {
      callback = is_gt_project,
    },
  })
end

-- END: jfc-global-templates-web tasks

-- BEGIN: jollibee-apollo-web tasks

overseer.register_template({
  name = "build",
  builder = function()
    return {
      cmd = { "npm" },
      args = { "run", "build" },
      name = "build",
      components = build_components,
    }
  end,
  desc = "Build project",
  condition = {
    callback = is_jb_project,
  },
})

overseer.register_template({
  name = "lint",
  builder = function()
    return {
      cmd = { "npm" },
      args = { "run", "lint" },
      name = "lint",
      components = lint_components,
    }
  end,
  desc = "Lint project",
  condition = {
    callback = is_jb_project,
  },
})

-- END: jollibee-apollo-web tasks
