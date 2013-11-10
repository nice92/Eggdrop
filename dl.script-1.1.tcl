# perplex dl.script v1.1 by dejavu
# 
#
# this script is for telling the bot to download files for you,
# that way your files can be downloaded directed to a shell account
# you have without logging in every time.
#
# commands:
#
# !getfile <url/file> [-limitbw x] [-path x] 		- Download a file.
#	-limitbw 	- Limit the bw of the download to x bytes.
#		You can add 'k' for kilobytes or 'm' for megabytes.
#	-path		- Save the file to subdirectory inside the base directory.
#		If you want to use spaces in path write in inside quetes (") or add \ before each space.
# !listfiles			- List downloads and queues.
# !stopfile <id>         	- Stop a download or remove a queue.
#		This is according to the list of downloads.
# !listbasedir		- List files downloaded to the base dir.
#		You have an option below to disable this command.
#
# config:

# set base dir to save files:
set dlsbase "/home/user/eggdrop/download"

# set where wget & kill resist in:
set dlswget "/usr/bin/wget"
set dlskill "/bin/kill"

# set temp directory to be used for log files:
# these log files are used by wget and we'll be deleted each time wget finish
# a download.
set dlstmp "/tmp"

# set the channels the script will work on: (seperate with space)
set dlschans "#chan"

# set max download simulations:
set dlsmaxdls "2"

# set max queues:
set dlsmaxqueues "5"

# Do you want to enable the !listbasedir command ? 1 yes 0 no
set dlselistbasedir 1

# set timer to check when wget finish its thing:
# timer will start running with atleast 1 download and will stop when there
# are no more downloads.
set dlschecktimer "5"

# config done.
# dont mess with anything below this line.
#
#########################################################

set dlsver "v1.1"

if {![file isdirectory $dlsbase]} {die "Check base directory setting!" ; return}
if {![file exists $dlswget]} {die "Check wget setting!" ; return}
if {![file exists $dlskill]} {die "Check kill setting!" ; return}

bind pub - !getfile dlsgetfile
bind pub - !listfiles dlslistfiles
bind pub - !stopfile dlsstopfile
if {$dlselistbasedir} {bind pub - !listbasedir dlslistbasedir}

