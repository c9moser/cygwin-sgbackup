#!/bin/sh

root_dir=${0%/sgrestore.sh}
conf_dir="${root_dir}/sgconf"
sg_restore_mode="r"

sg_list() {
	for i in `ls "${conf_dir}"/*.conf | sort`; do
		source "$i"
		conf="${i#${conf_dir}/}"
		cname="${conf%.conf}"
		if [ ${#cname} -lt 8 ]; then
			indent="			"
		elif [ ${#cname} -lt 16 ]; then
			indent="		"
		elif [ ${cname} -lt 24 ]; then
			indent="	"
		else
			indent=" "
		fi

		echo "${cname}${indent}${NAME}"
	done
}

sg_print_name() {
	cname="$1"
	conf="${conf_dir}/${cname}.conf"
	if [ ! -f "$conf" ]; then
		echo "Configuration for '${cname}' not found!" >&2
		return 1
	fi
	source "${conf}"

	if [ ${#cname} -lt 8 ]; then
		indent="			"
	elif [ ${#cname} -lt 16 ]; then
		indent="		"
	elif [ ${#cname} -lt 24 ]; then
		indent="	"
	else
		indent=" "
	fi
	echo	"${cname}${indent}${NAME}"

}

sg_restore() {
	cname=$1
	conf="${cname}.conf"
	sgconf="${conf_dir}/${conf}"
	if [ ! -f "${sgconf}" ]; then
		echo "Configuration for '$cname' not found!" >&2
		return 1
	fi
	source "${sgconf}"
	echo "----> restore '$NAME' <----"
	tar -xJvf "${root_dir}/SaveGames/${SGNAME}.tar.xz" -C "${SGROOT}"
}

sg_print_help() {
	echo "USAGE"
	echo "====="
	echo "  sgrestore.sh -a|-h|-l"
	echo "  sgrestore.sh [-n|-r] args ..."
	echo ""
	echo "Descritpion"
	echo "==========="
	echo "  -a     restore all savegames"
	echo "  -h     print help"
	echo "  -l     list savegames backups"
	echo "  -n     show savegame name by argument"
	echo "  -r     restore savegames by name [default]"

}

# parse otions
args=`getopt ahlr $*`
if [ $? -ne 0 ]; then
	sg_print_help
	exit 1
fi
set -- $args
while :; do
	case $1 in
		-a)
			sg_restore_mode="a"
			shift
			;;
		-h)
			sg_print_help
			exit
			;;
		-l)
			sg_list
			exit
			;;
		-n)
			sg_restore_mode="n"
			shift
			;;
		-r)
			sg_restore_mode="r"
			shift
			;;
		--)
			shift; break
			;;
		*)
			echo "UNKNOWN OPTION '$1'" >&2
			sg_print_help
			exit 1
			;;
	esac
done

case $sg_restore_mode in
	a)
		for i in "${conf_dir}"/*.conf; do
			conf=${i#${sgconfdir}/}
			cname=${conf%.conf}
			sg_restore "$cname"
		done
		;;
	n)
		if [ $# -eq 0 ]; then
			echo "MISSING ARGUMENTS!" >&2
			sg_print_help
			exit 1
		fi
		while [ $# -gt 0 ]; do
			sg_print_name "$1"
			shift
		done
		;;
	r)
		if [ $# -eq 0 ]; then
			echo "MISSING ARGUMENTS!" >&2
			sg_print_help
			exit 1
		fi
		while [ $# -gt 0 ]; do
			sg_restore "$1"
			shift
		done
		;;
	*)
		# should never be reached!!!
		echo "UNKNOWN RESTORE MODE '${sg_restore_mode}'!" >&2
		exit 1
		;;
esac
