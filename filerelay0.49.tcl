########################################################################################
# File Relay TCL v.049 by [IsP]@Efnet (q_lander@hotmail.com) (c) 14.11.05 18:02
# 
# If you don't know how to use this script, then don't use it ;p
#
# Someone asked me to quickly write this script - what it does is search a local dir for
# a file and it will allow a user to d/l it. Wildcard searches are in-built.
#
# TODO: 
# - Queue search/sends if dc limit reached
# - create independant thread searches & free up the bot (currently searching locks the bot until completed)
# - Optional searching folders names and sending whole folder contents 
# - Wild card file sending (multiple files dcc sending)
#
# v0.1 - 1st scripted
# v0.2 - made fr_transfer proc (dcc sending) removing duplicate tasks.
# v0.3 - fixed emtpy trigger args to display help info.
#      - Added new default help info.
#      - Fixed a counter problem
#      - Added support for multiple searches at once (just in case).
# v0.31- Minor bug fix - removed case sensitve channel checks.
# v0.4 - Added Optional !get trigger. Now if left blank, this script
#        will only search, not allow d/ling of the file found
#      - Now includes filesize when searching
#      - minor access flag alteration - you can now leave it blank,
#        instead of '-'
#      - Now included a description for channel flag support as per
#        eggdrop 1.6.X flag standards (for those that are doh!'s ;))
# v0.41- BUGFIX: corrected wrong proc call in fr_msearch
#      - Removed filesize listing
#      - Removed support for multiple searches at once (variable conflicts)
#      - Re-done and removed 'ls' command, now uses TCL based 'glob' (no longer OS dependant, Windrop friendly)
# v0.43- Optional 'SIZE' field to show in KB, MB & GB
# v0.46- Now does sub-dir searches, upto 3 levels 
#      - Now can send files to a user in a valid channel (good when restricting script access!)
# v0.47- Now you can specify the max number of subdirs to search (script setting)
#      - Subdir searching speedup
# v0.48- Small bug fix
# v0.49- Damn bugs, changed dcc errors from the 'switch' command to the 'catch' command
#      - Optimised root folder '/' trimming
#
# NOTE: MAKE SURE YOU HAVE YOUR BOT 'TRANSFER MODULE' ENABLED!!!
#
########################################
# SETTINGS:

# Set your Initial Info Message
set frmess "--==( Pour #Chan )==--"

# Set your dir here (no need for the trailing '/')
set frdir "/home/suer/eggdrop/folder/"

# Set the channels you want this script to apply to
set frchans "#chan"

# Set your (global or "-|<flag>" channel) user access flag here (leave blank for anyone)
set fraccess "-"

# Set Max Number Of Search Results 
set frlimit 20

# Set your SEARCH trigger here
set frstrigger "-s"

# Set your SEND trigger here to get a file (eg !send <filepath & name>)
set frgtrigger "-sn"

# Set your SEND trigger here to send to another user 
#   (eg !send <nick> <filepath & name>), can be the same as frgtrigger
set frntrigger "-sn <nick>"

# Set to show the SIZE of each file (0 = disable, faster searching)
set showsize 1

# Set Subdirectory depth level
#   WARNING: 3+ sub-folder depths containing 5000+ folders, 14000+ files can take 150+secs on slow systems
#            ***MAY TIMEOUT YOUR BOT***
set folderlevels 3

# Set the SEARCH help info here (leave blank for no help - won't flood the bot)
set frshelp "Usage: \002$frstrigger <search request>\002 & \002$frgtrigger <request result>\002"

# Set the GET help info here (leave blank for no help - won't flood the bot)
set frghelp "Usage: \002$frstrigger <search request>\002 & \002$frgtrigger <request result>\002"

