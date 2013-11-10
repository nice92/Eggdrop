# chanrelay.tcl 3.6-3
#
# A way to link your channels
#
# Author: CrazyCat <crazycat@c-p-f.org>
# http://www.eggdrop.fr
# irc.zeolia.net #eggdrop

## DESCRIPTION ##
#
# This TCL is a complete relay script wich works with botnet.
# All you have to do is to include this tcl in all the eggdrop who
# are concerned by it.
#
# You can use it as a spy or a full duplex communication tool.
#
# It don't mind if the eggdrops are on the same server or not,
# it just mind about the channels and the handle of each eggdrop.

## CHANGELOG ##
#
# 3.6-3
# Correction of trans mode on/off
#
# 3.6-2
# Correction of the logging of actions (/me)
#   Nick was replaced with ACTION
# Correction of empty chan list (!who)
# 
# 3.6-1
# Correction of the !who command
# It's now possible to have the list from a specific server
#
# 3.6
# Correction of modes catching / transmitting
#
# 3.5 (Beta)
# Integration of Message Delivery Service (MDS)
# by MenzAgitat
#
# 3.4
# Settings modified by msg commands are now saved
# Correction of small bugs
# Best verification of settings sent
# Acknowledgement and error messages added
#
# 3.3-1
# Correction for /msg eggdrop trans <action> [on|off]
#
# 3.3
# Added lines introducing beginning and ending of userlist
#
# 3.2
# Added gray user highlight
#
# 3.1
# Added check for linked bot
# Corrected parse of some messages
# Corrected pub commands
#
# 3.0
# Complete modification of configuration
# Use of namespace
# No more broadcast, the relay is done with putbot

## TODO ##
#
# Enhance configuration
# Allow save of configuration
# Multi-languages

## CONFIGURATION ##
#
# For each eggdrop in the relay, you have to
# indicate his botnet nick, the chan and the network.
#
# Syntax:
# set regg(USERNAME) {
#	"chan"		"#CHANNEL"
#	"network"	"NETWORK"
#}
# with:
# USERNAME : The username sets in eggdrop.conf (case-sensitive)
# optionaly, you can override default values:
# * highlight (0/1/2/3): is speaker highlighted ? (no/bold/undelined/gray)
# * snet (y/n): is speaker'network shown ?
# * transmit (y/n): does eggdrop transmit his channel activity ?
# * receive (y/n): does eggdrop diffuse other channels activity ?
#
# userlist(beg) is the sentence announcing the start of !who
# userlist(end) is the sentence announcing the end of !who

namespace eval crelay {
    
    variable regg
    variable default
    variable userlist
	
    set regg(^Oort) {
        "chan"		"#chan"
        "network"	"reseau"
        "highlight"	0
        "log"		"y"
    }
    
    set regg(^Oort) {
        "chan"		"#chan"
        "network"	"reseau"
        "highlight"	0
    }

    set default {
        "highlight"	1
        "snet"		"y"
        "transmit"	"y"
        "receive"	"y"
        "log"		"n"
    }
	
    # transmission configuration
    set trans_pub "y"; # transmit the pub
    set trans_act "n"; # transmit the actions (/me)
    set trans_nick "n"; # transmit the nick changement
    set trans_join "n"; # transmit the join
    set trans_part "n"; # transmit the part
    set trans_quit "n"; # transmit the quit
    set trans_topic "n"; # transmit the topic changements
    set trans_kick "n"; # transmit the kicks
    set trans_mode "n"; #transmit the mode changements
    set trans_who "n"; # transmit the who list
    
    # reception configuration
    set recv_pub "y"; # recept the pub
    set recv_act "y"; # recept the actions (/me)
    set recv_nick "n"; # recept the nick changement
    set recv_join "n"; # recept the join
    set recv_part "n"; # recept the part
    set recv_quit "n"; # recept the quit
    set recv_topic "n"; # recept the topic changements
    set recv_kick "n"; # recept the kicks
    set recv_mode "n"; # recept the mode changements
    set recv_who "n"; # recept the who list
    
	set userlist(beg) "Beginning of userlist"
	set userlist(end) "End of userlist"
	
	variable config "databases/chanrelay.db"
	
