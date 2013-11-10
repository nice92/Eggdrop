# SCRIPT INFORMATION
# This script allows users to check the status of their SABnzbd
# in the specified IRC channels.
#
# Currently there are 8 commands (4 can be done by anyone, 4 require you to be set in the config):
# ANYONE
# !sabnzbd stats - Gives a quick breakdown current status"
# !sabnzbd queue [n] - Shows current items in queue. Default is 3. Specify n to show more or less
# !sabnzbd version - Shows current version of SABnzbd and also this script
# !sabnzbd help - Shows usage information
# !sabnzbd add <URL/Newzbin ID> - Adds a URL or Newzbin ID to SABnzbd
# !sabnzbd speed <Speed in KB/s (0 to remove limit)> - Sets the speedlimit in SABnzbd
# !sabnzbd pause - Pauses SABnzbd
# !sabnzbd resume - Resumes SABnzbd
# 
# Omgwtfnzbs
# !efn add <ID> <section> - add Omgwtfnzbs ID to SABnzbd / Ajoute une ID Omgwtfnzbs à SABnzbd
#
# NZBMatrix
# !efn matrix <ID> <section> - add NZBMatrix ID to SABnzbd / Ajoute une ID NZBMatrix à SABnzbd
#
# Gotnzb4u
# !efn teevee <ID> <section> - Ajoutez un ID Teevee à SABnzbd 
# !efn moovee <ID> <section> - Ajoutez un ID Moovee à SABnzbd
# !efn hd <ID> <section> - Ajoutez un ID HD à SABnzbd 
# !efn foreign <ID> <section> - Ajoutez un ID Foreign à SABnzbd 
# !efn erotica <ID> <section> - Ajoutez un ID Erotica à SABnzbd 
# !efn pciso <ID> <section> - Ajoutez un ID PCiso à SABnzbd 
# !efn sanctum <ID> <section> - Ajoutez un ID Sanctum à SABnzbd
# !efn mp3 <ID> <section> - Ajoutez un ID Erotica à SABnzbd
# !efn flac <ID> <section> - Ajoutez un ID Flac à SABnzbd 
# !efn 0day <ID> <section> - Ajoutez un ID 0Day à SABnzbd
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
# Set your SABnzbd username here, if you don't use one set to ""
set sabnzbd(username) ""
# Set your SABnzbd password here, if you don't use one set to ""
set sabnzbd(password) "!"
# Set you SABnzbd API key here
set sabnzbd(key) ""
# Set the host that SABnzbd runs on.
set sabnzbd(host) ""
# Set the port that SABnzbd runs on.
set sabnzbd(port) ""
# Set the channels that the script should respond on.
set sabnzbd(chans) ""
# Set the nicks that can add/pause/resume/speed.
set sabnzbd(nicks) ""
# Set Omgwtfnzbs supports
set sabnzbd(omgwtfnzbs) ""
set sabnzbd(omgname) ""
set sabnzbd(omg) ""
# Set Gotnzb4u supports
set sabnzbd(gotnzb4u) ""
set sabnzbd(got) ""
# Set NZBMatrix supports
set sabnzbd(nzbmatrix) ""
set sabnzbd(matrixname) ""
set sabnzbd(matrix) ""
# END CONFIGURATION

bind pub - !sab sabnzbdTrigger

if {$sabnzbd(omgwtfnzbs) == "true"} {
	bind pub - !omg omgwtfnzbsTrigger
}
if {$sabnzbd(nzbmatrix) == "true"} {
	bind pub - !matrix nzbmatrixTrigger
}
if {$sabnzbd(gotnzb4u) == "true"} {
	bind pub - !got gotnzb4uTrigger
}
set sabnzbd(version) "0.5.1"

