--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.scrolloff = 17

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end
  },

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    "cuducos/yaml.nvim",
    ft = { "yaml" }, -- optional
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has 'win32' == 1 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']]', function()
          if vim.wo.diff then
            return ']]'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[[', function()
          if vim.wo.diff then
            return '[['
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        -- map('v', '<leader>hs', function()
        --   gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        -- end, { desc = 'stage git hunk' })
        -- map('v', '<leader>hr', function()
        --   gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        -- end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>ga', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>gA', gs.stage_buffer, { desc = 'git stage buffer' })
        map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>gg', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>gb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>gD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
      'tzachar/local-highlight.nvim',
      config = function()
        require('local-highlight').setup()
      end
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.cursorline = true
-- vim.opt.cursorlineopt = "number"

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local function getLastNDirectoriesAsString(path, n)
    local separator = "/"
    -- Check if the path contains backslashes
    if path:find("\\") then
        separator = "\\"
    end

    local directories = {}
    for directory in path:gmatch("[^" .. separator .. "]+") do
        table.insert(directories, directory)
    end

    local numDirectories = #directories
    if numDirectories <= n then
        return table.concat(directories, separator)
    else
        local startIdx = numDirectories - n + 1
        return table.concat(directories, separator, startIdx)
    end
end

local function filenameFirst(_, path)
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
  parent = getLastNDirectoriesAsString(path, 3)
  if parent == "." then return tail end
  return string.format("%s\t\t%s", tail, parent)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopeResults",
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd("TelescopeParent", "\t\t.*$")
      vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
    end)
  end,
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
    path_display = filenameFirst,
  },
  pickers = {
    path_display = filenameFirst,
    lsp_references = {
      show_line = false
    }
  }
}


-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