    variable author "CrazyCat"
    variable version "3.6"
}

####################################
#    DO NOT EDIT ANYTHING BELOW    #
####################################
proc ::crelay::init {args} {
	
    variable me
	
    array set me $::crelay::default
    array set me $::crelay::regg($::username)

    if { [file exists $::crelay::config] } {
	    [namespace current]::preload
    }
    
    if { $me(transmit) == "y" } {
        bind msg o|o "trans" [namespace current]::set:trans
        if { $::crelay::trans_pub == "y" } { bind pubm - * [namespace current]::trans:pub }
        if { $::crelay::trans_act == "y" } { bind ctcp - "ACTION" [namespace current]::trans:act }
        if { $::crelay::trans_nick == "y" } { bind nick - * [namespace current]::trans:nick }
        if { $::crelay::trans_join == "y" } { bind join - * [namespace current]::trans:join }
        if { $::crelay::trans_part == "y" } { bind part - * [namespace current]::trans:part }
        if { $::crelay::trans_quit == "y" } { bind sign - * [namespace current]::trans:quit }
        if { $::crelay::trans_topic == "y" } { bind topc - * [namespace current]::trans:topic }
        if { $::crelay::trans_kick == "y" } { bind kick - * [namespace current]::trans:kick }
        if { $::crelay::trans_mode == "y" } { bind raw - "MODE" [namespace current]::trans:mode }
        if { $::crelay::trans_who == "y" } { bind pub - "!who" [namespace current]::trans:who }
    }
    
    if { $me(receive) =="y" } {
        bind msg o|o "recv" ::crelay::set:recv
        if { $::crelay::recv_pub == "y" } { bind bot - ">pub" [namespace current]::recv:pub }
        if { $::crelay::recv_act == "y" } { bind bot - ">act" [namespace current]::recv:act }
        if { $::crelay::recv_nick == "y" } { bind bot - ">nick" [namespace current]::recv:nick }
        if { $::crelay::recv_join == "y" } { bind bot - ">join" [namespace current]::recv:join }
        if { $::crelay::recv_part == "y" } { bind bot - ">part" [namespace current]::recv:part }
        if { $::crelay::recv_quit == "y" } { bind bot - ">quit" [namespace current]::recv:quit }
        if { $::crelay::recv_topic == "y" } { bind bot - ">topic" [namespace current]::recv:topic }
        if { $::crelay::recv_kick == "y" } { bind bot - ">kick" [namespace current]::recv:kick }
        if { $::crelay::recv_mode == "y" } { bind bot - ">mode" [namespace current]::recv:mode }
        if { $::crelay::recv_who == "y" } {
            bind bot - ">who" [namespace current]::recv:who
            bind bot - ">wholist" [namespace current]::recv:wholist
        }
    }
    
    [namespace current]::set:hl $me(highlight);
    
	if { $me(log) == "y"} {
		logfile sjpk $me(chan) "logs/[string range $me(chan) 1 end].log"
	}
    bind msg o|o "rc.status" [namespace current]::help:status
    bind msg - "rc.help" [namespace current]::help:cmds
    bind msg o|o "rc.light" [namespace current]::set:light
    bind msg o|o "rc.net" [namespace current]::set:snet
    
    variable eggdrops
    variable chans
    variable networks
    foreach bot [array names [namespace current]::regg] {
	array set tmp $::crelay::regg($bot)
        lappend eggdrops $bot
        lappend chans $tmp(chan)
        lappend networks $tmp(network)
    }
    [namespace current]::save
    bind evnt -|- prerehash [namespace current]::deinit
    
    if {[lsearch [package names] "MDS"] >= 0 } {
	    unbind pub $::MDS::pub_msg_auth $::MDS::pub_msg_cmd MDS::pub_sendmsg
	    bind pub $::MDS::pub_msg_auth $::MDS::pub_msg_cmd [namespace current]::pub_sendmsg
	    unbind msg $::MDS::priv_msg_auth $::MDS::priv_msg_cmd MDS::priv_sendmsg
	    bind msg $::MDS::priv_msg_auth $::MDS::priv_msg_cmd [namespace current]::priv_sendmsg
	    bind bot - ">mds" [namespace current]::recv:mds
	    set ::MDS::msgdb_file "databases/MDS_messages.$::username.db"
    }
    
    package provide ChanRelay $::crelay::version
    
}