#####################################################################
# DO NOT EDIT BELOW!
#####################################################################
if {[string match "*/" $frdir]} {set frdir [string range $frdir 0 [expr [string length $frdir] -2]]};proc fr_psearch {frnick fruhost frhandle frchan frarg} {global frdir frchans frstrigger frshelp frlimit frmess folderlevels showsize;if {([string tolower $frarg] == "help" || [string tolower $frarg] == "") && $frshelp != ""} {puthelp "PRIVMSG $frnick :$frshelp" ; return};regsub -all -- " " ${frarg} "*" frrequest;set frcnt 0;set frcntfld 1;set startim [clock seconds];set homefullfile "";set homefullsize "";set homefulldir "";puthelp "PRIVMSG $frnick :$frmess";putlog "FILERELAY: Searching for '$frarg' Requested by $frnick";set currentfolderlevel 0;catch {unset homefulldir};set homefulldir($currentfolderlevel) $frdir;while {$currentfolderlevel < $folderlevels} {if {$homefulldir($currentfolderlevel) != ""} {set homefulldir([expr $currentfolderlevel + 1]) "";foreach homedir $homefulldir($currentfolderlevel) {set currentdircontents [glob -nocomplain "$homedir/*"];foreach item1tmp $currentdircontents {if {[file isdirectory $item1tmp]} {incr frcntfld 1;lappend homefulldir([expr $currentfolderlevel + 1]) $item1tmp} else {incr frcnt 1;if {[string match "*[string tolower $frrequest]*" [string tolower $item1tmp]]} {lappend homefullfile $item1tmp;lappend homefullsize [file size $item1tmp]}}}};incr currentfolderlevel 1} else {set currentfolderlevel $folderlevels}};set frlist "";foreach homerelativefile $homefullfile {lappend frlist [string range $homerelativefile [expr [string length $frdir]+1] end]};set frcntr 0;set frlst 0;set frnotlst 0;while {$frcntr < [llength $frlist]} {set frnotlst $frcntr;if {$frlst < $frlimit} {if {$showsize == 0} {puthelp "PRIVMSG $frnick :[lindex $frlist $frcntr]"} else {set sizetmpbytes [file size "$frdir/[lindex $frlist $frcntr]"];set homefullfilesize "$sizetmpbytes  bytes";if {[expr $sizetmpbytes / 1024] >= 1} {set homefullfilesize "[string range "[expr $sizetmpbytes / 1024.0]" 0 [expr [string length "[expr $sizetmpbytes / 1024]"]+ 2] ] KB"};if {[expr $sizetmpbytes / 1048576] >= 1} {set homefullfilesize "[string range "[expr $sizetmpbytes / 1048576.0]" 0 [expr [string length "[expr $sizetmpbytes / 1048576]"]+ 2] ] MB"};if {[expr $sizetmpbytes / 1073741824] >= 1} {set homefullfilesize "[string range "[expr $sizetmpbytes / 1073741824.0]" 0 [expr [string length "[expr $sizetmpbytes / 1073741824]"]+ 2] ] GB"};puthelp "PRIVMSG $frnick :[lindex $frlist $frcntr] (SIZE:: $homefullfilesize)"};incr frlst 1} else {set frnotlst [expr $frcntr -1];set frcntr [llength $frlist];puthelp "PRIVMSG $frnick :Maximum outputlimit ($frlimit) reached. Please refine your search..."};incr frcntr 1};puthelp "PRIVMSG $frnick : Shown $frlst of [llength $frlist] out of $frcnt entries in $frcntfld folder(s), completed within [expr [clock seconds] - $startim] seconds..."};putlog "\002File Relay TCL v0.49\002 by \[IsP\]@Efnet (q_lander@hotmail.com)";proc fr_pget {frnick fruhost frhandle frchan frarg} {global frdir frchans frgtrigger frghelp;set fnd 0;foreach frch [split $frchans] {if {[string tolower $frch] == [string tolower $frchan]} {set fnd 1}};if {$fnd == 0} {return};fr_transfer $frnick $frarg};proc fr_mget {frnick fruhost frhandle frarg} {global frdir frchans frgtrigger frghelp;set fnd 0;foreach frch [split $frchans] {if {![catch {onchan $frnick $frch}]} {if {[onchan $frnick $frch]} {set fnd 1}}};if {$fnd == 0} {return};fr_transfer $frnick $frarg};proc fr_transfer {frnck frargs} {global frghelp frdir frchans;if {([string tolower $frargs] == "help" || [string tolower $frargs] == "") && $frghelp != ""} {puthelp "PRIVMSG $frnck :$frghelp" ; return};foreach frch [split ${frchans}] {if {[onchan [lindex ${frargs} 0] ${frch}]} {set frnck [lindex ${frargs} 0];set frargs [string trimleft [lrange ${frargs} 1 end]]	}};if {![file exists "${frdir}/${frargs}"]} {set frargs [string trimleft [string tolower ${frargs}]];if {![file exists "${frdir}/${frargs}"]} {set frargs [string toupper ${frargs}];if {![file exists "${frdir}/${frargs}"]} {puthelp "PRIVMSG ${frnck} : ${frargs} not found ...";return 1}}};if {![catch {[dccsend "${frdir}/${frargs}" ${frnck}]}]} {puthelp "PRIVMSG ${frnck} : Error sending file, try again later..."}};proc fr_searchtmer {frnick1 fruhost1 frhandle1 frchan1 frarg1} {global frchans;set fnd 0;foreach frch [split $frchans] {if {[string tolower $frch] == [string tolower $frchan1]} {set fnd 1}};if {$fnd == 0} {return};puthelp "PRIVMSG $frnick1 : Searching...please wait...";utimer 1 "[fr_psearch $frnick1 $fruhost1 $frhandle1 $frchan1 $frarg1]"};proc fr_msearch {frnick fruhost frhandle frarg} {global frdir frchans frgtrigger frghelp;set fnd 0;foreach frch [split $frchans] {if {![catch {onchan $frnick $frch}]} {if {[onchan $frnick $frch]} {set frchan $frch; set fnd 1}}};if {$fnd == 0} {return};fr_searchtmer $frnick $fruhost $frhandle $frchan $frarg};if {$frntrigger != ""} {bind pub $fraccess $frntrigger fr_pget;bind msg $fraccess $frntrigger fr_mget} ;if {$frgtrigger != ""} {bind pub $fraccess $frgtrigger fr_pget;bind msg $fraccess $frgtrigger fr_mget};if {$frstrigger != ""} {bind pub $fraccess $frstrigger fr_searchtmer ; bind msg $fraccess $frstrigger fr_msearch}