proc dlslistbasedir {nick host hand chan arg {dir {}}} {
 global dlsbase dlselistbasedir
 if {!$dlselistbasedir} {return}
 set d [glob -nocomplain $dlsbase/$dir/*]
 if {$d == ""} {
  if {$dir == ""} {puthelp "PRIVMSG $chan :Base dir is empty."}
  return
 }
 set l [string length $dlsbase]
 foreach i $d {
  set i2 [string range $i $l end]
  if {[file isdirectory $i]} {dlslistbasedir $nick $host $hand $chan $arg $i2 ; continue}
  set s [file size $i]
  if {$s < 1048576} {set s [expr $s/1024]K} else {set s [expr $s/1024/1024]M}
  puthelp "PRIVMSG $chan :$i2 ($s)"
 }
}

proc dlschannel {chan} {
 global dlschans
 if {[lsearch [string tolower $dlschans] [string tolower $chan]] > -1} {return 1}
 return 0
}

proc dlsgetfile {nick host hand chan arg} {
    global dlsbase dlsdownloads dlsqueues dlsmaxdls dlsmaxqueues
    #Check channel
    if {![dlschannel $chan]} {return}
    #Check arguments, dont allow -limitbw and -path before download link.
    if {([lindex $arg 0] == "") || ([lindex $arg 0] == "-limitbw") || ([lindex $arg 0] == "-path")} {
	puthelp "PRIVMSG $chan :\002syntax\002: !getfile <url/file> \[-limitbw x\] \[-path x\]"
	return
    }
    if {([llength [array names dlsdownloads]] >= $dlsmaxdls) && ([llength [array names dlsqueues]] >= $dlsmaxqueues)} {
     puthelp "PRIVMSG $chan :Max download simulations and max queues reached!"
     return
    }
    set url [lindex $arg 0]
    set tmp_l [lsearch $arg -limitbw]
    if {$tmp_l > -1} {set limitbw [lindex $arg [expr $tmp_l+1]]} else {set limitbw ""}
    set tmp_p [lsearch $arg -path]
    if {$tmp_p > -1} {set dpath [lindex $arg [expr $tmp_p+1]]} else {set dpath ""}
    if {$limitbw != ""} {
#     set tmp_l "(limited to ${limitbw}bytes)"
     set limitbw "--limit-rate=$limitbw"
    } else {set tmp_l "(Not limiting bandwidth)"}
    if {$dpath != ""} {
     #Removing // /./ /../ and / from start and end of the dir.
     set dpath [string trim [string map {// / /./ / /../ /} /[string trim $dpath /]/] /]
#     set tmp_p "(Saving to $dpath)"
     set dpath [file join $dlsbase $dpath]
     set dpath "-P $dpath"
    } else {
#     set tmp_p "(Saving to base dir)"
     set dpath "-P $dlsbase"
    }
    set downloadinfo "$url $dpath $limitbw"
    if {[llength [array names dlsdownloads]] >= $dlsmaxdls} {
     puthelp "PRIVMSG $chan :Max download simulations reached. adding to queue."
     set i [dlsgetnewid]
     set dlsqueues($i) [list $chan $downloadinfo]
     return
    }
    eval "dlsdownloadthis $chan [list $downloadinfo]"
}

proc dlsgetnewid {} {
 global dlsdownloads dlsqueues
    set i [lindex [lsort -integer -increasing "[array names dlsdownloads] [array names dlsqueues]"] end]
#putlog last_id:$i
    if {$i == ""} {set i 0} else {incr i}
#putlog now_using:$i
    return $i
}

proc dlsdownloadthis {chan downloadinfo} {
    global dlswget dlsdownloads dlsqueues dlstmp dlstargetstatus dlsflags
    set url [lindex $downloadinfo 0]
#putlog downloadinfo:$downloadinfo
    set limitbw [lindex $downloadinfo 3]
    if {$limitbw != ""} {set limitbw " ($limitbw)"}
    set i [dlsgetnewid]
    set thepid [string trimright [lindex [eval "exec $dlswget -v --progress=dot -b -o $dlstmp/dls.$i.tmp $downloadinfo"] 4] .]
    set dlsdownloads($i) [list $chan $downloadinfo $thepid]
    set dlstargetstatus($i) "Unknown"
    set dlsflags($i) 0
    puthelp "PRIVMSG $chan :Downloading $url (id: $i)$limitbw"
    putlog "dl.script: Downloading $url (id: $i)$limitbw"
    if {![string match -nocase *dlschecker* [utimers]]} {
    global dlschecktimer ; utimer $dlschecktimer dlschecker}
}

proc dlslistfiles {nick host hand chan arg} {
 global dlsdownloads dlsqueues dlstargetstatus
 if {[array names dlsdownloads] == ""} {puthelp "PRIVMSG $chan :There are no downloads." ; return}
 foreach i [array names dlsdownloads] {
  puthelp "PRIVMSG $chan :#\00302\002$i\017 - [lindex [lindex $dlsdownloads($i) 1] 0] \00304(In progress) - $dlstargetstatus($i)"
 }
 foreach i [array names dlsqueues] {
  puthelp "PRIVMSG $chan :#\00302\002$i\017 - [lindex [lindex $dlsqueues($i) 1] 0] \00304(On queue)"
 }
}

proc dlsstopfile {nick host hand chan arg} {
 global dlsdownloads dlsqueues dlskill dlstargetstatus dlsflags
 if {$arg == ""} {puthelp "PRIVMSG $chan :Usage: !stopfile <id>" ; return}
 if {[info exists dlsdownloads($arg)]} {
  set thepid [lindex $dlsdownloads($arg) 2]
  catch {eval "exec $dlskill $thepid"}
  catch {unset dlstargetstatus($arg)}
  catch {unset dlsflags($arg)}
  set id $arg
  set tmp "Killed download $id ([lindex [lindex $dlsdownloads($arg) 1] 0])."
  puthelp "PRIVMSG $chan :$tmp"
  putlog "dl.script: $tmp"
  dlsnextdownload $id
  return
 }
 if {[info exists dlsqueues($arg)]} {
  set tmp "Removed queue [lindex $dlsqueues($arg) 0] ([lindex [lindex $dlsqueues($arg) 1] 0])."
  puthelp "PRIVMSG $chan :$tmp"
  putlog "dl.script: $tmp"
  unset dlsqueues($arg)
  return
 }
 puthelp "PRIVMSG $chan :No such download id."
}

proc dlschecker {} {
    global dlstmp dlsbase dlsdownloads dlstargetstatus
    foreach i [glob -nocomplain $dlstmp/dls.*.tmp] {
     set id [lindex [split $i .] 1]
     if {![file exists $i]} {dlsnextdownload $id; continue}
     set f [open $i r]
     if {$dlstargetstatus($id) == "Unknown"} {
      set d [read $f [file size $i]]
      set tmp [lsearch $d Length:]
      if {$tmp > -1} {
       set dlstargetstatus($id) [lindex $d [expr $tmp+1]]
      } else {set dlstargetstatus($id) "(Unknown)"}
     }
     seek $f [expr [file size $i]-100]
     set d [read $f 100]
     close $f
     set chan [lindex $dlsdownloads($id) 0]
#putlog debug:$d
     switch -glob -- [string tolower $d] {
      "* .......... */s*" {
       set tmp [lsearch $d *%]
       set tmp_percentage [lindex $d $tmp]
       set tmp_speed [list [lindex $d [expr $tmp+1]] [lindex $d [expr $tmp+2]]]
       set dlstargetstatus($id) "[lindex $dlstargetstatus($id) 0] $tmp_percentage $tmp_speed"
       dlspercentagenotice $id $tmp_percentage
      }
      "*saved*" {
       set url [lindex [lindex $dlsdownloads($id) 1] 0]
       set saved [string trimright [file tail [lindex $d [expr [lsearch $d saved]-1]]] ']
       puthelp "PRIVMSG $chan :Download $id ($url) finished. (File: $saved)"
       putlog "dl.script: Download $id ($url) finished."
       dlsnextdownload $id
      }
      "*404*not found*" {
       set url [lindex [lindex $dlsdownloads($id) 1] 0]
       set tmp "Requested download $id ($url) not found."
       puthelp "PRIVMSG $chan :$tmp"
       putlog "dl.script: $tmp"
       dlsnextdownload $id
      }
      "*failed:*host not found*" {
       set url [lindex [lindex $dlsdownloads($id) 1] 0]
       set tmp "Requested download $id ($url) not found."
       puthelp "PRIVMSG $chan :$tmp"
       putlog "dl.script: $tmp"
       dlsnextdownload $id
      }
      "*error*" {
       set url [lindex [lindex $dlsdownloads($id) 1] 0]
       set tmp "Requested download $id ($url) returned an error."
       puthelp "PRIVMSG $chan :$tmp"
       putlog "dl.script: $tmp"
       dlsnextdownload $id
      }
    #end switch
    }
#end foreach     
    }
