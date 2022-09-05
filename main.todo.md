

# Files

- [ ] entrypoints are: `dots/stow`, `apps/gha`, `apps/cxi`, `pkgs/dcbi`
  - [ ] *??* single toplevel script `setup` which acceps folder's name, like: `setup apps lunarvim` or `setup dots`
- [ ] divide config files by projects in `conf/`, to folders: `gha`, `apt`, `kde`
- [ ] move `note*` files from `conf` to another location (`notes/`?)
- [ ] where to place patches? for **leo** and whatever else
- [X] root-tree reorganize: toplevel folders are: `apps`, `dots`m `pkgs` and `notes`
  - [X] `apps`: `bin`, `lib`, `conf`
  - [X] `dots`: as is 
  - [X] `pkgs`: all ubuntu-related stuff like apt, ppa, etc
  - [X] `notes`: all the notes, todos, hints etc...

# Configs

- [ ] **wezterm** lua configs
- [ ] **qmmp** configs (they are messy, need to extract parts and then merge back)
  - [ ] or use **deadbeef** which has pretty simple config files (it crashes alot and then annoys with logs)
- [ ] xml configs for **DoubleCmd** in `~/.config/doublecmd`
- [ ] automate **khotkeys** extraction/injection
- [ ] goldendict & its dicts (steal from 'sync') + place suitable config to 'stow' (if possible)

# GitHubApps

- [ ] **wezterm** - has strange filenames, need to integrate
- [ ] **encpipe** - libhydrogen wants `cc` shortcut which is available only when default gcc is installed
  - [ ] can build `libhydrogen` with cmake, not make
  - [ ] can make own form and build and release encpipe for my needs, make it available in binary form

# NeoVim plugins

- [ ] **list** - https://github.com/rockerBOO/awesome-neovim
- [ ] **encryption** - use `/dev/shm` instead of `/tmp` wherever possible

# Encrypted notes

- [ ] try `pass` for storing password
  - [ ] use extensions that hides the filenames
  - [ ] choose btw `gpg` and `age` backends
  - [ ] enhance safety with other plugins
  - [ ] decide how to remotely store and distribute the db
  - [ ] think of using cli-tools based on `KeePassX` backend
- [ ] how to store encrypted notes - use what? encryption plugin for vim? which?
  - [ ] prefer anything wide-spreaded for all oses like gpa or openssl
