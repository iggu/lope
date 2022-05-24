
#!/usr/bin/env bash


## https://stackoverflow.com/a/68522349
ESeq="\x1b["

# Set up our Colour Holders. 
ResetColor="$ESeq"'0m'    # Text Reset
Bold="$ESeq"'1m';    Underline="$ESeq"'4m'

# Regular              Bold                        Underline                       High Intensity           
Black="$ESeq"'0;30m';  BoldBlack="$ESeq"'1;30m';   UnderlineBlack="$ESeq"'4;30m';  IntenseBlack="$ESeq"'0;90m'; 
Red="$ESeq"'0;31m';    BoldRed="$ESeq"'1;31m';     UnderlineRed="$ESeq"'4;31m';    IntenseRed="$ESeq"'0;91m';   
Green="$ESeq"'0;32m';  BoldGreen="$ESeq"'1;32m';   UnderlineGreen="$ESeq"'4;32m';  IntenseGreen="$ESeq"'0;92m'; 
Yellow="$ESeq"'0;33m'; BoldYelllow="$ESeq"'1;33m'; UnderlineYellow="$ESeq"'4;33m'; IntenseYellow="$ESeq"'0;93m';
Blue="$ESeq"'0;34m';   BoldBlue="$ESeq"'1;34m';    UnderlineBlue="$ESeq"'4;34m';   IntenseBlue="$ESeq"'0;94m';  
Purple="$ESeq"'0;35m'; BoldPurple="$ESeq"'1;35m';  UnderlinePurple="$ESeq"'4;35m'; IntensePurple="$ESeq"'0;95m';
Cyan="$ESeq"'0;36m';   BoldCyan="$ESeq"'1;36m';    UnderlineCyan="$ESeq"'4;36m';   IntenseCyan="$ESeq"'0;96m';  
White="$ESeq"'0;37m';  BoldWhite="$ESeq"'1;37m';   UnderlineWhite="$ESeq"'4;37m';  IntenseWhite="$ESeq"'0;97m'; 

#Bold High Intensity                Background              High Intensity Backgrounds
BoldIntenseBlack="$ESeq"'1;90m';    OnBlack="$ESeq"'40m';   OnIntenseBlack="$ESeq"'0;100m';
BoldIntenseRed="$ESeq"'1;91m';      OnRed="$ESeq"'41m';     OnIntenseRed="$ESeq"'0;101m';
BoldIntenseGreen="$ESeq"'1;92m';    OnGreen="$ESeq"'42m';   OnIntenseGreen="$ESeq"'0;102m';
BoldIntenseYellow="$ESeq"'1;93m';   OnYellow="$ESeq"'43m';  OnIntenseYellow="$ESeq"'0;103m';
BoldIntenseBlue="$ESeq"'1;94m';     OnBlue="$ESeq"'44m';    OnIntenseBlue="$ESeq"'0;104m';
BoldIntensePurple="$ESeq"'1;95m';   OnPurple="$ESeq"'45m';  OnIntensePurple="$ESeq"'0;105m';
BoldIntenseCyan="$ESeq"'1;96m';     OnCyan="$ESeq"'46m';    OnIntenseCyan="$ESeq"'0;106m';
BoldIntenseWhite="$ESeq"'1;97m';    OnWhite="$ESeq"'47m';   OnIntenseWhite="$ESeq"'0;107m';