# Reads settings from a file
proc ::crelay::preload {args} {
	set fp [open $::crelay::config r]
	set settings [read -nonewline $fp]
    close $fp
    foreach line [split $settings "\n"] {
	    set lset [split $line "|"]
	    switch [lindex $lset 0] {
		    transmit { set [namespace current]::me(transmit) [lindex $lset 1] }
		    receive { set [namespace current]::me(receive) [lindex $lset 1] }
		    snet { set [namespace current]::me(snet) [lindex $lset 1] }
		    highlight { set [namespace current]::me(highligt) [lindex $lset 1] }
		    default {
			    set [namespace current]::[lindex $lset 0] [lindex $lset 1]
		    }
	    }
    }
}
# Save all settings in a file
proc ::crelay::save {args} {
	set fp [open $::crelay::config w]
	puts $fp "transmit|$::crelay::me(transmit)"
	puts $fp "receive|$::crelay::me(transmit)"
	puts $fp "snet|$::crelay::me(transmit)"
	puts $fp "highlight|$::crelay::me(transmit)"
	puts $fp "trans_pub|$::crelay::trans_pub"
	puts $fp "trans_act|$::crelay::trans_act"
	puts $fp "trans_nick|$::crelay::trans_nick"
   puts $fp "trans_join|$::crelay::trans_join"
   puts $fp "trans_part|$::crelay::trans_part"
   puts $fp "trans_quit|$::crelay::trans_quit"
   puts $fp "trans_topic|$::crelay::trans_topic"
   puts $fp "trans_kick|$::crelay::trans_kick"
   puts $fp "trans_mode|$::crelay::trans_mode"
   puts $fp "trans_who|$::crelay::trans_who"
   puts $fp "recv_pub|$::crelay::recv_pub"
   puts $fp "recv_act|$::crelay::recv_act"
   puts $fp "recv_nick|$::crelay::recv_nick"
   puts $fp "recv_join|$::crelay::recv_join"
   puts $fp "recv_part|$::crelay::recv_part"
   puts $fp "recv_quit|$::crelay::recv_quit"
   puts $fp "recv_topic|$::crelay::recv_topic"
   puts $fp "recv_kick|$::crelay::recv_kick"
   puts $fp "recv_mode|$::crelay::recv_mode"
   puts $fp "recv_who|$::crelay::recv_who"
   close $fp
}

proc ::crelay::deinit {args} {
	putlog "Starting unloading CHANRELAY $::crelay::version"
	[namespace current]::save
	putlog "Settings are saved in $::crelay::config"
    catch {unbind evnt -|- prerehash [namespace current]::deinit}
    catch {
      unbind msg o|o "trans" [namespace current]::set:trans
      unbind pubm - * [namespace current]::trans:pub
		unbind ctcp - "ACTION" [namespace current]::trans:act
		unbind nick - * [namespace current]::trans:nick
		unbind join - * [namespace current]::trans:join
		unbind part - * [namespace current]::trans:part
		unbind sign - * [namespace current]::trans:quit
		unbind topc - * [namespace current]::trans:topic
		unbind kick - * [namespace current]::trans:kick
      unbind raw - "MODE" [namespace current]::trans:mode
		unbind pub - "!who" [namespace current]::trans:who
    }
    catch {
		unbind msg o|o "recv" [namespace current]::set:recv
		unbind bot - ">pub" [namespace current]::recv:pub
		unbind bot - ">act" [namespace current]::recv:act
		unbind bot - ">nick" [namespace current]::recv:nick
		unbind bot - ">join" [namespace current]::recv:join
		unbind bot - ">part" [namespace current]::recv:part
		unbind bot - ">quit" [namespace current]::recv:quit
		unbind bot - ">topic" [namespace current]::recv:topic
		unbind bot - ">kick" [namespace current]::recv:kick
		unbind bot - ">mode" [namespace current]::recv:mode
		unbind bot - ">who" [namespace current]::recv:who
		unbind bot - ">wholist" [namespace current]::recv:wholist
    }
    catch {
		unbind msg o|o "rc.status" [namespace current]::help:status
		unbind msg - "rc.help" [namespace current]::help:cmds
		unbind msg o|o "rc.light" [namespace current]::set:light
		unbind msg o|o "rc.net" [namespace current]::set:snet
    }

    foreach child [namespace children] {
		catch {[set child]::deinit}
    }
    if {[lsearch [package names] "MDS"] >= 0 } {
	    unbind pub $::MDS::pub_msg_auth $::MDS::pub_msg_cmd [namespace current]::pub_sendmsg
	    bind pub $::MDS::pub_msg_auth $::MDS::pub_msg_cmd MDS::pub_sendmsg
	    unbind bot - ">mds" [namespace current]::recv:mds
	    unbind msg $::MDS::priv_msg_auth $::MDS::priv_msg_cmd [namespace current]::priv_sendmsg
	    bind msg $::MDS::priv_msg_auth $::MDS::priv_msg_cmd MDS::priv_sendmsg
    }
	putlog "CHANRELAY $::crelay::version unloaded"
    namespace delete [namespace current]
}