#If there are still downloads make a new timer.
    if {[llength [array names dlsdownloads]] > 0} {
     if {![string match -nocase *dlschecker* [utimers]]} {
     global dlschecktimer ; utimer $dlschecktimer dlschecker}
    }
}

proc dlspercentagenotice {id percentage} {
 global dlsdownloads dlsflags
 set percentage [string trimright $percentage %]
 set url [lindex [lindex $dlsdownloads($id) 1] 0]
 set chan [lindex $dlsdownloads($id) 0]
 set a {puthelp "PRIVMSG $chan :Download $id ($url) is $percentage% complete."}
 if {$percentage >= 75 && $dlsflags($id) < 3} {
    incr dlsflags($id)
    eval [subst $a]
 } elseif {$percentage >= 50 && $dlsflags($id) < 2} {
    incr dlsflags($id)
    eval [subst $a]
 } elseif {$percentage >= 25 && $dlsflags($id) < 1} {
    incr dlsflags($id)
    eval [subst $a]
 }
}

proc dlsnextdownload {what_finished} {
 global dlsdownloads dlsqueues dlstmp
 set id $what_finished
 if {[file exists $dlstmp/dls.$id.tmp]} {file delete $dlstmp/dls.$id.tmp}
 catch {unset dlsdownloads($id)}
 set nextid [array names dlsqueues]
 if {$nextid != ""} {
  set nextid [lindex $nextid 0]
  set chan [lindex $dlsqueues($nextid) 0]
  set downloadinfo [lindex $dlsqueues($nextid) 1]
  dlsdownloadthis $chan $downloadinfo
  unset dlsqueues($nextid)
 }
}

putlog "PERPLEX dl.script $dlsver loaded."
