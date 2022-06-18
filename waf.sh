#!/bin/sh

if [ -z "$(date)" ] ; then
	echo "Somehow, you don't have 'date' in your PATH. It's probably a 50/50 as to whether you're seeing this message, since you're likely to lack 'echo' as well. I'd reconsider a few things."
	exit
fi

print_usage()
{
	echo "ArBe's Wack-A-File v.0.0.1"
	echo "Executes a command every time a file is updated."
	echo "Usage:"
	echo -e "\t"$0" file [command] [shell]"
	echo -e "file    \t - file to watch"
	echo -e "command \t - command to execute (default: 'echo update')"
	echo -e "shell   \t - shell to execute the command (assumed piping support) (default: 'sh -e')"
}

file=$1
if [ -z "$file" ] ; then
	print_usage
	exit
fi
[ $# -gt 1 ] && command=$2
[ -z "$command" ] && command='echo update'
[ $# -gt 2 ] && shell=$2
[ -z "$shell" ] && shell='sh -e'

last=$(date -r "$file" '+%s')
while true
do
	new=$(date -r "$file" '+%s')
	if [ $new -gt $last ] ; then
		echo "$command" | $shell
		last=$new
	fi
	sleep .1
done
