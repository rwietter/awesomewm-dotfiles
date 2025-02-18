local dark = {
  red = "#F79DC3",
  redshift = "#F48097",
  grey = "#A0A8C1",
  black = "#11111B",
  white = "#161722",
  green = "#83a598",
  orange = "#fe8019",
  violet = "#AF82FF",
  blue = "#83ACFF",
}

local light = {
  red = "#C13B58",
  redshift = "#F48097",
  grey = "#A0A8C1",
  black = "#F8F8FC",
  white = "#FFFFFF",
  green = "#83a598",
  orange = "#fe8019",
  violet = "#AF82FF",
  blue = "#83ACFF",
}

local sequoia_monochrome = {
  red = "#C13B58",
  redshift = "#F48097",
  grey = "#A0A8C1",
  black = "#0D0E11",
  white = "#D3D5DE",
  green = "#999EB2",
  orange = "#626983",
  violet = "#7C829D",
  blue = "#626983",
}

local colors = sequoia_monochrome

local theme = {
  normal = {
    a = { fg = colors.black, bg = colors.violet, gui = "bold" },
    b = { fg = colors.violet, bg = colors.black },
    c = { fg = colors.white, bg = colors.black },
    x = { fg = colors.violet, bg = colors.black },
    z = { fg = colors.black, bg = colors.violet, gui = "bold" },
  },
  insert = {
    a = { fg = colors.black, bg = colors.blue, gui = "bold" },
    b = { fg = colors.blue, bg = colors.black },
    c = { fg = colors.white, bg = colors.black },
    z = { fg = colors.black, bg = colors.blue, gui = "bold" },
  },
  visual = {
    a = { fg = colors.white, bg = colors.orange, gui = "bold" },
    b = { fg = colors.orange, bg = colors.black },
    c = { fg = colors.white, bg = colors.black },
    z = { fg = colors.white, bg = colors.orange, gui = "bold" },
  },
  replace = {
    a = { fg = colors.black, bg = colors.redshift, gui = "bold" },
    b = { fg = colors.redshift, bg = colors.black },
    c = { fg = colors.black, bg = colors.black },
    x = { fg = colors.redshift, bg = colors.black },
    z = { fg = colors.black, bg = colors.redshift, gui = "bold" },
  },
  command = {
    a = { fg = colors.white, bg = colors.red, gui = "bold" },
    b = { fg = colors.red, bg = colors.black },
    c = { fg = colors.white, bg = colors.black },
    z = { fg = colors.white, bg = colors.red, gui = "bold" },
  },
}

local function empty_component()
  local component = require("lualine.component"):extend()
  function component:draw(default_highlight)
    self.status = ""
    self.applied_separator = ""
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    return self.status
  end

  return component
end

-- Put proper separators and gaps between components in sections
local function process_sections(sections)
  local empty = empty_component()
  for name, section in pairs(sections) do
    local left = name:sub(9, 10) < "x"
    for pos = 1, name ~= "lualine_z" and #section or #section - 1 do
      table.insert(section, pos * 2, { empty, color = { fg = colors.white, bg = colors.white } })
    end
    for id, comp in ipairs(section) do
      if type(comp) ~= "table" then
        comp = { comp }
        section[id] = comp
      end
      comp.separator = left and { right = "" } or { left = "" }
    end
  end
  return sections
end

local function search_result()
  if vim.v.hlsearch == 0 then
    return ""
  end
  local last_search = vim.fn.getreg "/"
  if not last_search or last_search == "" then
    return ""
  end
  local searchcount = vim.fn.searchcount { maxcount = 9999 }
  return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
end

local function modified()
  if vim.bo.modified then
    return "+"
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    return "-"
  end
  return ""
end

local function setup()
  require("lualine").setup {
    options = {
      theme = theme,
      icons_enabled = true,
      refresh = {
        statusline = 600,
        tabline = 600,
        winbar = 600,
      },
      component_separators = "",
      section_separators = { left = "", right = "" },
    },
    sections = process_sections {
      lualine_a = {
        "mode",
      },
      lualine_b = {
        {
          "branch",
          icon = "",
          on_click = function()
            require("telescope.builtin").git_branches()
          end,
        },
        {
          "diff",
          colored = true,
          diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.orange },
            removed = { fg = colors.redshift },
          },
          symbols = {
            added = " ",
            modified = " ",
            removed = " ",
          },
        },
        {
          "diagnostics",
          source = { "nvim" },
          sections = { "error" },
          diagnostics_color = { error = { bg = colors.red, fg = colors.white } },
        },
        {
          "diagnostics",
          source = { "nvim" },
          sections = { "warn" },
          diagnostics_color = { warn = { bg = colors.orange, fg = colors.white } },
        },
        { "filename", file_status = false, path = 0 },
        { modified, color = { bg = colors.white, fg = colors.black, gui = "bold" } },
        {
          "%w",
          cond = function()
            return vim.wo.previewwindow
          end,
        },
        {
          "%r",
          cond = function()
            return vim.bo.readonly
          end,
        },
        {
          "%q",
          cond = function()
            return vim.bo.buftype == "quickfix"
          end,
        },
      },
      lualine_c = {},
      lualine_x = {},
      lualine_y = { search_result, "filetype", { "datetime", style = "%H:%M" } },
      lualine_z = { "%l:%c", "%p%%/%L" },
    },
    inactive_sections = {
      lualine_c = { "%f %y %m" },
      lualine_x = {},
    },
  }
end

return { setup = setup }
