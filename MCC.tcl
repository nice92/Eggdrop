# ----------------------------------------------------------
# MCC v2.5 by dirty Inc.
#
# Public Command Script
#
# Contact
# irc.UnderNet.org @ #BotZone
# WwW.BotZone.Tk
#
# -= v1.0 =- 
# Standard eggdrop commands made public (no addons)
# -= v2.0 =-
# Rewrite of the code for faster reaction and less CPU usage
# -= v2.1 =-
# Added more configuration options, updates & addons
# -= v2.2 =-
# Added channel service login for:
# GnuWorld - X: UnderNet, ZoomNet.Org, SuprtechNet
# Q9 - Q: QuakeNet
# Added botnet support (bots request op/unban/invite from each other)
# -= v2.3 =-
# Fixed a couple of bugs and edited some small parts of code
# -= v2.3a =-
# Added 3 new commands ssh, dns, ipinfo when +ipinfo channel setting
# -= v2.4 =-
# Moved from MCC main script into separate tcl addons and standalone
#scripts:
# - +ipinfo with ssh, dns & ipinfo commands
# - Channel Service (X/Q) login system.
# -= v2.5 =-
# Fixed bugs discovered by users. Thank you everyone for your feedback.
#
# ----------------------------------------------------------

# -------------------------------------
# Global Variables ( SETTINGS )
# -------------------------------------

# Write here the special characters that the commands will work with.
# Ex: !op .op `op -op 
set mcc(trigger) "."

# Write here the name of your console channel (hidden from public)
set mcc(home) "#chan"

# Write here the name of your main channel (bot lending channel)
set mcc(home@bl) "#chan1 #chan2 #chan3 etc"

# Write here the mask of Hidden Host (/mode +x) if the network uses any.
# Pay attention at the *. before the host
set mcc(regusermask) "*.host"

# Do you want the eggdrop to allow anyone to register a user in the database?
# 1 - yes | 0 - no
set mcc(selfreguser) "0"

# Set here the global ban reasons for flooders.
# CHANEL Flooder:
set mcc(flood@chan) "Channel Flooder. Dégage !"
# CTCP Flooder:
set mcc(flood@ctcp) "CTCP Flooder. Dégage !"
# JOIN Flooder:
set mcc(flood@join) "Join/Part Flooder. Dégage !"
# DEOP Flooder:
set mcc(flood@deop) "Mass DeOp. Dégage !"
# KICK Flooder:
set mcc(flood@kick) "Mass Kick. Dégage !"
# NICK Flooder:
set mcc(flood@nick) "Trop de changement de pseudo. Dégage !"

# ## PLEASE DO NOT EDIT BELOW THIS ## #

set mcc(scriptversion) "v2.5"
set ctcp-version "eggdrop[lindex $version 0] :: MCC $mcc(scriptversion) (c) dirty Inc."
unbind msg - hello *msg:hello
unbind msg - ident *msg:ident
unbind msg - addhost *msg:addhost
unbind msg - help *msg:help
unbind msg - whois *msg:whois
unbind msg - who *msg:who
unbind msg - voice *msg:voice
unbind msg - info *msg:info
unbind msg - go *msg:go
unbind msg - halfop *msg:halfop
unbind msg - op *msg:op
unbind msg o|o key *msg:key
unbind msg o|o invite *msg:invite
unbind msg m|- save *msg:save
unbind msg m|- reset *msg:reset
unbind msg m|- rehash *msg:rehash
unbind msg m|- memory *msg:memory
unbind msg m|- jump *msg:jump
unbind msg m|m status *msg:status
unbind msg n|- die *msg:die


setudef flag debug
setudef str greet-text
setudef flag limit
setudef int limit-int

setudef flag autotopic
setudef flag locktopic
setudef str topic-text
setudef flag voicetalk

setudef flag anti-voiceidle
setudef flag anti-opidle
setudef flag anti-spam
setudef flag anti-notice
setudef flag anti-ctcp
setudef flag anti-color
setudef flag anti-bold
setudef flag anti-underline
setudef flag anti-caps
setudef flag anti-flyby
setudef flag anti-badword
setudef flag anti-badwhois
setudef flag anti-badpart
setudef flag anti-badchan
setudef str badword-text
setudef str badchan-text

channel add $mcc(home) {
	+static +debug
	limit-int 5
}

# -------------------------------------
# Other Processes
# -------------------------------------

# Detecting TELNET port
foreach portlist [dcclist TELNET] {
	if {([lindex $portlist 1] == "(all)") || ([lindex $portlist 1] == "(users)") || ([lindex $portlist 1] == "(telnet)")} {
		set mcc(telnetport) [lindex [lindex $portlist 4] 1]; break
	}
}

# Server side limits
bind raw - 005 mcc:server:limits
proc mcc:server:limits {from idx args} {
	global max-modes max-bans nick-len network mcc
  
	set args [lrange [lindex $args 0] 1 end]
	foreach option $args {
		regsub -all "=" $option " " option
  
		switch [lindex $option 0] {	
			MAXCHANNELS { set mcc(srv@maxchan) "11" }
				  MODES { set max-modes [lindex $option 1] }
				MAXBANS { set max-bans [lindex $option 1] }
				SILENCE { set mcc(srv@silence) [lindex $option 1] }
			   TOPICLEN { set mcc(srv@topiclen) [lindex $option 1] }
				KICKLEN { set mcc(srv@kicklen) [lindex $option 1] }
				AWAYLEN { set mcc(srv@awaylen) [lindex $option 1] }	
			 CHANNELLEN { set mcc(srv@chanlen) [lindex $option 1] }
			  CHANTYPES { set mcc(srv@chantypes) [lindex $option 1] }
			  CHANMODES { set mcc(srv@chanmodes) [lindex $option 1] }
			    NETWORK { set network [lindex $option 1] }
		}
	}
}

# Checks related to server side limits
proc mcc:check:server_limits {type text} {
	global mcc
	
	if {$type == "topic"} {
		if {![info exists mcc(srv@topiclen)]} { return 1 }
		if {[string length $text] > $mcc(srv@topiclen)} { return 0 }
	return 1 }
	
	if {$type == "kick"} {
		if {![info exists mcc(srv@kicklen)]} { return 1 }
		if {[string length $text] > $mcc(srv@kicklen)} { return 0 }
	return 1 }
	
	if {$type == "away"} {
		if {![info exists mcc(srv@awaylen)]} { return 1 }
		if {[string length $text] > $mcc(srv@awaylen)} { return 0 }
	return 1 }
	
	if {$type == "chanlen"} {
		if {![info exists mcc(srv@chanlen)]} { return 1 }
		if {[string length $text] > $mcc(srv@chanlen)} { return 0 }
	return 1 }
	
	if {$type == "chantype"} {
		if {![info exists mcc(srv@chantypes)]} { return 1 }
		if {![string match *[lindex [split $text {}] 0]* $mcc(srv@chantypes)]} { return 0 }
	return 1 }
	
	if {$type == "channels"} {
		if {[llength [channels]] >= $mcc(srv@maxchan)} { return 0 }
	return 1 }
	
	if {$type == "modes"} {
		if {![info exists mcc(srv@chanmodes)]} { return 1 }
		set chanmodes "+ - k l [split [lindex [split $mcc(srv@chanmodes) ,] end] {}]"
		foreach cmode [split $text {}] {
			if {[lsearch -exact $chanmodes $cmode] == "-1"} { return 0 }
		}
	return 1 }
return 0 }

# Send debug messages to all +debug channels.
proc mcc:msg:debug {message} {
	
	foreach chan [channels] {
		if {![channel get $chan debug]} { continue }
		putnotc $chan "$message"
	}
}

# Split lines bigger then 350 chars (thanks thommey)
proc mcc:check:splitline {string {maxlength 350}} {
	while {[string length $string] > $maxlength} {
		# Where would a hard cut be?
		set hardcut $maxlength
		# search backwards for " "
		for {set cut $hardcut} {$cut >= 0 && [string index $string $cut] != " "} {incr cut -1} { }
		# if not found, use hard cut (long word)
		if {$cut < 0} { set cut $hardcut }
		lappend result [string range $string 0 [expr {$cut-1}]]
		# if it was a soft cut, skip the " "
		if {[string index $string $cut] == " "} { incr cut }
		set string [string range $string $cut end]
	}
	# rest bit
	if {[string length $string]} {
		lappend result $string
	}
	return $result
}

# Channel Greet Parser
proc mcc:check:greet {nick host handle channel text} {
	global botnick server

	set text [string map [list %nickname $nick] $text]
	set text [string map [list %hostname $host] $text]
	set text [string map [list %channel $channel] $text]
	set text [string map [list %access [mcc:check:level $handle $channel]] $text]
	set text [string map [list %handle $handle] $text]
	set text [string map [list %botnick $botnick] $text]
return $text }

# Detect the flags/level of a user
proc mcc:check:level {handle channel} {
		
        if {![validuser $handle]} { return "Unknown" }
        if {[matchattr $handle W]} { return "Network Service" }
        if {[matchattr $handle n]} { return "Global Owner" }
        if {[matchattr $handle m]} { return "Global Master" }
        if {[matchattr $handle o]} { return "Global Op" }
        if {[matchattr $handle &n $channel]} { return "Channel Owner" }
        if {[matchattr $handle &m $channel]} { return "Channel Master" }
        if {[matchattr $handle &o $channel]} { return "Channel Op" }
        if {[matchattr $handle &v $channel]} { return "Channel Voice" }
		
return "No Access" }

# Level difference protection
proc mcc:check:leveldiff {hand1 hand2 channel} {
	global owner
	
	set hand1 [string tolower $hand1]
	set hand2 [string tolower $hand2]
	
	if {$channel == ""} {
		if {$hand1 == $hand2} { return 1 }
		if {$hand1 == [string tolower $owner]} { return 0 }
		if {[matchattr $hand1 n] && $hand2 != [string tolower $owner]} { return 0 }
		if {[matchattr $hand1 W] && ![matchattr $hand2 n]} { return 0 }
		if {[matchattr $hand1 b] && ![matchattr $hand2 m]} { return 0 }
		if {[matchattr $hand1 m] && ![matchattr $hand2 n]} { return 0 }
		if {[matchattr $hand1 o] && ![matchattr $hand2 m]} { return 0 }
		if {![matchattr $hand2 o]} { return 0 }
	return 1 } elseif {[validchan $channel]} {
		if {$hand1 == $hand2} { return 1 }
		if {[matchattr $hand1 &n $channel] && ![matchattr $hand2 o]} { return 0 }
		if {[matchattr $hand1 &m $channel] && (![matchattr $hand2 &n $channel] && ![matchattr $hand2 o])} { return 0 }
		if {[matchattr $hand1 &o $channel] && (![matchattr $hand2 &m $channel] && ![matchattr $hand2 o])} { return 0 }
		if {[matchattr $hand1 &v $channel] && (![matchattr $hand2 &o $channel] && ![matchattr $hand2 o])} { return 0 }
		if {![haschanrec $hand2 $channel] && ![matchattr $hand2 o]} { return 0 }
	return 1 }
	mcc:msg:debug "\[\002MCC:CHECK:LEVELDIFF\002\] Error! $hand1 - $hand2 for $channel"
return 0 }

# Verify if logged in
proc mcc:check:logged {nick handle uhost} {
	global botnick
	
	if {![matchattr $handle Q]} { 
		if {[getuser $handle XTRA PERMIDENT] == "1"} { return 1 }
		puthelp "NOTICE $nick :You are not logged in. ( /msg $botnick login )"
		return 0
	}
	return 1
}

