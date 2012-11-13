#! /bin/bash

# Copyright 2012 Kevin Cox

################################################################################
#                                                                              #
#  This software is provided 'as-is', without any express or implied           #
#  warranty. In no event will the authors be held liable for any damages       #
#  arising from the use of this software.                                      #
#                                                                              #
#  Permission is granted to anyone to use this software for any purpose,       #
#  including commercial applications, and to alter it and redistribute it      #
#  freely, subject to the following restrictions:                              #
#                                                                              #
#  1. The origin of this software must not be misrepresented; you must not     #
#     claim that you wrote the original software. If you use this software in  #
#     a product, an acknowledgment in the product documentation would be       #
#     appreciated but is not required.                                         #
#                                                                              #
#  2. Altered source versions must be plainly marked as such, and must not be  #
#     misrepresented as being the original software.                           #
#                                                                              #
#  3. This notice may not be removed or altered from any source distribution.  #
#                                                                              #
################################################################################

ext='\(avi\|mkv\|mp4\)' # File extensions to play as movies (file'ing each file
                        # is too slow).  Add more and send a pull request.

dir=( )
args=(-really-quiet)

usage ()
{
	echo "Usage: $0 [options] directory...
	-q --no-sound:
		Disable sound output.
	-f --full-screen:
		Make playback full screen.  Usefull when not run from
		xscreensaver.
	-h --help:
		This message."
	exit 1
}

OPTS=$(getopt -ao qfhd: -l no-sound,full-screen,help,window-id: -- "$@")
[ $? == 0 ] || usage

eval set -- "$OPTS"
while true ; do
	echo $1 >> /tmp/log.txt
	case "$1" in
		-h|--help)
			usage
			shift;;
		-q|--no-sound)
			args+=(-nosound)
			shift;;
		-f|--full-screen)
			args="$args -fs"
			shift;;
		-d)
			dir+=("$2")
			shift 2;;
		--window-id)
			XSCREENSAVER_WINDOW="$2"
			shift 2;;
		--) shift; break;;
		*)
			usage
	esac
done

[ "$XSCREENSAVER_WINDOW" ] && args+=(-nostop-xscreensaver -wid "$XSCREENSAVER_WINDOW")

dir+=("$@")                               # Add positional parameters.
[ ${#dir[@]} == 0 ] && dir=( ~/"Videos" ) # Default

IFS=$'\n'

trap : SIGTERM SIGINT SIGHUP

while (true) #!(keystate lshift)
do

	[ "$vids" ] || vids="$(find "${dir[@]}" -type f -iregex ".*\\.$ext\$" | shuf)"
	[ "$vids" ] || { echo "Error: No videos found." ; exit 1 ; }

	vid=$(echo "$vids" | head -n1)
	nvids=$(echo "$vids" | wc -l)
	vids=$(echo "$vids" | tail -n$((nvids-1)))

	#echo mplayer "${args[@]}" "$vid" &
	mplayer "${args[@]}" "$vid" &
	pid=$!

	wait $pid
	[ $? -gt 128 ] && { kill $pid ; exit 128; } ;
done