namespace eval crelay {
    variable hlnick
    variable snet
	
    # Setting of hlnick
    proc set:light { nick uhost handle arg } {
		# message binding
		switch $arg {
			"bo" { [namespace current]::set:hl 1; }
			"un" { [namespace current]::set:hl 2; }
			"gr" { [namespace current]::set:hl 3; }
			"off" { [namespace current]::set:hl 0; }
			default { puthelp "NOTICE $nick :you must chose \002(bo)\002ld , \037(un)\037derline, \00314(gr)\003ay or (off)" }
		}
		[namespace current]::save
		return 0;
    }
    
    proc set:hl { arg } {
		# global hlnick setting function
		switch $arg {
			1 { set [namespace current]::hlnick "\002"; }
			2 { set [namespace current]::hlnick "\037"; }
			3 { set [namespace current]::hlnick "\00314"; }
			default { set [namespace current]::hlnick ""; }
		}
    }
    
    # Setting of show network
    proc set:snet {nick host handle arg } {
		if { $arg == "yes" } {
			set [namespace current]::snet "y"
			puthelp "NOTICE $nick :Network is now showed"
		} elseif { $arg == "no" } {
			set [namespace current]::snet "n"
			puthelp "NOTICE $nick :Network is now hidden"
		} else {
			puthelp "NOTICE $nick :you must chose yes or no"
			return 0
		}
		[namespace current]::save
    }
    
    # proc setting of transmission by msg
    proc set:trans { nick host handle arg } {
		if { $::crelay::me(transmit) == "y" } {
			if { $arg == "" } {
				putquick "NOTICE $nick :you'd better try /msg $::botnick trans help"
			}
			if { [lindex [split $arg] 0] == "help" } {
				putquick "NOTICE $nick :usage is /msg $::botnick trans <value> on|off"
				putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
				return 0
			} else {
				switch [lindex [split $arg] 0] {
					"pub" { set type pubm }
					"act" { set type ctcp }
					"nick" { set type nick }
					"join" { set type join }
					"part" { set type part }
					"quit" { set type sign }
					"topic" { set type topc }
					"kick" { set type kick }
					"mode" { set type mode }
					"who" { set type who }
					default {
						putquick "NOTICE $nick :Bad mode. Try /msg $::botnick trans help"
						return 0
					}
				}
				set proc_change "[namespace current]::trans:[lindex [split $arg] 0]"
				set mod_change "[namespace current]::trans_[lindex [split $arg] 0]"
				if { [lindex [split $arg] 1] eq "on" } {
				   if { $type eq "mode" } {
				      bind raw - "MODE" [namespace current]::trans:mode
				   } else {
   					bind $type - * $proc_change
   			   }
					set ${mod_change} "y"
					putserv "NOTICE $nick :Transmission of [lindex [split $arg] 0] enabled"
				} elseif { [lindex [split $arg] 1] eq "off" } {
				   if { $type eq "mode" } {
				      unbind raw - "MODE" [namespace current]::trans:mode
				   } else {
   					unbind $type - * $proc_change
   				}
					set ${mod_change} "n"
					putserv "NOTICE $nick :Transmission of [lindex [split $arg] 0] disabled"
				} else {
					putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
				}
			}
		} else {
			putquick "NOTICE $nick :transmission is not activated, you can't change anything"
		}
		[namespace current]::save
    }
    