# Verify if user has no password
bind cron - "*/30 * * * *" mcc:check:nopass
proc mcc:check:nopass {a b c d e} {
	global mcc
	
	set count "0"
	set list ""
	foreach user [userlist] {
		if {[passwdok $user ""] && ![matchattr $user b]} {
			if {[unixtime] > [getuser $user XTRA NOPASSDEL]} {
				deluser $user
				lappend list $user
				incr count
			}
		}
	}
	if {$count != "0"} {
		mcc:msg:debug "\[\002CleanDB\002\] Automatically deleted $count users: $list"
	}
}

# Verify user idle time
bind cron - "*/5 * * * *" mcc:check:idleuser
proc mcc:check:idleuser {a b c d e} {

	foreach chan [channels] {
		if {[channel get $chan inactive] || ![botisop $chan]} { continue }
		if {[channel get $chan anti-voiceidle] || [channel get $chan anti-opidle] || [channel get $chan voicetalk]} {
			foreach user [chanlist $chan] {
				if {[isbotnick $user]} { continue }
				if {[getchanidle $user $chan] < 20} { continue }
				
				if {[channel get $chan anti-voiceidle] || [channel get $chan voicetalk]} {
					if {[isvoice $user $chan]} {
						pushmode $chan -v $user
					}
				}
				
				if {[channel get $chan anti-opidle]} {
					if {[isop $user $chan]} {
						pushmode $chan -o $user
					}
				}
			}
		}
	}
}

# Protect channel topic
bind topc - * mcc:check:topic
proc mcc:check:topic {nick uhost handle channel text} {
	
	if {[channel get $channel locktopic] && ![isbotnick $nick]} {
		putserv "TOPIC $channel :[join [lrange [split [channel get $channel topic-text]] 1 end]]"
		putserv "NOTICE $nick :Channel topic locked by [lindex [join [channel get $channel topic-text]] 0]"
		return
	}
	if {$text != ""} {
		channel set $channel topic-text "$nick [join [lrange [split $text] 0 end]]"
	}
}

# Set channel limit
proc mcc:check:limit {channel} {
	
	set users [llength [chanlist $channel]]
	set limit [channel get $channel limit-int]
	pushmode $channel +l [expr {$users + $limit}]
}