proc sabnzbdTrigger { nick host hand chan arg } {
	global sabnzbd
	set sabUserPass ""
	if {($sabnzbd(username) != "") && ($sabnzbd(password) != "")} {
		set sabUserPass "&ma_username=$sabnzbd(username)&ma_password=$sabnzbd(password)"
	}
	if {([lsearch -exact $sabnzbd(chans) $chan] == -1)} { return }    
	set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=qstatus&output=xml$sabUserPass&apikey=$sabnzbd(key)"

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
		set jobs [llength [$root selectNodes /queue/jobs/job]]
		if {($jobs != 0)} {
			set firstJobNode [lindex [$root selectNodes /queue/jobs/job] 0]
			set curFileName [[$firstJobNode selectNodes filename/text()] data]
			set curMb [format "%.2f" [[$firstJobNode selectNodes mb/text()] data]]
			set curMbLeft [format "%.2f" [[$firstJobNode selectNodes mbleft/text()] data]]
			set curMbDone [format "%.2f" [expr $curMb - $curMbLeft]]
			set curPercent [format "%.2f" [expr [expr $curMbDone / $curMb] * 100]]
			set currentJob "$curFileName (${curMbDone}MB/${curMb}MB) (${curPercent}%)"
		} else {
			set currentJob "Aucun fichier"
		}
		putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \00307\002\[\003Vitesse\00307]\002 \003\[$speed\] \00307\002\[\003Temps Restant\00307]\002 \003\[$time\] \00307\002\[\003En Attente\00307]\002 \003\[${mbleft}Mo/${mb}Mo ($noinq fichier(s))\]"
		putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \00307\002\[\003Fichier Actuel\00307]\002 \003\[$currentJob\]"
	} elseif {([lindex $arg 0] == "queue")} {
		set queueStatus [http::data [http::geturl $url]]
		set doc [dom parse $queueStatus]
		set root [$doc documentElement]
		set jobs [$root selectNodes /queue/jobs/job]
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
				set mb [format "%.2f" [[$x selectNodes mb/text()] data]]
				set mbleft [format "%.2f" [[$x selectNodes mbleft/text()] data]]
				putserv "PRIVMSG $chan :\002\ #$item\]\002 \003[Fichier]\003\002\[$fname\]\002 [Restant]\003\002\[${mbleft} MB/${mb} MB\]\002"
				if {($item >= $noDisplay)} { return }
			}
		} else {
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003~ Rien en attente"
		}		
    } elseif {([lindex $arg 0] == "add")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003 Vous n'êtes pas autorisé à ça"
			return
		}   
		if {([llength $arg] <= 1)} {
			putserv "NOTICE $nick :Usage: !sab add <URL/Newzbin ID>"
		} else {		
			if {([string is integer -strict [lindex $arg 1]])} {
				set sabnzbd(cat) "[lindex $arg 2]"
				set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=addid&name=[lindex $arg 1]$sabUserPass&apikey=$sabnzbd(key)&cat=$sabnzbd(cat)"
				set returnMess [http::data [http::geturl $url]]
			} else {
				if {![regexp {^http://.+} [lindex $arg 1]]} { 
					putserv "PRIVMSG $chan :\00304\002\[Cronos\]\002\003 URL non valide. Dans le type de: http://example.com/example.nzb"
					return
				}
				set urlEncode [http::formatQuery mode addurl name [lindex $arg 1] ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key)]
				set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
				set returnMess [http::data [http::geturl $url -query $urlEncode]]
			}
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Nzb rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Nzb non rajouté" 
			}
		}
	} elseif {([lindex $arg 0] == "pause")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=pause$sabUserPass&apikey=sabnzbd(key)"
		set returnMess [http::data [http::geturl $url]]
		if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003En pause"
		} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Pause non effective" 
		}
	} elseif {([lindex $arg 0] == "resume")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=resume$sabUserPass&apikey=$sabnzbd(key)"
		set returnMess [http::data [http::geturl $url]]
		if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Pause enlevée"
		} else {
				putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Téléchargement non repris pour une raison inconnue" 
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
			putserv "PRIVMSG $chan :\00307\002\[\003Cronos\00307]\002 \003Vous n'êtes pas autorisé à ça"
			return
		}   
		if {([lindex $arg 1] != "") && ([string is integer -strict [lindex $arg 1]])} {
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?mode=speedlimit&value=[lindex $arg 1]$sabUserPass&apikey=$sabnzbd(key)"
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
			putserv "NOTICE $nick :Usage: !sabnzbd speedlimit <Speed in KB/s>"
		}
	} elseif {([lindex $arg 0] == "help")} {
		putserv "NOTICE $nick :\00307\002\[SABnzbd Cronos Usage\]\002"
		putserv "NOTICE $nick :\00307\002\!sab stats\002 - Donne les infos sur le status de SABnzbd"
		putserv "NOTICE $nick :\00314\002\!sab queue \[n\]\002 - Montre les fichiers en attente. Par défaut 3. Spécifiez n pour plus ou moins de résultats"
		putserv "NOTICE $nick :\00314\002\!sab version\002 - Montre la version actuelle de SABnzbd et ses scripts"
		if {([lsearch -exact $sabnzbd(nicks) $nick] != -1)} { 
			putserv "NOTICE $nick :\00307\002\!sab add <URL/Newzbin ID>\002 - Ajoutez une URL ou Newzbin ID à SABnzbd"
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
	if {($sabnzbd(username) != "") && ($sabnzbd(password) != "")} {
		set sabUserPass "&ma_username=$sabnzbd(username)&ma_password=$sabnzbd(password)"
	}
	if {([lsearch -exact $sabnzbd(chans) $chan] == -1)} { return }    
	if {([lindex $arg 0] == "add")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://omgwtfnzbs.com/send.php?dl=auto&id=[lindex $arg 1]&user=$sabnzbd(omgname)&apikey=$sabnzbd(omg)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\002\[Omgwtfnzbs\]\002 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\002\[Omgwtfnzbs\]\002 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\002\[Omgwtfnzbs\]\002 Vous devez spécifier une ID Omgwtfnzbs spécifique valide."
		}
	} elseif {([lindex $arg 0] == "help")} {
		putserv "NOTICE $nick :\00307\002\[Usage de la commande !omg - Pour Omgwtfnzbs - http://omgwtfnzbs.com/index.php\]\002"
		if {([lsearch -exact $sabnzbd(nicks) $nick] != -1)} { 
			putserv "NOTICE $nick :\00312\002\!omg add <Omgwtfnzbs ID> <categorie>\002 \00314- Ajoutez un ID Omgwtfnzbs à SABnzbd"
		}
	} else {
		putserv "PRIVMSG $chan :\002\[Omgwtfnzbs\]\002 Tapes \"!omg help\" pour plus d'infos"
	}	
}
proc nzbmatrixTrigger { nick host hand chan arg } {
	global sabnzbd
	if {($sabnzbd(username) != "") && ($sabnzbd(password) != "")} {
		set sabUserPass "&ma_username=$sabnzbd(username)&ma_password=$sabnzbd(password)"
	}
	if {([lsearch -exact $sabnzbd(chans) $chan] == -1)} { return }    
	if {([lindex $arg 0] == "add")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://api.nzbmatrix.com/v1.1/download.php?id=[lindex $arg 1]&username=$sabnzbd(matrixname)&apikey=$sabnzbd(matrix)&scenename=1"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\002\[NZBMATRiX\]\002 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\002\[NZBMATRiX\]\002 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\002\[NZBMATRiX\]\002 Vous devez spécifier une ID NZBMATRiX spécifique valide."
		}
	} elseif {([lindex $arg 0] == "help")} {
		putserv "NOTICE $nick :\00307\002\[Usage de la commande !matrix - Pour NZBMatrix - http://nzbmatrix.com/index.php\]\002"
		if {([lsearch -exact $sabnzbd(nicks) $nick] != -1)} { 
			putserv "NOTICE $nick :\00312\002\!matrix add <NZBMatrix ID> <categorie>\002 \00314- Ajoutez un ID NZBMatrix à SABnzbd"
		}
	} else {
		putserv "PRIVMSG $chan :\002\[NZBMatrix\]\002 Tapes \"!matrix help\" pour plus d'infos"
	}	
}
proc gotnzb4uTrigger { nick host hand chan arg } {
	global sabnzbd
	if {($sabnzbd(username) != "") && ($sabnzbd(password) != "")} {
		set sabUserPass "&ma_username=$sabnzbd(username)&ma_password=$sabnzbd(password)"
	}
	if {([lsearch -exact $sabnzbd(chans) $chan] == -1)} { return }    
	if {([lindex $arg 0] == "teevee")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=teevee&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00308\002\[Teevee\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00308\002\[Teevee\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00308\002\[Teevee\]\002\003 Vous devez spécifier une ID Teevee spécifique valide."
		}
	} elseif {([lindex $arg 0] == "foreign")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=foreign&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00302\002\[Foreign\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00302\002\[Foreign\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00302\002\[Foreign\]\002\003 Vous devez spécifier une ID Foreign spécifique valide."
		}
	} elseif {([lindex $arg 0] == "hd")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=hd&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00307\002\[HD\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00307\002\[HD\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00307\002\[HD\]\002\003 Vous devez spécifier une ID HD spécifique valide."
		}
	} elseif {([lindex $arg 0] == "moovee")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=moovee&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00311\002\[Moovee\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00311\002\[Moovee\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00311\002\[Moovee\]\002\003 Vous devez spécifier une ID Moovee spécifique valide."
		}
	} elseif {([lindex $arg 0] == "flac")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=flac&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00309\002\[Flac\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00309\002\[Flac\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00309\002\[Flac\]\002\003 Vous devez spécifier une ID Flac spécifique valide."
		}
	} elseif {([lindex $arg 0] == "mp3")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=mp3&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00303\002\[MP3\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00303\002\[MP3\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00303\002\[MP3\]\002\003 Vous devez spécifier une ID MP3 spécifique valide."
		}
	} elseif {([lindex $arg 0] == "sanctum")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=sanctum&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00312\002\[Sanctum\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00312\002\[Sanctum\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00312\002\[Sanctum\]\002\003 Vous devez spécifier une ID Sanctum spécifique valide."
		}
	} elseif {([lindex $arg 0] == "erotica")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=erotica&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00313\002\[Erotica\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00313\002\[Erotica\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00313\002\[Erotica\]\002\003 Vous devez spécifier une ID Erotica spécifique valide."
		}
	} elseif {([lindex $arg 0] == "divx")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=divx&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00306\002\[DiVX\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00306\002\[DiVX\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00306\002\[DiVX\]\002\003 Vous devez spécifier une ID DiVX spécifique valide."
		}
	} elseif {([lindex $arg 0] == "pciso")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=pciso&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00305\002\[PCiSO\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00305\002\[PCiSO\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00305\002\[PCiSO\]\002\003 Vous devez spécifier une ID PCiSO spécifique valide."
		}
	} elseif {([lindex $arg 0] == "0day")} {
		if {([lsearch -exact $sabnzbd(nicks) $nick] == -1)} { 
			putserv "PRIVMSG $chan :\002\[SABnzbd\]\002 S'pas pour toi !"
			return
		}
		if {([string is integer -strict [lindex $arg 1]])} {
			set omgUrl "http://85.214.105.230/nzb.php?id=[lindex $arg 1]&section=0day&key=$sabnzbd(got)"
			set sabnzbd(cat) "[lindex $arg 2]"
			set urlEncode [http::formatQuery mode addurl name $omgUrl ma_username $sabnzbd(username) ma_password $sabnzbd(password) apikey $sabnzbd(key) cat $sabnzbd(cat)]
			set url "http://$sabnzbd(host):$sabnzbd(port)/sabnzbd/api?"
			set returnMess [http::data [http::geturl $url -query $urlEncode]]
			if { [string compare $returnMess "ok"] != 0 } {
				putserv "PRIVMSG $chan :\00314\002\[0Day\]\002\003 Fichier rajouté avec succès"
			} else {
				putserv "PRIVMSG $chan :\00314\002\[0Day\]\002\003 Fichier non rajouté" 
			}
		} else {
			putserv "PRIVMSG $chan :\00314\002\[0Day\]\002\003 Vous devez spécifier une ID 0Day spécifique valide."
		}
	} elseif {([lindex $arg 0] == "help")} {
		putserv "NOTICE $nick :\00307\002\[Usage de la commande !got - Pour Gotnzb4u - http://85.214.105.230/search/index.php\]\002"
		if {([lsearch -exact $sabnzbd(nicks) $nick] != -1)} { 
			putserv "NOTICE $nick :\00312\002\!got teevee <Teevee ID> <categorie>\002 \00314- Ajoutez un ID Teevee à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got moovee <Moovee ID> <categorie>\002 \00314- Ajoutez un ID Moovee à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got hd <HD ID> <categorie>\002 \00314- Ajoutez un ID HD à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got foreign <Froegin ID> <categorie>\002 \00314- Ajoutez un ID Foreign à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got erotica <Erotica ID> <categorie>\002 \00314- Ajoutez un ID Erotica à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got pciso <PCiso ID> <categorie>\002 \00314- Ajoutez un ID PCiso à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got sanctum <Sanctum ID> <categorie>\002 \00314- Ajoutez un ID Sanctum à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got mp3 <MP3 ID> <categorie>\002 \00314- Ajoutez un ID Erotica à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got flac <FLAC ID> <categorie>\002 \00314- Ajoutez un ID Flac à SABnzbd"
			putserv "NOTICE $nick :\00312\002\!got 0day <0Day ID> <categorie>\002 \00314- Ajoutez un ID 0Day à SABnzbd"
		}
	} else {
		putserv "PRIVMSG $chan :\002\[Gotnzb4u\]\002 Tapes \"!got help\" pour plus d'infos"
	}	
}

putlog "SABnzbd Eggdrop Controller v$sabnzbd(version) by dr0pknutz and modify by nice92 loaded."