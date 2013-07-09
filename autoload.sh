# autoload.sh script for dotpkg

# define path manipulators

path_append() {
	_pathvar="${2:-PATH}"
	_extra="$1"
	eval _pathval=\"\$$_pathvar\"
	[ "$_pathval" ] && _pathval="$_pathval:"

	# Bail if already in path
	case ":$_pathval" in
	*:"$_extra":*) false ;;
	*) eval "$_pathvar=$_pathval$_extra" ; true ;;
	esac
}

path_prepend() {
	path_remove "$@"
	_pathvar="${2:-PATH}"
	_extra="$1"
	eval _pathval=\"\$$_pathvar\"
	[ "$_pathval" ] && _pathval=":$_pathval"
	eval "$_pathvar=$_extra$_pathval"
	true
}

path_remove() {
	_pathvar="${2:-PATH}"
	_remove="$1"
	eval _pathval=\"\$$_pathvar\"

	case ":$_pathval:" in
	*:"$_remove":*)
		_pathval=`echo ":$_pathval:" | sed -e "s|:$_remove:|:|g" -e 's/^://' -e 's/:$//'`
		eval "$_pathvar"=\"$_pathval\"
		;;
	esac
	true
}
