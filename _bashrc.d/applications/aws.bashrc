
AWS_COMPLETER=$(which aws_completer 2> /dev/null)

if [ -f "$AWS_COMPLETER" ] ; then
	complete -C $AWS_COMPLETER aws
fi
