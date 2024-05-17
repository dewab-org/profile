# Determine if grep supports color
if is-supported "grep --color a <<< a"; then
  GREP_OPTIONS+=" --color=auto"
fi

# Avoid grepping into certain folders
if is-supported "echo | grep --exclude-dir=.cvs ''"; then
  for PATTERN in .cvs .git .hg .svn
  do
    GREP_OPTIONS+=" --exclude-dir=$PATTERN"
  done
elif is-supported "echo | grep --exclude=.cvs ''"; then
  for PATTERN in .cvs .git .hg .svn
  do
    GREP_OPTIONS+=" --exclude=$PATTERN"
  done
fi
