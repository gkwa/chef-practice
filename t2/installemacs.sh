cd /tmp

[ -f stow-install.sh ] && exit

export DEBIAN_FRONTEND=noninteractive

apt-get -y -qq update
apt-get -y install autoconf	git

# Install stow
curl -o stow-install.sh https://raw.githubusercontent.com/TaylorMonacelli/gnu-stow-install/master/install.sh
sh -x stow-install.sh

cd /tmp

# Install emacs
curl -o emacs-install-generic.sh https://raw.githubusercontent.com/TaylorMonacelli/emacs_build/emacsgeneric/emacs-install-generic.sh
sh -x emacs-install-generic.sh

cd /tmp

# Install taylor's dotfiles
cd ~
git init
git remote add origin https://github.com/taylormonacelli/dotfiles
git fetch --prune
git checkout --force --track origin/master

# Download emacs packages read from .emacs
emacs --daemon
