vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
-- Decrease update time
vim.o.updatetime = 2000
-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '\\', ':lua MiniFiles.open()<CR>')
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic floating window' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Teest shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '>', '<cmd>bnext<CR>', { desc = 'Buffer next' })
vim.keymap.set('n', '<', '<cmd>bprev<CR>', { desc = 'Buffer next' })
vim.o.winborder = 'rounded'
local orig_open = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  if opts.border == nil then opts.border = 'rounded' end
  return orig_open(contents, syntax, opts, ...)
end

-- Toggle between Java source and test files (like IntelliJ's Ctrl+Shift+T)
local function toggle_java_test()
  local file = vim.fn.expand '%:p'
  if not file or file == '' then
    print 'No file'
    return
  end

  -- Normalize path
  local norm = file:gsub('\\', '/')
  local alternate

  if norm:match '/src/main/java/' then
    -- Source -> Test
    local test_norm = norm:gsub('/src/main/java/', '/src/test/java/')
    local dir = test_norm:match '(.*/)'
    local basename = test_norm:match '([^/]+)%.java$'
    if not dir or not basename then
      print 'Not a Java resource file'
      return
    end

    -- Try common test suffixes
    local candidates = {
      dir .. basename .. 'Test.java',
    }

    for _, cand in ipairs(candidates) do
      -- convert back to OS-specific separators if you prefer
      if vim.fn.filereadable(cand) == 1 then
        alternate = cand
        break
      end
    end

    if not alternate then alternate = candidates[1] end
  elseif norm:match '/src/test/java/' then
    -- Test -> Source
    local src_norm = norm:gsub('/src/test/java/', '/src/main/java/')
    local dir = src_norm:match '(.*/)'
    local basename = src_norm:match '([^/]+)%.java$'
    if not dir or not basename then
      print 'Not a Java test file'
      return
    end

    -- Remove common test suffixes
    local bare = basename
    bare = bare:gsub('Tests$', '')
    bare = bare:gsub('Test$', '')

    alternate = dir .. bare .. '.java'
  else
    print 'Not a Java source or test file'
    return
  end

  if alternate and vim.fn.filereadable(alternate) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(alternate))
  else
    print('Alternate file not found: ' .. (alternate or 'unknown'))
  end
end

vim.keymap.set('n', '<leader>tt', toggle_java_test, { desc = '[T]oggle [T]est/Source' })
vim.keymap.set('n', '<leader>jb', '<cmd>JavaBuildBuildWorkspace<CR>', { desc = '[J]ava [B]uild' })

-- Java test keybindings (only set in Java files)
-- Report will auto-show when tests complete (configured in nvim-java setup)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    vim.keymap.set('n', '<leader>tc', '<cmd>JavaTestRunCurrentClass<cr>', { buffer = true, desc = '[T]est [C]urrent Class' })
    vim.keymap.set('n', '<leader>tm', '<cmd>JavaTestRunCurrentMethod<cr>', { buffer = true, desc = '[T]est Current [M]ethod' })
    vim.keymap.set('n', '<leader>tr', '<cmd>JavaTestViewLastReport<cr>', { buffer = true, desc = '[T]est View Last [R]eport' })
    vim.keymap.set('n', '<leader>td', '<cmd>JavaTestDebugCurrentClass<cr>', { buffer = true, desc = '[T]est [D]ebug Current Class' })
    -- Keymap to show all Errors in the project in a quickfix list
    vim.keymap.set('n', '<leader>be', function()
      vim.diagnostic.setqflist { severity = vim.diagnostic.severity.ERROR }
      vim.cmd 'copen'
    end, { desc = '[B]uild [E]rrors' })
    -- Keymap to show all Warnings in the project in a quickfix list
    vim.keymap.set('n', '<leader>bw', function()
      local all_diags = vim.diagnostic.get() -- alle Buffer/alle Severities

      local filtered = {}
      for _, d in ipairs(all_diags) do
        -- Buffer-Name holen (Dateipfad)
        local name = vim.api.nvim_buf_get_name(d.bufnr)
        -- Einträge aus target/ überspringen
        if not name:match '[/\\]target[/\\]' then
          -- in Quickfix-Format umwandeln
          table.insert(filtered, {
            bufnr = d.bufnr,
            lnum = d.lnum + 1,
            col = d.col + 1,
            text = d.message,
            severity = d.severity,
          })
        end
      end

      -- Nur Warnungen übernehmen
      local qf_items = {}
      for _, item in ipairs(filtered) do
        if item.severity == vim.diagnostic.severity.WARN then table.insert(qf_items, item) end
      end

      vim.fn.setqflist({}, ' ', {
        title = 'Diagnostics (WARN, ohne target/)',
        items = qf_items,
      })
      vim.cmd.copen()
    end, { desc = '[B]uild [W]arnings' })
  end,
})

