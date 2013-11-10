# SCRIPT INFORMATION
# This script allows users to check the status of their SABnzbd
# in the specified IRC channels.
#
# Currently there are 8 commands (4 can be done by anyone, 4 require you to be set in the config):
# ANYONE
# !sab stats - Gives a quick breakdown current status"
# !sab queue [n] - Shows current items in queue. Default is 3. Specify n to show more or less
# !sab version - Shows current version of SABnzbd and also this script
# !sab help - Shows usage information
# !sab add <URL/Newzbin ID> - Adds a URL or Newzbin ID to SABnzbd
# !sab speed <Speed in KB/s (0 to remove limit)> - Sets the speedlimit in SABnzbd
# !sab pause - Pauses SABnzbd
# !sab resume - Resumes SABnzbd
# 
# Omgwtfnzbs
# !efn add <ID> <section> - add Omgwtfnzbs ID to SABnzbd / Ajoute une ID Omgwtfnzbs à SABnzbd
#
# This is the first ever TCL script I have written so if you have any
# suggestions as too how it can be improved or find any bugs contact me on
# Efnet nick: dr0pknutz
# modify by nice92
# REQUIREMENTS:
#
# TCL HTTP package is required.
# tDOM - Can be found here http://www.tdom.org/#SECTid0x80bd158
# zlib - Is only required if you want TVBINZ support. Available here: http://pascal.scheffers.net/software/zlib-1.1.1.tar.bz2

package require http
package require tdom

# CONFIGURATION
set sabnzbd(username) ""
set sabnzbd(password) ""
set sabnzbd(key) ""
set sabnzbd(host) ""
set sabnzbd(port) ""
set sabnzbd(chans) ""
set sabnzbd(nicks) ""
set sab(username) ""
set sab(password) ""
set sab(key) ""
set sab(host) ""
set sab(port) ""
set sab(chans) ""
set sab(nicks) ""
set sab(omgwtfnzbs) ""
set sab(omgname) ""
set sab(omg) ""
set sabnzbd(omgwtfnzbs) ""
set sabnzbd(omgname) ""
set sabnzbd(omg) ""
# END CONFIGURATION

bind pub - !sab asgardTrigger
bind pub - !sab2 cronosTrigger

if {$sab(omgwtfnzbs) == "true"} {
	bind pub - !omg2 omgwtfnzbsTrigger
}
if {$sabnzbd(omgwtfnzbs) == "true"} {
	bind pub - !omg omgTrigger
}
set sab(version) "0.6"

