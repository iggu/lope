# supported variables:
#   $codename: ubuntu's release codename

# PPAs from launchpad; user/repo as a key and key hash as a value
declare -A PPA_LAUNCHPAD=(
    [costales/anoise]="0DD210ABE883B905B88B55E7FC14671BA89CA06C"
    [libreoffice/ppa]="36E81C9267FD1383FCC4490983FBA1751378B444"
)

# PPAs from ext repos; values are the deb string w/o prefix
# keys are imported in a usual way (doesnt need signed-by property)
declare -A PPA_REPO_DEBS=(
    [opera-stable]="http://deb.opera.com/opera-stable/ stable non-free"
    [vivaldi-stable]="https://repo.vivaldi.com/archive/deb/ stable main"
    [librewolf]="http://deb.librewolf.net $codename main"
    [codium]="https://download.vscodium.com/debs vscodium main"
    [brave-browser]="https://brave-browser-apt-release.s3.brave.com/ stable main"
)

# signed PPAs from ext repos; values are the deb string w/o prefix
# keys are imported in a special way (needs signed-by property)
declare -A PPA_KEYS_AUTO=(
    [opera-stable]="https://deb.opera.com/archive.key"
    [vivaldi-stable]="https://repo.vivaldi.com/archive/linux_signing_key.pub"
    [librewolf]="https://deb.librewolf.net/keyring.gpg"
    [codium]="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg"
)

declare -A PPA_KEYS_SIGN=(
    [brave-browser]="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
)