require("catppuccin").setup({
  background = {
    light = "latte",
    dark = "mocha",
  },
  color_overrides = {
    latte = {
      rosewater = "#c14a4a",
      flamingo = "#c14a4a",
      red = "#c14a4a",
      maroon = "#c14a4a",
      pink = "#945e80",
      mauve = "#945e80",
      peach = "#c35e0a",
      yellow = "#b47109",
      green = "#6c782e",
      teal = "#4c7a5d",
      sky = "#4c7a5d",
      sapphire = "#4c7a5d",
      blue = "#45707a",
      lavender = "#45707a",
      text = "#654735",
      subtext1 = "#73503c",
      subtext0 = "#805942",
      overlay2 = "#8c6249",
      overlay1 = "#8c856d",
      overlay0 = "#a69d81",
      surface2 = "#bfb695",
      surface1 = "#d1c7a3",
      surface0 = "#e3dec3",
      base = "#f9f5d7",
      mantle = "#f0ebce",
      crust = "#e8e3c8",
    },
    mocha = {
      rosewater = "#ea6962",
      flamingo = "#ea6962",
      red = "#ea6962",
      maroon = "#ea6962",
      pink = "#d3869b",
      mauve = "#d3869b",
      peach = "#e78a4e",
      yellow = "#d8a657",
      green = "#a9b665",
      teal = "#89b482",
      sky = "#89b482",
      sapphire = "#89b482",
      blue = "#7daea3",
      lavender = "#7daea3",
      text = "#ebdbb2",
      subtext1 = "#d5c4a1",
      subtext0 = "#bdae93",
      overlay2 = "#a89984",
      overlay1 = "#928374",
      overlay0 = "#595959",
      surface2 = "#4d4d4d",
      surface1 = "#404040",
      surface0 = "#292929",
      base = "#1d2021",
      mantle = "#191b1c",
      crust = "#141617",
    },
  },
  transparent_background = false,
  show_end_of_buffer = false,
  integration_default = false,
  integrations = {
    barbecue = { dim_dirname = true, bold_basename = true, dim_context = false, alt_background = false },
    cmp = true,
    gitsigns = true,
    hop = true,
    illuminate = { enabled = true },
    native_lsp = { enabled = true, inlay_hints = { background = true } },
    neogit = true,
    neotree = true,
    semantic_tokens = true,
    treesitter = true,
    treesitter_context = true,
    vimwiki = true,
    which_key = true,
  },
  highlight_overrides = {
    all = function(colors)
      return {
        CmpItemMenu = { fg = colors.surface2 },
        CursorLineNr = { fg = colors.text },
        FloatBorder = { bg = colors.base, fg = colors.surface0 },
        GitSignsChange = { fg = colors.peach },
        LineNr = { fg = colors.overlay0 },
        LspInfoBorder = { link = "FloatBorder" },
        NeoTreeDirectoryIcon = { fg = colors.subtext1 },
        NeoTreeDirectoryName = { fg = colors.subtext1 },
        NeoTreeFloatBorder = { link = "TelescopeResultsBorder" },
        NeoTreeGitConflict = { fg = colors.red },
        NeoTreeGitDeleted = { fg = colors.red },
        NeoTreeGitIgnored = { fg = colors.overlay0 },
        NeoTreeGitModified = { fg = colors.peach },
        NeoTreeGitStaged = { fg = colors.green },
        NeoTreeGitUnstaged = { fg = colors.red },
        NeoTreeGitUntracked = { fg = colors.green },
        NeoTreeIndent = { fg = colors.surface1 },
        NeoTreeNormal = { bg = colors.mantle },
        NeoTreeNormalNC = { bg = colors.mantle },
        NeoTreeRootName = { fg = colors.subtext1, style = { "bold" } },
        NeoTreeTabActive = { fg = colors.text, bg = colors.mantle },
        NeoTreeTabInactive = { fg = colors.surface2, bg = colors.crust },
        NeoTreeTabSeparatorActive = { fg = colors.mantle, bg = colors.mantle },
        NeoTreeTabSeparatorInactive = { fg = colors.crust, bg = colors.crust },
        NeoTreeWinSeparator = { fg = colors.base, bg = colors.base },
        NormalFloat = { bg = colors.base },
        Pmenu = { bg = colors.mantle, fg = "" },
        PmenuSel = { bg = colors.surface0, fg = "" },
        TelescopePreviewBorder = { bg = colors.crust, fg = colors.crust },
        TelescopePreviewNormal = { bg = colors.crust },
        TelescopePreviewTitle = { fg = colors.crust, bg = colors.crust },
        TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
        TelescopePromptCounter = { fg = colors.mauve, style = { "bold" } },
        TelescopePromptNormal = { bg = colors.surface0 },
        TelescopePromptPrefix = { bg = colors.surface0 },
        TelescopePromptTitle = { fg = colors.surface0, bg = colors.surface0 },
        TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
        TelescopeResultsNormal = { bg = colors.mantle },
        TelescopeResultsTitle = { fg = colors.mantle, bg = colors.mantle },
        TelescopeSelection = { bg = colors.surface0 },
        VertSplit = { bg = colors.base, fg = colors.surface0 },
        WhichKeyFloat = { bg = colors.mantle },
        YankHighlight = { bg = colors.surface2 },
        FidgetTask = { fg = colors.subtext1 },
        FidgetTitle = { fg = colors.peach },

        IblIndent = { fg = colors.surface0 },
        IblScope = { fg = colors.overlay0 },

        Boolean = { fg = colors.mauve },
        Number = { fg = colors.mauve },
        Float = { fg = colors.mauve },

        PreProc = { fg = colors.mauve },
        PreCondit = { fg = colors.mauve },
        Include = { fg = colors.mauve },
        Define = { fg = colors.mauve },
        Conditional = { fg = colors.red },
        Repeat = { fg = colors.red },
        Keyword = { fg = colors.red },
        Typedef = { fg = colors.red },
        Exception = { fg = colors.red },
        Statement = { fg = colors.red },

        Error = { fg = colors.red },
        StorageClass = { fg = colors.peach },
        Tag = { fg = colors.peach },
        Label = { fg = colors.peach },
        Structure = { fg = colors.peach },
        Operator = { fg = colors.peach },
        Title = { fg = colors.peach },
        Special = { fg = colors.yellow },
        SpecialChar = { fg = colors.yellow },
        Type = { fg = colors.yellow, style = { "bold" } },
        Function = { fg = colors.green, style = { "bold" } },
        Delimiter = { fg = colors.subtext1 },
        Ignore = { fg = colors.subtext1 },
        Macro = { fg = colors.teal },

        TSAnnotation = { fg = colors.mauve },
        TSAttribute = { fg = colors.mauve },
        TSBoolean = { fg = colors.mauve },
        TSCharacter = { fg = colors.teal },
        TSCharacterSpecial = { link = "SpecialChar" },
        TSComment = { link = "Comment" },
        TSConditional = { fg = colors.red },
        TSConstBuiltin = { fg = colors.mauve },
        TSConstMacro = { fg = colors.mauve },
        TSConstant = { fg = colors.text },
        TSConstructor = { fg = colors.green },
        TSDebug = { link = "Debug" },
        TSDefine = { link = "Define" },
        TSEnvironment = { link = "Macro" },
        TSEnvironmentName = { link = "Type" },
        TSError = { link = "Error" },
        TSException = { fg = colors.red },
        TSField = { fg = colors.blue },
        TSFloat = { fg = colors.mauve },
        TSFuncBuiltin = { fg = colors.green },
        TSFuncMacro = { fg = colors.green },
        TSFunction = { fg = colors.green },
        TSFunctionCall = { fg = colors.green },
        TSInclude = { fg = colors.red },
        TSKeyword = { fg = colors.red },
        TSKeywordFunction = { fg = colors.red },
        TSKeywordOperator = { fg = colors.peach },
        TSKeywordReturn = { fg = colors.red },
        TSLabel = { fg = colors.peach },
        TSLiteral = { link = "String" },
        TSMath = { fg = colors.blue },
        TSMethod = { fg = colors.green },
        TSMethodCall = { fg = colors.green },
        TSNamespace = { fg = colors.yellow },
        TSNone = { fg = colors.text },
        TSNumber = { fg = colors.mauve },
        TSOperator = { fg = colors.peach },
        TSParameter = { fg = colors.text },
        TSParameterReference = { fg = colors.text },
        TSPreProc = { link = "PreProc" },
        TSProperty = { fg = colors.blue },
        TSPunctBracket = { fg = colors.text },
        TSPunctDelimiter = { link = "Delimiter" },
        TSPunctSpecial = { fg = colors.blue },
        TSRepeat = { fg = colors.red },
        TSStorageClass = { fg = colors.peach },
        TSStorageClassLifetime = { fg = colors.peach },
        TSStrike = { fg = colors.subtext1 },
        TSString = { fg = colors.teal },
        TSStringEscape = { fg = colors.green },
        TSStringRegex = { fg = colors.green },
        TSStringSpecial = { link = "SpecialChar" },
        TSSymbol = { fg = colors.text },
        TSTag = { fg = colors.peach },
        TSTagAttribute = { fg = colors.green },
        TSTagDelimiter = { fg = colors.green },
        TSText = { fg = colors.green },
        TSTextReference = { link = "Constant" },
        TSTitle = { link = "Title" },
        TSTodo = { link = "Todo" },
        TSType = { fg = colors.yellow, style = { "bold" } },
        TSTypeBuiltin = { fg = colors.yellow, style = { "bold" } },
        TSTypeDefinition = { fg = colors.yellow, style = { "bold" } },
        TSTypeQualifier = { fg = colors.peach, style = { "bold" } },
        TSURI = { fg = colors.blue },
        TSVariable = { fg = colors.text },
        TSVariableBuiltin = { fg = colors.mauve },

        ["@annotation"] = { link = "TSAnnotation" },
        ["@attribute"] = { link = "TSAttribute" },
        ["@boolean"] = { link = "TSBoolean" },
        ["@character"] = { link = "TSCharacter" },
        ["@character.special"] = { link = "TSCharacterSpecial" },
        ["@comment"] = { link = "TSComment" },
        ["@conceal"] = { link = "Grey" },
        ["@conditional"] = { link = "TSConditional" },
        ["@constant"] = { link = "TSConstant" },
        ["@constant.builtin"] = { link = "TSConstBuiltin" },
        ["@constant.macro"] = { link = "TSConstMacro" },
        ["@constructor"] = { link = "TSConstructor" },
        ["@debug"] = { link = "TSDebug" },
        ["@define"] = { link = "TSDefine" },
        ["@error"] = { link = "TSError" },
        ["@exception"] = { link = "TSException" },
        ["@field"] = { link = "TSField" },
        ["@float"] = { link = "TSFloat" },
        ["@function"] = { link = "TSFunction" },
        ["@function.builtin"] = { link = "TSFuncBuiltin" },
        ["@function.call"] = { link = "TSFunctionCall" },
        ["@function.macro"] = { link = "TSFuncMacro" },
        ["@include"] = { link = "TSInclude" },
        ["@keyword"] = { link = "TSKeyword" },
        ["@keyword.function"] = { link = "TSKeywordFunction" },
        ["@keyword.operator"] = { link = "TSKeywordOperator" },
        ["@keyword.return"] = { link = "TSKeywordReturn" },
        ["@label"] = { link = "TSLabel" },
        ["@math"] = { link = "TSMath" },
        ["@method"] = { link = "TSMethod" },
        ["@method.call"] = { link = "TSMethodCall" },
        ["@namespace"] = { link = "TSNamespace" },
        ["@none"] = { link = "TSNone" },
        ["@number"] = { link = "TSNumber" },
        ["@operator"] = { link = "TSOperator" },
        ["@parameter"] = { link = "TSParameter" },
        ["@parameter.reference"] = { link = "TSParameterReference" },
        ["@preproc"] = { link = "TSPreProc" },
        ["@property"] = { link = "TSProperty" },
        ["@punctuation.bracket"] = { link = "TSPunctBracket" },
        ["@punctuation.delimiter"] = { link = "TSPunctDelimiter" },
        ["@punctuation.special"] = { link = "TSPunctSpecial" },
        ["@repeat"] = { link = "TSRepeat" },
        ["@storageclass"] = { link = "TSStorageClass" },
        ["@storageclass.lifetime"] = { link = "TSStorageClassLifetime" },
        ["@strike"] = { link = "TSStrike" },
        ["@string"] = { link = "TSString" },
        ["@string.escape"] = { link = "TSStringEscape" },
        ["@string.regex"] = { link = "TSStringRegex" },
        ["@string.special"] = { link = "TSStringSpecial" },
        ["@symbol"] = { link = "TSSymbol" },
        ["@tag"] = { link = "TSTag" },
        ["@tag.attribute"] = { link = "TSTagAttribute" },
        ["@tag.delimiter"] = { link = "TSTagDelimiter" },
        ["@text"] = { link = "TSText" },
        ["@text.danger"] = { link = "TSDanger" },
        ["@text.diff.add"] = { link = "diffAdded" },
        ["@text.diff.delete"] = { link = "diffRemoved" },
        ["@text.emphasis"] = { link = "TSEmphasis" },
        ["@text.environment"] = { link = "TSEnvironment" },
        ["@text.environment.name"] = { link = "TSEnvironmentName" },
        ["@text.literal"] = { link = "TSLiteral" },
        ["@text.math"] = { link = "TSMath" },
        ["@text.note"] = { link = "TSNote" },
        ["@text.reference"] = { link = "TSTextReference" },
        ["@text.strike"] = { link = "TSStrike" },
        ["@text.strong"] = { link = "TSStrong" },
        ["@text.title"] = { link = "TSTitle" },
        ["@text.todo"] = { link = "TSTodo" },
        ["@text.todo.checked"] = { link = "Green" },
        ["@text.todo.unchecked"] = { link = "Ignore" },
        ["@text.underline"] = { link = "TSUnderline" },
        ["@text.uri"] = { link = "TSURI" },
        ["@text.warning"] = { link = "TSWarning" },
        ["@todo"] = { link = "TSTodo" },
        ["@type"] = { link = "TSType" },
        ["@type.builtin"] = { link = "TSTypeBuiltin" },
        ["@type.definition"] = { link = "TSTypeDefinition" },
        ["@type.qualifier"] = { link = "TSTypeQualifier" },
        ["@uri"] = { link = "TSURI" },
        ["@variable"] = { link = "TSVariable" },
        ["@variable.builtin"] = { link = "TSVariableBuiltin" },

        ["@lsp.type.class"] = { link = "TSType" },
        ["@lsp.type.comment"] = { link = "TSComment" },
        ["@lsp.type.decorator"] = { link = "TSFunction" },
        ["@lsp.type.enum"] = { link = "TSType" },
        ["@lsp.type.enumMember"] = { link = "TSProperty" },
        ["@lsp.type.events"] = { link = "TSLabel" },
        ["@lsp.type.function"] = { link = "TSFunction" },
        ["@lsp.type.interface"] = { link = "TSType" },
        ["@lsp.type.keyword"] = { link = "TSKeyword" },
        ["@lsp.type.macro"] = { link = "TSConstMacro" },
        ["@lsp.type.method"] = { link = "TSMethod" },
        ["@lsp.type.modifier"] = { link = "TSTypeQualifier" },
        ["@lsp.type.namespace"] = { link = "TSNamespace" },
        ["@lsp.type.number"] = { link = "TSNumber" },
        ["@lsp.type.operator"] = { link = "TSOperator" },
        ["@lsp.type.parameter"] = { link = "TSParameter" },
        ["@lsp.type.property"] = { link = "TSProperty" },
        ["@lsp.type.regexp"] = { link = "TSStringRegex" },
        ["@lsp.type.string"] = { link = "TSString" },
        ["@lsp.type.struct"] = { link = "TSType" },
        ["@lsp.type.type"] = { link = "TSType" },
        ["@lsp.type.typeParameter"] = { link = "TSTypeDefinition" },
        ["@lsp.type.variable"] = { link = "TSVariable" },
      }
    end,
    latte = function(colors)
      return {
        IblIndent = { fg = colors.mantle },
        IblScope = { fg = colors.surface1 },

        LineNr = { fg = colors.surface1 },
      }
    end,
  },
})
--
-- require("catppuccin").setup({
--   integrations = {
--     cmp = true,
--     gitsigns = true,
--     nvimtree = true,
--     treesitter = true,
--     notify = false,
--     harpoon = true,
--     mini = {
--       enabled = true,
--       indentscope_color = "",
--     },
--     native_lsp = {
--       enabled = true,
--       virtual_text = {
--         errors = { "italic" },
--         hints = { "italic" },
--         warnings = { "italic" },
--         information = { "italic" },
--       },
--       underlines = {
--         errors = { "underline" },
--         hints = { "underline" },
--         warnings = { "underline" },
--         information = { "underline" },
--       },
--       inlay_hints = {
--         background = true,
--       },
--     },
--   },
	-- color_overrides = {
	-- 	mocha = {
	-- 		rosewater = "#efc9c2",
	-- 		flamingo = "#ebb2b2",
	-- 		pink = "#f2a7de",
	-- 		mauve = "#b889f4",
	-- 		red = "#ea7183",
	-- 		maroon = "#ea838c",
	-- 		peach = "#f39967",
	-- 		yellow = "#eaca89",
	-- 		green = "#96d382",
	-- 		teal = "#78cec1",
	-- 		sky = "#91d7e3",
	-- 		sapphire = "#68bae0",
	-- 		blue = "#739df2",
	-- 		lavender = "#a0a8f6",
	-- 		text = "#b5c1f1",
	-- 		subtext1 = "#a6b0d8",
	-- 		subtext0 = "#959ec2",
	-- 		overlay2 = "#848cad",
	-- 		overlay1 = "#717997",
	-- 		overlay0 = "#63677f",
	-- 		surface2 = "#505469",
	-- 		surface1 = "#3e4255",
	-- 		surface0 = "#2c2f40",
	-- 		base = "#1a1c2a",
	-- 		mantle = "#141620",
	-- 		crust = "#0e0f16",
	-- 	},
	-- },
  --  color_overrides = {
  --    all = {
  --      base = "#000000",
  --      mantle = "#000000",
  --      crust = "#000000",
  --    },
  --  }
  --})

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end

local chrono_path = 'C:/Users/thomas-51/chronicle-server/'

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, { desc = 'Search [G]it [S]tatus' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>v', ':e $MYVIMRC<CR>' , { desc = 'opens nvim init lua' })
vim.keymap.set('n', '<leader>ch', ':e ' .. chrono_path .. 'docs/openapi/chronicle.yaml<CR>', { desc = 'opens nvim init lua' })
vim.keymap.set('n', '<Esc>', ':noh<CR>')

local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<leader>h", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>j", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>k", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>l", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-h>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():next() end)

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
    modules = {},
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']c'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[c'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>z'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>Z'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
-- require('which-key').register({
--   ['<leader>'] = { name = 'VISUAL <leader>' },
--   ['<leader>g'] = { 'Git [H]unk' },
-- }, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

require('lspconfig').yamlls.setup {
  settings = {
    yaml = {
      schemas = { 'https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.json' },
    }
  }
}

require('lspconfig').gdscript.setup({
  cmd = {'ncat', 'localhost', '6008'},
  on_attach = on_attach
})

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

vim.o.background = "dark"
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "hard", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd([[colorscheme catppuccin-mocha]])

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
