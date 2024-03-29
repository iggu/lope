-- VimCore & LVim Options {{{
-- https://www.lunarvim.org/configuration/01-settings.html#example-options


table.appendt = function(tbl, t)
    for i = 1, #t do
        tbl[#tbl + 1] = t[i]
    end
end

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
    lvim.keys.normal_mode["K"] = "<Cmd>lua vim.lsp.buf.hover()<CR>"
    lvim.keys.normal_mode["<C-w>z"] = "<Cmd>WindowsMaximize<CR>"
    lvim.keys.normal_mode["<C-a>"] = "<Cmd>WindowsMaximize<CR>"
    lvim.keys.normal_mode["<C-j>"] = "<Cmd>StripTrailingWhitespace<CR>"
    lvim.keys.normal_mode["<C-k>"] = "<Cmd>ClangdSwitchSourceHeader<CR>"
    -- open Mind only when it is required and close it when done
    -- lvim.keys.normal_mode["<M-w>"] = "<Cmd>MindOpenProject<CR><C-W>L<Cmd>Goyo<CR>" -- <Cmd>vertical resize 50%<CR><C-W>h"
    -- lvim.keys.normal_mode["<M-W>"] = "<Cmd>Goyo!<CR><Cmd>MindClose<CR>"
    -- vim.keymap.set('n', '<C-w>z', '<Cmd>WindowsMaximize<CR>')
    lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
    lvim.keys.normal_mode["\"`"] = ":Telescope marks<cr>"
    lvim.keys.normal_mode["\"\""] = ":Telescope registers<cr>"
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
    lvim.keys.normal_mode["<A-m>"] = ":Glow %<CR>"

    -- Magic buffer-picking mode
    lvim.keys.normal_mode["<A-l>"]   = ":BufferLineCycleNext<CR>"
    lvim.keys.normal_mode["<A-h>"]   = ":BufferLineCyclePrev<CR>"
    lvim.keys.normal_mode["<A-S-l>"] = ":BufferLineMoveNext<CR>"
    lvim.keys.normal_mode["<A-S-h>"] = ":BufferLineMovePrev<CR>"
    lvim.keys.normal_mode["<A-S-o>"] = ":BufferLinePick<CR>"

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

    local function mk_layout(type, w, h)
        return { layout_strategy = type, layout_config = { width = w, height = h, }, }
    end

    lvim.builtin.telescope.pickers = {
        live_grep = mk_layout('horizontal', 0.9, 0.9),
        grep_string = mk_layout('horizontal', 0.9, 0.9),
        colorscheme = {
            enable_preview = false -- after making several cursor movements neovim hangs
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
    -- lvim.builtin.notify.active = true -- gh:'rcarriga/nvim-notify', popup notifications
    lvim.builtin.terminal.active = true
    lvim.builtin.nvimtree.setup.view.side = "right"
    -- lvim.builtin.nvimtree.show_icons.git = 0
    lvim.builtin.project.detection_methods = { "pattern", "lsp" }
    lvim.builtin.project.patterns = { ".git", ".svn", "Makefile", "package.json", "main.*" }
    lvim.builtin.project.silent_chdir = false

    -- https://www.lunarvim.org/configuration/06-statusline.html ; lvim/core/lualine
    -- provides: mode, branch, filename, diff, python_env, diagnostics, treesitter, lsp, location, progress, spaces, encoding, filetype, scrollbar
    -- local ts = require('nvim-treesitter')
    local ll = lvim.builtin.lualine
    local llc = require("lvim.core.lualine.components")
    local cc = require("lvim.core.lualine.colors")
    local z_hhmm = { 'os.date("%H:%M")', cond = llc.hide_in_width, color = { fg = cc.darkblue }, }
    local z_fn = { "filename", cond = nil, color = { gui = "bold", fg = cc.orange }, }
    -- local z_codecoord = { function() return ts.statusline(700) end, fmt = string.upper, cond = llc.hide_in_width, color = { fg = cc.purple } }
    ll.style = "default" -- "lvim" "none"; "default" allows to customize as lvim's docs say
    ll.sections.lualine_a = { 'mode' } -- time on the color which represents current mode
    ll.sections.lualine_b = { 'hostname', llc.branch, llc.diff, }
    ll.sections.lualine_c = { z_fn } --, z_codecoord, }
    ll.sections.lualine_x = { llc.diagnostics, llc.treesitter, llc.lsp, llc.filetype, "o:encoding", }
    ll.sections.lualine_y = { llc.scrollbar, llc.progress, "location" }
    ll.sections.lualine_z = { z_hhmm, }
    ll.options.disabled_filetypes = lvim.userdata.exclude_filetypes

    lvim.builtin.treesitter.ensure_installed = {
        "bash", "python", "c", "cpp", "lua", "dockerfile", "typescript", "javascript", "css", "html", "json", "markdown",
        "yaml", "toml",
    }
    lvim.builtin.treesitter.ignore_install = { "haskell" } -- lua always give weird errors
    lvim.builtin.treesitter.highlight.enabled = true
end

init_plugins_builtin()
-- }}}

-- Additional Plugins {{{
local function init_plugins_vimg_options()
    vim.g.glow_width = 200
    vim.g.goyo_width = "80%+5%"
    vim.g.scrollview_on_startup = 1
    vim.g.scrollview_current_only = 1
    vim.g.scrollview_excluded_filetypes = lvim.userdata.exclude_filetypes
    -- vim.g.javascript_plugin_jsdoc = 1
    vim.g.skylight_opener = 'drop' -- jump to location using the same split the search was performed in
    vim.g.ctrlsf_position = 'left'
    vim.g.ctrlsf_auto_focus = { at = "start" }
    vim.g.cpp_function_highlight = 1
    vim.g.cpp_attributes_highlight = 1
    vim.g.cpp_member_highlight = 1
    vim.g.cpp_simple_highlight = 1
    vim.g.tagbar_position = "right"
    vim.g.tagbar_autofocus = 0
    vim.g.tagbar_file_size_limit = 200000 -- doesnt save from freezing
    vim.g.vista_stay_on_open = 0
    -- vim.g.vista_sidebar_position = "right" -- any attemp to use this option leads to total mess
    vim.g.indent_blankline_filetype_exclude = lvim.userdata.exclude_filetypes
    vim.opt.fillchars:append { diff = "╱" } -- diagonal lines in place of deleted lines in diff-mode instead of '-'

    -- https://www.reddit.com/r/vim/comments/d77t6j/guide_how_to_setup_ctags_with_gutentags_properly/
    -- from: https://github.com/kuator/nvim/blob/master/lua/plugins/vim-gutentags.lua
    vim.g.gutentags_ctags_exclude = {
        '*.git', '*.svg', '*.hg',
        '*/tests/*', 'build', 'dist', 'bin', '*sites/*/files/*',
        'cache', 'compiled', 'example', 'docs', '*.md',
        -- '*.css', '*.less', '*.scss',
        'node_modules', 'bower_components', 'bundle', 'vendor', '*bundle*.js', '*build*.js',
        '*-lock.json', '*.lock', '.*rc*', '*.json', '*.min.*', '*.map',
        '*.bak', '*.zip', '*.pyc', '*.class',
        '*.sln', '*.Master', '*.csproj', '*.csproj.user', '*.cache', '*.pdb', '*.exe', '*.dll',
        '*.tmp', 'tags*', 'cscope.*',
        '*.mp3', '*.ogg', '*.flac',
        '*.swp', '*.swo',
        '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
        '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
        '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
    }

    vim.g.gutentags_add_default_project_roots = false
    vim.g.gutentags_project_root = { 'package.json', '.git' }
    vim.g.gutentags_cache_dir = vim.fn.expand('~/.cache/nvim/ctags/')
    vim.g.gutentags_generate_on_new = true
    vim.g.gutentags_generate_on_missing = true
    vim.g.gutentags_generate_on_write = true
    vim.g.gutentags_generate_on_empty_buffer = true
    vim.cmd([[command! -nargs=0 GutentagsClearCache call system('rm ' . g:gutentags_cache_dir . '/*')]])
    vim.g.gutentags_ctags_extra_args = { '--tag-relative=yes', '--fields=+ailmnS', }

end

init_plugins_vimg_options()

-- setup globals in init_plugins_vimg_options()
lvim.plugins = {}

local function init_plugins_tools()
    table.appendt(lvim.plugins, {
        -- {'TimUntersberger/neogit'}, -- lazygit does the same - and more pretty
        -- { 'nvim-telescope/telescope-media-files.nvim' },

        -- GENERAL PURPOSE
        { "anuvyklack/middleclass" },
        -- { "nathom/filetype.nvim" }, -- is already in neovim core since 0.8; trying to use this leads to errors on file open

        -- INTEGRATIONS
        { 'is0n/fm-nvim' }, -- use your favorite terminal file managers (and fuzzy finders)
        { 'sindrets/diffview.nvim' }, -- single tabpage interface for cycling through diffs for any git rev.
        { 'aspeddro/gitui.nvim' },
        { 'ellisonleao/glow.nvim' },
        { 'junegunn/limelight.vim' },
        { 'junegunn/goyo.vim' },

        -- NOTES TAKING
        -- { 'simplenote-vim/simplenote.vim' }, -- works pretty slow
        -- file type 'board' for notes, define shortcuts to directories, files, and various commands.
        -- { 'azabiong/vim-board' }, -- not sure that understand the idea and what it is for... fast notes?
        -- { 'phaazon/mind.nvim' }, -- `hnb` tui behaves better

        -- HELPERS
        { 'vim-scripts/Rename2' },
        { 'dstein64/nvim-scrollview' },
        { "anuvyklack/windows.nvim" }, -- <C-W>z , <C-A> = maximize
        -- { "anuvyklack/animation.nvim" }, -- to get smooth animation of windows resizing

    })
end

init_plugins_tools()

local function init_plugins_editor()
    table.appendt(lvim.plugins, {
        -- EDITING
        { 'axelf4/vim-strip-trailing-whitespace' }, -- removes trailing whitespace from modified lines on save OR :StripTrailingWhitespace
        -- { 'ur4ltz/surround.nvim' }, -- works too, has sandwitch mode, need to be explicitely started
        { 'kylechui/nvim-surround' -- operate on surrounding pairs - quotes, braces, tags, ts-objs
            --[[ insert = "<C-g>s", insert_line = "<C-g>S"; ! need to be explicitely started (see eof)
            q = any-quote `"', b = brace , t = tag, f = function << csqb changes nearest quote to parentheses
            modes: ato=around-text-obj, acl=arounf-current-line
            normal: ato="ys", acl="yS" (curline shortcuts: yss, ySS)
            visual: ato="S", acl="gS";
            delete="ds"; change="cs" ]]
        -- { 'gennaro-tedesco/nvim-peekup' }, -- "" to show registers menu, "x to clear them all, C-j, C-k to scroll
        },
        { 'ivanesmantovich/xkbswitch.nvim', -- always EN for normal mode, whatever layout was in insert
            -- requires grwlf/xkb-switch lib of version 1.*: dcbi xkbswitch:1.8.5 + accept to export system-wide
            -- works only if insert-mode exited with ESC; normally restores layout for insert mode
            -- (can be related to extra ft hooks which conflicts with switching)
            -- for some filetypes like lua when switching ins-norm-ins - layout does not switched back to RU
            -- alternatives:
            --   - keaising/im-select.nvim : requires ibus or fctix, which is not desired
            --   - lyokha/vim-xkbswitch    : for vim; not tested yet
       },
        -- DECORATIONS
        { 'm-demare/hlargs.nvim' }, -- highlight arguments' definitions and usages, asynchronously, using Treesitter
        { 'Pocco81/HighStr.nvim' }, -- Permanently highlight selection
        { 'haringsrob/nvim_context_vt' }, -- Shows virtual text of the current context at the end of: functions, if, for, ...
        { 'HiPhish/nvim-ts-rainbow2' }, -- p00f/nvim-ts-rainbow is archived; suddenly all kind of rainbow plugins stopped to work
        -- {'pseewald/vim-anyfold'}, -- folds are pretty unusable since preview windows content is folded too
        { "nyngwang/murmur.lua" }, -- highlight word under cursor - some themes do it themeselves

        -- SEARCH/FIND
        { "princejoogie/dir-telescope.nvim" }, -- do telescope in  in selected directories; :GrepInDirectory & :FileInDirectory
        { 'rlane/pounce.nvim' }, -- incremental fuzzy search on motions
        -- { 'woosaaahh/sj.nvim' }, -- quick-jump search (but how does it work?)
        -- Search for file/symbol/word under cursor and preview in the floating window.
        { 'voldikss/vim-skylight', }, -- <C>w-p to jump to preview window and back
        { 'dyng/ctrlsf.vim' },
        { 'kevinhwang91/nvim-bqf' }, -- better quickfix window,

        -- FILETYPES
        { 'hauleth/vim-encpipe' }, -- files encoded by encpipe, with '.enc' extension
        -- { 'aserebryakov/vim-todo-lists' },
        { 'bfrg/vim-jq' },
        -- {'bfrg/vim-jqplay'}, -- pretty useless, have dedicated shell scripts for that
        { 'bfrg/vim-cpp-modern' }, -- Enhanced C and C++ syntax highlighting
        -- {'pangloss/vim-javascript' }, -- Vastly improved Javascript indentation and syntax support in Vim

        -- https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
        -- { 'mg979/vim-visual-multi' }, -- mulitple cursors for vim
        -- { 'Rasukarusan/nvim-select-multi-line' }, -- select multi lines, even  not adjacent
        -- NOTE: not sure that need plugins above


    })
end

init_plugins_editor()

local function init_plugins_ide()
    table.appendt(lvim.plugins, {

        -- DIAGNOSTICS
        { "folke/trouble.nvim" },
        { "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim" },

        -- CODE MANIPULATIONS
        { 'sbdchd/neoformat' },
        { 'folke/todo-comments.nvim' }, -- use :Todo... commands
        { 'Wansmer/treesj' }, -- :TSJToggle, :TSJSplit, :TSJJoin

        -- SYMBOLS NAVIGATION
        -- { 'c0r73x/neotags.lua' },
        { 'romgrk/nvim-treesitter-context' },
        -- main rule is: left side - tree-sitter based outliners (should be used in general as fastest),
        -- right side - ctags-based (they may be pretty slow on big files)
        { 'sidebar-nvim/sidebar.nvim' },
        { 'simrat39/symbols-outline.nvim' },
        -- very concise representation, works fast, tree-sitter based
        { 'stevearc/aerial.nvim', }, -- branch 'main' requires neovim-0.8
        -- strange view, works with huge js, can have lsp backends (which aint work for cpp), by default uses ctags
        { 'liuchengxu/vista.vim' },
        -- eats processor and freezes ui on almost every file, pure ctags; sometimes breaks layout when toggled after other outlines
        { 'preservim/tagbar' }, -- builds tags in-momory for a limited scope, doesnt affect tag file
        { 'ludovicchabant/vim-gutentags' }, -- general-purpose project-wide tags management tool
        -- navigation in large markdown files - doesnt sync with the doc, strip empty lines, do not use
        -- { 'Scuilion/markdown-drawer' },
        { 'SidOfc/mkdx' },
        { 'dhruvasagar/vim-table-mode' },


        -- CONTENT NAVIGATION
        { 'zhimsel/vim-stay' }, -- restore cursor pos when reopen file
        -- choose win in complex layouts with '-' key (activates the mode where other ops are also avail)
        -- tabs: 0=first, [=prev, ]=next, $=last, x=close
        -- wins: ;=curr, -=prev, s=swap, S=swap-stay, <cr>=curr
        { 't9md/vim-choosewin' },
        { 'tpope/vim-unimpaired' }, -- complementary pairs of mappings
        { 'xiyaowong/nvim-cursorword' }, -- underline words similar to one under cursor
        { "max397574/better-escape.nvim" }, -- jk in insert mode acts as <esc>
        -- { 'Kristoffer-PBS/interesting-words.nvim' }, -- highlight words in the buffer
        -- { 'lukas-reineke/indent-blankline.nvim' }, -- draw vertical lines as indent markers; already in lvim
        { 'jinh0/eyeliner.nvim' }, -- color unique char in the line to speed up f/F to the corresponding word

    })
end

init_plugins_ide()

local function init_plugins_colorshemes()
    table.appendt(lvim.plugins, {
        -- COLORSCHEMES
        { "abzcoding/zephyr-nvim" }, --<< this theme uses treesitter in an invalid way which gives permanent erros
        -- INFO: color schemes as they appear in <leader>C menu
        { "sjl/badwolf" }, { 'rockerBOO/boo-colorscheme-nvim' }, { 'tomasiser/vim-code-dark' },
        { 'catppuccin/nvim', name = "catppuccin" }, { 'nvimdev/oceanic-material' },
        { "abzcoding/doom-one.nvim" }, { 'Everblush/everblush.nvim', name = 'everblush' }, { 'cocopon/iceberg.vim' },
        { 'marko-cerovac/material.nvim' }, { 'nyoom-engineering/oxocarbon.nvim' },
        { 'rafamadriz/neon' }, { 'sainnhe/sonokai' }, { 'sainnhe/edge' }, { "rose-pine/neovim" }, -- { 'LunarVim/onedarker.nvim' },
        { 'jsit/toast.vim' }, { 'sam4llis/nvim-tundra' }, { 'elianiva/gruvy.nvim', dependencies = { 'rktjmp/lush.nvim' } },
        { 'sainnhe/gruvbox-material' }, { 'sainnhe/everforest' }, { 'Tsuzat/NeoSolarized.nvim' },
        { "morhetz/gruvbox" }, { "tomasr/molokai" }, { "Mofiqul/dracula.nvim" }, { "jnurmine/Zenburn" },
        { "kyoz/purify", rtp = "vim" }, { "nanotech/jellybeans.vim" }, { "arcticicestudio/nord-vim" },
        { "jacoborus/tender.vim" }, { 'safv12/andromeda.vim' }, { 'NTBBloodbath/sweetie.nvim' },
        { 'savq/melange' }, { 'bluz71/vim-moonfly-colors' }, { 'liuchengxu/space-vim-theme' },
        { 'Shatur/neovim-ayu' }, { 'EdenEast/nightfox.nvim' }, { 'rebelot/kanagawa.nvim' },
        { 'noorwachid/nvim-nightsky' }, { 'talha-akram/noctis.nvim' }, --<< very good
        { 'projekt0n/github-nvim-theme' }, { 'd00h/nvim-rusticated' },
        -- not working schemes: they do not color the code, and this is already in: { "folke/tokyonight.nvim" },
        -- { 'AlessandroYorba/Despacio', setup = function() vim.g.despacio_Pitc = 1 end },
        -- { 'junegunn/seoul256.vim', setup = function() vim.g.seoul256_background = 233 end }, --[[233=darkest, 236=lightest; not working here]]
    })
end

init_plugins_colorshemes()

-- }}}

-- Which Keys {{{
local function init_whichkeys_menu()

    local function format()
        lvim.builtin.which_key.mappings["F"] = {
            name = "Format",
            j = { ":TSJJoin<CR>", "{} Block Join" },
            s = { ":TSJSplit<CR>", "{} Block Split" },
        }
    end

    format()

    local function highlights()
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
        lvim.builtin.which_key.mappings.H = {
            name = "+Highlight",
            g = { ":Goyo<cr>", "Toggle Goyo" },
            G = { ":Glow!<cr>", "Preview MD in Glow" },
            F = { [[:lua lvim.userdata.terminal_cmd_toggle('frogmouth ]]..vim.fn.expand('%:p')..[[')<cr>]], "Preview MD in FrogMouth" },
            l = { ":Limelight!!<cr>", "Toggle LimeLight" },
        }
    end

    highlights()


    local function make()
        lvim.builtin.which_key.mappings.L.F = { ':lua init_plugins_setup()<CR>', "Force Plugins Setup" }
        lvim.builtin.which_key.mappings.M = { ':make<CR>', "Make" }
        lvim.builtin.which_key.mappings["W"] = {
            name = "Compile",
            q = { ":lua lvim.userdata.assign_outmakers('', 'xwin/debug')<cr>", "Make XWin/Debug" },
            w = { ":lua lvim.userdata.assign_outmakers('emmake', 'wasm/relwithdebinfo')<cr>", "Make Wasm/RelWithDebInfo" }
        }
    end

    make()


    local function lsp()
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
    end

    lsp()

    local function git()
        lvim.builtin.which_key.mappings.g.D = { [[:lua lvim.userdata.terminal_cmd_toggle('git diff '..vim.fn.expand('%:p')..]] ..
                                                                                     [['; read -p "Press any key to continue..." -s -n 1')<cr>]], "Diff Current" }
        lvim.builtin.which_key.mappings.g.z = { [[:lua lvim.userdata.terminal_cmd_toggle('git-tui diff '..vim.fn.expand('%:p'))<cr>]], "Diff TUI Current" }
        lvim.builtin.which_key.mappings.g.Z = { [[:lua lvim.userdata.terminal_cmd_toggle('git-tui diff')<cr>]], "Diff TUI All" }
        lvim.builtin.which_key.mappings.g.X = { [[:lua lvim.userdata.terminal_cmd_toggle('git-tui log '..vim.fn.expand('%:p'))<cr>]], "Log TUI Current" }
        lvim.builtin.which_key.mappings.g.x = { [[:lua lvim.userdata.terminal_cmd_toggle('git-tui log')<cr>]], "Log TUI All" }
        lvim.builtin.which_key.mappings.g.G = { ":Gitui<cr>", "GitUI" }
        lvim.builtin.which_key.mappings.g.v = { ":DiffviewOpen<cr>", "Diffview" }
    end

    git()

    local function extra_tools()
        lvim.builtin.which_key.mappings.x = {
            name = "+Tools",
            a = { ":lua lvim.userdata.terminal_cmd_toggle('apts vivaldi && read')<cr>", "Bottom" },
            c = { [[:lua lvim.userdata.terminal_cmd_toggle('date && LANG=EN ccal -y -m && LANG=EN ccal && read -n 1')<cr>]],
                "Calendar" },
            -- M = {":Calendar -first_day=monday<cr>", "Calendar Month"},
            -- Y = {":Calendar -view=year -first_day=monday<cr>", "Calendar Year"},
            -- T = {":Calendar -view=clock<cr>", "Clock"},
            j = { [[:lua lvim.userdata.terminal_cmd_toggle('jqsh')<cr>]], "JQ shell" },
            l = { [[<Cmd>Lf<cr>]], "LF" },
            -- l = { [[:lua lvim.userdata.terminal_cmd_toggle('lf')<cr>]], "LF" },
            L = { [[:lua lvim.userdata.terminal_cmd_toggle('xplr')<cr>]], "XPLR" },
            --n = {":lua lvim.userdata.terminal_cmd_toggle('nnn-nerd-static')<cr>", "NNN"},
            p = { ":lua lvim.userdata.terminal_cmd_toggle('htop')<cr>", "Top" },
            P = { ":lua lvim.userdata.terminal_cmd_toggle('btop')<cr>", "BTop" },
            w = { ":lua lvim.userdata.terminal_cmd_toggle('curl ru.wttr.in && read -n 1')<cr>", "Weather" },
            -- open todo files in project's root - where .git folder is living
            h = { ":lua lvim.userdata.terminal_cmd_toggle('_GR=$(git rev-parse --show-toplevel); hnb \"$_GR${_GR:+/.todo.hnb}\"')<cr>", "HierNoteBook" },
            t = { ":lua lvim.userdata.terminal_cmd_toggle('_GR=$(git rev-parse --show-toplevel); taskell \"$_GR${_GR:+/.todo.taskell}\"')<cr>", "Taskell" },
            T = { ":lua lvim.userdata.terminal_cmd_toggle('_GR=$(git rev-parse --show-toplevel); tudu ${_GR:+-f} \"$_GR${_GR:+/.todo.tudu}\"')<cr>", "TuDu" },
        }
    end

    extra_tools()

    local function buffers()
        lvim.builtin.which_key.mappings.b.b = { "<cmd>Telescope buffers<CR>", "Buffers" }
        lvim.builtin.which_key.mappings.b.E = { ":BufferLineSortByExtension<cr>", "Sort by extenstion" }
        lvim.builtin.which_key.mappings.b.F = { ":BufferLineSortByRelativeDir<cr>", "Sort by reldir" }
        lvim.builtin.which_key.mappings.b.R = { ":bufdo checktime<cr>", "Reload all open buffers if changed" }
    end

    buffers()

    local function search()
        lvim.builtin.which_key.mappings.s.w = { ":Skylight! word<cr>", "Word UC in ThisBuf" }
        lvim.builtin.which_key.mappings.s.s = { ":Telescope resume<cr>", "Resume last search" }
        lvim.builtin.which_key.mappings.s.G = { ":Telescope grep_string<cr>", "Fuzzy for Word UC" }
        lvim.builtin.which_key.mappings.s.m = { ":Telescope marks<cr>", "Search for Media" }
        lvim.builtin.which_key.mappings.s.g = { ":Telescope current_buffer_fuzzy_find<cr>", "Fizzy in Buffer" }
        lvim.builtin.which_key.mappings.s.M = { ":Telescope media_files<cr>", "Search for Media" }
        lvim.builtin.which_key.mappings.s.p = { ":<cmd>Pounce<cr>", "Pounce" }
        lvim.builtin.which_key.mappings.s.P = { ":<cmd>PounceRepeat<cr>", "Pounce Repeat" }
        lvim.builtin.which_key.mappings.s.A = { "<cmd>Telescope projects<CR>", "Projects" }
        lvim.builtin.which_key.mappings.s.D = { ":<cmd>TodoTelescope<cr>", "ToDos & FixMes" }
        lvim.builtin.which_key.mappings.s.T = { ":<cmd>GrepInDirectory<cr>", "Grep in Dir" }
        lvim.builtin.which_key.mappings.s.F = { ":<cmd>FileInDirectory<cr>", "File in Dir" }
    end

    search()

    local function trouble()
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
    end

    trouble()

    local function outlines()
        lvim.builtin.which_key.mappings["o"] = {
            name = "+Outlines",
            -- M = { "<cmd>MinimapToggle<CR>", "Minimap Toggle" },
            -- m = { "<cmd>MinimapRefresh<CR>", "Minimap Refresh" },
            a = { "<cmd>AerialToggle! left<CR>", "Aerial Toggle Left" },
            A = { "<cmd>AerialToggle! right<CR>", "Aerial Toggle Right" },
            b = { "<cmd>SidebarNvimToggle<CR>", "SideBar Toggle" },
            s = { "<cmd>SymbolsOutline<CR>", "SymbolsOutline Toggle" },
            t = { "<cmd>TagbarToggle<CR>", "Tagbar Toggle" },
            v = { "<cmd>Vista!!<CR>", "Vista Toggle" },
        }
    end

    outlines()

    local function colorshemes()
        lvim.builtin.which_key.mappings["C"] = {
            name = "+ColorSchemes",
            a = { ":colorscheme ayu-dark<CR>", "Ayu Dark" },
            A = { ":colorscheme ayu-mirage<CR>", "Ayu Mirage" },
            b = { ":colorscheme badwolf<CR>", "Bad Wolf" },
            B = { ":colorscheme boo<CR>", "Boo" },
            c = { ":colorscheme codedark<CR>", "Code Dark" },
            C = { ":colorscheme catppuccin<CR>", "Catppuccin" },
            d = { ":colorscheme doom-one<CR>", "Doom One" },
            e = { ":colorscheme edge<CR>", "Edge" },
            E = { ":colorscheme everforest<CR>", "EverForest" },
            D = { ":colorscheme dracula<CR>", "Dracula" },

            -- f = { ":colorscheme despacio<CR>", "Despacio" },
            F = {
                name = "Fox",
                c = { ":colorscheme carbonfox<CR>", "Carbon" },
                d = { ":colorscheme dayfox<CR>", "Day" },
                D = { ":colorscheme dawnfox<CR>", "Dawn" },
                f = { ":colorscheme duskfox<CR>", "Dusk" },
                n = { ":colorscheme nightfox<CR>", "Night" },
                N = { ":colorscheme nordfox<CR>", "Nord" },
                t = { ":colorscheme terafox<CR>", "Tera" },
            },

            g = { ":colorscheme gruvbox-material<CR>", "Gruv Box Material" },
            G = { ":colorscheme gruvy<CR>", "Gruvy" },
            i = { ":colorscheme iceberg<CR>", "Iceberg" },
            j = { ":colorscheme jellybeans<CR>", "Jellybeans" },
            k = { ":colorscheme kanagawa<CR>", "Kanagawa" },
            K = { ":colorscheme melange<CR>", "Melange" },
            l = { ":colorscheme lunar<CR>", "Lunar" },

            -- L = { ":colorscheme moonfly<CR>", "Moonfly" },
            -- m = { ":colorscheme molokai<CR>", "Molokai" },
            M = { ":colorscheme material<CR>", "Material" },
            n = { ":colorscheme neon<CR>", "Neon" },
            N = { ":colorscheme NeoSolarized<CR>", "NeoSolarized" },
            O = { ":colorscheme nord<CR>", "Nord" },
            o = { ":colorscheme onedarker<CR>", "One Darker" },

            -- p = { ":colorscheme purify<CR>", "Purify" },
            r = { ":colorscheme rose-pine<CR>", "Rose Pine" },
            q = { ":colorscheme sonokai<CR>", "Sonokai" },
            Q = { ":colorscheme tender<CR>", "Tender" },
            s = { ":colorscheme space_vim_theme<CR>", "Space Vim" },

            -- S = { ":let g:seoul256_background = 233<CR>:colorscheme seoul256<CR>", "Seoul 256" },
            t = { ":colorscheme tokyonight<CR>", "TokyoNight" },
            T = { ":colorscheme tundra<CR>", "Tundra" },
            Y = { ":colorscheme toast<CR>", "Toast" },
            z = { ":colorscheme zephyr<CR>", "Zephir" },
            Z = { ":colorscheme zenburn<CR>", "Zenburn" },
        }
    end

    colorshemes()
end

init_whichkeys_menu()
-- }}}

-- Autocommands {{{ (https://neovim.io/doc/user/autocmd.html)
local function init_autocommands()
    --      some vim's options (like vim.o.fmd) a changed multiple times by various scripts and plugins
    --      so it's not in general possible to set them up here in hooks
    -- lvim.autocommands.custom_groups = { -- no longer supportedm but we aint use it
    -- { "BufWinEnter", "config.lua", "set foldmethod=marker" },
    -- { "FileType", "cpp", [[lua lvim.userdata.somefunc()]] },
    -- { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
    -- }
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.md", "*.mkd", "*.md.enc", "*.mkd.enc", "*.taskell" },
        command = "setlocal nospell syntax=markdown ts=2 sw=2",
        -- tabstop=2 to reduce problem that nested list items are colored as inline code
        -- cause in syntax file no check to detect if a line with 4 spaces or a tab is in fact a list.
        -- with such ts problems arise only with 4th nesting level, not 3rd
    })
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.tudu", "*.hnb", "*.tines" },
        command = "setlocal nospell syntax=xml",
    })
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "Dockerfile.*" },
        command = "setlocal ft=dockerfile",
    })
    vim.api.nvim_create_autocmd("User", {
        pattern = { "DiffviewViewOpened" },
        command = "nmap <buffer> q :DiffviewClose<CR>",
    })
end

init_autocommands()
-- }}}

-- Plugins Force Init {{{
local function init_plugins_setup()
    local hasSetup = {
        ['telescope'] = {},
        ['todo-comments'] = {},
        ['xkbswitch'] = {},
        -- on recent versions it doesnt want to show awesome icons - forcing to use plain text
        ['aerial'] = { nerd_font = false }, -- FIXME: show awesome icons
        -- ['mind'] = {},
        ['glow'] = { width = 200, width_ratio = 0.8, height_ratio = 0.8 },
        ['treesj'] = { use_default_keymaps = false, },
        ['murmur'] = {},
        ['eyeliner'] = { highlight_on_key = true },
        -- ['neotags'] = { enable = true, ctags = { run = true, directory = '~/.cache/nvim/ctags' } },
        ['symbols-outline'] = { width = 15, position = "left" },
        ['dir-telescope'] = { hidden = true, respect_gitignore = true, },
        ['nvim-surround'] = {},
        ['windows'] = { autowidth = { enable = false, winwidth = 10, },
            ignore = { filetype = lvim.userdata.exclude_filetypes }, },
        ['sidebar-nvim'] = { open = false, side = "left", initial_width = 25,
            sections = { "symbols", "git", "todos", "diagnostics", }, },
        ["nvim-treesitter.configs"] = { rainbow = { enable = true, query = 'rainbow-parens',
                                            strategy = require 'ts-rainbow.strategy.global', } },
    }
    for m, o in pairs(hasSetup) do
        pcall(function() require(m).setup(o) end)
    end

    local hasInit = {
        ['toggle_lsp_diagnostics'] = {},
    }
    for m, o in pairs(hasInit) do
        pcall(function() require(m).init(o) end)
    end
    -- pcall( function() require('telescope').load_extension('media_files') end )
    require("telescope").load_extension("dir") -- `:Telescope dir live_grep` or `:Telescope dir find_files`
    local lspc = require('lspconfig')
    -- WARN: when manually setuping servers - need to speify each of them or they would not start
    local lspSetup = {
        ['marksman'] = {},
        ['tsserver'] = {},
        ['lua_ls'] = {},
        ['clangd'] = {},
    }
    for m, o in pairs(lspSetup) do
        pcall(function() lspc[m].setup(o) end)
    end
end

init_plugins_setup()
-- }}}