-- [[ Basic Autocommands ]]
-- Deaktiviere Swap für jdt://-Buffer
vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = 'jdt://*',
  callback = function() vim.opt_local.swapfile = false end,
})
--  See `:help lua-guide-autocommands`
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.cmd [[retab]]
  end,
})
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    enabled = true,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        file_ignore_pattern = { 'target/.*' },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set(
        'n',
        '<leader>sf',
        function()
          require('telescope.builtin').git_files {
            previewer = false,
          }
        end,
        { desc = '[S]earch Git [F]iles' }
      )
      vim.keymap.set('n', '<leader>sF', builtin.find_files, { desc = '[S]earch all [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
      -- it is better explained there). This allows easily switching between pickers if you prefer using something else!
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf

          -- Find references for the word under your cursor.
          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types without an actual implementation.
          vim.keymap.set('n', 'gi', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where a function is defined, etc.
          -- To jump back, press <C-t>.
          vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

          -- Fuzzy find all the symbols in your current document.
          -- Symbols are things like variables, functions, types, etc.
          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

          -- Fuzzy find all the symbols in your current workspace.
          -- Similar to document symbols, except searches over your entire project.
          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

          -- Jump to the type of the word under your cursor.
          -- Useful when you're not sure what type a variable is and you want to see
          -- the definition of its *type*, not where it was *defined*.
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })

      -- Override default behavior and theme when searching

      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })
      -- It's also possible to pass additional configuration options.
      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[S]earch [/] in Open Files' }
      )
      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  -- LSP Plugins
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'nvim-java/nvim-java',
        config = function()
          require('java').setup {
            jdk = {
              auto_install = false,
            },
            root_markers = {
              'settings.gradle',
              'settings.gradle.kts',
              'pom.xml',
              'build.gradle',
              'mvnw',
              'gradlew',
              'build.gradle.kts',
              '.git',
            },
            spring_boot_tools = {
              enable = false,
            },
            java_test = {
              enable = true,
            },
            java_debug_adapter = {
              enable = true,
            },
            jdtls = {
              java = {
                vmargs = {
                  '-Xms512M',
                  '-Xmx2G',
                  '-XX:+UseG1GC',
                  '-XX:+UseStringDeduplication',
                  '-XX:MaxMetaspaceSize=512M',
                  '-XX:ReservedCodeCacheSize=256M',
                },
              },
              settings = {
                java = {
                  -- Enable automatic source download from Maven repositories
                  maven = {
                    downloadSources = false,
                  },
                  eclipse = {
                    downloadSources = false,
                  },
                  format = {
                    enabled = false,
                  },
                  autobuild = {
                    enabled = false,
                  },
                  completion = {
                    maxResults = 50,
                  },
                  import = {
                    gradle = {
                      enabled = false,
                    },
                    maven = {
                      enabled = true,
                    },
                  },
                },
              },
            },
          }
          vim.lsp.enable 'jdtls'
          -- Hook into test completion to auto-show report
          local java_test = require 'java-test'
          local original_get_report = java_test.get_report
          java_test.get_report = function()
            local report = original_get_report()
            local original_on_close = report.on_close

            -- Override on_close to show report when tests complete
            report.on_close = function(self)
              if original_on_close then original_on_close(self) end
              -- Show report after tests finish
              vim.schedule(function() self:show_report() end)
            end

            return report
          end
        end,
      },

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
      -- Allows extra capabilities provided by blink.cmp
      {
        'saghen/blink.cmp',
        -- use a release tag to download pre-built binaries
        version = '1.*',
      },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          -- Rename the variable under your cursor.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          -- Execute a code action, usually your cursor needs to be on top of an error
          map('<leader>ga', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == 'jdtls' then client.server_capabilities.semanticTokensProvider = nil end

          -- Semantic Tokens für Java komplett deaktivieren (nur Treesitter-Highlighting nutzen)
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('java-disable-semantic-tokens', { clear = true }),
            callback = function(event)
              local client = vim.lsp.get_client_by_id(event.data.client_id)
              if not client then return end

              -- Nur Java
              if vim.bo[event.buf].filetype ~= 'java' then return end

              -- Semantic Tokens für diesen Client abklemmen
              if client.server_capabilities.semanticTokensProvider then client.server_capabilities.semanticTokensProvider = nil end
            end,
          })

          if client and client.name ~= 'jdlts' and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
      }
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'lua_ls',
        'stylua',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      for name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- Special Lua Config, as recommended by neovim help docs
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
              --  See https://github.com/neovim/nvim-lspconfig/issues/3189
              library = vim.api.nvim_get_runtime_file('', true),
            },
          })
        end,
        settings = {
          Lua = {},
        },
      })
      vim.lsp.enable 'lua_ls'
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          -- Skip formatting for Java files
          if vim.bo.filetype == 'java' then
            vim.notify('Java formatting is disabled. Use IntelliJ to format.', vim.log.levels.INFO)
            return
          end
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true, java = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'super-tab',

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets' },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },

  --{
  --  'catppuccin/nvim',
  --  name = 'catppuccin',
  --  priority = 1000,
  --  vim.cmd.colorscheme 'catppuccin-mocha',
  --},
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    config = function()
      require('rose-pine').setup {
        styles = {
          italic = false,
        },
        highlight_groups = {
          NormalFloat = { bg = 'base' }, -- konsistenter BG aus der Palette
          FloatBorder = { fg = 'iris', bg = 'base' }, -- Rahmen hebt sich ab
        },
      }
      vim.cmd.colorscheme 'rose-pine'

      -- Semantic-Modifier wieder wie Keywords einfärben
      vim.api.nvim_set_hl(0, '@lsp.type.modifier', { link = '@keyword' })
      vim.api.nvim_set_hl(0, '@lsp.type.modifier.java', { link = '@keyword' })
    end,
  },
  -- {
  --   'rebelot/kanagawa.nvim',
  --   priority = 1000,
  --   config = function()
  --     require('kanagawa').setup {
  --       keywordStyle = { italic = true },
  --     }
  --     vim.cmd.colorscheme 'kanagawa'
  --   end,
  -- },
  -- {
  --   'catppuccin/nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   config = function()
  --     ---@diagnostic disable-next-line: missing-fields
  --     require('catppuccin').setup {
  --       flavour = 'mocha',
  --     }
  --     -- Load the colorscheme here.
  --     -- Like many other themes, this one has different styles, and you could load
  --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
  --     vim.cmd.colorscheme 'catppuccin'
  --   end,
  -- },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }
      require('mini.files').setup()

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      -- require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end

      -- Show keybindings helper (replaces which-key)
      local miniclue = require 'mini.clue'
      miniclue.setup {
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },

          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },

          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },

          -- Window commands
          { mode = 'n', keys = '<C-w>' },

          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),

          -- Custom leader key groups (matching your which-key spec)
          { mode = 'n', keys = '<Leader>s', desc = '+[S]earch' },
          { mode = 'n', keys = '<Leader>t', desc = '+[T]oggle' },
          { mode = 'n', keys = '<Leader>h', desc = '+Git [H]unk' },
          { mode = 'v', keys = '<Leader>h', desc = '+Git [H]unk' },
          { mode = 'n', keys = '<Leader>l', desc = '+[L]azy' },
        },
      }

      -- ... and there is more!
      --  Check out: https://github.com/nvim-mini/mini.nvim
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = function()
      local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'java' }
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }
      require('nvim-treesitter').install(parsers)
    end,
    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }
    end,
  },

  -- require 'kickstart.plugins.debug',
  require 'kickstart.plugins.autopairs',
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
