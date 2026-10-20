return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      "rafamadriz/friendly-snippets",
      "kristijanhusak/vim-dadbod-completion",
    },
    opts = {
      snippets = {
        preset = "luasnip",
        active = function(filter)
          return require("features.snippets").active(filter)
        end,
        jump = function(direction)
          return require("features.snippets").jump(direction)
        end,
      },

      keymap = {
        preset = "none",

        ["<C-Space>"] = {
          "show",
          "show_documentation",
          "hide_documentation",
        },

        ["<C-e>"] = {
          "hide",
          "fallback",
        },

        ["<C-n>"] = {
          "select_next",
          "fallback_to_mappings",
        },

        ["<C-p>"] = {
          "select_prev",
          "fallback_to_mappings",
        },

        ["<Down>"] = {
          "select_next",
          "fallback",
        },

        ["<Up>"] = {
          "select_prev",
          "fallback",
        },

        ["<C-y>"] = {
          "select_and_accept",
          "fallback",
        },

        ["<CR>"] = {
          "accept",
          "fallback",
        },

        ["<Tab>"] = {
          "snippet_forward",
          "fallback",
        },

        ["<S-Tab>"] = {
          "snippet_backward",
          "fallback",
        },

        ["<C-b>"] = {
          "scroll_documentation_up",
          "fallback",
        },

        ["<C-f>"] = {
          "scroll_documentation_down",
          "fallback",
        },

        ["<C-k>"] = {
          "show_signature",
          "hide_signature",
          "fallback",
        },
      },

      completion = {
        keyword = {
          range = "prefix",
        },

        trigger = {
          prefetch_on_insert = true,
          show_in_snippet = true,
        },

        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },

        accept = {

          auto_brackets = {
            enabled = false,
          },
        },

        menu = {
          auto_show = true,
          auto_show_delay_ms = 0,
          border = "rounded",
          scrollbar = true,

          draw = {
            columns = {
              { "kind_icon", "kind", gap = 1 },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 150,
          window = {
            border = "rounded",
          },
        },

        ghost_text = {
          enabled = false,
        },
      },

      signature = {
        enabled = true,
        window = {
          border = "rounded",
        },
      },

      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
        },

        per_filetype = {
          sql = {
            inherit_defaults = true,
            "dadbod",
          },

          mysql = {
            inherit_defaults = true,
            "dadbod",
          },

          plsql = {
            inherit_defaults = true,
            "dadbod",
          },

          tex = {
            inherit_defaults = true,
            "latex_kernel",
          },

          plaintex = {
            inherit_defaults = true,
            "latex_kernel",
          },

          bib = {
            inherit_defaults = true,
            "latex_kernel",
          },

          cls = {
            inherit_defaults = true,
            "latex_kernel",
          },

          sty = {
            inherit_defaults = true,
            "latex_kernel",
          },

          dtx = {
            inherit_defaults = true,
            "latex_kernel",
          },

          ins = {
            inherit_defaults = true,
            "latex_kernel",
          },
        },

        providers = {
          lsp = {
            name = "LSP",
            min_keyword_length = 0,
            timeout_ms = 2000,
            score_offset = 100,

            fallbacks = {},
          },

          path = {
            name = "Path",
            score_offset = 40,
          },

          snippets = {
            name = "Snippet",
            score_offset = 20,
          },

          buffer = {
            name = "Buffer",
            min_keyword_length = 3,
            max_items = 8,
            score_offset = -50,
          },

          dadbod = {
            name = "Database",
            module = "vim_dadbod_completion.blink",
            min_keyword_length = 0,
            score_offset = 110,
          },

          latex_kernel = {
            name = "TeX Kernel",
            module = "languages.latex_completion",
            min_keyword_length = 1,
            max_items = 200,
            score_offset = 90,
          },
        },
      },

      fuzzy = {
        implementation = "prefer_rust",
        sorts = {
          "exact",
          "score",
          "sort_text",
        },
      },

      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
        },
        completion = {
          menu = {
            auto_show = true,
          },
        },
      },
    },

    config = function(_, opts)
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.stdpath("config") .. "/snippets",
      })

      luasnip.config.setup({
        history = false,
        region_check_events = "InsertEnter,CursorMoved,CursorMovedI",
        delete_check_events = "TextChanged,TextChangedI,InsertLeave",
      })

      require("blink.cmp").setup(opts)
    end,
  },
}
