# profile.sh
#
# Must be first executed line!
_sourced="$_"

############################################################################
###
### Global Variables
###
############################################################################

# Only load this module once:
[ "x$_DP_DOTPKG_LOADED" = "x" ] || return 0
_DP_DOTPKG_LOADED=true

# Directory containing dotpkg files
if [ "x$DOTPKG_DIR" = "x" ]
then
	DOTPKG_DIR=`dirname "${_sourced:-$HOME/dotfiles/dotpkg/profile.sh}"`
	if [ "x$DOTPKG_DIR" = "x." ]
	then
		DOTPKG_DIR=`pwd`
	fi
fi
unset _sourced
export DOTPKG_DIR

# List of directories to search for packages
[ "x$DOTPKG_PACKAGE_PATH" = "x" ] && DOTPKG_PACKAGE_PATH=`dirname "$DOTPKG_DIR"`
export DOTPKG_PACKAGE_PATH

# Store to last directory in path - guessing that sequence is system:user directories
[ "x$DOTPKG_PACKAGE_STORE" = "x" ] && DOTPKG_PACKAGE_STORE=`echo "$DOTPKG_PACKAGE_PATH" | sed -e 's/^.*://'`
export DOTPKG_PACKAGE_STORE

# Default suffix for this shell
[ "x$DOTPKG_SHELL_EXT" = "x" ] && DOTPKG_SHELL_EXT=`basename "$SHELL"`
export DOTPKG_SHELL_EXT

# List of suffixes to check for files
case "$DOTPKG_SHELL_EXT" in
bash ) DOTPKG_SUFFIXES="${DOTPKG_SUFFIXES:-.bash .ksh .sh}" ;;
ash ) DOTPKG_SUFFIXES="${DOTPKG_SUFFIXES:-.ash .sh}" ;;
ksh ) DOTPKG_SUFFIXES="${DOTPKG_SUFFIXES:-.ksh .sh}" ;;
zsh ) DOTPKG_SUFFIXES="${DOTPKG_SUFFIXES:-.zsh .ksh .sh}" ;;
# handle 'sh' and any leakers.
* ) DOTPKG_SUFFIXES="${DOTPKG_SUFFIXES:-.sh}" ;;
esac
export DOTPKG_SUFFIXES

DOTPKG_DEFAULT_REPO="${DOTPKG_DEFAULT_REPO:-github}"
export DOTPKG_DEFAULT_REPO

############################################################################
###
### Subroutines
###
############################################################################

_DP_run_pkg_script() {
	_dp_script="$1"
	for _dp_ext in "$DOTPKG_SUFFIXES"
	do
		[ -f "$_DP_PKG_DIR/$_dp_script$_dp_ext" ] || continue
		. "$_DP_PKG_DIR/$_dp_script$_dp_ext"
		return
	done
	unset _dp_ext _dp_script
}

_DP_load_pkg() {
	echo "Loading package: $_DP_PACKAGE"
	_DP_run_pkg_script autoload

	for _dp_ext in "$DOTPKG_SUFFIXES"
	do
		[ -f "$_DP_PKG_DIR/logout$_dp_ext" ] || continue
		DOTPKG_LOGOUT="$DOTPKG_LOGOUT:$_DP_PKG_DIR/logout$_dp_ext"
		export DOTPKG_LOGOUT
		break
	done
}

_DP_refresh_package() {
	if [ -d "$_DP_PKG_DIR" ]
	then
		oldCWD=`pwd`
		cd "$_DP_PKG_DIR"

		case "$_DP_PKG_VCS" in
		git )	git pull ;;
		hg  )	hg  pull ;;
		esac

		cd "$oldCWD"
	else
		case "$_DP_PKG_VCS" in
		git )	git clone "$_DP_PKG_URL" "$_DP_PKG_DIR"	;;
		hg )	hg  clone "$_DP_PKG_URL" "$_DP_PKG_DIR" ;;
		esac
	fi
}

