local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    config = function()
      require "custom.configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require "custom.configs.conform"
    end,
  },

  -- OxoCarbon theme
  {
    "nyoom-engineering/oxocarbon.nvim",
    config = function()
      require("oxocarbon").setup()
    end,
  },

  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = { "InsertEnter", "BufRead" },
    build = ":Copilot auth",
    config = function()
      require("copilot").setup {
        panel = {
          auto_refresh = true,
          enabled = true,
          suggestion = { enabled = true },
          panel = { enabled = true },
          filetypes = {
            markdown = true,
            help = true,
            ["."] = true,
          },
        },
        server_opts_overrides = {
          -- trace = "verbose",
          settings = {
            advanced = {
              listCount = 20, -- #completions for panel
              inlineSuggestCount = 10, -- #completions for getCompletions
            },
          },
        },
      }
    end,
  },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   event = { "InsertEnter", "LspAttach" },
  --   fix_pairs = true,
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end,
  -- },

  -- telescope file browser
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = {
      {
        "<leader>sb",
        ":Telescope file_browser path=%:p:h=%:p:h<cr>",
        desc = "Browse Files",
      },
    },
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension "file_browser"
    end,
    lazy = false,
  },

  -- wakatime plugin for tracking time
  {
    "wakatime/vim-wakatime",
    lazy = false,
  },

  -- Comment jsx and tsx
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("ts_context_commentstring").setup {
        enable_autocmd = false,
      }
    end,
  },
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },

  -- Autotag for jsx and tsx
  {
    "windwp/nvim-ts-autotag",
    event = "BufRead",
    config = function()
      require "plugins.configs.treesitter"
    end,
  },

  -- Select text
  {
    "mg979/vim-visual-multi",
    lazy = false,
    branch = "master",
  },

  -- Problem viewer
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    config = function()
      dofile(vim.g.base46_cache .. "trouble")
      require("trouble").setup()
    end,
    opts = {
      use_diagnostic_signs = true,
    },
  },

  -- Highlights references under cursor
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },

  -- Spectre for search and replace
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = {
      {
        "<leader>sr",
        function()
          require("spectre").open()
        end,
        desc = "Replace in files (Spectre)",
      },
    },
  },

  -- Custom statusbar for nvim
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      return require("custom.configs.lualine").setup()
    end,
  },

  -- Howdoi AI
  {
    "zane-/howdoi.nvim",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      return require("telescope").load_extension "howdoi"
    end,
  },

  -- Error lens
  --[[
  {
    "chikko80/error-lens.nvim",
    event = "BufRead",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      -- your options go here
    },
  },
  ]]

  -- Notification and popups API
  --[[
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          timeout = 1500,
          max_height = function()
            return math.floor(vim.o.lines * 0.75)
          end,
          max_width = function()
            return math.floor(vim.o.columns * 0.75)
          end,
        },
      },
    },
    config = function()
      require("noice").setup {
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            ["config.lsp.hover.enabled"] = false,
            ["config.lsp.signature.enabled"] = false,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = true, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      }
      require("telescope").load_extension "noice"
    end,
  },
  ]]

  --[[
   + Override nvim-web-devicons
   + Needs termicons font to work. <mskelton.github.io/termicons>
  ]]
  {
    "mskelton/termicons.nvim",
    requires = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("termicons").setup()
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function(_, opts)
      require("termicons").setup(opts)
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  -- Extended Increment/Derement plugin for booleans and days
  {
    "nat-418/boole.nvim",
    cmd = "Boole",
    lazy = false,
    config = function()
      require("boole").setup {
        mappings = {
          increment = "<C-a>",
          decrement = "<C-x>",
        },
      }
    end,
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    lazy = false,
    config = function()
      require("inc_rename").setup()
    end,
  },
}
return plugins
