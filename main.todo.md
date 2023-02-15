# API

- [ ] all top-level scripts should provide complete help (cut-off underlying stuff from text)
- [ ] in help - show which apps are installed and which versions
- [ ] update/upgrade commands
- [ ] nextg eval-based common-lib stuff (colorization etc)
- [ ] extract encryption base from sn-cli - this is normal approach for all script which requires sensitive data
- [ ] when installing fonts - also try to detect the latest version available and use it
  - [ ] this will require standalone gh-api impl
- [ ] move project wide todos to **phaazon/mind.nvim** or to **todotxt-machine**
    - [ ] maybe tasks themeselves more convinient to keep in todotxt while docs and notes - in mind-nvim
    - [ ] use `jonatanpedersen/git-json-merge` to git-merge it's jsons

# Files

- [ ] entrypoints are: `dots/stow`, `apps/gha`, `apps/cxi`, `pkgs/dcbi`
  - [ ] *??* single toplevel script `setup` which acceps folder's name, like: `setup apps lunarvim` or `setup dots`
- [ ] divide config files by projects in `conf/`, to folders: `gha`, `apt`, `kde`
- [ ] move `note*` files from `conf` to another location (`notes/`?)
- [ ] where to place patches? for **leo** and whatever else
- [ ] root-tree reorganize: toplevel folders are: `apps`, `dots`m `pkgs` and `notes`
  - [ ] `apps`: `bin`, `lib`, `conf`
  - [ ] `dots`: as is
  - [ ] `pkgs`: all ubuntu-related stuff like apt, ppa, etc
  - [ ] `notes`: all the notes, todos, hints etc...
- [ ] `conf` reorganize
  - [ ] make subdirs for every entrypoint
  - [ ] use yaml as a format - with help of for instance `mrbaseman/parse_yaml`
    - [ ] then can setup preferrable archive types, supported oses etc
