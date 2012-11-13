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

args='-really-quiet'
#args="$args -fs"
#args="$args -nosound" # Uncomment out to disable sound.

[ "$2" ] && args="$args -nostop-xscreensaver -wid $2"

OIFS=$IFS

trap : SIGTERM SIGINT SIGHUP

while (true) #!(keystate lshift)
do
	IFS='
	'

	[ "$vids" ] || vids="$(find "$1" -type f -iregex ".*\\.$ext\$" | shuf)"

	vid=$(echo "$vids" | head -n1)
	nvids=$(echo "$vids" | wc -l)
	vids=$(echo "$vids" | tail -n$((nvids-1)))

	IFS="$OIFS"
	mplayer $args "$vid" &
	pid=$!

	wait $pid
	[ $? -gt 128 ] && { kill $pid ; exit 128; } ;
done