proc asgardTrigger { nick host hand chan arg } {
	global sabnzbd
	global sab
	set sabUserPass ""
	if {($sabnzbd(username) != "") && ($sabnzbd(password) != "")} {
		set sabUserPass "&ma_username=$sabnzbd(username)&ma_password=$sabnzbd(password)"
	}
	if {([lsearch -exact $sabnzbd(chans) $chan] == -1)} { return }    
	set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=queue&start=START&limit=LIMIT&output=xml&apikey=$sabnzbd(key)"

	if {($arg == "stats")} {
		set queueStatus [http::data [http::geturl $url]]
		set doc [dom parse $queueStatus]
		set root [$doc documentElement]
		set paused [[$root selectNodes /queue/paused/text()] data]
		if {$paused == "True"} {
			set speed "Paused"
		} else {
			set speed "[format "%.2f" [[$root selectNodes /queue/kbpersec/text()] data]]KB/s"
		}
		set mb [format "%.2f" [[$root selectNodes /queue/mb/text()] data]]
		set mbleft [format "%.2f" [[$root selectNodes /queue/mbleft/text()] data]]
		set noinq [[$root selectNodes /queue/noofslots/text()] data]
		set time [[$root selectNodes /queue/timeleft/text()] data]
		set jobs [llength [$root selectNodes /queue/slots/slot]]
		if {($jobs != 0)} {
			set firstJobNode [lindex [$root selectNodes /queue/slots/slot] 0]
			set curFileName [[$firstJobNode selectNodes filename/text()] data]
			set curCat [[$firstJobNode selectNodes cat/text()] data]
			set curMb [format "%.2f" [[$firstJobNode selectNodes mb/text()] data]]
			set curMbLeft [format "%.2f" [[$firstJobNode selectNodes mbleft/text()] data]]
			set curMbDone [format "%.2f" [expr $curMb - $curMbLeft]]
			set curPercent [format "%.2f" [expr [expr $curMbDone / $curMb] * 100]]
			set currentJob "$curFileName - \00307Cat:\017 $curCat - (${curMbDone}MB/${curMb}MB) - ${curPercent}%"
		} else {
			set currentJob "Aucun fichier"
		}
		putserv "PRIVMSG $chan :\00307(\017Asgard\00307)\017 \00307Fichier:\017 \003$currentJob"
		putserv "PRIVMSG $chan :\00307(\017Asgard\00307)\017 \00307Vitesse:\017 \003\[$speed\] \00307Temps Restant:\017\003 $time \00307En Attente:\017\003 ${mbleft}Mo/${mb}Mo ($noinq fichier(s))"
	} elseif {([lindex $arg 0] == "queue")} {
		set queueStatus [http::data [http::geturl $url]]
		set doc [dom parse $queueStatus]
		set root [$doc documentElement]
		set jobs [$root selectNodes /queue/slots/slot]
		if {([lindex $arg 1] != "") && ([string is integer -strict [lindex $arg 1]])} { 
			set noDisplay [lindex $arg 1] 
			if [expr [lindex $arg 1] > 10] { set noDisplay 10 }
		} else {
			set noDisplay 3
	    }
		if {([llength $jobs] != 0)} {
			if {([llength $jobs] < $noDisplay)} { 
				set showing [llength $jobs]
			} else { set showing $noDisplay }
			set mb [format "%.2f" [[$root selectNodes /queue/mb/text()] data]]
			set mbleft [format "%.2f" [[$root selectNodes /queue/mbleft/text()] data]]
			set noinq [[$root selectNodes /queue/noofslots/text()] data]
			putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003\[En Attente] \002\[${mbleft}MB/${mb}MB ($noinq fichier(s))\]\002 \[Affichage]\002\[$showing\]\002"
			foreach x $jobs {
				incr item
				set fname [[$x selectNodes filename/text()] data]
                            set curCat [[$x selectNodes cat/text()] data]
				set mb [format "%.2f" [[$x selectNodes mb/text()] data]]
				set mbleft [format "%.2f" [[$x selectNodes mbleft/text()] data]]
				putserv "PRIVMSG $chan :\002\00307Fichier\003 $item:\002\017 $fname - \00307Restant:\017 ${mbleft} MB/${mb} MB - \00307Cat:\017 $curCat"
				if {($item >= $noDisplay)} { return }
			}
		} else {
			putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003~ Rien en attente"
		}		
    } elseif {([lindex $arg 0] == "add")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003 Vous n'êtes pas autorisé à ça"
			return
		}   
		if {([llength $arg] <= 1)} {
			putserv "NOTICE $nick :Usage: !sab add <URL>"
		} else {		
			if {([string is integer -strict [lindex $arg 1]])} {
				set sabnzbd(cat) "[lindex $arg 2]"
				set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=addurl&name=[lindex $arg 1]$sabUserPass&apikey=$sabnzbd(key)&cat=$sabnzbd(cat)"
				set returnMess [http::data [http::geturl $url]]
			} else {
				if {![regexp {^http.+} [lindex $arg 1]]} { 
					putserv "PRIVMSG $chan :\00304\002\[Asgard\]\002\003 URL non valide. Dans le type de: http://example.com/example.nzb"
					return
				}
				set urlEncode [http::formatQuery mode addurl name [lindex $arg 1] cat $sabnzbd(cat) apikey $sabnzbd(key)]
				set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
				set returnMess [http::data [http::geturl $url -query $urlEncode]]
			}
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Nzb rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Nzb non rajouté" 
			}
		}
	} elseif {([lindex $arg 0] == "pause")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=pause$sabUserPass&apikey=sabnzbd(key)"
		set returnMess [http::data [http::geturl $url]]
		if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003En pause"
		} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Pause non effective" 
		}
	} elseif {([lindex $arg 0] == "resume")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=resume$sabUserPass&apikey=$sabnzbd(key)"
		set returnMess [http::data [http::geturl $url]]
		if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Pause enlevée"
		} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Téléchargement non repris pour une raison inconnue" 
		}
	} elseif {([lindex $arg 0] == "version")} {
		set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=version&output=xml$sabUserPass&apikey=$sabnzbd(key)"
		set version [http::data [http::geturl $url]]
		set doc [dom parse $version]
		set root [$doc documentElement]
		set version [[$root selectNodes /versions/version/text()] data]
		putserv "PRIVMSG $chan :\00307\002\[SABnzbd\]\002\003 Script Version:\002\[$sabnzbd(version)\]\002 SABnzbd Version:\002\[$version\]\002" 
	} elseif {([lindex $arg 0] == "speed")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		if {([lindex $arg 1] != "") && ([string is integer -strict [lindex $arg 1]])} {
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=speedlimit&value=[lindex $arg 1]$sabUserPass&apikey=$sabnzbd(key)"
			set returnMess [http::data [http::geturl $url]]
			if { [string compare $returnMess "ok"] != 0 } {
				if {([lindex $arg 1] == 0)} {
					putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Limite de vitesse enlevée"
				} else {
					putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003Limite de vitesse à [lindex $arg 1]KB/s"
				}
			} else {
				putserv "PRIVMSG $chan :\002\[Asgard\]\002 \003La limite de vitesse n'a pas été changée pour une raison inconnue" 
			}		
		} else {
			putserv "NOTICE $nick :Usage: !sab speedlimit <Speed in KB/s>"
		}
	} elseif {([lindex $arg 0] == "help")} {
		putserv "NOTICE $nick :\00307\002\[SABnzbd Asgard Usage\]\002"
		putserv "NOTICE $nick :\00307\002\!sab stats\002 - Donne les infos sur le status de SABnzbd"
		putserv "NOTICE $nick :\00314\002\!sab queue \[n\]\002 - Montre les fichiers en attente. Par défaut 3. Spécifiez n pour plus ou moins de résultats"
		putserv "NOTICE $nick :\00314\002\!sab version\002 - Montre la version actuelle de SABnzbd et ses scripts"
		if {([lsearch -exact $sabnzbd(nicks) $nick] != -1)} { 
			putserv "NOTICE $nick :\00307\002\!sab add <URL>\002 - Ajoutez une URL à SABnzbd"
			putserv "NOTICE $nick :\00314\002\!sab speed <Speed in KB/s>\002 - Ajustez la limite de vitesse de SABnzbd"
			putserv "NOTICE $nick :\00314\002\!sab pause\002 - Mettre en pause SABnzbd"
			putserv "NOTICE $nick :\00314\002\!sab resume\002 - Reprendre le téléchargement sur SABnzbd"
		}
	} else {
		putserv "PRIVMSG $chan :\00307\002\[\003Asgard\00307]\002 \003 Tapes \"!sab help\" pour plus d'information"
	}
}

