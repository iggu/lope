# supported variables:
#   $codename: ubuntu's release codename

# PPAs from launchpad; user/repo as a key and key hash as a value
declare -A PPA_LAUNCHPAD=(
    [pbek/qownnotes]="FDF1BE5B4B0286C8D8B0587F54223C6547878405"
    [atareao/telegram]="A3D8A366869FE2DC5FFD79C36A9653F936FD5529"
    [costales/anoise]="0DD210ABE883B905B88B55E7FC14671BA89CA06C"
    [libreoffice/ppa]="36E81C9267FD1383FCC4490983FBA1751378B444"
    [mozillateam/ppa]="0AB215679C571D1C8325275B9BDB3D89CE49EC21"
    [phd/chromium-browser]="079FA39EE6A75D23" # by default installs outdated version from the original repos, needs manual version picking
    [mozillateam/ppa]="0AB215679C571D1C8325275B9BDB3D89CE49EC21"
)

# PPAs from ext repos; values are the deb string w/o prefix
declare -A PPA_REPO_DEBS=(
    [opera-stable]="http://deb.opera.com/opera-stable/ stable non-free"
    [vivaldi-stable]="https://repo.vivaldi.com/archive/deb/ stable main"
    [librewolf]="http://deb.librewolf.net $codename main"
    [codium]="https://download.vscodium.com/debs vscodium main"
    [brave-browser]="https://brave-browser-apt-release.s3.brave.com/ stable main"
    [sublime-text]="https://download.sublimetext.com/ apt/stable/"
    [media-human]="https://www.mediahuman.com/packages/ubuntu $codename main "
    [nodejs]="https://deb.nodesource.com/node_20.x nodistro main"
)

# unsigned PPAs from ext repos; values are urls to keys which are imported via apt-key add
declare -A PPA_KEYS_AUTO=(
    [opera-stable]="https://deb.opera.com/archive.key"
    [vivaldi-stable]="https://repo.vivaldi.com/archive/linux_signing_key.pub"
    [librewolf]="https://deb.librewolf.net/keyring.gpg"
    [codium]="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg"
    [sublime-text]="https://download.sublimetext.com/sublimehq-pub.gpg"
    [nodejs]="https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key"
)


# signed PPAs from ext repos; values are urls to gpg keys which are saved locally
# and are imported in a special way (needs signed-by property)
declare -A PPA_KEYS_SIGN=(
    [brave-browser]="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
)

# PPAs from ext repos; values are hash of keys which need to be imported from launchpad
#   (as for regular lp-ppas)
declare -A PPA_KEYS_LP=(
    [media-human]="7D19F1F3" # D808832C7D19F1F3: youtube-to-mp3 youtube-downloader lyrics-finder
)

