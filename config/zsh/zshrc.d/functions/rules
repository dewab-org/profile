# Rules

## Print a horizontal rule
rule () {
      printf -v _hr "%*s" $(tput cols) && echo ${_hr// /${1--}}
}

## Print horizontal ruler with message
rulem ()  {
      if [ $# -eq 0 ]; then
          echo "Usage: rulem MESSAGE [RULE_CHARACTER]"
              return 1
      fi
      # Fill line with ruler character ($2, default "-"), reset cursor, move 2 cols right, print message
      printf -v _hr "%*s" $(tput cols) && echo -en ${_hr// /${2--}} && echo -e "\r\033[2C$1"
}

rulemc ()  {
      if [ $# -eq 0 ]; then
          echo "Usage: rulem MESSAGE [RULE_CHARACTER]"
              return 1
      fi
      # Fill line with ruler character ($2, default "-"), reset cursor, move 2 cols right, print message
      printf -v _hr "%*s" $(tput cols) && print -n ${_hr// /${2--}} && printf "\r\033[2C${fg[yellow]}${1}${reset_color}\n"
}
