#-----------------------------------------------------------------------------------------------------------------
#
# Trigger.Machine.V2.0.EGGDROP.TCL-ALG0RiTHM
#

#-----------------------------------------------------------------------------------------------------------------
# DESCRIPTION:
#
# - provides custom triggers per channel with custom reply.
#   reply methods can be: public, private, notice
# - provides custom onjoin notice per channel
# - provides three access levels per trigger; all, voice, op
#

#-----------------------------------------------------------------------------------------------------------------
# SYNTAX:
#
# <trigger>
#        shows info specified by you for this particular trigger in the right channel
# <trigger> <nick>
#        shows info specified by you for this particular trigger to <nick>
#

#-----------------------------------------------------------------------------------------------------------------
# VERSION HISTORY:
#
# 1.00 - initial release
# 2.00 - added deinit function to cleanup namespace environment before rehash
#      - it is now possible to load this script multiple times in the same eggdrop, providing the filename is not
#      the same of course. the configs for each script can be treated as if there is no script loaded previously
#      all the configs are checked for consistency and merged behind the scenes at load time. This gives the 
#      user the flexibility to split several configs into different files, which makes it easier to maintain in
#      the long run.
#      - added option for triggers that respond in pm or notice to mention in channel that a user is being queried
#      and when the query is finished.

#-----------------------------------------------------------------------------------------------------------------

#set triggermvar(trigger,0) "{trigger,trigger} {channelnumber,channelnumber} {responsenumber} {pub|priv|notc} {all|voice|op}"
#example: set triggermvar(trigger,0) "{!h,!help} {0,1} {0} {pub} {all}"
set triggermvar(trigger,0) "{!listing} {0} {0} {notc} {all}"
set triggermvar(trigger,1) "{!pass} {1} {1} {pub} {all}"
set triggermvar(trigger,2) "{!sites} {1} {2} {pub} {all}"
set triggermvar(trigger,3) "{!rules} {0} {3} {priv} {all}"
set triggermvar(trigger,4) "{!xdcc} {1,0} {4} {priv} {all}"
set triggermvar(trigger,5) "{!cmds} {0} {5} {pub} {all}"
set triggermvar(trigger,6) "{!cmds} {1} {6} {pub} {all}"
set triggermvar(trigger,7) "{!cmds} {2} {7} {pub} {all}"
set triggermvar(trigger,8) "{!cmds} {3} {8} {pub} {all}"
set triggermvar(trigger,9) "{!cmds} {5} {9} {pub} {all}"
set triggermvar(trigger,10) "{!cmds} {4} {10} {pub} {all}"
set triggermvar(trigger,11) "{!cmds} {6} {11} {pub} {all}"
set triggermvar(trigger,12) "{!chans} {1} {12} {priv} {all}"
set triggermvar(trigger,13) "{!chans} {0} {13} {priv} {all}"
set triggermvar(trigger,14) "{!nfo} {0} {14} {pub} {all}"
set triggermvar(trigger,15) "{!don} {0} {15} {pub} {all}"

#-----------------------------------------------------------------------------------------------------------------
#set triggermvar(channel,0) "{channelname}"
set triggermvar(channel,0) "{#lechan1}"
set triggermvar(channel,1) "{#lechan2}"
set triggermvar(channel,2) "{#lechan3}"
set triggermvar(channel,3) "{#lechan4}"
set triggermvar(channel,4) "{#lechan5}"
set triggermvar(channel,5) "{#lechan6}"
set triggermvar(channel,6) "{#lechan7}"

#-----------------------------------------------------------------------------------------------------------------
#set triggermvar(onjoin,0) "{channel} {delay} {msg}"
#to disable leave the first: set triggermvar(onjoin,0) "{} {} {}"
#set triggermvar(onjoin,0) "{#ViP} {5} {Bienvenue sur #ViP. Commandes: !cmds !xdcc !listing}"
#set triggermvar(onjoin,1) "{#Hella} {5} {Bienvenue sur #Hella. Tapes !cmds pour tous les commandes dispo}"