    # proc setting of reception by msg
    proc set:recv { nick host handle arg } {
		if { $::crelay::me(receive) == "y" } {
			if { $arg == "" } {
				putquick "NOTICE $nick :you'd better try /msg $::botnick recv help"
			}
			if { [lindex [split $arg] 0] == "help" } {
				putquick "NOTICE $nick :usage is /msg $::botnick recv <value> on|off"
				putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
				return 0
			} else {
				switch [lindex [split $arg] 0] {
					"pub" -
					"act" -
					"nick" -
					"join" -
					"part" -
					"quit" -
					"topic" -
					"kick" -
					"mode" -
					"who" { set type [lindex [split $arg] 0] }
					default {
						putquick "NOTICE $nick :Bad mode. Try /msg $::botnick recv help"
						return 0
					}
				}
				set change ">$type"
				set proc_change "[namespace current]::recv:$type"
				set mod_change "[namespace current]::recv_$type"
				if { [lindex [split $arg] 1] eq "on" } {
					bind bot - $change $proc_change
					set ${mod_change} "y"
					putserv "NOTICE $nick :Reception of $type enabled"
				} elseif { [lindex [split $arg] 1] == "off" } {
					unbind bot - $change $proc_change
					set ${mod_change} "n"
					putserv "NOTICE $nick :Reception of $type disabled"
				} else {
					putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
				}
			}
		} else {
			putquick "NOTICE $nick :reception is not activated, you can't change anything"
		}
		[namespace current]::save
    }
    
    # Generates an user@network name
    # based on nick and from bot
    proc make:user { nick frm_bot } {
		if {[string length $::crelay::hlnick] > 0 } {
			set ehlnick [string index $::crelay::hlnick 0]
		} else {
			set ehlnick ""
		}
	    array set him $::crelay::regg($frm_bot)
        if { $::crelay::me(snet) == "y" } {
            set speaker [concat "$::crelay::hlnick\($nick@$him(network)\)$ehlnick"]
        } else {
            set speaker $::crelay::hlnick$nick$ehlnick
        }
        return $speaker
    }
    
    # Logs virtual channel activity 
    proc cr:log { lev chan line } {
		if { $::crelay::me(log) == "y" } {
		    putloglev $lev "$chan" "$line"
    	}
        return 0
    }
    
    # Global transmit procedure
    proc trans:bot { usercmd chan usernick text } {
      set transmsg [concat $usercmd $usernick $text]
		set ::crelay::eob 0
      if {$chan == $::crelay::me(chan)} {
            foreach bot [array names [namespace current]::regg] {
	            if {$bot != $::botnick && [islinked $bot]} {
                	putbot $bot $transmsg
					if {$usercmd == ">who" } { incr [namespace current]::eob }
            	}
            }
      } else {
            return 0
      }
    }

    # proc transmission of pub (trans_pub = y)
    proc trans:pub {nick uhost hand chan text} {
        if { [string tolower [lindex [split $text] 0]] == "!who" } { return 0; }
        [namespace current]::trans:bot ">pub" $chan $nick [join [split $text]]
    }
    
    # proc transmission of action (trans_act = y)
    proc trans:act {nick uhost hand chan key text} {
        set arg [concat $key $text]
        [namespace current]::trans:bot ">act" $chan $nick $arg
    }
    
    # proc transmission of nick changement
    proc trans:nick {nick uhost hand chan newnick} {
        [namespace current]::trans:bot ">nick" $chan $nick $newnick
    }
    
    # proc transmission of join
    proc trans:join {nick uhost hand chan} {
        [namespace current]::trans:bot ">join" $chan $chan $nick
    }
    
    # proc transmission of part
    proc trans:part {nick uhost hand chan text} {
        set arg [concat $chan $text]
        [namespace current]::trans:bot ">part" $chan $nick $arg
    }
    