# Check if caps
proc mcc:check:isupper {letter} {
	set caps {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
	if {[lsearch -exact $caps $letter] > -1} {  
	return 1 } { 
	return 0 }
}

# Check for +anti-* protection 
proc mcc:check:cs_anti {nick uhost handle channel type text} {
	global mcc_anti botnick
	
	if {[isbotnick $nick] || ![validchan $channel]} { return }
	
	if {![matchattr $handle bfo|fo $channel]} {
		set text [join [lrange [split $text] 0 end]]
		set banreason "You broke the channel rules. See PRV for more information."
		set msgreason ""
		if {[lsearch -exact "pub ctcp notc" $type] > "-1"} {
			if {[channel get $channel anti-spam]} {
				set spam ""
				if {[lsearch -all -inline -glob -nocase $text "*http*://*"] != ""} {
					lappend spam [join [lsearch -all -inline -glob -nocase $text "*http*://*"]]
				}
				if {[lsearch -all -inline -glob -nocase $text "*www.*"] != ""} {
					lappend spam [join [lsearch -all -inline -glob -nocase $text "*www.*"]]
				}
				if {[lsearch -all -inline -glob -nocase $text "*#??*"] != ""} {
					lappend spam [join [lsearch -all -inline -glob -nocase $text "*#??*"]]
				}
				if {$spam != ""} {
					lappend msgreason "Spamming is not allowed in $channel : [join $spam ", "]"
				}
			}
			if {[channel get $channel anti-notice] && $type == "notc"} {
				lappend msgreason "Channel noticing is not allowed in $channel"
			}
			if {[channel get $channel anti-ctcp] && $type == "ctcp"} {
				lappend msgreason "Channel ctcping is not allowed in $channel"
			}
			if {[channel get $channel anti-color] && [string match *\x03* $text]} {
				lappend msgreason "Using color is not allowed in $channel"
			}
			if {[channel get $channel anti-bold] && [string match *\002* $text]} {
				lappend msgreason "Using bold is not allowed in $channel"
			}
			if {[channel get $channel anti-underline] && [string match *\037* $text]} {
				lappend msgreason "Using underline is not allowed in $channel"
			}
			if {[channel get $channel anti-caps]} {
				set len [string length $text]
				set cnt 0
				set capcnt 0
				while {$cnt < $len} {
						if {[mcc:check:isupper [string index $text $cnt]]} { 
							incr capcnt 
						}
						incr cnt 
				}
				if {$capcnt > 15 && 100*$capcnt/$len > 60} {
					lappend msgreason "Using CAPS is not allowed in $channel"
				}
			}
			if {[channel get $channel anti-badword]} {
				set bword ""
				foreach word [channel get $channel badword-text] {
					set wrd [lsearch -all -inline -glob -nocase $text $word]
					if {$wrd != ""} {
						lappend bword $wrd
					}
				}
				if {$bword != ""} {
					lappend msgreason "Swearing is not allowed in $channel : [join $bword ", "]"
				}
			}
		}
		if {$type == "whois"} {
			if {[channel get $channel anti-badwhois]} {
				set wnick ""
				set wident ""
				foreach word [channel get $channel badword-text] {
					if {[string match $word $nick]} {
						lappend msgreason "Please change your nickname before entering $channel again."
						break
					}
					if {[string match $word [lindex [split $uhost @] 0]]} {
						lappend msgreason "Please change your identd before entering $channel again."
						break
					}
				}
				if {$wnick != ""} {
					lappend msgreason "Please change your nickname before entering $channel again."
				}
				if {$wident != ""} {
					lappend msgreason "Please change your identd before entering $channel again."
				}
			}
			if {[channel get $channel anti-badchan]} {
				set clist ""
				foreach chn [channel get $channel badchan-text] {
					set who [join [lsearch -all -inline -glob -nocase $text $chn]]
					if {$who != ""} {
						lappend clist $who
					}
				}
				if {$clist != ""} {
					lappend msgreason "Leave channels [join $clist ", "] before joining $channel"
				}
			}
		}
		if {$type == "leave"} {
			if {[channel get $channel anti-badpart]} {
				set bword ""
				foreach word [channel get $channel badword-text] {
					set wrd [lsearch -all -inline -glob -nocase $text $word]
					if {$wrd != ""} {
						lappend bword $wrd
					}
				}
				if {$bword != ""} {
					lappend msgreason "Never part $channel saying: [join $bword ", "]"
				}
			}
			if {[channel get $channel anti-flyby]} {
				if {[info exists mcc_anti(flyby@$nick)]} {
					lappend msgreason "Banned for fast join/part on $channel"
				}
			}
		}
		if {$type == "quit"} {
			if {[channel get $channel anti-badpart]} {
				foreach word [channel get $channel badword-text] {
					if {[lsearch -all -inline -glob -nocase $text $word] > "-1"} {
						newchanban $channel [maskhost "$nick!$uhost" [channel get $channel ban-type]] $botnick $banreason [channel get $channel ban-time]
						return 1
					}
				}
			}
		}
		if {$msgreason != ""} { 
			newchanban $channel [maskhost "$nick!$uhost" [channel get $channel ban-type]] $botnick $banreason [channel get $channel ban-time]
			foreach msg $msgreason {
				putserv "PRIVMSG $nick :$msg"
			}
			return 1
		}
	}
	if {[channel get $channel voicetalk] && ![isop $nick $channel] && ![isvoice $nick $channel] && [botisop $channel]} {
		pushmode $channel +v $nick
	}
}

# MaskHost Proc
proc mcc:proc:maskhost {uhost} {
	global mcc
	
	if {[string match -nocase $mcc(regusermask) $uhost]} { 
		return "*!*@[lindex [split $uhost @] 1]" 
	}
	return "*!$uhost"
}

# New BotNick Proc
proc mcc:proc:newnick {newnick} {
	global nick
	
	set nick $newnick
}

# Server Quit Proc
bind sign - * mcc:proc:quit
proc mcc:proc:quit {nick uhost handle channel text} {
	
	mcc:check:cs_anti $nick $uhost $handle $channel "quit" $text
	if {[validuser $handle]} { 
		chattr $handle -Q
	}
}

# Channel Joins Proc
bind join - * mcc:proc:join
proc mcc:proc:join {nick uhost handle channel} {
	global mcc mcc_anti
	
	if {[isbotnick $nick]} { return }
	
	if {[channel get $channel anti-flyby]} {
		set mcc_anti(flyby@$nick) $channel
		utimer 10 [list unset -nocomplain mcc_anti(flyby@$nick)]
	}
	if {[channel get $channel autotopic] && [channel get $channel topic-text] != "" && [topic $channel] == ""} {
		putserv "TOPIC $channel :[join [lrange [split [channel get $channel topic-text]] 1 end]]"
	}
	if {[channel get $channel anti-badchan]} {
		putserv "WHOIS $nick"
		set mcc(whois@$nick) $channel
	}
	if {[channel get $channel greet] && [channel get $channel greet-text] != "" && ![matchattr $handle b]} {
		foreach line [channel get $channel greet-text] {
			putserv "NOTICE $nick :[mcc:check:greet $nick $uhost $handle $channel $line]"
		}
	}
	if {[channel get $channel limit]} { mcc:check:limit $channel }
	if {[channel get $channel autovoice]} { pushmode $channel +v $nick }
}

# Channel Part Proc
bind part - * mcc:proc:part
proc mcc:proc:part {nick uhost handle channel text} {
	
	if {[isbotnick $nick]} { return }
	
	if {[channel get $channel limit]} { mcc:check:limit $channel }
	mcc:check:cs_anti $nick $uhost $handle $channel "leave" $text
}

# Channel Modes Proc
bind mode - * mcc:proc:mode
proc mcc:proc:mode {nick uhost handle channel mode target} {
	global mcc botname
	
	switch -- $mode {
		"+s" - "+p" {
			channel set $channel +secret
		}
		"-s" - "-p" {
			channel set $channel -secret
		}
	}
}

# Nick Change Proc
bind nick - * mcc:proc:nick
proc mcc:proc:nick {nick uhost handle channel newnick} {
	
	mcc:check:cs_anti $newnick $uhost $handle $channel "whois" ""
}

# PUBM Proc
bind pubm - * mcc:proc:pubm
proc mcc:proc:pubm {nick uhost handle channel text} {

	mcc:check:cs_anti $nick $uhost $handle $channel "pub" $text
}

# CTCP Proc
bind ctcp - * mcc:proc:ctcp
proc mcc:proc:ctcp {nick uhost handle dest keyword text} {
	
	if {$keyword != "ACTION"} {
		mcc:check:cs_anti $nick $uhost $handle $dest "ctcp" $text
	}
}

# NOTC Proc
bind notc - * mcc:proc:notc
proc mcc:proc:notc {nick uhost handle text dest} {
	
	mcc:check:cs_anti $nick $uhost $handle $dest "notc" $text
}

# BotNet Proc
bind link - * mcc:proc:link
proc mcc:proc:link {bot via} {
	
	mcc:msg:debug "\[\002BOTNET\002\] Linked to $bot via $via."
}
bind disc - * mcc:proc:unlink
proc mcc:proc:unlink {bot} {
	
	mcc:msg:debug "\[\002BOTNET\002\] Unlinked from $bot."
}

# RAW Proc
bind raw - 319 mcc:proc:raw:whois 
proc mcc:proc:raw:whois {from key chans} {
	global mcc
	
	set nick [lindex [join $chans] 1]
	set chans [join [lrange [split $chans] 2 end]]
	set text ""
	if {[info exists mcc(whois@$nick)]} {
		foreach chan $chans {
			lappend text [string trimleft $chan ":@+"]
		}
		mcc:check:cs_anti $nick [getchanhost $nick $mcc(whois@$nick)] [nick2hand $nick] $mcc(whois@$nick) "whois" $text
		unset -nocomplain mcc(whois@$nick)
	}
}

# Custom Flood Handler Proc
bind flud - * mcc:proc:flood_handler
proc mcc:proc:flood_handler {nick uhost handle type channel} {
	global botnick mcc
	
	if {[matchattr $handle bfo|f $channel]} { return 1 }
	
	switch $type {
		"msg" {
			newignore "*!*@[lindex [split $uhost @] 1]" $botnick "MSG FLOOD" 60
			mcc:msg:debug "\[\002FLOOD\002\] $nick!$uhost ignored. (MSG FLOOD)"
			return 1
		}
		"pub" {
			newchanban $channel [maskhost "$nick!$uhost" [channel get $channel ban-type]] $botnick $mcc(flood@chan) [channel get $channel ban-time]
			return 1
		}
		"ctcp" {
			newignore "*!*@[lindex [split $uhost @] 1]" $botnick "CTCP FLOOD" 60
			foreach chan [channels] {
				newchanban $chan [maskhost "$nick!$uhost" [channel get $chan ban-type]] $botnick $mcc(flood@ctcp) [channel get $chan ban-time]
			}
			mcc:msg:debug "\[\002FLOOD\002\] $nick!$uhost ignored and banned. (CTCP FLOOD)"
			return 1
		}
		"join" {
			newchanban $channel [maskhost "$nick!$uhost" [channel get $channel ban-type]] $botnick $mcc(flood@join) [channel get $channel ban-time]
			if {[botisop $channel]} {
				putserv "NOTICE $channel :Join flood detected setting channel to +i"
				putnow "MODE $channel +i"
				timer 2 [list pushmode $channel -i]
			}
			return 1
		}
		"deop" {
			newchanban $channel [maskhost "$nick!$uhost" [channel get $channel ban-type]] $botnick $mcc(flood@deop) [channel get $channel ban-time]
			return 1
		}
		"kick" {
			newchanban $channel [maskhost "$nick!$uhost" [channel get $channel ban-type]] $botnick $mcc(flood@kick) [channel get $channel ban-time]
			return 1
		}
		"nick" {
			newchanban $channel [maskhost "$nick!$uhost" [channel get $channel ban-type]] $botnick $mcc(flood@nick) [channel get $channel ban-time]
			return 1
		}
	}
}

# Custom Need Handler Proc
bind need - * mcc:proc:need
proc mcc:proc:need {channel type} {
	global mcc botnick network
	
	switch -- $type {
		"op" {
			putallbots "MCC-BOTNET $network op $channel"
			return
		}
		"unban" {
			putallbots "MCC-BOTNET $network unban $channel"
			return
		}
		"invite" {
			putallbots "MCC-BOTNET $network invite $channel"
			return
		}
		"limit" {
			mcc:proc:need $channel "invite"
		}
		"key" {
			mcc:proc:need $channel "invite"
		}
	}
}

# BOTNET Need Respond Porc
bind bot - MCC-BOTNET mcc:proc:need_botnet
proc mcc:proc:need_botnet {bot key text} {
	global network
	
	set net [lindex [split $text] 0]
	if {[string tolower $network] != [string tolower $net]} { return }
	set req [lindex [split $text] 1]
	set chn [lindex [split $text] 2]
	if {![validchan $chn]} { return }
	if {![botisop $chn]} { return }
	
	switch -- $req {
		"op" {
			pushmode $chn +o [hand2nick $bot]
			return
		}
		"unban" {
			set bhost "[hand2nick $bot]![getchanhost [hand2nick $bot]]"
			foreach ban [chanbans $chn] {
				set host [lindex $ban 0]
				if {[string match -nocase $host $bhost]} {
					pushmode $chn -b $host
				}
			}
			foreach ban [banlist $chn] {
				set host [lindex $ban 0]
				if {[string match -nocase $host $bhost]} {
					killchanban $chn $host
					return
				}
			}
			foreach ban [banlist] {
				set host [lindex $ban 0]
				if {[string match -nocase $host $bhost]} {
					killban $host
					return
				}
			}
			return
		}
		"invite" {
			mcc:proc:need_botnet $bot $key "$net unban $chn"
			putserv "INVITE [hand2nick $bot] $chn"
			return
		}
	}
}

# -------------------------------------
# User Registration
# -------------------------------------
bind msg - hello mcc:cmd:msg_hello
bind msg - reguser mcc:cmd:msg_hello
proc mcc:cmd:msg_hello {nick uhost handle text} {
	global mcc botnick lastbind handlen network
	
	if {$mcc(selfreguser) != "1" && [userlist] != ""} { return }
	if {[validuser $handle]} { 
		puthelp "NOTICE $nick :You can not register a new user. You are recognized as \002$handle\002."
		puthelp "NOTICE $nick :If this is not you join $mcc(home@bl) and contact a staff member. Thank You."
		return
	}
	
	set username [lindex [join $text] 0]
	set password [lindex [join $text] 1]
	
	if {$username == "" || $password == ""} {
		puthelp "NOTICE $nick :Error. Usage: /msg $botnick $lastbind <username> <password>"
		return
	}
	set usernamepb [regsub -all -nocase {[a-z0-9]} $username ""]
	if {[string length $username] < 2 || [string length $username] > $handlen || $usernamepb != ""} {
		puthelp "NOTICE $nick :Error. Username must be \002BETWEEN\002 2 and $handlen characters long and can contain \002ONLY\002 letters and numbers."
		return
	}
	if {[validuser $username]} {
		puthelp "NOTICE $nick :Error. Username is unavailable. Please choose another one."
		return
	}
	if {[string length $password] < 6} {
		puthelp "NOTICE $nick :Error. Password must be \002AT LEAST\002 6 characters long for security reasons."
		return
	}
	
	set hostname [mcc:proc:maskhost $uhost]
	
	if {[adduser $username $hostname]} {
		setuser $username PASS $password
		puthelp "NOTICE $nick :You have been registered as \002$username\002 with password \002$password\002."
		puthelp "NOTICE $nick :Before anything else login using \002/msg $botnick login\002"
		puthelp "NOTICE $nick :You can change your password at any time using \002/msg $botnick newpass\002"
		mcc:msg:debug "\[\002REGUSER\002\] $nick registered as $username ($hostname)"
	} else {
		puthelp "NOTICE $nick :Registration error! Please join $mcc(home@bl) and contact a staff member. Thank You."
		mcc:msg:debug "\[\002REGUSER\002\] Error. $nick ($uhost) tried to register $username with $password"
	}
	if {[userlist] == $username} {
		chattr $username +hjlmnoptvx
		puthelp "NOTICE $nick :***POOF*** You are now the owner of this bot!"
	}
}

# -------------------------------------
# New Password
# -------------------------------------
bind msg - newpass mcc:cmd:msg_newpass
proc mcc:cmd:msg_newpass {nick uhost handle text} {
	global botnick

	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	set password [lindex [join $text] 0]
	set newpassword [lindex [join $text] 1]
	
	if {$password == "" || $newpassword == ""} {
		puthelp "NOTICE $nick :Error. Usage: /msg $botnick newpass <old password> <new password>"
		return
	}
	if {![passwdok $handle $password]} {
		puthelp "NOTICE $nick :Error. Old password dose not match database."
		return
	}
	if {[string length $newpassword] < 6} {
		puthelp "NOTICE $nick :Error. Password must be \002AT LEAST\002 6 characters long for security reasons."
		return
	}
	setuser $handle PASS $newpassword
	puthelp "NOTICE $nick :Password set to: \002$newpassword\002"
	mcc:msg:debug "\[\002NEWPASS\002\] $nick/\002$handle\002 succesfully changed his password."
}

# -------------------------------------
# Log In
# -------------------------------------
bind msg - auth mcc:cmd:msg_login
bind msg - login mcc:cmd:msg_login
proc mcc:cmd:msg_login {nick uhost handle text} {
	global botnick mcc
	
	if {[validuser $handle] && [matchattr $handle Q]} {
		puthelp "NOTICE $nick :You are already logged in as \002$handle\002."
		puthelp "NOTICE $nick :If this is not you join $mcc(home@bl) and contact a staff member. Thank You."
		return
	}
	
	set username [lindex [join $text] 0]
	set password [lindex [join $text] 1]
	
	if {$username == "" || $password == ""} {
		puthelp "NOTICE $nick :Error. Usage: /msg $botnick login <username> <password>"
		return
	}
	if {![validuser $username]} {
		puthelp "NOTICE $nick :Error. Unknown username \002$username\002."
		return
	}
	if {![passwdok $username $password]} {
		puthelp "NOTICE $nick :Error. Wrong password."
		return
	}
	
	set hostname [mcc:proc:maskhost $uhost]
	
	setuser $username HOSTS $hostname
	chattr $username +Q
	puthelp "NOTICE $nick :Authentication successful!"
	puthelp "NOTICE $nick :Do not give out your password to anyone and remember that no administrator of this bot will ever ask you for it."
	mcc:msg:debug "\[\002LOGIN\002\] Authentication successful $nick/\002$username\002!"
}

# -------------------------------------
# Main Script Command List
# -------------------------------------

# Catch BotNick and send the command to the correct bind
bind pubm - "% *" mcc:cmd:botnick_reroute
proc mcc:cmd:botnick_reroute {nick uhost handle channel text} {
	global mcc
	
	set sh [string tolower [lindex [split $text] 0]]
	
	if {![isbotnick $sh]} { return }
	
	set cmd [string tolower [lindex [split $text] 1]]
	set rest [join [lrange [split $text] 2 end]]
	
	if {[catch {mcc:cmd:$cmd $nick $uhost $handle $channel $rest}]} { return }
}

# Catch all msgs and send the command to the correct bind
bind msgm - * mcc:cmd:msg_reroute
proc mcc:cmd:msg_reroute {nick uhost handle text} {
	global mcc lastbind botnick
	
	set cmd [string tolower [lindex [split $text] 0]]
	set chan [string tolower [lindex [split $text] 1]]
	
	set exepts "pass login auth newpass hello reguser notes"
	if {[lsearch -exact $exepts $cmd] != "-1"} { return }
	
	if {$chan == ""} {
		puthelp "PRIVMSG $nick :Error. Usage: /msg $botnick [lindex [split $text] 0] <#channel> \[options\]"
		return
	}
	if {![validchan $chan]} {
		puthelp "PRIVMSG $nick :Error. I`m not monitoring channel: $chan"
		return
	}
	
	set rest [join [lrange [split $text] 2 end]]
	
	if {[catch {mcc:cmd:$cmd $nick $uhost $handle $chan $rest}]} { return }
}

#
# Commands Level: NONE (-)
#

# HELP Command
bind pub -|- $mcc(trigger)help mcc:cmd:help
proc mcc:cmd:help {nick uhost handle channel text} {
	global mcc
	
	putserv "NOTICE $nick :Go to http://BotZone.Tk for more help or use $mcc(trigger)commands"
}

# COMMANDS Command
bind pub -|- $mcc(trigger)commands mcc:cmd:commands
proc mcc:cmd:commands {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	putserv "NOTICE $nick :No Access    (-|-): help commands dbcount uptime version date channels whois set ssh dns ipinfo"
	putserv "NOTICE $nick :ChanVoice    (-|v): voice devoice users del"
	putserv "NOTICE $nick :ChanOp       (-|o): op deop invite chaninfo topic kick ban unban banlist mode add"
	putserv "NOTICE $nick :ChanMaster   (-|m): chanset cycle"
	putserv "NOTICE $nick :ChanOwner    (-|n): say act join part greet"
	putserv "NOTICE $nick :GlobalOp     (o|-): ignore unignore ignorelist host broadcast"
	putserv "NOTICE $nick :GlobalMaster (m|-): msg"
	putserv "NOTICE $nick :GlobalOwner  (n|-): rehash save restart jump"
	putserv "NOTICE $nick :BotOwner       (n): nick botnet die"
}

# DBCOUNT Command
bind pub -|- $mcc(trigger)dbcount mcc:cmd:dbcount
proc mcc:cmd:dbcount {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	putserv "NOTICE $nick :Monitoring a total of [countusers] users in my database. \( [llength [userlist o]] Global Users \)"
}

# UPTIME Command
bind pub -|- $mcc(trigger)uptime mcc:cmd:uptime
proc mcc:cmd:uptime {nick uhost handle channel text} {
	global uptime server-online
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	putserv "NOTICE $nick :Started [lrange [duration [expr [unixtime] - $uptime]] 0 3] ago and OnLine for [lrange [duration [expr [unixtime] - ${server-online}]] 0 3]"
}

# VERSION Command
bind pub -|- $mcc(trigger)version mcc:cmd:version
proc mcc:cmd:version {nick uhost handle channel text} {
	global version mcc
	
	putserv "NOTICE $nick :eggdrop[lindex $version 0] :: MCC $mcc(scriptversion) (c) dirty Inc."
}

# DATE Command
bind pub -|- $mcc(trigger)date mcc:cmd:date
proc mcc:cmd:date {nick uhost handle channel text} {
	
	putserv "NOTICE $nick :Today is [strftime "%d %b %Y" [unixtime]] and the time is [strftime "%H:%M" [unixtime]]"
}

# CHAT Command
bind pub -|- $mcc(trigger)chat mcc:cmd:chat
proc mcc:cmd:chat {nick uhost handle channel text} {
	global mcc nat-ip my-ip
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	if {![matchattr $handle p]} {
		putserv "NOTICE $nick :I don`t wanna chat with you."
		return
	}
	if {[hand2idx $handle] != "-1" } {
		putserv "NOTICE $nick :You are already in the partyline."
		return
	}
	if {$mcc(telnetport) < "1024"} {
		putserv "NOTICE $nick :Sorry, your host isn't reachable at this time."
		return
	}
	if {${nat-ip} == ""} {
		set ip ${my-ip}
	} else {
		set ip ${nat-ip}
	}
	if {$ip == ""} {
		set ip [format %u [eval format 0x%02x%02x%02x%02x [split "127.0.0.1" .]]]
	} else {
		set ip [format %u [eval format 0x%02x%02x%02x%02x [split $ip .]]]
	}
	putserv "PRIVMSG $nick :\001DCC CHAT chat $ip $mcc(telnetport)\001"
	putserv "NOTICE $nick :DCC Chat - Initializing.."
}

# CHANNELS Command
bind pub -|- $mcc(trigger)channels mcc:cmd:channels
proc mcc:cmd:channels {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	set chanlist "Monitoring [llength [channels]] channels: "
	foreach chn [channels] {
		if {![matchattr $handle o] && [channel get $chn secret]} { continue }
		set chanstatus ""
		if {[channel get $chn inactive]} {
			append chanstatus "i"
		}
		if {[channel get $chn secret]} {
			append chanstatus "s"
		}
		if {![botisop $chn]} {
			append chanstatus "\0034@\003"
		}
		if {$chanstatus != ""} {
			append chanlist "\[$chanstatus\]"
		}
		if {![botonchan $chn] && ![channel get $chn inactive]} {
			append chanlist "\002\0034$chn\003\002 "
		} else {
			append chanlist "$chn "
		}
	}
	putserv "NOTICE $nick :$chanlist"
}

# WHOIS Command
bind pub -|- $mcc(trigger)whois mcc:cmd:whois
proc mcc:cmd:whois {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	set who [lindex [join $text] 0]
	
	if {$who == ""} {
		set who $handle
	}
	if {[onchan $who $channel]} {
		set who [nick2hand $who]
	}
	if {![validuser $who]} {
		putserv "NOTICE $nick :Unknow user in the database."
		return
	}
	set automode "None"
	if {[matchattr $who &g $channel]} {
		set automode "Voice"
	}
	if {[matchattr $who &a $channel]} {
		set automode "Op"
	}
	if {[getuser $who XTRA PERMIDENT] == "1"} {
		set permident "On"
	} else {
		set permident "Off"
	}
	putserv "NOTICE $nick :\002Handle\002: $who \002Access\002: [mcc:check:level $who $channel] ([chattr $who $channel])"
	putserv "NOTICE $nick :\002PermIdent\002: $permident \002AutoMode\002: $automode"
	if {[matchattr $handle o]} {
		set laston [getuser $who LASTON]
		if {$laston == ""} {
			set laston "No Records"
		} else {
			set laston "[strftime "%d %b %Y %H:%M" [lindex [split $laston] 0]] [lindex [split $laston] 1]"
		}
		putserv "NOTICE $nick :\002Last Seen\002: $laston \002Hosts\002: [getuser $who HOSTS]"
	}
}

# SET Command
bind pub -|- $mcc(trigger)set mcc:cmd:set
proc mcc:cmd:set {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	set who [lindex [join $text] 0]
	set why [lindex [join $text] 1]
	set whyy [join [lrange [split $text] 1 end]]
	
	switch -- [string tolower $who] {
		"lang" {
			putserv "NOTICE $nick :This function is not available."
			return
		}
		"output" - "reply" {
			putserv "NOTICE $nick :This function is not available."
			return
		}
		"permident" {
			if {[string tolower $why] == "on"} {
				setuser $handle XTRA PERMIDENT "1"
				putserv "NOTICE $nick :Permanent Identification is now ON."
				return
			}
			if {[string tolower $why] == "off"} {
				setuser $handle XTRA PERMIDENT "0"
				putserv "NOTICE $nick :Permanent Identification is now OFF."
				return
			}
			putserv "NOTICE $nick :Error. Usage: $mcc(trigger)set permident <on|off>"
			return
		}
		"automode" {
			if {[string tolower $why] == "op"} {
				if {![matchattr $handle &o $channel]} {
					putserv "NOTICE $nick :Error. You don`t have enough access."
					return
				}
				chattr $handle -|+a-g $channel
				putserv "NOTICE $nick :Set AutoMode to OP on channel $channel"
				return
			}
			if {[string tolower $why] == "voice"} {
				if {![matchattr $handle &v $channel]} {
					putserv "NOTICE $nick :Error. You don`t have enough access."
					return
				}
				chattr $handle -|+g-a $channel
				putserv "NOTICE $nick :Set AutoMode to VOICE on channel $channel"
				return
			}
			if {[string tolower $why] == "none"} {
				if {![matchattr $handle &v $channel]} {
					putserv "NOTICE $nick :Error. You don`t have enough access."
					return
				}
				chattr $handle -|-ga $channel
				putserv "NOTICE $nick :Set AutoMode to NONE on channel $channel"
				return
			}
			putserv "NOTICE $nick :Error. Usage: $mcc(trigger)set automode <none|voice|op>"
			return
		}
		"modify" {
			putserv "NOTICE $nick :This function is not available."
			return
		}
		"handle" {
			if {$why == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)set handle <new handle>"
				return
			}
			if {[string length $why] < 2} {
				putserv "NOTICE $nick :Error. New handle must be atlist 2 characters."
				return
			}
			if {[validuser $why]} {
				putserv "NOTICE $nick :Error. New handle $why is already in use."
				return
			}
			if {[chhandle $handle $why]} {
				putserv "NOTICE $nick :Your new handle is now \002$why\002."
				return
			}
			putserv "NOTICE $nick :Error. Could not change your handle. Please contact $mcc(home@bl) staff for help."
			mcc:msg:debug "\[\002SET\002\] Error changing handle from $handle to $why for $nick."
			return
		}
	}
	putserv "NOTICE $nick :Error. Usage: $mcc(trigger)set <lang|output|permident|automode|modify|handle> <option>"
}