proc cronosTrigger { nick host hand chan arg } {
	global sabnzbd
	global sab
	set sabUserPass ""
	if {($sab(username) != "") && ($sab(password) != "")} {
		set sabUserPass "&ma_username=$sab(username)&ma_password=$sab(password)"
	}
	if {([lsearch -exact $sab(chans) $chan] == -1)} { return }    
	set url "http://$sab(host):$sab(port)/sabnzbd/api?mode=queue&start=START&limit=LIMIT&output=xml&apikey=$sab(key)"

	if {($arg == "stats")} {
		set queueStatus [http::data [http::geturl $url]]
		set doc [dom parse $queueStatus]
		set root [$doc documentElement]
		set paused [[$root selectNodes /queue/paused/text()] data]
		if {$paused == "True"} {
			set speed "Paused"
		} else {
			set speed "[format "%.2f" [[$root selectNodes /queue/kbpersec/text()] data]]KB/s"
		}
		set mb [format "%.2f" [[$root selectNodes /queue/mb/text()] data]]
		set mbleft [format "%.2f" [[$root selectNodes /queue/mbleft/text()] data]]
		set noinq [[$root selectNodes /queue/noofslots/text()] data]
		set time [[$root selectNodes /queue/timeleft/text()] data]
		set jobs [llength [$root selectNodes /queue/slots/slot]]
		if {($jobs != 0)} {
			set firstJobNode [lindex [$root selectNodes /queue/slots/slot] 0]
			set curFileName [[$firstJobNode selectNodes filename/text()] data]
			set curCat [[$firstJobNode selectNodes cat/text()] data]
			set curMb [format "%.2f" [[$firstJobNode selectNodes mb/text()] data]]
			set curMbLeft [format "%.2f" [[$firstJobNode selectNodes mbleft/text()] data]]
			set curMbDone [format "%.2f" [expr $curMb - $curMbLeft]]
			set curPercent [format "%.2f" [expr [expr $curMbDone / $curMb] * 100]]
			set currentJob "$curFileName - \00307Cat:\017 $curCat - (${curMbDone}MB/${curMb}MB) - ${curPercent}%"
		} else {
			set currentJob "Aucun fichier"
		}
		putserv "PRIVMSG $chan :\00307(\017Cronos\00307)\017 | \00307Fichier:\017 \003$currentJob"
		putserv "PRIVMSG $chan :\00307(\017Cronos\00307)\017 | \00307Vitesse:\017 \003\[$speed\] \00307Temps Restant:\017\003 $time \00307En Attente:\017\003 ${mbleft}Mo/${mb}Mo ($noinq fichier(s))"
	} elseif {([lindex $arg 0] == "queue")} {
		set queueStatus [http::data [http::geturl $url]]
		set doc [dom parse $queueStatus]
		set root [$doc documentElement]
		set jobs [$root selectNodes /queue/slots/slot]
		if {([lindex $arg 1] != "") && ([string is integer -strict [lindex $arg 1]])} { 
			set noDisplay [lindex $arg 1] 
			if [expr [lindex $arg 1] > 10] { set noDisplay 10 }
		} else {
			set noDisplay 3
	    }
		if {([llength $jobs] != 0)} {
			if {([llength $jobs] < $noDisplay)} { 
				set showing [llength $jobs]
			} else { set showing $noDisplay }
			set mb [format "%.2f" [[$root selectNodes /queue/mb/text()] data]]
			set mbleft [format "%.2f" [[$root selectNodes /queue/mbleft/text()] data]]
			set noinq [[$root selectNodes /queue/noofslots/text()] data]
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003\[En Attente] \002\[${mbleft}MB/${mb}MB ($noinq fichier(s))\]\002 \[Affichage]\002\[$showing\]\002"
			foreach x $jobs {
				incr item
				set fname [[$x selectNodes filename/text()] data]
                            set curCat [[$x selectNodes cat/text()] data]
				set mb [format "%.2f" [[$x selectNodes mb/text()] data]]
				set mbleft [format "%.2f" [[$x selectNodes mbleft/text()] data]]
				putserv "PRIVMSG $chan :\002\00307Fichier\003 $item:\002\017 $fname - \00307Restant:\017 ${mbleft} MB/${mb} MB - \00307Cat:\017 $curCat"
				if {($item >= $noDisplay)} { return }
			}
		} else {
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003~ Rien en attente"
		}		
    } elseif {([lindex $arg 0] == "add")} {
		if {([lsearch -exact $sab(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003 Vous n'êtes pas autorisé à ça"
			return
		}   
		if {([llength $arg] <= 1)} {
			putserv "NOTICE $nick :Usage: !sab add <URL>"
		} else {		
			if {([string is integer -strict [lindex $arg 1]])} {
				set sab(cat) "[lindex $arg 2]"
				set url "http://$sab(host):$sab(port)/sabnzbd/api?mode=addurl&name=[lindex $arg 1]$sabUserPass&apikey=$sab(key)&cat=$sab(cat)"
				set returnMess [http::data [http::geturl $url]]
			} else {
				if {![regexp {^http.+} [lindex $arg 1]]} { 
					putserv "PRIVMSG $chan :\00304\002\[Cronos\]\002\003 URL non valide. Dans le type de: http://example.com/example.nzb"
					return
				}
				set urlEncode [http::formatQuery mode addurl name [lindex $arg 1] cat $sab(cat) apikey $sab(key)]
				set url "http://$sab(host):$sab(port)/sabnzbd/api?"
				set returnMess [http::data [http::geturl $url -query $urlEncode]]
			}
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Nzb rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Nzb non rajouté" 
			}
		}
	} elseif {([lindex $arg 0] == "pause")} {
		if {([lsearch -exact $sab(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		set url "http://$sab(host):$sab(port)/sabnzbd/api?mode=pause$sabUserPass&apikey=sab(key)"
		set returnMess [http::data [http::geturl $url]]
		if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003En pause"
		} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Pause non effective" 
		}
	} elseif {([lindex $arg 0] == "resume")} {
		if {([lsearch -exact $sab(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		set url "http://$sab(host):$sab(port)/sabnzbd/api?mode=resume$sabUserPass&apikey=$sab(key)"
		set returnMess [http::data [http::geturl $url]]
		if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Pause enlevée"
		} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Téléchargement non repris pour une raison inconnue" 
		}
	} elseif {([lindex $arg 0] == "version")} {
		set url "http://$sab(host):$sab(port)/sabnzbd/api?mode=version&output=xml$sabUserPass&apikey=$sab(key)"
		set version [http::data [http::geturl $url]]
		set doc [dom parse $version]
		set root [$doc documentElement]
		set version [[$root selectNodes /versions/version/text()] data]
		putserv "PRIVMSG $chan :\00307\002\[SABnzbd\]\002\003 Script Version:\002\[$sab(version)\]\002 SABnzbd Version:\002\[$version\]\002" 
	} elseif {([lindex $arg 0] == "speed")} {
		if {([lsearch -exact $sab(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		if {([lindex $arg 1] != "") && ([string is integer -strict [lindex $arg 1]])} {
			set url "http://$sab(host):$sab(port)/sabnzbd/api?mode=speedlimit&value=[lindex $arg 1]$sabUserPass&apikey=$sab(key)"
			set returnMess [http::data [http::geturl $url]]
			if { [string compare $returnMess "ok"] != 0 } {
				if {([lindex $arg 1] == 0)} {
					putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Limite de vitesse enlevée"
				} else {
					putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Limite de vitesse à [lindex $arg 1]KB/s"
				}
			} else {
				putserv "PRIVMSG $chan :\002\[Cronos\]\002 \003La limite de vitesse n'a pas été changée pour une raison inconnue" 
			}		
		} else {
			putserv "NOTICE $nick :Usage: !sab speedlimit <Speed in KB/s>"
		}
	} elseif {([lindex $arg 0] == "help")} {
		putserv "NOTICE $nick :\00307\002\[SABnzbd Cronos Usage\]\002"
		putserv "NOTICE $nick :\00307\002\!sab stats\002 - Donne les infos sur le status de SABnzbd"
		putserv "NOTICE $nick :\00314\002\!sab queue \[n\]\002 - Montre les fichiers en attente. Par défaut 3. Spécifiez n pour plus ou moins de résultats"
		putserv "NOTICE $nick :\00314\002\!sab version\002 - Montre la version actuelle de SABnzbd et ses scripts"
		if {([lsearch -exact $sab(nicks) $nick] != -1)} { 
			putserv "NOTICE $nick :\00307\002\!sab add <URL>\002 - Ajoutez une URL à SABnzbd"
			putserv "NOTICE $nick :\00314\002\!sab speed <Speed in KB/s>\002 - Ajustez la limite de vitesse de SABnzbd"
			putserv "NOTICE $nick :\00314\002\!sab pause\002 - Mettre en pause SABnzbd"
			putserv "NOTICE $nick :\00314\002\!sab resume\002 - Reprendre le téléchargement sur SABnzbd"
		}
	} else {
		putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003 Tapes \"!sab help\" pour plus d'information"
	}
}

proc getString {searchstr first last} {
	set start [string first $first $searchstr]
	set returnString [string range $searchstr $start end]
	set end [string first $last $returnString]
	set returnString [string range $returnString [string length $first] [expr $end - 1]]
	return $returnString
}

proc omgwtfnzbsTrigger { nick host hand chan arg } {
	global sabnzbd
	global sab
	if {($sab(username) != "") && ($sab(password) != "")} {
		set sabUserPass "&ma_username=$sab(username)&ma_password=$sab(password)"
	}
	if {([lsearch -exact $sab(chans) $chan] == -1)} { return }    
	if {([lindex $arg 0] == "add")} {
		if {([lsearch -exact $sab(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
        	if {([string is alnum -strict [lindex $arg 1]])} {
			set omgUrl "http://api.omgwtfnzbs.org/sn.php?id=[lindex $arg 1]&user=$sab(omgname)&api=$sab(omg)"
			set sab(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl apikey $sab(key) cat $sab(cat)]
			set url "http://$sab(host):$sab(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
                putserv "PRIVMSG $chan :\002\00309,01\[Omgwtfnzbs\]\003\002 Fichier rajouté avec succès"
            } else {
                putserv "PRIVMSG $chan :\002\00309,01\[Omgwtfnzbs\]\003\002 Fichier non rajouté"
            }
        } else {
            putserv "PRIVMSG $chan :\002\00309,01\[Omgwtfnzbs\]\003\002 Vous devez spécifier une ID Omgwtfnzbs spécifique valide."
		}
	} elseif {([lindex $arg 0] == "help")} {
		putserv "NOTICE $nick :\00307\002\[Usage de la commande !omg - Pour Omgwtfnzbs - http://omgwtfnzbs.com/index.php\]\002"
		if {([lsearch -exact $sab(nicks) $nick] != -1)} { 
			putserv "NOTICE $nick :\00312\002\!omg add <Omgwtfnzbs ID> <categorie>\002 \00314- Ajoutez un ID Omgwtfnzbs à SABnzbd"
		}
	} else {
		putserv "PRIVMSG $chan :\002\[Omgwtfnzbs\]\002 Tapes \"!omg help\" pour plus d'infos"
	}	
}
proc omgTrigger { nick host hand chan arg } {
    global sabnzbd
    global sab
    if {($sabnzbd(username) != "") && ($sabnzbd(password) != "")} {
        set sabUserPass "&ma_username=$sabnzbd(username)&ma_password=$sabnzbd(password)"
    }
    if {([lsearch -exact $sabnzbd(chans) $chan] == -1)} { return }
    if {([lindex $arg 0] == "add")} {
        if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} {
            putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
            return
        }
        if {([string is alnum -strict [lindex $arg 1]])} {
            set omgUrl "http://api.omgwtfnzbs.org/sn.php?id=[lindex $arg 1]&user=$sabnzbd(omgname)&api=$sabnzbd(omg)"
            set sabnzbd(cat) "[lindex $arg 2]"
            set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
            set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
            set returnMess [http::data [http::geturl $url -query $urlEncode]]
            if { [string compare $returnMess "ok"] != 0 } {
                putserv "PRIVMSG $chan :\002\00309,01\[Omgwtfnzbs\]\003\002 Fichier rajouté avec succès"
            } else {
                putserv "PRIVMSG $chan :\002\00309,01\[Omgwtfnzbs\]\003\002 Fichier non rajouté"
            }
        } else {
            putserv "PRIVMSG $chan :\002\00309,01\[Omgwtfnzbs\]\003\002 Vous devez spécifier une ID Omgwtfnzbs spécifique valide."
        }
    } elseif {([lindex $arg 0] == "help")} {
        putserv "NOTICE $nick :\00307\002\[Usage de la commande !omg - Pour Omgwtfnzbs - http://omgwtfnzbs.com/index.php\]\002"
        if {([lsearch -exact $sabnzbd(nicks) $nick] != -1)} {
            putserv "NOTICE $nick :\00312\002\!omg add <Omgwtfnzbs ID> <categorie>\002 \00314- Ajoutez un ID Omgwtfnzbs à SABnzbd"
            putserv "NOTICE $nick :\00307Les ID se trouvent sur les chans de flux rss, sur le site"

        }
    } else {
        putserv "PRIVMSG $chan :\002\[Omgwtfnzbs\]\002 Tapes \"!omg help\" pour plus d'infos"
    }
}
putlog "SABnzbd Eggdrop v$sab(version) chargé"