- [ ] support for [editorconfig](http://editorconfig.org/) concept
  - [ ] look at the [example](https://github.com/angular/angular.js/blob/master/.editorconfig)

# Configs

- [ ] [Dorothy](https://github.com/bevry/dorothy) is a dotfile ecosystem **LEARN**
- [ ] **wezterm** lua configs
- [ ] **qmmp** configs (they are messy, need to extract parts and then merge back)
  - [ ] or use **deadbeef** which has pretty simple config files (it crashes alot and then annoys with logs)
- [ ] **tilix** configs: https://gist.github.com/peterrus/f7a8f6ce09ba6506b780f6ca8bceb74f
- [ ] xml configs for **DoubleCmd** in `~/.config/doublecmd`
- [ ] automate **khotkeys** extraction/injection
- [ ] goldendict & its dicts (steal from 'sync') + place suitable config to 'stow' (if possible)
- [ ] use `glow` to preview `md` in `fzf`
- [ ] Dotfiles for investigation
  - [ ] *hackorama/devprof* :: Development profile for bash, vim, git
  - [ ] *junegunn/dotfiles* :: from the author of `fzf`
  - [ ] *Naheel-Azawy/naheel-dotfiles* :: from the author of `fmz` and `stpv`
  - [ ] *ViRu-ThE-ViRuS/configs* :: kitty + tmux + fish setup for macos
- [ ] `doom-neovim/doom-nvim` :: configuration basis

# Lunar Vim

- [ ] sources of inspiration:
    - https://github.com/abzcoding/lvim
    - https://github.com/danielnehrig/nvim
    - https://github.com/kuator/nvim
    - https://github.com/alex-popov-tech/.dotfiles/tree/master/nvim
    - https://github.com/mathiasbynens/dotfiles
    - https://github.com/ThePrimeagen/.dotfiles
    - https://github.com/zanshin/dotfiles
    - https://github.com/caarlos0/dotfiles.fish
    - https://github.com/samoshkin/dotfiles
    - https://github.com/abzcoding/lvim
    - https://github.com/kuator/nvim/

# GitHubApps

- [ ] move to `asdf`? https://github.com/asdf-vm/asdf
- [ ] `jq` may be unavailable on the tarhet systems
  - [ ] may download `gojq` first or have an option to build it witj `dcbi` (see Dockerfile there)
- [ ] add apps:
      * *ajeetdsouza/zoxide* : smarter cd command
      * *xxh/xxh* : bring your favorite shell wherever you go through ssh without root access and system installations
      * *Mellbourn/zabb* : plugin for finding z abbreviations
      * *nachoparker/xcol* : tool colorize its standard input for each one of its arguments (zsh-only, need bash-adoption)
- [ ] github rate limits may fail the installation process
  - [ ] curl -I https://api.github.com/users/octocat << to check how many is left (also decrements the counter)
  - [ ] for anon user - 60 requests per hour
  - [ ] good approach - first download the meta with validation, and then install
    - [ ] meta can be cached in git for instance and reused from the repo - just to get rid of failure
- [ ] provide upgrades
- [ ] option for installing to /usr/local
- [ ] conf must provide suitable for all arches packages and suitable only for current ones
- [ ] **wezterm** - has strange filenames, need to integrate
- [ ] **encpipe** - libhydrogen wants `cc` shortcut which is available only when default gcc is installed
  - [ ] can build `libhydrogen` with cmake, not make
  - [ ] can make own form and build and release encpipe for my needs, make it available in binary form

# NeoVim plugins

- [ ] **list** - https://github.com/rockerBOO/awesome-neovim
- [ ] **encryption** - use `/dev/shm` instead of `/tmp` wherever possible
  - [ ] `billyvg/tigris.nvim` - a NodeJS remote plugin that provides async syntax highlighting for js
- [ ] `sindrets/diffview.nvim` - single tabpage interface for easily cycling through diffs for all modified files for any git rev
- [ ] `jackguo380/vim-lsp-cxx-highlight` - C/C++/Cuda/ObjC semantic highlighting using LSP
- [ ] `amerlyq/nou.vim` - notes and outline united
- [ ] `jakewvincent/mkdnflow.nvim` - fluent navigation of documents and notebooks (AKA "wikis") in markdown
- [ ] `oberblastmeister/neuron.nvim` - lua and the neuron binary allow one of the coolest note taking experiences
- [ ] `tpope/vim-sleuth` or `gpanders/editorconfig.nvim` for `editorconfig`
- [ ] `mizlan/iswap.nvim` - interactively select and swap: function arguments, list elements, function parameters, and more
- [ ] `ray-x/lsp_signature.nvim` - function signature when you type
- [ ] `rohit-px2/nvui` - gui app for neovim
- [ ] `anuvyklack/vim-cppman` - use `aitjcize/cppman` to lookup "C++ 98/11/14/17/20 manual pages"
- [ ] `AckslD/nvim-FeMaco.lua` - edit injected language trees with correct filetype in a floating window
- [ ] `ldelossa/litee.nvim` - library for building "IDE-lite" experiences
- [ ] `sindrets/diffview.nvim` - simple, unified, single tabpage diff interface
- [ ] `ray-x/navigator.lua` - code analysis and navigate tool
- [ ] `nvim-treesitter/nvim-treesitter-textobjects` - text-objects, select, move, swap, and peek support
- [ ] `svermeulen/vim-subversive` -  two new operator motions to make it very easy to perform quick substitutions
- [ ] `wellle/targets.vim` - adds various text objects for  more targets to operate on
- [ ] `ggandor/leap.nvim` - general-purpose motion plugin
- [ ] `ThePrimeagen/harpoon` - mark and create persisting key strokes to go to the files of interest

# Encrypted notes

- [ ] try `pass` for storing password
  - [ ] use extensions that hides the filenames
  - [ ] choose btw `gpg` and `age` backends
  - [ ] enhance safety with other plugins
  - [ ] decide how to remotely store and distribute the db
  - [ ] think of using cli-tools based on `KeePassX` backend
- [ ] how to store encrypted notes - use what? encryption plugin for vim? which?
  - [ ] prefer anything wide-spreaded for all oses like gpg or openssl

# Utils

## Console Sounds

- use `radio.sh` and `ogg123 -rz /usr/share/anoise/sounds/` as a basis
    - choose terminal emulator which supports panes and pre-configuration
        - this can be clone of tmux
        - https://github.com/cdleon/awesome-terminals
    - on startup - several panes, in one - radio, in another - anoise sounds
    - custom shortcuts which can mute/stop/change the sounds
        - https://wiki.archlinux.org/title/PulseAudio/Troubleshooting#Muted_application
        - there can be single popup with a menu for all
    

        