#
# Commands Level: CHANNEL VOICE (-|v)
#

# VOICE Commands
bind pub o|v $mcc(trigger)voice mcc:cmd:voice
proc mcc:cmd:voice {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|v $channel]} { return }
	
	set who [join [lrange [split $text] 0 end]]
	
	if {$who == ""} {
		pushmode $channel +v $nick
	} else {
		foreach user $who {
			pushmode $channel +v $user
		}
	}
}

# DEVOICE Command
bind pub o|v $mcc(trigger)devoice mcc:cmd:devoice
proc mcc:cmd:devoice {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|v $channel]} { return }
	
	set who [join [lrange [split $text] 0 end]]
	
	if {$who == ""} {
		pushmode $channel -v $nick
	} else {
		foreach user $who {
			pushmode $channel -v $user
		}
	}
}

# USERS Command
bind pub o|v $mcc(trigger)users mcc:cmd:users
proc mcc:cmd:users {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|v $channel]} { return }
	
	set users ""
	set usersv ""
	set userso ""
	set usersm ""
	set usersn ""
	set usertot "0"
	set useron "0"
	foreach user [userlist &v $channel] {
		if {[matchattr $user &n $channel]} {
			if {[onchan [hand2nick $user] $channel]} {
				lappend usersn "$user/\002[hand2nick $user]\002"
				incr useron
			} else {
				lappend usersn "$user"
			}
			incr usertot
			continue
		}
		if {[matchattr $user &m $channel]} {
			if {[onchan [hand2nick $user] $channel]} {
				lappend usersm "$user/\002[hand2nick $user]\002"
				incr useron
			} else {
				lappend usersm "$user"
			}
			incr usertot
			continue
		}
		if {[matchattr $user &o $channel]} {
			if {[onchan [hand2nick $user] $channel]} {
				lappend userso "$user/\002[hand2nick $user]\002"
				incr useron
			} else {
				lappend userso "$user"
			}
			incr usertot
			continue
		}
		if {[matchattr $user &v $channel]} {
			if {[onchan [hand2nick $user] $channel]} {
				lappend usersv "$user/\002[hand2nick $user]\002"
				incr useron
			} else {
				lappend usersv "$user"
			}
			incr usertot
			continue
		}
	}
	if {$usersn != ""} {
		lappend users "\[\002\037ChanOwner\002\037\] $usersn" 
	}
	if {$usersm != ""} {
		lappend users "\[\002\037ChanMaster\002\037\] $usersm" 
	}
	if {$userso != ""} {
		lappend users "\[\002\037ChanOp\002\037\] $userso" 
	}
	if {$usersv != ""} {
		lappend users "\[\002\037ChanVoice\002\037\] $usersv" 
	}
	if {$users == ""} {
		putserv "NOTICE $nick :Channel $channel has no users."
		return
	}
	putserv "NOTICE $nick :Detected a total of $usertot users \[$useron in the channel\]"
	foreach line [mcc:check:splitline [join $users]] {
		putserv "NOTICE $nick :USERS: $line"
	}
}

