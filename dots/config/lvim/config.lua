-- VimCore & LVim Options {{{
-- https://www.lunarvim.org/configuration/01-settings.html#example-options

-- {{{ VARS
local function init_userdata()
  local function get_terminal() return require('toggleterm.terminal').Terminal end

  local __TerminalTogglers = {}

  return {
    exclude_filetypes = { '', 'prompt', 'aerial', 'TelescopePrompt', 'dashboard', 'netrw', 'Outline', 'tagbar',
      'NvimTree', 'SidebarNvim' },
    assign_outmakers = function(makeprg, relpath)
      local bldpath = [[$MY_PROJECT_ROOT/build/]] .. relpath
      vim.cmd([[setlocal mp=cd\ ]] .. bldpath .. [[\ &&\ ]] .. makeprg .. [[\ make\ -j8\ ]])
      vim.cmd([[wa]])
      vim.cmd([[make]])
    end,
    terminal_cmd_toggle = function(cmd)
      local _, __Terminal = pcall(get_terminal)
      print(vim.fn.expand("%:p:h", true))
      if not __Terminal then
        return nil
      elseif __TerminalTogglers[cmd] == nil then
        local opts = { cmd = cmd }
        table.insert(opts, { hidden = true, direction = "float", float_opts = { border = "shadow" } })
        __TerminalTogglers[cmd] = __Terminal:new(opts)
      end
      return __TerminalTogglers[cmd]:toggle()
    end,
  }
end

lvim.userdata = init_userdata()
--  }}}

local function init_vim_options()
  vim.o.guifont = "UbuntuMono Nerd Font:h12"
  vim.o.expandtab = true
  vim.o.tabstop = 4
  vim.o.shiftwidth = 4
  vim.o.foldmethod = 'expr'
  vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
  vim.o.foldlevel = 20 -- default folding in general breaks preview plugins (since file content is shown folded)
  vim.o.foldlevelstart = 20
  vim.o.relativenumber = true

  lvim.log.level = "warn"
  lvim.format_on_save = false
  -- lvim.colorscheme = "onedarker"
end

init_vim_options()
-- }}}

-- Key Mappings {{{
local function init_keymaps()
  -- local map = vim.api.nvim_set_keymap
  -- local opts = { noremap = true, silent = true }
  -- map('n', '<A-l>', ':BufferLineMoveNext<CR>', opts)

  lvim.leader = "space" -- view all the defaults by pressing <leader>Lk
  lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
  vim.cmd [[
              nmap  -  <Plug>(choosewin)
              nmap     <C-F>f <Plug>CtrlSFPrompt
              vmap     <C-F>f <Plug>CtrlSFVwordPath
              vmap     <C-F>F <Plug>CtrlSFVwordExec
              nmap     <C-F>n <Plug>CtrlSFCwordPath
              nmap     <C-F>p <Plug>CtrlSFPwordPath
              nnoremap <C-F>o :CtrlSFOpen<CR>
              nnoremap <C-F>t :CtrlSFToggle<CR>
              inoremap <C-F>t <Esc>:CtrlSFToggle<CR>
    ]]

  -- plugin works only when ft=markdown which is not always convinient, try to fool it by calling with filename
  lvim.keys.normal_mode["<A-m>"]     = ":Glow %<CR>"

  -- Magic buffer-picking mode
  lvim.keys.normal_mode["<A-l>"]     = ":BufferLineCycleNext<CR>"
  lvim.keys.normal_mode["<A-h>"]     = ":BufferLineCyclePrev<CR>"
  lvim.keys.normal_mode["<A-S-l>"]   = ":BufferLineMoveNext<CR>"
  lvim.keys.normal_mode["<A-S-h>"]   = ":BufferLineMovePrev<CR>"
  lvim.keys.normal_mode["<A-S-o>"]   = ":BufferLinePick<CR>"

  -- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
  -- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
  local _, actions = pcall(require, "telescope.actions")
  lvim.builtin.telescope.defaults.mappings = {
    -- for input mode
    i = {
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
      ["<C-n>"] = actions.cycle_history_next,
      ["<C-p>"] = actions.cycle_history_prev,
    },
    -- for normal mode
    n = {
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
    },
  }
end

init_keymaps()
-- }}}

