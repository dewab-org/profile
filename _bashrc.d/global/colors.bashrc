#
# Set all color variables for use in other scripts
#

#
# NOTE:  Remember to escape NON-PRINTABLE characters with \[ and \] so that readline knows where text actually is for line-wrap purposes
# NOTE2:  DON'T escape PRINTABLE characters with \ otherwise readline will think that they're NON-PRINTABLE
# NOTE3:  In otherwords ONLY USE \[ or \] if it's NOT PRINTABLE
#

RCol='\[\e[0m\]'    # Text Reset

# Regular           	Bold                	Underline           	High Intensity      	BoldHigh Intens     	Background          	High Intensity Backgrounds
Bla='\[\e[0;30m\]';     BBla='\[\e[1;30m\]';    UBla='\[\e[4;30m\]';    IBla='\[\e[0;90m\]';    BIBla='\[\e[1;90m\]';   On_Bla='\[\e[40m\]';    On_IBla='\[\e[0;100m\]';
Red='\[\e[0;31m\]';     BRed='\[\e[1;31m\]';    URed='\[\e[4;31m\]';    IRed='\[\e[0;91m\]';    BIRed='\[\e[1;91m\]';   On_Red='\[\e[41m\]';    On_IRed='\[\e[0;101m\]';
Gre='\[\e[0;32m\]';     BGre='\[\e[1;32m\]';    UGre='\[\e[4;32m\]';    IGre='\[\e[0;92m\]';    BIGre='\[\e[1;92m\]';   On_Gre='\[\e[42m\]';    On_IGre='\[\e[0;102m\]';
Yel='\[\e[0;33m\]';     BYel='\[\e[1;33m\]';    UYel='\[\e[4;33m\]';    IYel='\[\e[0;93m\]';    BIYel='\[\e[1;93m\]';   On_Yel='\[\e[43m\]';    On_IYel='\[\e[0;103m\]';
Blu='\[\e[0;34m\]';     BBlu='\[\e[1;34m\]';    UBlu='\[\e[4;34m\]';    IBlu='\[\e[0;94m\]';    BIBlu='\[\e[1;94m\]';   On_Blu='\[\e[44m\]';    On_IBlu='\[\e[0;104m\]';
Pur='\[\e[0;35m\]';     BPur='\[\e[1;35m\]';    UPur='\[\e[4;35m\]';    IPur='\[\e[0;95m\]';    BIPur='\[\e[1;95m\]';   On_Pur='\[\e[45m\]';    On_IPur='\[\e[0;105m\]';
Cya='\[\e[0;36m\]';     BCya='\[\e[1;36m\]';    UCya='\[\e[4;36m\]';    ICya='\[\e[0;96m\]';    BICya='\[\e[1;96m\]';   On_Cya='\[\e[46m\]';    On_ICya='\[\e[0;106m\]';
Whi='\[\e[0;37m\]';     BWhi='\[\e[1;37m\]';    UWhi='\[\e[4;37m\]';    IWhi='\[\e[0;97m\]';    BIWhi='\[\e[1;97m\]';   On_Whi='\[\e[47m\]';    On_IWhi='\[\e[0;107m\]';

# 2015-10-30 The above prints the \[ and \] for some reason.  Removed versions below
_RCol='\e[0m'    # Text Reset

# Regular           	Bold                	Underline           	High Intensity      	BoldHigh Intens     	Background          	High Intensity Backgrounds
_Bla='\e[0;30m';     _BBla='\e[1;30m';    _UBla='\e[4;30m';    _IBla='\e[0;90m';    _BIBla='\e[1;90m';   _On_Bla='\e[40m';    _On_IBla='\e[0;100m';
_Red='\e[0;31m';     _BRed='\e[1;31m';    _URed='\e[4;31m';    _IRed='\e[0;91m';    _BIRed='\e[1;91m';   _On_Red='\e[41m';    _On_IRed='\e[0;101m';
_Gre='\e[0;32m';     _BGre='\e[1;32m';    _UGre='\e[4;32m';    _IGre='\e[0;92m';    _BIGre='\e[1;92m';   _On_Gre='\e[42m';    _On_IGre='\e[0;102m';
_Yel='\e[0;33m';     _BYel='\e[1;33m';    _UYel='\e[4;33m';    _IYel='\e[0;93m';    _BIYel='\e[1;93m';   _On_Yel='\e[43m';    _On_IYel='\e[0;103m';
_Blu='\e[0;34m';     _BBlu='\e[1;34m';    _UBlu='\e[4;34m';    _IBlu='\e[0;94m';    _BIBlu='\e[1;94m';   _On_Blu='\e[44m';    _On_IBlu='\e[0;104m';
_Pur='\e[0;35m';     _BPur='\e[1;35m';    _UPur='\e[4;35m';    _IPur='\e[0;95m';    _BIPur='\e[1;95m';   _On_Pur='\e[45m';    _On_IPur='\e[0;105m';
_Cya='\e[0;36m';     _BCya='\e[1;36m';    _UCya='\e[4;36m';    _ICya='\e[0;96m';    _BICya='\e[1;96m';   _On_Cya='\e[46m';    _On_ICya='\e[0;106m';
_Whi='\e[0;37m';     _BWhi='\e[1;37m';    _UWhi='\e[4;37m';    _IWhi='\e[0;97m';    _BIWhi='\e[1;97m';   _On_Whi='\e[47m';    _On_IWhi='\e[0;107m';