# DEL Command
bind pub o|v $mcc(trigger)del mcc:cmd:del
proc mcc:cmd:del {nick uhost handle channel text} {
	global mcc owner
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|v $channel]} { return }
	
	set user [lindex [join $text] 0]
	set glob [lindex [join $text] 1]
	
	if {$user == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)del <nick|handle> \[-global|-perm\]"
		return
	}
	if {[onchan $user $channel]} {
		set user [nick2hand $user $channel]
	}
	if {$user == "" || $user == "*"} {
		putserv "NOTICE $nick :Error. User [lindex [join $text] 0] is not logged in."
		return
	}
	if {$glob == "-global"} {
		if {[string tolower $user] == [string tolower $owner]} {
			putserv "NOTICE $nick :Error. Can not delete a BOT OWNER."
			return
		}
		if {[chattr $user] == "-"} {
			putserv "NOTICE $nick :Error. User $user dosn`t have any global access."
			return
		}
		if {[mcc:check:leveldiff $user $handle ""]} {
			chattr $user -[chattr $user]
			putserv "NOTICE $nick :Deleted $user`s global access."
			return
		}
	}
	if {$glob == "-perm"} {
		if {[string tolower $user] == [string tolower $owner]} {
			putserv "NOTICE $nick :Error. Can not delete a BOT OWNER."
			return
		}
		if {![matchattr $handle n]} { return }
		if {[mcc:check:leveldiff $user $handle ""]} {
			deluser $user
			putserv "NOTICE $nick :Deleted $user from database."
			return
		}
	}
	if {![haschanrec $user $channel]} {
		putserv "NOTICE $nick :Error. User $user dosn`t have any channel access."
		return
	}
	if {[mcc:check:leveldiff $user $handle $channel]} {
		delchanrec $user $channel
		putserv "NOTICE $nick :Deleted $user`s channel access."
		return
	}
	putserv "NOTICE $nick :Error. Can not delete a user with lower or equal access then yours."
}

#
# Commands Level: CHANNEL OP (-|o)
#

# OP Commands
bind pub o|o $mcc(trigger)op mcc:cmd:op
proc mcc:cmd:op {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set who [join [lrange [split $text] 0 end]]
	
	if {$who == ""} {
		pushmode $channel +o $nick
	} else {
		foreach user $who {
			pushmode $channel +o $user
		}
	}
}

# DEOP Command
bind pub o|o $mcc(trigger)deop mcc:cmd:deop
proc mcc:cmd:deop {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set who [join [lrange [split $text] 0 end]]
	
	if {$who == ""} {
		pushmode $channel -o $nick
	} else {
		foreach user $who {
			pushmode $channel -o $user
		}
	}
}

# INVITE Command
bind pub o|o $mcc(trigger)invite mcc:cmd:invite
proc mcc:cmd:invite {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set who [join [lrange [split $text] 0 end]]
	
	if {$who == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)invite <nick(s)>"
		return
	}
	if {[llength $who] > 6} {
		putserv "NOTICE $nick :Error. You can not invite more then 6 people at a time."
		return
	}
	set invited ""
	foreach user $who {
		if {[onchan $user $channel]} { continue }
		putserv "INVITE $user $channel"
		lappend invited $user
	}
	if {$invited != ""} {
		putserv "NOTICE $nick :Invited $invited to $channel"
	} else {
		putserv "NOTICE $nick :No invite sent. Already in the channel."
	}
}

# CHANINFO Command
bind pub o|o $mcc(trigger)chaninfo mcc:cmd:chaninfo
proc mcc:cmd:chaninfo {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set sets ""
	putserv "NOTICE $nick :\002Channel Information\002"
	if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
		append sets "\002Enforce-Mode\002: [channel get $channel chanmode] "
		append sets "\002ChanLimit\002: [channel get $channel limit-int] "
		append sets "\002Idle-Kick\002: [channel get $channel idle-kick] "
		append sets "\002StopNetHack-Mode\002: [channel get $channel stopnethack-mode] "
		append sets "\002Revenge-Mode\002: [channel get $channel revenge-mode] "
		append sets "\002AOP-Delay\002: [channel get $channel aop-delay] "
		append sets "\002Ban-Type\002: [channel get $channel ban-type] "
		append sets "\002Ban-Time\002: [channel get $channel ban-time] "
		append sets "\002Flood-Chan\002: [channel get $channel flood-chan] "
		append sets "\002Flood-Ctcp\002: [channel get $channel flood-ctcp] "
		append sets "\002Flood-Join\002: [channel get $channel flood-join] "
		append sets "\002Flood-Kick\002: [channel get $channel flood-kick] "
		append sets "\002Flood-DeOp\002: [channel get $channel flood-deop] "
		append sets "\002Flood-Nick\002: [channel get $channel flood-nick]"			
		putserv "NOTICE $nick :$sets"
	}
	if {[matchattr $handle o|n $channel]} {
		set badwords [channel get $channel badword-text]
		set badchans [channel get $channel badchan-text]
		if {$badwords != ""} {
			putserv "NOTICE $nick :\002BadWord Masks\002: [join $badwords]"
		}
		if {$badchans != ""} {
			putserv "NOTICE $nick :\002BadChan Masks\002: [join $badchans]"
		}
	}
	foreach line [mcc:check:splitline [join [lsearch -all -inline -glob [lrange [channel info $channel] 1 end] +*]]] { 
		putserv "NOTICE $nick :\002Settings Enabled\002: $line" 
	}
	if {[matchattr $handle &m $channel] || [matchattr $handle o]} {
		foreach line [mcc:check:splitline [join [lsearch -all -inline -glob [lrange [channel info $channel] 1 end] -*]]] { 
			putserv "NOTICE $nick :\002Settings Disabled\002: $line" 
		}
	}
	if {[userlist &n $channel] == ""} {
		putserv "NOTICE $nick :\002ChanOwner\002: NO CHANNEL OWNER!"
	} else {
		foreach co [userlist &n $channel] {
			putserv "NOTICE $nick :\002ChanOwner\002: $co (LastSeen: [ctime [lindex [getuser $co LASTON $channel] 0]])" 
		}
	}
	putserv "NOTICE $nick :\002End of channel information\002"
}

# TOPIC Command
bind pub o|o $mcc(trigger)topic mcc:cmd:topic
proc mcc:cmd:topic {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set topic [join [lrange [split $text] 0 end]]
	
	if {$topic == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)topic <topic>"
		return
	}
	if {![botisop $channel]} {
		putserv "NOTICE $nick :Error. I`m not opped in $channel"
		return
	}
	if {![mcc:check:server_limits topic $topic]} {
		putserv "NOTICE $nick :Error. My current IRC server restricts topics to maximum $mcc(srv@topiclen) characters."
		return
	}
	if {[channel get $channel locktopic]} {
		putserv "NOTICE $nick :Error. Channel topic locked by [lindex [join [channel get $channel topic-text]] 0]"
		return
	}
	putserv "TOPIC $channel :$topic"
}

# KICK Command
bind pub o|o $mcc(trigger)kick mcc:cmd:kick
proc mcc:cmd:kick {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set user [lindex [join $text] 0]
	set reas [join [lrange [split $text] 1 end]]
	
	if {$user == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)kick <nick> \[reason\]"
		return
	}
	if {![botisop $channel]} {
		putserv "NOTICE $nick :Error. I`m not opped in $channel"
		return
	}
	if {![onchan $user $channel]} {
		putserv "NOTICE $nick :Error. User $user is not in the channel."
		return
	}
	if {[isbotnick $user] || [matchattr $user b]} {
		putkick $channel $nick "hah.. funny."
		return
	}
	if {![mcc:check:server_limits kick $reas]} {
		putserv "NOTICE $nick :Error. My current IRC server restricts kick/ban reason to maximum $mcc(srv@kicklen) characters."
		return
	}
	putkick $channel $user $reas
}

# BAN Command
bind pub o|o $mcc(trigger)ban mcc:cmd:ban
proc mcc:cmd:ban {nick uhost handle channel text} {
	global mcc botname
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set user [lindex [join $text] 0]
	
	if {$user == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)ban <nick|host> \[time\] \[-sticky\] \[-global\] \[reason\]"
		return
	}
	if {![botisop $channel]} {
		putserv "NOTICE $nick :Error. I`m not opped in $channel"
		return
	}
	if {[isbotnick $user] || [matchattr $user b]} {
		putkick $channel $nick "hah.. funny."
		return
	}
	if {[string match -nocase $user $botname]} {
		putkick $channel $nick "hah.. funny."
		return
	}
	if {[onchan $user $channel]} {
		set user [maskhost "$user![getchanhost $user $channel]" [channel get $channel ban-type]]
	}
	set time [lindex [join $text] 1]
	if {[isnumber $time]} {
		set reas [join [lrange [split $text] 2 end]]
	} else {
		set reas [join [lrange [split $text] 1 end]]
		set time [channel get $channel ban-time]
	}
	set sticky "none"
	if {[lsearch -exact $reas -sticky] != "-1"} {
		set where [lsearch -exact $reas -sticky]
		set reas [lreplace $reas $where $where]
		set sticky "sticky"
	}
	if {[lsearch -exact $reas -global] != "-1" && [matchattr $handle m]} {
		set where [lsearch -exact $reas -global]
		set reas [lreplace $reas $where $where]
		set global "yes"
	}
	if {![mcc:check:server_limits kick $reas]} {
		putserv "NOTICE $nick :Error. My current IRC server restricts kick/ban reason to maximum $mcc(srv@kicklen) characters."
		return
	}
	if {[info exists global]} {
		newban $user $handle $reas $time $sticky
		putserv "NOTICE $nick :Added $user to global banlist."
		mcc:msg:debug "\[\002BAN\002\] Added $user to global banlist."
	} else {
		newchanban $channel $user $handle $reas $time $sticky
		putserv "NOTICE $nick :Added $user to channel banlist."
	}
}

# UNBAN Command
bind pub o|o $mcc(trigger)unban mcc:cmd:unban
proc mcc:cmd:unban {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set user [lindex [join $text] 0]
	set glob [lindex [join $text] 1]
	
	if {$user == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)unban <hostmask> \[-global\]"
		return
	}
	set banlist ""
	set bbannr "0"
	set cbannr "0"
	if {$glob == "-global"} {
		if {![matchattr $handle o]} {
			putserv "NOTICE $nick :Error. You do not have access to remove global bans."
			return
		}
		foreach ban [banlist] {
			set banmask [lindex [join $ban] 0]
			set banuser [lindex [join $ban] 5]
			if {[string match -nocase $user $banmask] && [mcc:check:leveldiff $banuser $handle ""]} {
				killban $banmask
				lappend banlist $banmask
				incr bbannr
			}
		}
		putserv "NOTICE $nick :Removed $bbannr bans matching $user"
		if {$banlist != ""} {
			foreach line [mcc:check:splitline [join $banlist]] {
				mcc:msg:debug "\[\002UNBAN\002\] $nick/\002$handle\002: $line"
			}
		}
		return
	}
	foreach ban [banlist $channel] {
		set banmask [lindex [join $ban] 0]
		set banuser [lindex [join $ban] 5]
		if {[string match -nocase $user $banmask] && [mcc:check:leveldiff $banuser $handle $channel]} {
			killchanban $channel $banmask
			lappend banlist $banmask
			incr bbannr
		}
	}
	foreach ban [chanbans $channel] {
		set banmask [lindex [join $ban] 0]
		if {[string match -nocase $user $banmask]} {
			pushmode $channel -b $banmask
			incr cbannr
		}
	}
	putserv "NOTICE $nick :Removed $cbannr channel & $bbannr bot bans matching $user"
}