_DP_parse_package() {
	# _DP_PACKAGE looks like one of these: 
	# 1) a url: http://github.com/aghast/dotpkg
	# 2) a host/user/repo triple: github/aghast/dotpkg
	# 3) a user-or-project/repo pair: aghast/dotpkg
	# 4) something else: *

	_DP_PKG_NAME=`basename "$_DP_PACKAGE"`
	unset _DP_PKG_GROUP _DP_PKG_HOST _DP_PKG_URL _DP_PKG_VCS

	case "$_DP_PACKAGE" in
	*://*) # It's a url
		_DP_PKG_URL="$_DP_PACKAGE"
		_DP_PKG_GROUP=`dirname "$_DP_PACKAGE"`
		_DP_PKG_GROUP=`basename "$_DP_PKG_GROUP"`
		;;
	*/*/*)	# It's a triple
		_DP_PKG_GROUP=`dirname "$_DP_PACKAGE"`
		_DP_PKG_HOST=`dirname "$_DP_PKG_GROUP"`
		_DP_PKG_GROUP=`basename "$_DP_PKG_GROUP"`
		#_Figure out url from host
		;;
	*/*)	# It's a pair
		_DP_PKG_GROUP=`dirname "$_DP_PACKAGE"`
		_DP_PKG_HOST=$DOTPKG_DEFAULT_REPO
		#_Figure out url from host
		;;
	*)	# WTF?
		_DP_PKG_HOST=$DOTPKG_DEFAULT_REPO
		# Unexpected, but we can try it- maybe if pkg host is googlecode or something.
	esac
}

_DP_set_package() {
	_DP_PACKAGE="$1"
	_DP_parse_package
	_DP_set_pkgdir
	_DP_set_pkgurl
	_DP_set_pkgvcs
}

_DP_set_pkgdir() {
	_DP_PKG_DIR="$DOTPKG_PACKAGE_STORE/$_DP_PKG_NAME"
	oldIFS="$IFS"
	IFS=:
	for dir in "$DOTPKG_PACKAGE_PATH"
	do
		# Skip empty entries
		[ "x$dir" = "x" ] && continue
		# Check if package dir exists in this location
		[ -d "$dir/$_DP_PKG_NAME" ] || continue
		_DP_PKG_DIR="$dir/$_DP_PKG_NAME"
		break
	done
	IFS="$oldIFS"
	return 0
}

_DP_set_pkgurl() {
	[ "x$_DP_PKG_URL" = "x" ] || return 0

	_DP_PKG_HOST=${_DP_PKG_HOST:-$DOTPKG_DEFAULT_REPO}

	case "$_DP_PKG_HOST" in
	*://* )
		# TODO: How does this happen? Is there any benefit to this option?
		_DP_PKG_URL="$_DP_PKG_HOST"
		;;
	* )
		_DP_PKG_URL=`grep "^$_DP_PKG_HOST|" "$DOTPKG_DIR/repo-urls" \
		| cut -d'|' -f2`
		;;
	esac

	_DP_PKG_URL=`echo "$_DP_PKG_URL" \
	| sed -e "s/{PROJECT}/$_DP_PKG_GROUP/g" -e "s/{GROUP}/$_DP_PKG_GROUP/g" \
		-e "s/{USER}/$_DP_PKG_GROUP/g" -e "s/{REPO}/$_DP_PKG_NAME/g" `
}

_DP_set_pkgvcs() {
	[ "x$_DP_PKG_VCS" = "x" ] || return 0

	case "$_DP_PKG_URL" in
	*//git*|*.git) _DP_PKG_VCS=git	;;
	*) _DP_PKG_VCS=git ;;
	esac
}

dotpkg() {
	if [ $# -eq 0 ]
	then
		echo "Usage: dotpkg 'author/pkg' [ ... ]" >&2
		return 1
	fi

	_DP_set_package "$1"
	_DP_refresh_package || return 1
	_DP_load_pkg
}

dotpkg_logout() {
	[ "x$_DP_LOGOUT" = "x" ] || return 0
	_DP_LOGOUT=true

	oldIFS="$IFS"
	IFS=:
	for _dp_logout in "$DOTPKG_LOGOUT"
	do
		[ "x$_dp_logout" = "x" ] && continue
		. "$_dp_logout"
	done
	IFS="$oldIFS"
	unset _dp_logout
	return 0
}

# Try to hook the exit handler, but if someone overwrites us, we're borked.
# Please be sure you call dotpkg_logout from your .logout file, too.
trap dotpkg_logout EXIT