    # proc transmission of quit
    proc trans:quit {nick host hand chan text} {
        [namespace current]::trans:bot ">quit" $chan $nick $text
    }
    
    # proc transmission of topic changement
    proc trans:topic {nick uhost hand chan topic} {
        set arg [concat $chan $topic]
        [namespace current]::trans:bot ">topic" $chan $nick $arg
    }
    
    # proc transmission of kick
    proc trans:kick {nick uhost hand chan victim reason} {
        set arg [concat $victim $chan $reason]
        [namespace current]::trans:bot ">kick" $chan $nick $arg
    }
    
    # proc transmission of mode changement
    proc trans:mode {from keyw text} {
      set nick [lindex [split $from !] 0]
      set chan [lindex [split $text] 0]
      set text [concat $nick $text]
        [namespace current]::trans:bot ">mode" $chan $nick $text
    }
    
    # proc transmission of "who command"
    proc trans:who {nick uhost handle chan args} {
        if { [join [lindex [split $args] 0]] != "" } {
            set netindex [lsearch -nocase $::crelay::networks [lindex [split $args] 0]]
            if { $netindex == -1 } {
                putserv "PRIVMSG $nick :$args est un réseau inconnu";
                return 0
            } else {
               set [namespace current]::eol 0
               set [namespace current]::bol 0
        			set [namespace current]::eob 1
                putbot [lindex $::crelay::eggdrops $netindex] ">who $nick"
            }
        } else {
			set [namespace current]::eol 0
			set [namespace current]::bol 0
            [namespace current]::trans:bot ">who" $chan $nick ""
        }
    }