# BANLIST Command
bind pub o|o $mcc(trigger)banlist mcc:cmd:banlist
proc mcc:cmd:banlist {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set mask [lindex [join $text] 0]
	set glob [lindex [join $text] 1]
	
	set banlist ""
	if {$mask == "" || $mask == "-global"} {
		if {$mask == "-global"} {
			set thelist [banlist]
		} else {
			set thelist [banlist $channel]
		}
		foreach ban $thelist {
			lappend banlist [lindex [join $ban] 0]
		}
		if {$banlist == ""} {
			putserv "NOTICE $nick :Banlist is empty."
			return
		}
		foreach line [mcc:check:splitline [join $banlist]] {
			putserv "NOTICE $nick :Banlist: $line"
			return
		}
	}
	
	set bannr "0"
	if {$glob == "-global"} {
		set thelist [banlist]
	} else {
		set thelist [banlist $channel]
	}
	putserv "NOTICE $nick :Searching ban list.."
	foreach ban $thelist {
		set banmask [lindex [join $ban] 0]
		if {[string match -nocase $mask $banmask]} {
			set banreas [lindex $ban 1]
			set banexpr [lindex $ban 2]
			set banuser [lindex $ban 5]
			if {$banexpr == "0"} {
				set banexpr "Never"
			} else {
				set banexpr [lrange [duration [expr {[lindex $ban 2] - [unixtime]}]] 0 3]
			}
			putserv "NOTICE $nick :\002Mask\002: $banmask \002Creator\002: $banuser \002Expire\002: $banexpr \002Reason\002: $banreas"
			incr bannr
		}
	}
	putserv "NOTICE $nick :Found a total of $bannr bans matching $mask"
}

# MODE Command
bind pub o|o $mcc(trigger)mode mcc:cmd:mode
proc mcc:cmd:mode {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set mode [lindex [join $text] 0]
	set key [lindex [join $text] 1]
	
	if {$mode == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)mode <+|-mode>"
		return
	}
	if {![botisop $channel]} {
		putserv "NOTICE $nick :Error. I`m not opped in $channel"
		return
	}
	if {[lsearch -exact [split $mode ""] "k"] != "-1" && $key == ""} {
		putserv "NOTICE $nick :Error. Please specify a channel key."
		return
	}
	if {[lsearch -exact [split $mode ""] "l"] != "-1" && $key == ""} {
		putserv "NOTICE $nick :Error. Please specify the channel limit."
		return
	}
	if {![mcc:check:server_limits modes $mode]} {
		putserv "NOTICE $nick :Error. My current IRC server only supports these channel modes: \0036$mcc(srv@chanmodes)"
		return
	}
	pushmode $channel $mode $key
}

# ADD Command
bind pub o|o $mcc(trigger)add mcc:cmd:add
proc mcc:cmd:add {nick uhost handle channel text} {
	global mcc botnick owner
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|o $channel]} { return }
	
	set user [lindex [join $text] 0]
	set level [string tolower [lindex [join $text] 1]]
	set levels "ChanVoice ChanOp ChanMaster ChanOwner GlobalOp GlobalMaster GlobalOwner"
	
	if {[lsearch -exact [string tolower $levels] $level] == "-1"} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)add <nick> <level>"
		putserv "NOTICE $nick :Levels: [join $levels ", "]"
		return
	}
	if {![onchan $user $channel]} {
		putserv "NOTICE $nick :Error. User $user needs to be in the channel."
		return
	}
	
	set newuser [nick2hand $user $channel]
	
	if {![validuser $newuser]} {
		set userr $user
		if {![adduser $userr [mcc:proc:maskhost [getchanhost $user $channel]]]} {
			set iuser "0"
			while {![info exists okuser]} {
				set userr $user$iuser
				if {![validuser $userr]} { 
					set okuser "1" 
				} else {
					incr iuser
				}
			}
			adduser $userr [mcc:proc:maskhost [getchanhost $user $channel]]
			setuser $userr XTRA NOPASSDEL [clock add [unixtime] 2 hours]
		}
		putserv "NOTICE $user :You have been added as \002$userr\002 to my database."
		putserv "NOTICE $user :Please set a password (/msg $botnick pass) to avoid getting automaticaly deleted."
		set newuser $userr
	} else {
		if {[matchattr $newuser b]} {
			putserv "NOTICE $nick :Error. User $user/\002$newuser\002 is a bot."
			return
		}
		set chanlvl "chanvoice chanop chanmaster chanowner"
		if {[lsearch -exact $chanlvl $level] != "-1" && [matchattr $newuser nmof $channel]} {
			putserv "NOTICE $nick :Error. User $user/\002$newuser\002 ([mcc:check:level $newuser $channel]) already has access."
			return
		}
		set globlvl "globalop globalmaster globalowner"
		if {[lsearch -exact $globlvl $level] != "-1" && [matchattr $newuser nmov]} {
			putserv "NOTICE $nick :Error. User $user/\002$newuser\002 ([mcc:check:level $newuser $channel]) already has access."
			return
		}
	}
	if {[matchattr $handle o|o $channel] && $level == "chanvoice" } {
		chattr $newuser -|+fv $channel
		putserv "NOTICE $nick :Added $user/\002$newuser\002 as ChanVoice."
		putserv "NOTICE $user :You have been added as ChanVoice of $channel"
		return
	}
	if {[matchattr $handle o|m $channel] && $level == "chanop" } {
		chattr $newuser -|+flov $channel
		putserv "NOTICE $nick :Added $user/\002$newuser\002 as ChanOp."
		putserv "NOTICE $user :You have been added as ChanOp of $channel"
		return
	}
	if {[matchattr $handle o|n $channel] && $level == "chanmaster" } {
		chattr $newuser -|+flmov $channel
		putserv "NOTICE $nick :Added $user/\002$newuser\002 as ChanMaster."
		putserv "NOTICE $user :You have been added as ChanMaster of $channel"
		return
	}
	if {[matchattr $handle o] && $level == "chanowner" } {
		chattr $newuser -|+flmnov $channel
		putserv "NOTICE $nick :Added $user/\002$newuser\002 as ChanOwner."
		putserv "NOTICE $user :You have been added as ChanOwner of $channel"
		return
	}
	if {[matchattr $handle m] && $level == "globalop" } {
		chattr $newuser +flov
		putserv "NOTICE $nick :Added $user/\002$newuser\002 as GlobalOp."
		putserv "NOTICE $user :You have been added as GlobalOp."
		mcc:msg:debug "\[\002ADD\002\] $nick/\002$handle\002 added $user/\002$newuser\002 as GlobalOp"
		return
	}
	if {[matchattr $handle n] && $level == "globalmaster" } {
		chattr $newuser +flmov
		putserv "NOTICE $nick :Added $user/\002$newuser\002 as GlobalMaster."
		putserv "NOTICE $user :You have been added as GlobalMaster."
		mcc:msg:debug "\[\002ADD\002\] $nick/\002$handle\002 added $user/\002$newuser\002 as GlobalMaster"
		return
	}
	if {[string tolower $handle] == [string tolower $owner] && $level == "globalowner"} {
		chattr $newuser +flmnov
		putserv "NOTICE $nick :Added $user/\002$newuser\002 as GlobalOwner."
		putserv "NOTICE $user :You have been added as GlobalOwner."
		mcc:msg:debug "\[\002ADD\002\] $nick/\002$handle\002 added $user/\002$newuser\002 as GlobalOwner"
		return
	}
	putserv "NOTICE $nick :Error. You can`t add someone with level equal or bigger then yours."
}

#
# Commands Level: CHANNEL MASTER (-|m)
#

