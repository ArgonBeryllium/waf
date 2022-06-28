#!/bin/sh

if [ -z "$(date)" ] ; then
	echo "Somehow, you don't have 'date' in your PATH. It's probably a 50/50 as to whether you're seeing this message, since you're likely to lack 'echo' as well. I'd reconsider a few things."
	exit
fi

SHELL_DEFAULT='sh -e'
COMND_DEFAULT='echo update'
print_header()
{
	echo "ArBe's Wack-A-File v.1.0.0"
	echo "Executes a command every time a file is updated."
}
print_usage()
{
	echo "Usage:"
	echo -e " $0 [-c command] [-s shell] <file(s)>"
	echo -e "\t file(s)       file to watch"
	echo -e "\t -c command    command to execute (default: '$COMND_DEFAULT')"
	echo -e "\t -s shell      shell to execute the command (assumed piping support) (default: '$SHELL_DEFAULT')"
	echo -e "\t -v            print option values"
	echo -e "\t -h            print this message"
}
echo_err()
{
	echo "$@" >&2
}

verbose=0
files=()
i=1
while [[ $i -le $# ]]
do
	j=$(($i+1))
	opt=${!i}
	arg=${!j}

	case $opt in
		-c) command="$arg" ;;
		-s) shell="$arg" ;;
		-h) print_header && print_usage && exit ;;
		-v) verbose=1 ;;
		*)
			if ! [ -z `echo $opt | grep '^-'` ]; then
				echo_err "Not a recognised option: '$opt'"
				print_usage && exit
			fi
			if ! [[ -e "$opt" ]]; then
				echo_err "File '$opt' doesn't exist"
				print_usage && exit
			fi
			files+=("$opt")
			i=$j
			continue
			;;
	esac
	i=$(($i+2))
done

[ -z "$command" ] && command="$COMND_DEFAULT"
[ -z "$shell" ] && shell="$SHELL_DEFAULT"

if [ $verbose -ne 0 ]
then
	echo "command: $command"
	echo "shell: $shell"
	echo "files: ${files[@]}"
fi

if [[ "${#files[@]}" -eq 0 ]] ; then
	echo_err "No files provided"
	print_usage
	exit
fi

last=()
for file in "${files[@]}"
do
	last+=($(date -r "$file" '+%s'))
done
while true
do
	for (( i = 0; i < ${#files[@]}; i++ ))
	do
		new=$(date -r "${files[$i]}" '+%s')
		if [[ "$new" -gt "${last[$i]}" ]] ; then
			echo "$command" | $shell
			last[$i]=$new
		fi
	done
	sleep .1
done