-- Predefined Plugins {{{
local function init_plugins_builtin()

  lvim.builtin.bufferline.active = true -- tabs with open buffers atop of vim
  lvim.builtin.autopairs.active = false -- hate auto pairs

  --lvim.builtin.dashboard.active = true
  lvim.builtin.notify.active = true -- gh:'rcarriga/nvim-notify', popup notifications
  lvim.builtin.terminal.active = true
  lvim.builtin.nvimtree.setup.view.side = "right"
  -- lvim.builtin.nvimtree.show_icons.git = 0
  lvim.builtin.project.detection_methods = { "pattern", "lsp" }
  lvim.builtin.project.patterns = { ".git", ".svn", "Makefile", "package.json", "main.*" }
  lvim.builtin.project.silent_chdir = false

  -- https://www.lunarvim.org/configuration/06-statusline.html ; lvim/core/lualine
  -- provides: mode, branch, filename, diff, python_env, diagnostics, treesitter, lsp, location, progress, spaces, encoding, filetype, scrollbar
  local ts = require('nvim-treesitter')
  local ll = lvim.builtin.lualine
  local llc = require("lvim.core.lualine.components")
  local cc = require("lvim.core.lualine.colors")
  local z_hhmm = { function() return os.date("%H:%M") end, cond = llc.hide_in_width, color = { fg = cc.darkblue }, }
  local z_codecoord = { function() return ts.statusline(700) end, cond = llc.hide_in_width, color = { fg = cc.purple } }
  local z_fn = { "filename", cond = nil, color = { gui = "bold", fg = cc.orange }, }
  ll.style = "default" -- "lvim" "none"; "default" allows to customize as lvim's docs say
  ll.sections.lualine_a = { z_hhmm, } -- time on the color which represents current mode
  ll.sections.lualine_b = { llc.branch, llc.diff, }
  ll.sections.lualine_c = { z_fn, z_codecoord, }
  ll.sections.lualine_x = { llc.diagnostics, llc.treesitter, llc.lsp, llc.filetype, }
  ll.sections.lualine_y = { llc.scrollbar, llc.progress, "location" }
  ll.sections.lualine_z = { { "o:encoding", fmt = string.upper, color = { fg = cc.darkblue } } }
  ll.options.disabled_filetypes = lvim.userdata.exclude_filetypes

  lvim.builtin.treesitter.ensure_installed = {
    "bash", "python", "c", "cpp", "lua", "dockerfile", "typescript", "javascript", "css", "html", "json", "markdown", "yaml", "toml", "markdown",

  }
  lvim.builtin.treesitter.ignore_install = { "lua", "haskell" } -- lua always give weird errors
  lvim.builtin.treesitter.highlight.enabled = true
  lvim.builtin.treesitter.rainbow = {
    enable = true, -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
  }
end

init_plugins_builtin()
-- }}}