    # proc reception of pub
    proc recv:pub {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :$speaker [join [lrange $argl 1 end]]"
            [namespace current]::cr:log p "$::crelay::me(chan)" "<[lindex $argl 0]> [join [lrange $argl 1 end]]"
        }
        return 0
    }
    
    # proc reception of action
    proc recv:act {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :* $speaker [join [lrange $argl 2 end]]"
            [namespace current]::cr:log p "$::crelay::me(chan)" "Action: [lindex $argl 0] [join [lrange $argl 2 end]]"
        }
        return 0
    }
    
    # proc reception of nick changement
    proc recv:nick {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker is now known as [join [lrange $argl 1 end]]"
            [namespace current]::cr:log j "$::crelay::me(chan)" "Nick change: [lindex $argl 0] -> [join [lrange $argl 1 end]]"
        }
        return 0
    }
    
    # proc reception of join
    proc recv:join {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 1] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :--> $speaker has joined channel [lindex $argl 0]"
            [namespace current]::cr:log j "$::crelay::me(chan)" "[lindex $argl 1] joined $::crelay::me(chan)."
        }
        return 0
    }
    
    # proc reception of part
    proc recv:part {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :<-- $speaker has left channel [lindex $argl 1] ([join [lrange $argl 2 end]])"
            [namespace current]::cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left $::crelay::me(chan) ([join [lrange $argl 2 end]])"
        }
        return 0
    }
    
    # proc reception of quit
    proc recv:quit {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :-//- $speaker has quit ([join [lrange $argl 1 end]])"
            [namespace current]::cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left irc: [join [lrange $argl 1 end]]"
        }
        return 0
    }
    
    # proc reception of topic changement
    proc recv:topic {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker changes topic of [lindex $argl 1] to '[join [lrange $argl 2 end]]'"
        }
        return 0
    }
    
    # proc reception of kick
    proc recv:kick {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 1] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker has been kicked from [lindex $argl 2] by [lindex $argl 0]: [join [lrange $argl 3 end]]"
            [namespace current]::cr:log k "$::crelay::me(chan)" "[lindex $argl 1] kicked from $::crelay::me(chan) by [lindex $argl 0]:[join [lrange $argl 3 end]]"
        }
        return 0
    }
    
    # proc reception of mode changement
    proc recv:mode {frm_bot command arg} {
        if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
            set argl [split $arg]
            set speaker [[namespace current]::make:user [lindex $argl 1] $frm_bot]
            putquick "PRIVMSG $::crelay::me(chan) :*** $speaker set mode [join [lrange $argl 2 end]]"
        }
        return 0
    }
    
    # reception of !who command
    proc recv:who {frm_bot command arg} {
        set nick $arg
        set ulist ""
        set cusr 0
		if {![botonchan $::crelay::me(chan)]} {
			putbot $frm_bot ">wholist $::crelay::me(chan) $nick eol"
			return 0
		}
        foreach user [chanlist $::crelay::me(chan)] {
            if { $user == $::botnick } { continue; }
            if { [isop $user $::crelay::me(chan)] == 1 } {
                set st "@"
            } elseif { [ishalfop $user $::crelay::me(chan)] == 1 } {
                set st "%"
            } elseif { [isvoice $user $::crelay::me(chan)] == 1 } {
                set st "%"
            } else {
                set st ""
            }
            incr cusr 1
            append ulist " $st$user"
            if { $cusr == 5 } {
                putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
                set ulist ""
                set cusr 0
            }
        }
        if { $ulist != "" } {
            putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
        }
		putbot $frm_bot ">wholist $::crelay::me(chan) $nick eol"
    }
    
    # Proc reception of a who list
    proc recv:wholist {frm_bot command arg} {
        set nick [join [lindex [split $arg] 1]]
        set speaker [[namespace current]::make:user $frm_bot $frm_bot]
		if {$::crelay::bol == 0} {
			incr [namespace current]::bol
			putserv "NOTICE $nick :*** $::crelay::userlist(beg)"
		}
		if { [join [lrange [split $arg] 2 end]] == "eol"} {
			incr [namespace current]::eol
			if {$::crelay::eol == $::crelay::eob} {
				putserv "NOTICE $nick :*** $::crelay::userlist(end)"
			}
		} else {
 			putserv "NOTICE $nick :$speaker [join [lrange [split $arg] 2 end]]"
		}
    }
	
    ######################################
    # Private messaging
    #
    
    bind msg - "say" [namespace current]::prv:say_send
    proc prv:say_send {nick uhost handle text} {
	    if {[lsearch [package names] "MDS"] >= 0 } {
	    	[namespace current]::priv_sendmsg $nick $uhost $handle $text
	    	return 0
    	}
        set dest [join [lindex [split $text] 0]]
        set msg [join [lrange [split $text] 1 end]]
        set vict [join [lindex [split $dest @] 0]]
        set net [join [lindex [split $dest @] 1]]
        if { $vict == "" || $net == "" } {
            putserv "PRIVMSG $nick :Use \002say user@network your message to \037user\037\002";
            return 0
        }
        set him [lsearch -nocase $::crelay::networks $net]
        if { $him == -1 } {
            putserv "PRIVMSG $nick :I don't know any network called $net.";
			putserv "PRIVMSG $nick :Available networks: [join [split $::crelay::networks]]"
            return 0
        }
        if { [string length $msg] == 0 } {
            putserv "PRIVMSG $nick :Did you forget your message to $vict@$net ?";
            return 0
        }
        putbot [lindex $::crelay::eggdrops $him] ">pvmsg $vict $nick@$::crelay::me(network) $msg"
    }
    
    bind bot - ">pvmsg" [namespace current]::prv:say_get
    proc prv:say_get {frm_bot command arg} {
        set dest [join [lindex [split $arg] 0]]
        set from [join [lindex [split $arg] 1]]
        set msg [join [lrange [split $arg] 2 end]]
        if { [onchan $dest $::crelay::me(chan)] == 1 } {
            putserv "PRIVMSG $dest :$from: $msg"
        }
    }

    # Addition of MDS interception
    proc priv_sendmsg {nick host hand text} {
	    [namespace current]::pub_sendmsg $nick $host $hand $::crelay::me(chan) $text
    }
    
    proc pub_sendmsg {nick host hand chan arg} {
    	set dest [join [lindex [split $arg] 0]]
        set vict [join [lindex [split $dest @] 0]]
        set net [join [lindex [split $dest @] 1]]
        set msg [join [lrange [split $arg] 1 end]]
        if { $vict == "" } {
            putserv "PRIVMSG $nick :Use \002$MDS::pub_msg_cmd user[@network] your message to \037user\037\002";
            putserv "PRIVMSG $nick :If network is not filled, all networks will receive it";
            return 0
        }
        if { [string length $msg] == 0 } {
            putserv "PRIVMSG $nick :Did you forget your message to $vict@$net ?";
            return 0
        }
        if { ($net eq "") || ([lsearch -nocase $::crelay::networks $net] == -1)} {
	        putallbots ">mds $vict $nick@$::crelay::me(network) $msg"
	        send_msg_to dest $vict "crelay" $msg
        } else {
        	set him [lsearch -nocase $::crelay::networks $net]
        	if {[lindex $::crelay::eggdrops $him] eq $::username} {
	        	send_msg_to dest $vict "crelay" $msg
    		} else {
				putbot [lindex $::crelay::eggdrops $him] ">mds $vict $nick@$::crelay::me(network) $msg"
			}
        }
        return 0
	}
	
	proc recv:mds {frm_bot command arg} {
		set dest [join [lindex [split $arg] 0]]
		set from [join [lindex [split $arg] 1]]
		set msg [join [lrange [split $arg] 2 end]]
		if { [onchan $dest $::crelay::me(chan)] == 1 } {
			putserv "PRIVMSG $dest :$from: $msg"
		} else {
			send_msg_to dest "crelay" $msg
		}
	}
    
    ######################################
    # proc for helping
    #
    
    # proc status
    proc help:status { nick host handle arg } {
	putquick "PRIVMSG $nick :Chanrelay status for $::crelay::me(chan)@$crelay::me(network)"
	putquick "PRIVMSG $nick :\002 Global status\002"
	putquick "PRIVMSG $nick :\037type\037   -- | trans -|- recept |"
	putquick "PRIVMSG $nick :global -- | -- $::crelay::me(transmit) -- | -- $::crelay::me(receive) -- |"
	putquick "PRIVMSG $nick :pub    -- | -- $::crelay::trans_pub -- | -- $::crelay::recv_pub -- |"
	putquick "PRIVMSG $nick :act    -- | -- $::crelay::trans_act -- | -- $::crelay::recv_act -- |"
	putquick "PRIVMSG $nick :nick   -- | -- $::crelay::trans_nick -- | -- $::crelay::recv_nick -- |"
	putquick "PRIVMSG $nick :join   -- | -- $::crelay::trans_join -- | -- $::crelay::recv_join -- |"
	putquick "PRIVMSG $nick :part   -- | -- $::crelay::trans_part -- | -- $::crelay::recv_part -- |"
	putquick "PRIVMSG $nick :quit   -- | -- $::crelay::trans_quit -- | -- $::crelay::recv_quit -- |"
	putquick "PRIVMSG $nick :topic  -- | -- $::crelay::trans_topic -- | -- $::crelay::recv_topic -- |"
	putquick "PRIVMSG $nick :kick   -- | -- $::crelay::trans_kick -- | -- $::crelay::recv_kick -- |"
	putquick "PRIVMSG $nick :mode   -- | -- $::crelay::trans_mode -- | -- $::crelay::recv_mode -- |"
	putquick "PRIVMSG $nick :who   -- | -- $::crelay::trans_who -- | -- $::crelay::recv_who -- |"
	putquick "PRIVMSG $nick :nicks appears as $::crelay::hlnick$nick$::crelay::hlnick"
	putquick "PRIVMSG $nick :\002 END of STATUS"
    }
        
    # proc help
    proc help:cmds { nick host handle arg } {
	putquick "NOTICE $nick :/msg $::botnick trans <type> on|off to change the transmissions"
	putquick "NOTICE $nick :/msg $::botnick recv <type> on|off to change the receptions"
	putquick "NOTICE $nick :/msg $::botnick rc.status to see my actual status"
	putquick "NOTICE $nick :/msg $::botnick rc.help for this help"
	putquick "NOTICE $nick :/msg $::botnick rc.light <bo|un|off> to bold, underline or no higlight"
	putquick "NOTICE $nick :/msg $::botnick rc.net <yes|no> to show the network"
    }
    
}

::crelay::init

putlog "CHANRELAY $::crelay::version by \002$::crelay::author\002 loaded - http://www.eggdrop.fr"