#-----------------------------------------------------------------------------------------------------------------
#set triggermvar(info,0) "{info info info} {and some more info} {and finally some more info}"
set triggermvar(info,0) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,1) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,2) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,3) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,4) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,5) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,6) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,7) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,8) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,9) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,10) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,11) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,12) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,13) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,14) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"
set triggermvar(info,15) "
{ce que l'on veut afficher ligne 1}
{ce que l'on veut afficher ligne 2}
{ce que l'on veut afficher ligne etc}
"

#-----------------------------------------------------------------------------------------------------------------
# set triggermvar(alertinchan) 2
# set to 0 to disable
# set to 1 to enable: Sending infos to <nick> ...
# set to 2 to enable: Finished sending infos to <nick>
# set to 3 to enable both messages
set triggermvar(alertinchan) 1



# config finished - don't change anything below this line
#-----------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------
# main a0m namespace
namespace eval ::a0m:: {
	namespace export readconflist
	namespace export isconsecutive
	namespace export lremove
	namespace export stripcodes
	namespace export reindex
	namespace export relist
}

#-----------------------------------------------------------------------------------------------------------------
# return configs in list form - $arrayname(targetlist,*)
proc ::a0m::readconflist {targetlist arrayname} {
	upvar 1 $arrayname ar
	set thelist ""
	set finallist ""
	foreach v [array names ar] {
		if [string match "$targetlist" $v] {
			lappend thelist $v
		}
	}
	set presort [lsort -dictionary $thelist]
	for {set itterate 0} {$itterate < [llength $presort]} {incr itterate} {
		lappend finallist $ar([lindex $presort $itterate])
	}
	return $finallist
}

# returns 1 if the arraylist is consecutive, 0 if not, inconsistency is returned as second arg
proc ::a0m::isconsecutive {targetlist arrayname} {
	set result 1
	upvar 1 $arrayname ar
	set presort [lsort -dictionary [array names ar "$targetlist"]]
	for {set itterate 0} {$itterate < [llength $presort]} {incr itterate} {
		set listID [lindex [split [lindex $presort $itterate] ","] 1]
		if {$listID != $itterate} {
			set result [list 0 "$arrayname\([regsub -all {(\*)} $targetlist $listID]\)"]
			break
		}
	}
	return $result
}

# removes listitem from thelist
proc ::a0m::lremove {listitem thelist} {return [lsearch -not -inline -all $thelist $listitem]}

# strips color codes
proc ::a0m::stripcodes {text} {regsub -all {([\002\017\026\037]|[\003]{1}[0-9]{0,2})} $text {} text; return $text}

# counts shift with each number from the given numlist
proc ::a0m::reindex {numlist shift} {
	set result ""
	foreach number $numlist {
		lappend result [expr $number + $shift]	
	}
	return $result
}

# puts a list back into a config list with , as delimiter
proc ::a0m::relist {itemlist} {
	set result [join $itemlist]
	regsub -all { } $result {,} result
	return $result
}

#-----------------------------------------------------------------------------------------------------------------
# namespace for the script
namespace eval ::a0m::triggermachine:: {
	variable triggermvar
	# load global configs in tmp array
	array set tmptriggermvar [array get ::triggermvar]
	array unset ::triggermvar
	# check consistency first
	set checkconfigs "{trigger} {channel} {info} {onjoin}"
	set ok 1
	foreach conflist $checkconfigs {
		set consecutive [::a0m::isconsecutive "$conflist,*" "tmptriggermvar"]
		if {$consecutive != 1} {
			putlog "\[Error loading triggermachine\] config inconsistency found at: [regsub {tmptriggermvar} [lindex $consecutive 1] {triggermvar}]"
			namespace delete [namespace current]
			set ok 0
			break
		} else {
			foreach conflist $checkconfigs {
				set tmptriggermvar(${conflist}list) [::a0m::readconflist "$conflist,*" "tmptriggermvar"]
			}
		}
	}
	if {$ok == 1} {
		# append alert infos to triggerlist
		for {set itterate 0} {$itterate < [llength $tmptriggermvar(triggerlist)]} {incr itterate} {
			if {[lindex $tmptriggermvar(triggerlist) $itterate 3] == "pub"} {
				lset tmptriggermvar(triggerlist) $itterate [linsert [lindex $tmptriggermvar(triggerlist) $itterate] end 0]
			} else {
				lset tmptriggermvar(triggerlist) $itterate [linsert [lindex $tmptriggermvar(triggerlist) $itterate] end $tmptriggermvar(alertinchan)]
			}
		}
		# now we find out if we should merge with another existing array or if we should init first time
		if {[array size ::a0m::triggermachine::triggermvar] != 0} {
			# merge global with existing
			foreach triggeritem $tmptriggermvar(triggerlist) {
				set newline $triggeritem
				lset newline 1 [::a0m::relist [::a0m::reindex [split [lindex $triggeritem 1] ","] [llength $triggermvar(channellist)]]]
				lset newline 2 [::a0m::relist [::a0m::reindex [split [lindex $triggeritem 2] ","] [llength $triggermvar(infolist)]]]
				lappend triggermvar(triggerlist) $newline
			}
			foreach channelitem $tmptriggermvar(channellist) {
				lappend triggermvar(channellist) $channelitem
			}
			foreach infoitem $tmptriggermvar(infolist) {
				lappend triggermvar(infolist) $infoitem
			}
			foreach onjoinitem $tmptriggermvar(onjoinlist) {
				lappend triggermvar(onjoinlist) $onjoinitem
			}
			set triggermvar(alertinchan) $tmptriggermvar(alertinchan)
		} else {
			# load global as new
			array set triggermvar [array get tmptriggermvar]
		}
		foreach trigger $tmptriggermvar(triggerlist) {
			foreach foundbind [split [lindex $trigger 0] ","] {
				bind pub -|- $foundbind [namespace code ::a0m::triggermachine::triggerhandler]
			}
		}
		bind evnt - prerehash [namespace code ::a0m::triggermachine::deinit]
		# onjoinqueue
		set triggermvar(onjoinqueue) ""
		bind join - * [namespace code ::a0m::triggermachine::onjoin]
		array unset tmptriggermvar
	}
}

# deinit function to cleanup before rehash
proc ::a0m::triggermachine::deinit {args} {
	variable triggermvar
	foreach foundbind [binds *::a0m::triggermachine*] {
		catch {unbind [lindex [split $foundbind] 0] [lindex [split $foundbind] 1] [lindex [split $foundbind] 2] [join [lrange $foundbind 4 end]]} fid
	}
	foreach timerfound [timers] {
		catch {[killtimer [lindex $timerfound 2]]} fid	
	}
	foreach utimerfound [utimers] {
		catch {[killutimer [lindex $utimerfound 2]]} fid	
	}
	catch {array unset triggermvar} fid
	catch {namespace delete [namespace current]} fid
}

proc ::a0m::triggermachine::output {responsenumber who method} {
	variable triggermvar
	set convmethod "pub"
	switch $method {
		"pub"	{set convmethod "PRIVMSG"}
		"priv"	{set convmethod "PRIVMSG"}
		"notc"	{set convmethod "NOTICE"}
	}
	foreach respondline [lindex $triggermvar(infolist) $responsenumber] {
		putquick "$convmethod $who :\00399$respondline"
	}
}

proc ::a0m::triggermachine::triggerhandler {nick uhost hand chan text} {
	variable triggermvar
	set text [::a0m::stripcodes $text]
	foreach trigger $triggermvar(triggerlist) {
		if {[lsearch [split [lindex $trigger 0] ","] $::lastbind] != -1} {
			# trigger found now check if channel is correct and if so respond
			foreach chanfound [split [lindex $trigger 1] ","] {
				if {$chan == [lindex [lindex $triggermvar(channellist) $chanfound] 0]} {
					# now respond with correct infos
					if {$text != "" && [onchan [lindex $text 0] $chan]} {
						if {[checkuserstatus $nick [lindex $trigger 4]]} {
							if {$triggermvar(alertinchan) == 1 || $triggermvar(alertinchan) == 3} {
								putquick "PRIVMSG $chan :\00399Sending infos to [lindex $text 0] ..."
							}
							::a0m::triggermachine::output [lindex $trigger 2] [lindex $text 0] [lindex $trigger 3]
							if {$triggermvar(alertinchan) == 2 || $triggermvar(alertinchan) == 3} {
								putquick "PRIVMSG $chan :\00399Finished sending infos to [lindex $text 0]"
							}
						}
					} elseif {$text != "" && ![onchan [lindex $text 0] $chan]} {
						if {[checkuserstatus $nick [lindex $trigger 4]]} {
							putquick "PRIVMSG $chan :\00399[lindex $text 0] is not in this channel, get some glasses!"
						}
					} else {
						if {[checkuserstatus $nick [lindex $trigger 4]]} {
							set who $chan
							switch [lindex $trigger 3] {
								"pub"	{set who $chan}
								"priv"	{set who $nick}
								"notc"	{set who $nick}
							}
							if {[llength $trigger] == 6 && $triggermvar(alertinchan) != 0} {
								if {[lindex $trigger 5] == 1 || [lindex $trigger 5] == 3} {
								}
							}
							::a0m::triggermachine::output [lindex $trigger 2] $who [lindex $trigger 3]
							if {[llength $trigger] == 6 && $triggermvar(alertinchan) != 0} {
								if {[lindex $trigger 5] == 2 || [lindex $trigger 5] == 3} {
								}
							}
						}
					}
					break
				}
			}
		}
	}
}

proc ::a0m::triggermachine::onjoin {nick uhost hand chan} {
	variable triggermvar
	#check if the channel is in the list
	if {$nick != $::botnick} {
		set chanpos [chanexists $chan]
		if {$chanpos != -1} {
			lappend triggermvar(onjoinqueue) [list $nick $chan [lindex [lindex $triggermvar(onjoinlist) $chanpos] 2]]
			utimer [lindex [lindex $triggermvar(onjoinlist) $chanpos] 1] ::a0m::triggermachine::greetonjoin
		}
	}
}

proc ::a0m::triggermachine::greetonjoin {} {
	variable triggermvar
	putquick "NOTICE [lindex [lindex $triggermvar(onjoinqueue) 0 ] 0] :\00399[lindex [lindex $triggermvar(onjoinqueue) 0] 2]"
	set triggermvar(onjoinqueue) [::a0m::lremove [lindex $triggermvar(onjoinqueue) 0] $triggermvar(onjoinqueue)]
}

#return 1 if nick has the correct status, 0 if not
proc ::a0m::triggermachine::checkuserstatus {nick status} {
	set result 0
	switch $status {
		"all" {
			set result 1
		}
		"voice" {
			if {[isop $nick] || [isvoice $nick]} {set result 1}
		}
		"op" {
			if {[isop $nick]} {set result 1}
		}
	}
	return $result
}

proc ::a0m::triggermachine::chanexists {chan} {
	variable triggermvar
	set channelfound -1; set counter 0
	foreach channel $triggermvar(onjoinlist) {
		if {[string tolower [lindex $channel 0]] == [string tolower $chan]} {
			set channelfound $counter
		} else {
			incr counter
		}
	}
	return $channelfound
}

#-----------------------------------------------------------------------------------------------------------------
putlog "Trigger.TCL-ALG0RiTHM chargé"