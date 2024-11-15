#!/bin/bash

# sudo apt install -y python3-pip

# python stuff - makes me happy with github releases
#
sudo apt install python3 python3-pip pipx
pipx install mdv frogmouth install-release # as user; dont forget manually upgrade-all

# use existing code to install PPAs - it's pretty good; just give more choices - what exactly to install
#PPAs="
#	ppa:costales/anoise
#"

# many apps installed from github now are in packages - so use them in general
PKGs="
	tmux wmctrl xdotool 
	lm-sensors uuid net-tools exif mpg321 vorbis-tools 
	atool rar unrar libunrar5 zip unzip p7zip-full p7zip-rar 
	automake autoconf pkg-config cmake build-essential libtool shellcheck 
	zoxide ripgrep lsd eza 
	git-delta gitk kdiff3 
	htop btm 
	du-dust fd-find ncdu duf 
	chafa micro hnb vym ghostwriter 
	tree fzf bat mc lf lfm doublecmd-qt doublecmd-plugins 
	bash-completion direnv 
	jqp gron jq gawk 
	pandoc poppler-utils 
	goldendict 
	w3m-img sxiv imagemagick-6.q16hdri 
	mplayer smplayer smplayer-themes smtube qmmp ffmpegthumbnailer ffmpeg mpv
"

# console utils
#sudo apt install $PKGs

# nerds fonts: https://github.com/mcarvalho1/Simple-NerdFonts-Downloader
# also try: fonts-anonymous-pro
# maybe make nerd font system default: https://bookstack.bluecrow.net/books/neovim/page/neovim-setup-on-ubuntu-with-lazyvim-lunarvim-and-nerd-fonts

# anoise-gui anoise-community-extension2 anoise-community-extension3 # all=basic, 1=boring, 2=places, 3=noises, 4=lakes&rivers, 5=birds


# miss: neovim lazygit lazydocker glow sad gum rnr argc  gitui lazygit

# obsidian: curl -fsSL https://raw.githubusercontent.com/oviniciusfeitosa/obsidian-ubuntu-installer/main/install.sh | sh


