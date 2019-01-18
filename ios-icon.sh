#!/bin/sh
usage () {
	echo 
	echo "USAGE:"
	echo "$0 [TargetFile] [TargetDirectory]"
	echo
	echo "EXAMPLES:"
	echo "$0 1024.png ~/path"
	echo 
	exit 1
}
error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo "[${red}ERROR${normal}] $1"
}

info() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo "[${green}INFO${normal}] $1"
}

askfor () {
	while [ 1 ]; do
		printf "Export icon for $1?:(y/n)"
		read -n1 input
		echo 
	 	if [ "$input" == "y" ] 
	 	then
			return 1
			break
		else 
			if [ "$input" == "n" ]
			then
				return 0
				break
			fi
		fi
	done
}

image() {
	askfor $1
	[ $? -eq 1 ] && {
	[ ! -d "${directory}/$1_icon" ] && mkdir -p "${directory}/$1_icon"
	eval data=$(echo \${$1_sizes})
	for line in $data
	do
		name=`echo $line | awk '{print $1}'`
		size=`echo $line | awk '{print $2}'`
		info $name
		sips -Z $size $target_file --out ${directory}/$1_icon/$name.png >/dev/null
	done
	info "$1 icon is Completed."
	}
}

if [ $# != 2 ] 
then
	usage
fi
target_file=$1
directory=$2
[ ! -f "$target_file" ] && {
	error "The file $target_file does not exist"
	exit -1
}

width=`sips -g pixelWidth $target_file 2>/dev/null|awk '/pixelWidth:/{print $NF}'`

[ -z "$width" ] && {
	error "The file $tatget_file is not a image file"
	exit -1
}

[ ! -d "$directory" ] && mkdir -p "$directory"

iPhone_sizes=`cat << EOF
20*20@2x 40
20*20@3x 60
29*29@2x 58
29*29@3x 87
40*40@2x 80
40*40@3x 120
60*60@2x 120
60*60@3x 180
EOF`

iPad_sizes=`cat << EOF
20*20 20
20*20@2x 40
29*29 29
29*29@2x 58
40*40 40
40*40@2x 80
76*76 76
76*76@2x 152
83.5*83.5@2x 167
EOF`

mac_sizes=`cat << EOF
16*16 16
16*16@2x 32
32*32 32
32*32@2x 64
128*128 128
128*128@2x 256
256*256 256
256*256@2x 512
512*512 512
EOF`

OLD_IFS=$IFS
IFS=$'\n'
image iPhone
image iPad
image mac
IFS=$OLD_IFS