-- Additional Plugins {{{
local function init_plugins_manual()
  -- INFO https://github.com/rockerBOO/awesome-neovim
  -- {'ghuser/ghprj',
  -- setup = function()
  --   vim.g.some_global = "some value"
  --   vim.cmd [[let g:some_global = "some value"]]
  -- end, },
  lvim.plugins = {

    -- {'TimUntersberger/neogit'}, -- lazygit does the same - and more pretty
    -- { 'nvim-telescope/telescope-media-files.nvim' },

    -- INTEGRATIONS
    { 'is0n/fm-nvim' }, -- use your favorite terminal file managers (and fuzzy finders)
    { 'aspeddro/gitui.nvim' },
    { 'ellisonleao/glow.nvim', setup = function()
      vim.g.glow_width = 200
    end }, 
    { 'junegunn/limelight.vim' },
    { 'junegunn/goyo.vim', setup = function()
      vim.g.goyo_width = "80%+5%"
    end },
    -- {'itchyny/calendar.vim', setup = function() -- it's too slow
    --         vim.g.calendar_google_calendar = 0
    --         vim.g.calendar_google_task = 0
    --     end, },

    -- HELPERS
    { 'zakharykaplan/nvim-retrail' }, -- highlight & trim trailing whitespace upon :write.
    { 'vim-scripts/Rename2' },

    -- EDITING
    { 'kylechui/nvim-surround', setup = function() -- operate on surrounding pairs - quotes, braces, tags, ts-objs
        --[[ insert = "<C-g>s", insert_line = "<C-g>S";
            q = any-quote `"', b = brace , t = tag, f = function << csqb changes newares quote to parentheses
            modes: ato=around-text-obj, acl=arounf-current-line
            normal: ato="ys", acl="yS" (curline shortcuts: yss, ySS)
            visual: ato="S", acl="gS";
            delete="ds"; change="cs" ]]
        end
    },
    { 'nvim-treesitter/nvim-treesitter' -- syntax aware text-objects, select, move, swap, and peek support.
            --[[ TODO: learn it ]]
    },

    -- DECORATIONS
    { 'm-demare/hlargs.nvim' }, -- highlight arguments' definitions and usages, asynchronously, using Treesitter
    { 'Pocco81/HighStr.nvim' }, -- Permanently highlight selection
    { 'haringsrob/nvim_context_vt' }, -- Shows virtual text of the current context at the end of: functions, if, for, ...
    { 'p00f/nvim-ts-rainbow' }, -- Rainbow parentheses for neovim using tree-sitter
    -- {'wfxr/minimap.vim'} -- works weird - QuickFix appears small and ugly, layouts become broken
    { 'dstein64/nvim-scrollview', setup = function()
      vim.g.scrollview_on_startup = 1
      vim.g.scrollview_current_only = 1
      vim.g.scrollview_excluded_filetypes = lvim.userdata.exclude_filetypes
    end },
    -- {'petertriho/nvim-scrollbar', setup = { excluded_filetypes = lvim.userdata.exclude_filetypes }}, -- not working
    -- {'pangloss/vim-javascript', setup = function() -- Vastly improved Javascript indentation and syntax support in Vim
    --         vim.g.javascript_plugin_jsdoc = 1
    --     end, }, -- this plugin gives random-character coloring around the code what is very annoying
    -- {'pseewald/vim-anyfold'}, -- folds are pretty unusable since preview windows content is folded too

    -- SEARCH/FIND
    { 'rlane/pounce.nvim' }, -- incremental fuzzy search on motions
    { 'woosaaahh/sj.nvim' }, -- quick-jump search
    { 'voldikss/vim-skylight',
      setup = function() -- Search for file/symbol/word under cursor and preview in the floating window.
        vim.g.skylight_opener = 'drop' -- jump to location using the same split the search was performed in
      end, }, -- <C>w-p to jump to preview window and back
    { 'dyng/ctrlsf.vim', setup = function()
      vim.g.ctrlsf_position = 'left'
      vim.g.ctrlsf_auto_focus = { at = "start" }
    end, },
    { 'kevinhwang91/nvim-bqf' }, -- better quickfix window,

    -- FILETYPES
    { 'hauleth/vim-encpipe' }, -- files encoded by encpipe, with '.enc' extension
    { 'bfrg/vim-jq' },
    -- {'bfrg/vim-jqplay'}, -- pretty useless, have dedicated shell scripts for that
    { 'aserebryakov/vim-todo-lists' },
    { 'bfrg/vim-cpp-modern', setup = function() -- Enhanced C and C++ syntax highlighting
      vim.g.cpp_function_highlight = 1
      vim.g.cpp_attributes_highlight = 1
      vim.g.cpp_member_highlight = 1
      vim.g.cpp_simple_highlight = 1
    end, },

    -- DIAGNOSTICS
    { "folke/trouble.nvim" },
    { "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim" },

    -- CODE MANIPULATIONS
    { 'sbdchd/neoformat' },
    { 'folke/todo-comments.nvim', config = function() require("todo-comments").setup {} end, }, -- use :Todo... commands

    -- SYMBOLS NAVIGATION
    -- { 'ludovicchabant/vim-gutentags' },
    { "romgrk/nvim-treesitter-context" },
    { 'sidebar-nvim/sidebar.nvim', config = function() require("sidebar-nvim").setup(
        { open = false, side = "left", sections = { "symbols", "git", "todos", "diagnostics", }, })
    end },
    -- main rule is: left side - tree-sitter based outliners (should be used in general as fastest),
    -- right side - ctags-based (they may be pretty slow on big files)
    { 'simrat39/symbols-outline.nvim', setup = function() vim.g.symbols_outline = { width = 40, position = "left" } end, },
    -- very concise representation, works fast, tree-sitter based
    { 'stevearc/aerial.nvim', config = function()
      require "aerial".setup({
        -- backends = { cpp = {}, lua = {} }, -- gives non-stop errors on c++ sources, disable; after update 'lua' also works bad
        -- open_automatic = true,
        default_direction = "prefer_left",
      })
    end, },
    -- eats processor on huge (1000+ locs) js files, pure ctags; sometimes breaks layout when toggled after other outlines
    { 'preservim/tagbar', setup = function()
      vim.g.tagbar_position = "right"
      vim.g.tagbar_autofocus = 0
    end, },
    -- strange view, works with huge js, can have lsp backends (which aint work for cpp), by default uses ctags
    { 'liuchengxu/vista.vim', setup = function()
      vim.g.vista_stay_on_open = 0
      -- vim.g.vista_sidebar_position = "right" -- any attemp to use this option leads to total mess
    end, },

    -- CONTENT NAVIGATION
    { 'chentoast/marks.nvim' }, -- interact and manipulate vim marks
    { 'zhimsel/vim-stay' }, -- restore cursor pos when reopen file
    { 't9md/vim-choosewin' }, -- choose win in complex layouts with '-' key
    { 'cappyzawa/trim.nvim' }, -- trim ws on save
    { 'tpope/vim-unimpaired' }, -- complementary pairs of mappings
    { 'xiyaowong/nvim-cursorword' }, -- underline words similar to one under cursor
    { "max397574/better-escape.nvim" }, -- jk in insert mode acts as <esc>
    -- { 'Kristoffer-PBS/interesting-words.nvim' }, -- highlight words in the buffer
    { 'lukas-reineke/indent-blankline.nvim', setup = function() -- draw vertical lines as indent markers
      vim.g.indent_blankline_filetype_exclude = lvim.userdata.exclude_filetypes
    end },
    { 'jinh0/eyeliner.nvim' }, -- color unique char in the line to speed up f/F to the corresponding word

    -- COLORSCHEMES
    -- { "abzcoding/zephyr-nvim" }, << this theme uses treesitter in an invalid way which gives permanent erros
    -- INFO: color schemes as they appear in <leader>C menu
    { "sjl/badwolf" }, { 'rockerBOO/boo-colorscheme-nvim' }, { 'tomasiser/vim-code-dark' }, { 'catppuccin/nvim', as = "catppuccin" },
    { "abzcoding/doom-one.nvim" }, { 'Everblush/everblush.nvim', as = 'everblush' }, { 'cocopon/iceberg.vim' }, { 'marko-cerovac/material.nvim' },
    { 'rafamadriz/neon' }, { 'sainnhe/sonokai' }, { "rose-pine/neovim" }, -- +onedarker which is buildin
    { "folke/tokyonight.nvim" }, { 'jsit/toast.vim' },
    -- INFO: not working schemes: they do not color the coda
    -- { "kyoz/purify", rtp = "vim" }, { "nanotech/jellybeans.vim" }, { "arcticicestudio/nord-vim" }, { "jacoborus/tender.vim" },
    -- { "morhetz/gruvbox" }, { "tomasr/molokai" }, { "dracula/vim" }, { "jnurmine/Zenburn" },
    -- { 'savq/melange' }, { 'bluz71/vim-moonfly-colors' }, { 'liuchengxu/space-vim-theme' },
    -- { 'Shatur/neovim-ayu' }, { 'EdenEast/nightfox.nvim' }, { 'rebelot/kanagawa.nvim' },
    -- { 'AlessandroYorba/Despacio', setup = function() vim.g.despacio_Pitc = 1 end },
    -- { 'junegunn/seoul256.vim', setup = function() vim.g.seoul256_background = 233 end }, --[[233=darkest, 236=lightest; not working here]]
  }
end

init_plugins_manual()
-- }}}


-- Which Keys {{{
local function init_whichkeys_menu()
  lvim.builtin.which_key.vmappings["H"] = {
    name = "Highlight",
    H = { ":<c-u>HSRmHighlight<CR>", "UnDo" },
    h = { ":<c-u>HSHighlight<CR>", "Do" },
    ["0"] = { ":<c-u>HSHighlight 0<CR>", "Do 0" },
    ["1"] = { ":<c-u>HSHighlight 1<CR>", "Do 1" },
    ["2"] = { ":<c-u>HSHighlight 2<CR>", "Do 2" },
    ["3"] = { ":<c-u>HSHighlight 3<CR>", "Do 3" },
    ["4"] = { ":<c-u>HSHighlight 4<CR>", "Do 4" },
    ["5"] = { ":<c-u>HSHighlight 5<CR>", "Do 5" },
    ["6"] = { ":<c-u>HSHighlight 6<CR>", "Do 6" },
    ["7"] = { ":<c-u>HSHighlight 7<CR>", "Do 7" },
    ["8"] = { ":<c-u>HSHighlight 8<CR>", "Do 8" },
    ["9"] = { ":<c-u>HSHighlight 9<CR>", "Do 9" },
  }

  lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

  -- lvim.builtin.which_key.mappings.g.G = {":lua lvim.userdata.terminal_cmd_toggle('gitui')<cr>", "GitUI"}
  lvim.builtin.which_key.mappings.H = {
    name = "+Highlight",
    g = { ":Goyo<cr>", "Toggle Goyo" },
    G = { ":Glow!<cr>", "Preview MD in Glow" },
    l = { ":Limelight!!<cr>", "Toggle LimeLight" },
  }

  lvim.builtin.which_key.mappings.l.D = { ":ToggleDiag<cr>", "Toggle Diagnostics" }
  lvim.builtin.which_key.mappings.l.t = {
    name = "+Toggle Options",
    u = { "<Plug>(toggle-lsp-diag-underline)<cr>", "Underline" },
    s = { "<Plug>(toggle-lsp-diag-signs)<cr>", "Signs" },
    v = { "<Plug>(toggle-lsp-diag-vtext)<cr>", "Virtual Text" },
    i = { "<Plug>(toggle-lsp-diag-update_in_insert)<cr>", "Upd-On-Ins" },
    t = { "<Plug>(toggle-lsp-diag)<cr>", "-- All --" },
    d = { "<Plug>(toggle-lsp-diag-default)<cr>", "Defaults" },
    o = { "<Plug>(toggle-lsp-diag-off)<cr>", "On" },
    O = { "<Plug>(toggle-lsp-diag-on)<cr>", "Off" },

  }
  lvim.builtin.which_key.mappings.g.G = { ":Gitui<cr>", "GitUI" }
  lvim.builtin.which_key.mappings.g.f = {
    name = "+Fuzzy",
    l = { ":lua lvim.userdata.terminal_cmd_toggle('git fuzzy log')<cr>", "Log" },
    r = { ":lua lvim.userdata.terminal_cmd_toggle('git fuzzy reflog')<cr>", "RefLog" },
    s = { ":lua lvim.userdata.terminal_cmd_toggle('git fuzzy status')<cr>", "Status" },
    S = { ":lua lvim.userdata.terminal_cmd_toggle('git fuzzy stash')<cr>", "Stash" },
  }

  lvim.builtin.which_key.mappings.x = {
    name = "+Tools",
    a = { ":lua lvim.userdata.terminal_cmd_toggle('apts vivaldi && read')<cr>", "Bottom" },
    c = { [[:lua lvim.userdata.terminal_cmd_toggle('date && LANG=EN ccal -y -m && LANG=EN ccal && read -n 1')<cr>]],
      "Calendar" },
    -- M = {":Calendar -first_day=monday<cr>", "Calendar Month"},
    -- Y = {":Calendar -view=year -first_day=monday<cr>", "Calendar Year"},
    -- T = {":Calendar -view=clock<cr>", "Clock"},
    j = { [[:lua lvim.userdata.terminal_cmd_toggle('jqsh')<cr>]], "JQ shell" },
    l = { [[:lua lvim.userdata.terminal_cmd_toggle('lf')<cr>]], "LF" },
    L = { [[:lua lvim.userdata.terminal_cmd_toggle('xplr')<cr>]], "XPLR" },
    --n = {":lua lvim.userdata.terminal_cmd_toggle('nnn-nerd-static')<cr>", "NNN"},
    t = { ":lua lvim.userdata.terminal_cmd_toggle('tudu')<cr>", "TuDu" },
    T = { ":lua lvim.userdata.terminal_cmd_toggle('hnb')<cr>", "HierNoteBook" },
    p = { ":lua lvim.userdata.terminal_cmd_toggle('htop')<cr>", "Top" },
    P = { ":lua lvim.userdata.terminal_cmd_toggle('btm')<cr>", "Bottom" },
    w = { ":lua lvim.userdata.terminal_cmd_toggle('curl ru.wttr.in && read -n 1')<cr>", "Weather" },
  }

  lvim.builtin.which_key.mappings.b.E = { ":BufferLineSortByExtension<cr>", "Sort by extenstion" }
  lvim.builtin.which_key.mappings.b.F = { ":BufferLineSortByRelativeDir<cr>", "Sort by reldir" }
  lvim.builtin.which_key.mappings.b.R = { ":bufdo checktime<cr>", "Reload all open buffers if changed" }
  lvim.builtin.which_key.mappings.s.w = { ":Skylight! word<cr>", "Word UC in ThisBuf" }
  lvim.builtin.which_key.mappings.s.s = { ":Telescope resume<cr>", "Resume last search" }
  lvim.builtin.which_key.mappings.s.g = { ":Telescope grep_string<cr>", "Search for Word UC" }
  lvim.builtin.which_key.mappings.s.m = { ":Telescope media_files<cr>", "Search for Media" }
  lvim.builtin.which_key.mappings.s.j = { ":lua require('sj').run()<cr>", "Search/Jump" }
  lvim.builtin.which_key.mappings.s.p = { ":<cmd>Pounce<cr>", "Pounce" }
  lvim.builtin.which_key.mappings.s.P = { ":<cmd>PounceRepeat<cr>", "Pounce Repeat" }

  lvim.builtin.which_key.mappings["w"] = {
    name = "Compile",
    q = { ":lua lvim.userdata.assign_outmakers('', 'xwin/debug')<cr>", "Make XWin/Debug" },
    w = { ":lua lvim.userdata.assign_outmakers('emmake', 'wasm/relwithdebinfo')<cr>", "Make Wasm/RelWithDebInfo" }
  }

  lvim.builtin.which_key.mappings["t"] = {
    name = "+Trouble",
    r = { "<cmd>Trouble lsp_references<cr>", "References" },
    f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
    d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
    q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
    l = { "<cmd>Trouble loclist<cr>", "LocationList" },
    t = { "<cmd>TroubleToggle<cr>", "Toggle" },
    w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
  }

  lvim.builtin.which_key.mappings["o"] = {
    name = "+Outlines",
    -- M = { "<cmd>MinimapToggle<CR>", "Minimap Toggle" },
    -- m = { "<cmd>MinimapRefresh<CR>", "Minimap Refresh" },
    a = { "<cmd>AerialToggle!<CR>", "Aerial Toggle" },
    b = { "<cmd>SidebarNvimToggle<CR>", "SideBar Toggle" },
    s = { "<cmd>SymbolsOutline<CR>", "SymbolsOutline Toggle" },
    t = { "<cmd>TagbarToggle<CR>", "Tagbar Toggle" },
    v = { "<cmd>Vista!!<CR>", "Vista Toggle" },
  }

  lvim.builtin.which_key.mappings["C"] = {
    name = "+ColorSchemes",
    -- a = { ":colorscheme ayu-dark<CR>", "Ayu Dark" },
    -- A = { ":colorscheme ayu-mirage<CR>", "Ayu Mirage" },
    b = { ":colorscheme badwolf<CR>", "Bad Wolf" },
    B = { ":colorscheme boo<CR>", "Boo" },
    c = { ":colorscheme codedark<CR>", "Code Dark" },
    C = { ":colorscheme catppuccin<CR>", "Catppuccin" },
    d = { ":colorscheme doom-one<CR>", "Doom One" },
    e = { ":colorscheme everblush<CR>", "Everblush" },
    -- D = { ":colorscheme dracula<CR>", "Dracula" },
    -- f = { ":colorscheme despacio<CR>", "Despacio" },
    -- F = {
    --   name = "Fox",
    --   c = { ":colorscheme carbonfox<CR>", "Carbon" },
    --   d = { ":colorscheme dayfox<CR>", "Day" },
    --   D = { ":colorscheme dawnfox<CR>", "Dawn" },
    --   f = { ":colorscheme duskfox<CR>", "Dusk" },
    --   n = { ":colorscheme nightfox<CR>", "Night" },
    --   N = { ":colorscheme nordfox<CR>", "Nord" },
    --   t = { ":colorscheme terafox<CR>", "Tera" },
    -- },
    -- g = { ":colorscheme gruvbox<CR>", "Gruv Box" },
    i = { ":colorscheme iceberg<CR>", "Iceberg" },
    -- j = { ":colorscheme jellybeans<CR>", "Jellybeans" },
    -- k = { ":colorscheme kanagawa<CR>", "Kanagawa" },
    -- K = { ":colorscheme melange<CR>", "Melange" },
    -- L = { ":colorscheme moonfly<CR>", "Moonfly" },
    -- m = { ":colorscheme molokai<CR>", "Molokai" },
    M = { ":colorscheme material<CR>", "Material" },
    n = { ":colorscheme neon<CR>", "Neon" },
    -- N = { ":colorscheme nord<CR>", "Nord" },
    o = { ":colorscheme onedarker<CR>", "One Darker" },
    -- p = { ":colorscheme purify<CR>", "Purify" },
    r = { ":colorscheme rose-pine<CR>", "Rose Pine" },
    q = { ":colorscheme sonokai<CR>", "Sonokai" },
    -- s = { ":colorscheme space_vim_theme<CR>", "Space Vim" },
    -- S = { ":let g:seoul256_background = 233<CR>:colorscheme seoul256<CR>", "Seoul 256" },
    t = { ":colorscheme tokyonight<CR>", "TokyoNight" },
    -- T = { ":colorscheme tender<CR>", "Tender" },
    Y = { ":colorscheme toast<CR>", "Toast" },
    -- z = { ":colorscheme zephyr<CR>", "Zephir" },
    -- Z = { ":colorscheme zenburn<CR>", "Zenburn" },
  }
end

init_whichkeys_menu()
-- }}}

-- Autocommands {{{ (https://neovim.io/doc/user/autocmd.html)
local function init_autocommands()
  --      some vim's options (like vim.o.fmd) a changed multiple times by various scripts and plugins
  --      so it's not in general possible to set them up here in hooks
  -- lvim.autocommands.custom_groups = { -- no longer supportedm but we aint use it
  -- { "BufWinEnter", "config.lua", "set foldmethod=marker" },
  -- { "BufWinEnter", "markdown", [[lua lvim.useruserdata.somefunc()]] },
  -- { "FileType", "cpp", [[lua lvim.userdata.somefunc()]] },
  -- { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
  -- }
  vim.api.nvim_create_autocmd("BufEnter", {
	  pattern = { "*.todo.md", "*.md", "*.mkd", "*.md.enc", "*.mkd.enc" },
	  -- enable wrap mode for json files only
	  command = "setlocal nospell syntax=markdown",
  })
end

init_autocommands()
-- }}


local function load_telescope_ext(en)
  require('telescope').load_extension(en)
end

pcall(load_telescope_ext, 'media_files')