# CHANSET Command
bind pub o|m $mcc(trigger)chanset mcc:cmd:chanset
proc mcc:cmd:chanset {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|m $channel]} { return }
	
	set cmd [lindex [join $text] 0]
	set who [lindex [join $text] 1]
	set why [lindex [join $text] 2]
	set whyy [join [lrange [split $text] 1 end]]
	
	if {$cmd == ""} {
		putserv "NOTICE $nick :Error. No settings specified. Use \002$mcc(trigger)chaninfo\002 for a list of channel settings."
		return
	}
	
	switch -- [string tolower $cmd] {
		"enforce-mode" {
			if {$who == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <channel modes>"
				return
			}
			if {![mcc:check:server_limits modes $who]} {
				putserv "NOTICE $nick :Error. My current IRC server only supports these channel modes: \0036$mcc(srv@chanmodes)"
				return
			}
			channel set $channel chanmode $whyy
			putserv "NOTICE $nick :Enforce-Mode set to: [channel get $channel chanmode]"
			return
		}
		"chanlimit" {
			if {![isnumber $who] || $who < 0} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <limit>"
				return
			}
			channel set $channel limit-int $who
			putserv "NOTICE $nick :ChanLimit set to: [channel get $channel limit-int]"
			return
		}
		"idle-kick" {
			if {![isnumber $who] || $who < 0} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <minutes>"
				return
			}
			channel set $channel idle-kick $who
			putserv "NOTICE $nick :Idle-Kick set to: [channel get $channel idle-kick]"
			return
		}
		"stopnethack-mode" {
			if {![isnumber $who] || $who < 0 || $who > 6} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <type>"
				return
			}
			channel set $channel stopnethack-mode $who
			putserv "NOTICE $nick :StopNetHack-Mode set to: [channel get $channel stopnethack-mode]"
			return
		}
		"revenge-mode" {
			if {![isnumber $who] || $who < 0 || $who > 3} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <type>"
				return
			}
			channel set $channel revenge-mode $who
			putserv "NOTICE $nick :Revenge-Mode set to: [channel get $channel revenge-mode]"
			return
		}
		"need-op" {
			putserv "NOTICE $nick :Need-Op: Channel setting disabled."
			return
		}
		"need-invite" {
			putserv "NOTICE $nick :Need-Invite: Channel setting disabled."
			return
		}
		"need-key" {
			putserv "NOTICE $nick :Need-Key: Channel setting disabled."
			return
		}
		"need-unban" {
			putserv "NOTICE $nick :Need-UnBan: Channel setting disabled."
			return
		}
		"need-limit" {
			putserv "NOTICE $nick :Need-Limit: Channel setting disabled."
			return
		}
		"aop-delay" {
			if {![isnumber $who] || ![isnumber $why]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <seconds> <seconds>"
				return
			}
			if {$who == 0} {
				channel set $channel aop-delay $who:0
			} else {
				channel set $channel aop-delay $who:$why
			}
			putserv "NOTICE $nick :AOP-Delay set to: [channel get $channel aop-delay]"
			return
		}
		"ban-type" {
			if {![isnumber $who] || $who < 0 || $who > 29} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <type>"
				return
			}
			channel set $channel ban-type $who
			putserv "NOTICE $nick :Ban-Type set to: [channel get $channel ban-type]"
			return
		}
		"ban-time" {
			if {![isnumber $who] || $who < 0} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <type>"
				return
			}
			channel set $channel ban-time $who
			putserv "NOTICE $nick :Ban-Time set to: [channel get $channel ban-time]"
			return
		}
		"exempt-time" {
			putserv "NOTICE $nick :Exempt-Time: Channel setting disabled."
			return
		}
		"invite-time" {
			putserv "NOTICE $nick :Invite-Time: Channel setting disabled."
			return
		}
		"flood-*" {
			putserv "NOTICE $nick :Flood-*: Channel setting not available yet."
			return
		}
		"flood-chan" {
			if {![isnumber $who] || ![isnumber $why]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <lines> <seconds>"
				return
			}
			if {$who == 0} {
				channel set $channel flood-chan $who:0
			} else {
				channel set $channel flood-chan $who:$why
			}
			putserv "NOTICE $nick :Flood-Chan set to: [channel get $channel flood-chan]"
			return
		}
		"flood-ctcp" {
			if {![isnumber $who] || ![isnumber $why]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <ctcps> <seconds>"
				return
			}
			if {$who == 0} {
				channel set $channel flood-ctcp $who:0
			} else {
				channel set $channel flood-ctcp $who:$why
			}
			putserv "NOTICE $nick :Flood-Ctcp set to: [channel get $channel flood-ctcp]"
			return
		}
		"flood-join" {
			if {![isnumber $who] || ![isnumber $why]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <joins> <seconds>"
				return
			}
			if {$who == 0} {
				channel set $channel flood-join $who:0
			} else {
				channel set $channel flood-join $who:$why
			}
			putserv "NOTICE $nick :Flood-Join set to: [channel get $channel flood-join]"
			return
		}
		"flood-kick" {
			if {![isnumber $who] || ![isnumber $why]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <kicks> <seconds>"
				return
			}
			if {$who == 0} {
				channel set $channel flood-kick $who:0
			} else {
				channel set $channel flood-kick $who:$why
			}
			putserv "NOTICE $nick :Flood-Kick set to: [channel get $channel flood-kick]"
			return
		}
		"flood-deop" {
			if {![isnumber $who] || ![isnumber $why]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <deops> <seconds>"
				return
			}
			if {$who == 0} {
				channel set $channel flood-deop $who:0
			} else {
				channel set $channel flood-deop $who:$why
			}
			putserv "NOTICE $nick :Flood-DeOp set to: [channel get $channel flood-deop]"
			return
		}
		"flood-nick" {
			if {![isnumber $who] || ![isnumber $why]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)chanset $cmd <nick changes> <seconds>"
				return
			}
			if {$who == 0} {
				channel set $channel flood-nick $who:0
			} else {
				channel set $channel flood-nick $who:$why
			}
			putserv "NOTICE $nick :Flood-Nick set to: [channel get $channel flood-nick]"
			return
		}
		"badword" {
			if {$who == "add" && $why != ""} {
				set badwords [channel get $channel badword-text]
				lappend badwords $why
				channel set $channel badword-text $badwords
				putserv "NOTICE $nick :Added $why to BadWord list."
				return
			}
			if {$who == "del" && $why != ""} {
				set badwords [channel get $channel badword-text]
				set where [lsearch -exact $badwords $why]
				set badwords [lreplace $badwords $where $where]
				if {$where == "-1"} {
					putserv "NOTICE $nick :BadWord $why not found."
				} else {
					putserv "NOTICE $nick :Deleted $why from BadWord list."
					channel set $channel badword-text $badwords
				}
				return
			}
			putserv "NOTICE $nick :Usage: $mcc(trigger)chanset badword <add|del> <word mask>"
			if {[channel get $channel badword-text] == ""} {
				putserv "NOTICE $nick :BadWord list is empty."
			} else {
				putserv "NOTICE $nick :BadWord Masks: [join [channel get $channel badword-text]]"
			}
			return
		}
		"badchan" {
			if {$who == "add" && $why != ""} {
				set badchans [channel get $channel badchan-text]
				lappend badchans $why
				channel set $channel badchan-text $badchans
				putserv "NOTICE $nick :Added $why to BadChan list."
				return
			}
			if {$who == "del" && $why != ""} {
				set badchans [channel get $channel badchan-text]
				set where [lsearch -exact $badchans $why]
				set badchans [lreplace $badchans $where $where]
				if {$where == "-1"} {
					putserv "NOTICE $nick :BadChan $why not found."
				} else {
					putserv "NOTICE $nick :Deleted $why from BadChan list."
					channel set $channel badchan-text $badchans
				}
				return
			}
			putserv "NOTICE $nick :Usage: $mcc(trigger)chanset badchan <add|del> <chan mask>"
			if {[channel get $channel badchan-text] == ""} {
				putserv "NOTICE $nick :BadChan list is empty."
			} else {
				putserv "NOTICE $nick :BadChan Masks: [join [channel get $channel badchan-text]]"
			}
			return
		}
	}
	set goodmodes ""
	set badmodes ""
	foreach mode "$cmd $whyy" {
		if {[string match -nocase "?debug" $mode] && ![matchattr $handle n]} {
			lappend badmodes $mode
			continue
		}
		if {[string match -nocase "?statuslog" $mode] && ![matchattr $handle n]} {
			lappend badmodes $mode
			continue
		}
		if {[string match -nocase "?static" $mode] && ![matchattr $handle n]} {
			lappend badmodes $mode
			continue
		}
		if {[string match -nocase "?inactive" $mode] && ![matchattr $handle m]} {
			lappend badmodes $mode
			continue
		}
		if {([string match -nocase "+autotopic" $mode] || [string match -nocase "+locktopic" $mode]) && [topic $channel] == ""} {
			lappend badmodes $mode
			continue
		}
		if {([string match -nocase "+autotopic" $mode] || [string match -nocase "+locktopic" $mode]) && [topic $channel] != ""} {
			channel set $channel topic-text "$nick [topic $channel]"
		}
		if {[string match -nocase "+limit" $mode]} {
			mcc:check:limit $channel
		}
		if {[catch {channel set $channel $mode} fid]} {
			lappend badmodes $mode
		} else {
			lappend goodmodes $mode
		}
	}
	if {$goodmodes != ""} {
		putserv "NOTICE $nick :Setting channel to $goodmodes"
	}
	if {$badmodes != ""} {
		putserv "NOTICE $nick :Bad Settings: $badmodes"
	}
	return
}

# CYCLE Command
bind pub o|m $mcc(trigger)cycle mcc:cmd:cycle
proc mcc:cmd:cycle {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|m $channel]} { return }
	
	set time [lindex [join $text] 0]
	
	if {![isnumber $time]} {
		putserv "PART $channel :Cycling at the request of $nick/\002$handle\002"
		return
	}
	putserv "PART $channel :Cycling at the request of $nick/\002$handle\002 for $time seconds"
	channel set $channel +inactive
	utimer $time [list channel set $channel -inactive]
}

#
# Commands Level: CHANNEL OWNER (-|n)
#

# SAY Command
bind pub o|n $mcc(trigger)say mcc:cmd:say
proc mcc:cmd:say {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|n $channel]} { return }
	
	set text [join [lrange [split $text] 0 end]]
	
	if {$text == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)say <text>"
		return
	}
	putserv "PRIVMSG $channel :$text"
}

# ACT Command
bind pub o|n $mcc(trigger)act mcc:cmd:act
proc mcc:cmd:act {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|n $channel]} { return }
	
	set text [join [lrange [split $text] 0 end]]
	
	if {$text == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)act <text>"
		return
	}
	putserv "PRIVMSG $channel :\001ACTION $text\001"
}

# JOIN Command
bind pub -|- $mcc(trigger)join mcc:cmd:join
proc mcc:cmd:join {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	set chan [lindex [split $text] 0]
	
	if {$chan == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)join <#channel>"
		return
	}
	if {![matchattr $handle o|n $chan]} { return }
		
	if {![mcc:check:server_limits chanlen $chan]} {
		putserv "NOTICE $nick :Error. My current IRC server restricts channel names to $mcc(srv@chanlen) characters."
		return
	}
	if {![mcc:check:server_limits chantype $chan]} {
		putserv "NOTICE $nick :Error. My current IRC server restricts channel types to [split $mcc(srv@chantypes) ""]"
		return
	}
	if {![mcc:check:server_limits channels $chan]} {
		putserv "NOTICE $nick :Error. I have reached my maximum channel capacity."
		return
	}
	if {[validchan $chan]} {
		if {[channel get $chan inactive]} {
			channel set $chan -inactive
			putserv "NOTICE $nick :Rejoining $chan"
			return
		}
		if {[botonchan $chan]} {
			putserv "NOTICE $nick :I am already in $chan"
			return
		}
		putserv "JOIN $chan"
		return
	}
	if {[matchattr $handle m]} {
		channel add $chan {
			limit-int 5
		}
		putserv "NOTICE $nick :Adding channel $chan to database."
		mcc:msg:debug "\[\002JOIN\002\] $nick added $chan to database."
	}
}

# PART Command
bind pub o|n $mcc(trigger)part mcc:cmd:part
proc mcc:cmd:part {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	
	set chan [lindex [join $text] 0]
	
	if {![matchattr $handle o|n $chan]} { return }
	
	if {$chan == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)part <#channel>"
		putserv "NOTICE $nick :NOTE: This will delete the channel and all access records."
		return
	}
	if {![validchan $chan]} {
		putserv "NOTICE $nick :Error. Channel $chan is not in my database."
		return
	}
	if {[channel get $chan static] && [matchattr $handle n]} {
		putserv "NOTICE $nick :Error. Channel $chan is +static"
		return
	}
	putserv "PART $chan :Channel purged by $nick/\002$handle\002"
	channel remove $chan
	mcc:msg:debug "\[\002PART\002\] $nick/\002$handle\002 purged $chan"
	putserv "NOTICE $nick :Channel $chan has been purged."
}

# GREET Command
bind pub o|n $mcc(trigger)greet mcc:cmd:greet
proc mcc:cmd:greet {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o|n $channel]} { return }
	
	set cmd [lindex [join $text] 0]
	set txt [join [lrange [split $text] 1 end]]
	
	switch -- [string tolower $cmd] {
		"add" {
			if {$txt == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)greet add <text>"
				putserv "NOTICE $nick :NOTE: Parsers available for dynamic information are: %nickname %hostname %handle %channel %botnick %access"
				return
			}
			if {[llength [channel get $channel greet-text]] > 3} {
				putserv "NOTICE $nick :Error. Maximum number of 4 greets reached."
				putserv "NOTICE $nick :NOTE: Remove one of the current greets before trying to add a new one."
				return
			}
			set greet [channel get $channel greet-text]
			lappend greet $txt
			channel set $channel greet-text $greet
			putserv "NOTICE $nick :New channel greet has been added."
			return
		}
		"del" {
			if {![isnumber $txt]} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)greet del <id>"
				return
			}
			set nr [expr {$txt - 1}]
			set greet [channel get $channel greet-text]
			set greet [lreplace $greet $nr $nr]
			channel set $channel greet-text $greet
			putserv "NOTICE $nick :Greet ID $txt deleted."
			return
		}
		"list" {
			set greetlist [channel get $channel greet-text]
			if {$greetlist == ""} {
				putserv "NOTICE $nick :Greet is empty."
				return
			}
			set nr "1"
			foreach greet $greetlist {
				putserv "NOTICE $nick :\[\002ID $nr\002\] $greet"
				incr nr
			}
			return
		}
	}
	putserv "NOTICE $nick :Error. Usage: $mcc(trigger)greet <add|del|list> \[text\]"
	putserv "NOTICE $nick :NOTE: Parsers available for dynamic information are: %nickname %hostname %handle %channel %botnick %access"
}

#
# Commands Level: GLOBAL OP (o|-)
#

# IGNORE Command
bind pub o $mcc(trigger)ignore mcc:cmd:ignore
proc mcc:cmd:ignore {nick uhost handle channel text} {
	global mcc ignore-time
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o]} { return }
	
	set host [lindex [join $text] 0]
	
	if {$host == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)ignore <hostmask> \[time\] <reason>"
		return
	}
	if {[isnumber [lindex [join $text] 1]]} {
		set time [lindex [join $text] 1]
		set reas [join [lrange [split $text] 2 end]]
	} else {
		set time ${ignore-time}
		set reas [join [lrange [split $text] 1 end]]
	}
	newignore $host $handle $reas $time
	putserv "NOTICE $nick :Hostmask $host added to ignore list."
	mcc:msg:debug "\[\002IGNORE\002\] $nick/\002$handle\002 added $host to ignore list."
}

# UNIGNORE Command
bind pub o $mcc(trigger)unignore mcc:cmd:unignore
proc mcc:cmd:unignore {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o]} { return }
	
	set host [lindex [join $text] 0]
	
	if {$host == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)unignore <hostmask>"
		return
	}
	set ignorenr "0"
	foreach ignore [ignorelist] {
		set ihost [lindex $ignore 0]
		if {[string match -nocase $host $ihost]} {
			killignore $ihost
			incr ignorenr
		}
	}
	putserv "NOTICE $nick :Removed $ignorenr ingores matching $host"
	mcc:msg:debug "\[\002IGNORE\002\] $nick/\002$handle\002 removed $ignorenr ignores matching $host"
}

