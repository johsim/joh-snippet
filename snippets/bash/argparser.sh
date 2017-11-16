#
# Outline for an argument parser in bash using getopts.
#

# Indicates the index of the input options.
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Option letters to be recognized. Syntax:
# x: = x is expected to have an argument (separeted with whitespace)
export optstring="h?vf:"

# Print help for argument parser
show_help()
{
    echo "Usage: [-a] [-b filename] [-h] ..."
}

# If no input arguments, show help and exit
# $# = Number of input arguments.
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Argument parser
#  - opt: Each time getopts is invoked, the next option will be placed in opt.
#  - OPTARG: When an option require an argument, the argument will be placed in OPTARG
#  - optstring ("h?vf"): Option letters to be recognized. Syntax:
#    x: = x is expected to have an argument (separeted with whitespace)

# If an invalid argument is passed, "?" will be placed in opt.
while getopts "h?ab:" opt; do
    case "$opt" in
	h |\? | *)  # Prints help for -h and an invalid argument
	    show_help
	    exit 0
	    ;; # End of case alternative (like break in C)
	a)  verbose=1
	    ;;
	b)  output_file=$OPTARG
	    ;;
    esac # End of case
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose, output_file='$output_file'"