# IGNORELIST Command
bind pub o $mcc(trigger)ignorelist mcc:cmd:ignorelist
proc mcc:cmd:ignorelist {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o]} { return }
	
	set host [lindex [join $text] 0]
	
	set ignorelist [ignorelist]
	if {$ignorelist == ""} {
		putserv "NOTICE $nick :Ignore list is empty."
		return
	}
	set igns ""
	if {$host == "" || ![matchattr $handle o]} {
		foreach ignore $ignorelist {
			lappend igns [lindex $ignore 0]
		}
		foreach line [mcc:check:splitline [join $igns]] {
			putserv "NOTICE $nick :IgnoreList: $line"
		}
		return
	}
	set ignr "0"
	putserv "NOTICE $nick :Searching ignore list.."
	foreach ignore $ignorelist {
		set ignhost [lindex $ignore 0]
		if {[string match -nocase $host $ignhost]} {
			set ignuser [lindex $ignore 4]
			set ignreas [lindex $ignore 1]
			set igntime [lindex $ignore 2]
			if {$igntime == "0"} {
				set igntime "Never"
			} else {
				set igntime [lrange [duration [expr {[lindex $ignore 2] - [unixtime]}]] 0 3]
			}
			putserv "NOTICE $nick :\002Mask\002: $ignhost \002Creator\002: $ignuser \002Expire\002: $igntime \002Reason\002: $ignreas"
			incr ignr
		}
	}
	putserv "NOTICE $nick :Found $ignr ignores matching $host"
}

# HOST Command
bind pub o $mcc(trigger)host mcc:cmd:host
proc mcc:cmd:host {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o]} { return }
	
	set cmd [lindex [join $text] 0]
	set who [lindex [join $text] 1]
	set why [lindex [join $text] 2]
	
	switch -- [string tolower $cmd] {
		"add" {
			if {$why == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)host add <handle> <hostname>"
				return
			}
			if {![validuser $who]} {
				putserv "NOTICE $nick :Error. Invalid handle."
				return
			}
			setuser $who HOSTS $why
			putserv "NOTICE $nick :Added $why as $who`s hostname."
			return
		}
		"del" {
			if {$why == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)host del <handle> <hostname>"
				return
			}
			if {![validuser $who]} {
				putserv "NOTICE $nick :Error. Invalid handle."
				return
			}
			if {[delhost $who $why]} {
				putserv "NOTICE $nick :Deleted host $why from $who`s hostlist."
			} else {
				putserv "NOTICE $nick :Hostname $why not found on $who`s hostlist."
			}
			return
		}
		"list" {
			if {$who == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)host list <handle>"
				return
			}
			if {![validuser $who]} {
				putserv "NOTICE $nick :Error. Invalid handle."
				return
			}
			putserv "NOTICE $nick :$who Hosts: [getuser $who HOSTS]"
			return
		}
		"search" {
			if {$who == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)host search <hostmask>"
				return
			}
			putserv "NOTICE $nick :Searching.."
			set userlist ""
			set usernr "0"
			foreach user [userlist] {
				if {[lsearch -glob [getuser $user HOSTS] $who] != "-1"} {
					lappend userlist $user
					incr usernr
				}
			}
			if {$userlist != ""} {
				foreach line [mcc:check:splitline [join $userlist]] {
					putserv "NOTICE $nick :UserList: $line"
				}
			}
			putserv "NOTICE $nick :Found $usernr users matching $who"
			return
		}
	}
	putserv "NOTICE $nick :Error. Usage: $mcc(trigger)host <add|del|list|search> <handle|hostmask>"
}

# BROADCAST Command
bind pub o $mcc(trigger)broadcast mcc:cmd:broadcast
proc mcc:cmd:broadcast {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle o]} { return }
	
	set txt [join [lrange [split $text] 0 end]]
	
	if {$txt == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)broadcast <text>"
		return
	}
	foreach chan [channels] {
		if {![botonchan $chan]} { continue }
		putserv "PRIVMSG $chan :\[\002BROADCAST\002\] $txt"
	}
}

#
# Commands Level: GLOBAL MASTER (m|-)
#

# MSG Command
bind pub m $mcc(trigger)msg mcc:cmd:msg
proc mcc:cmd:msg {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle m]} { return }
	
	set user [lindex [join $text] 0]
	set txt [join [lrange [split $text] 1 end]]
	
	if {$txt == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)msg <nick> <text>"
		return
	}
	putserv "PRIVMSG $user :$txt"
	putserv "NOTICE $nick :Message sent to $user."
}

#
# Commands Level: GLOBAL OWNER (n|-)
#

# REHASH Command
bind pub n $mcc(trigger)rehash mcc:cmd:rehash
proc mcc:cmd:rehash {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle n]} { return }
	
	putserv "NOTICE $nick :Rehashing.."
	mcc:msg:debug "\[\002REHASH\002\] $nick/\002$handle\002 rehashing.."
	rehash
}

# SAVE Command
bind pub n $mcc(trigger)save mcc:cmd:save
proc mcc:cmd:save {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle n]} { return }
	
	putserv "NOTICE $nick :Saving.."
	mcc:msg:debug "\[\002SAVE\002\] $nick/\002$handle\002 saving.."
	save
}

# RESTART Command
bind pub n $mcc(trigger)restart mcc:cmd:restart
proc mcc:cmd:restart {nick uhost handle channel text} {
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle n]} { return }
	
	putserv "NOTICE $nick :Restarting.."
	mcc:msg:debug "\[\002RESTART\002] $nick/\002$handle\002 restarting.."
	utimer 5 [list restart]
}

# JUMP Command
bind pub n $mcc(trigger)jump mcc:cmd:jump
proc mcc:cmd:jump {nick uhost handle channel text} {
	global mcc
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle n]} { return }
	
	set server [lindex [join $text] 0]
	
	if {$server == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)jump <server>"
		return
	}
	jump $server
}

#
# Commands Level: BOT OWNER (n)
#

# DIE Command
bind pub n $mcc(trigger)die mcc:cmd:die
proc mcc:cmd:die {nick uhost handle channel text} {
	global owner
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle n]} { return }
	if {[string tolower $handle] != [string tolower $owner]} { return }
	save
	utimer 5 [list die "010000100111100101100101"]
}

# NICK Command
bind pub n $mcc(trigger)nick mcc:cmd:nick
proc mcc:cmd:nick {nick uhost handle channel text} {
	global mcc owner
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle n]} { return }
	if {[string tolower $handle] != [string tolower $owner]} { return }
	
	set bnick [lindex [join $text] 0]
	
	if {$bnick == ""} {
		putserv "NOTICE $nick :Error. Usage: $mcc(trigger)nick <nick>"
		return
	}
	mcc:proc:newnick $bnick
	putserv "NOTICE $nick :Changing my nick to $bnick."
	mcc:msg:debug "\[\002NICK\002\] $nick/\002$handle\002 changed my nick to $bnick"
}

# BOTNET Command
bind pub n $mcc(trigger)botnet mcc:cmd:botnet
proc mcc:cmd:botnet {nick uhost handle channel text} {
	global mcc botnet-nick my-ip owner nat-ip
	
	if {![mcc:check:logged $nick $handle $uhost]} { return }
	if {![matchattr $handle n]} { return }
	if {[string tolower $handle] != [string tolower $owner]} { return }
	
	set cmd [lindex [join $text] 0]
	set netnick [lindex [join $text] 1]
	set netip [lindex [join $text] 2]
	set netport [lindex [join $text] 3]
	set netflag [lindex [join $text] 4]
	
	switch -- [string tolower $cmd] {
		"info" {
			if {${nat-ip} == ""} {
				set ip ${my-ip}
			} else {
				set ip ${nat-ip}
			}
			putserv "NOTICE $nick :\002BotNet-Nick\002: ${botnet-nick} \002Telnet IP\002: ${ip} \002Telnet Port\002: $mcc(telnetport)"
			return
		}
		"list" {
			set blist ""
			foreach bot [userlist b] {
				if {[string tolower $bot] == [string tolower ${botnet-nick}]} { continue }
				if {[islinked $bot]} {
					lappend blist $bot
				} else {
					lappend blist \0034$bot\003
				}
			}
			if {$blist == ""} {
				putserv "NOTICE $nick :BotList is empty."
				return
			}
			foreach line [mcc:check:splitline [join $blist]] {
				putserv "NOTICE $nick :BotList: $line"
			}
			return
		}
		"addhub" {
			if {$netport == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)botnet addhub <botnet nick> <telnet ip> <telnet port> \[bot flags\]"
				return
			}
			if {[validuser $netnick]} {
				putserv "NOTICE $nick :Error. Handle \002$netnick\002 is not available."
				return
			}
			addbot $netnick $netip:$netport
			botattr $netnick +h$netflag
			chattr $netnick +b
			putserv "NOTICE $nick :Added \002$netnick\002 as HUB Bot."
			if {[onchan $netnick $channel]} {
				setuser $netnick HOSTS [getchanhost $netnick $channel]
			} else {
				putserv "NOTICE $nick :Could not detect \002$netnick\002`s hostname. Use: $mcc(trigger)host add $netnick <hostname>"
			}
			return
		}
		"addleaf" {
			if {$netport == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)botnet addleaf <botnet nick> <telnet ip> <telnet port> \[bot flags\]"
				return
			}
			if {[validuser $netnick]} {
				putserv "NOTICE $nick :Error. Handle \002$netnick\002 is not available."
				return
			}
			addbot $netnick $netip:$netport
			botattr $netnick +l$netflag
			chattr $netnick +b
			putserv "NOTICE $nick :Added \002$netnick\002 as LEAF Bot."
			if {[onchan $netnick $channel]} {
				setuser $netnick HOSTS [getchanhost $netnick $channel]
			} else {
				putserv "NOTICE $nick :Could not detect \002$netnick\002`s hostname. Use: $mcc(trigger)host add $netnick <hostname>"
			}
			return
		}
		"link" {
			if {$netnick == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)botnet link <botnet nick>"
				return
			}
			if {![validuser $netnick] || ![matchattr $netnick b]} {
				putserv "NOTICE $nick :Error. Could not find bot \002$netnick\002. See: $mcc(trigger)botnet list"
				return
			}
			if {[islinked $netnick]} {
				putserv "NOTICE $nick :Error. Bot \002$netnick\002 is linked."
				return
			}
			link $netnick
			putserv "NOTICE $nick :Starting link with \002$netnick\002.."
			return
		}
		"unlink" {
			if {$netnick == ""} {
				putserv "NOTICE $nick :Error. Usage: $mcc(trigger)botnet unlink <botnet nick>"
				return
			}
			if {![validuser $netnick] || ![matchattr $netnick b]} {
				putserv "NOTICE $nick :Error. Could not find bot \002$netnick\002. See $mcc(trigger)botnet list"
				return
			}
			if {![islinked $netnick]} {
				putserv "NOTICE $nick :Error. Bot \002$netnick\002 is not linked."
				return
			}
			unlink $netnick
			putserv "NOTICE $nick :Closing link with \002$netnick\002.."
			return
		}
	}
	putserv "NOTICE $nick :Error. Usage: $mcc(trigger)botnet <info|list|addhub|addleaf|link|unlink|chat> \[BotNet Nick\] \[Telnet Ip\] \[Telnet Port\] \[Bot Flags\]"
}

putlog "MCC $mcc(scriptversion) by dirty Inc. Loaded."