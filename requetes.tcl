# ##################################################################################################
# PrayerRequests Bot by ifiredmybrain
# for eggdrop 1.6.x
# for help with this script email me at adam@irc-cops.net
# or go to irc.awesomechristians.us #PrayerRequest
#
# Please read the entire README
#
# + add ajout status & raison (nice92)
# + add  modif raison (nice92)
#
# For a list of commands look in the README
# ##################################################################################################

# ##################################################################################################
# MySQL Options
# ##################################################################################################

set pdb(hostname) ""
set pdb(username) ""
set pdb(password) ""
set pdb(database) ""
set pdb(prefix) "pr-"

# ##################################################################################################
# Other Options
# ##################################################################################################

set pr(channels) "#"
set pr(character) "!"

# MySQL Tcl Location
load /usr/lib/tcltk/mysqltcl-3.051/libmysqltcl3.051.so

# ##################################################################################################
# The Border
# ##################################################################################################

set pr(version) "1.1"
set pr(channels) [string tolower [split "$pr(channels)" ","]]

set pr(userflag) "-"
set pr(opflag) "Qo|o"
set pr(masterflag) "Qo|m"

bind pub $pr(userflag) ${pr(character)}requete pr:prayer
bind pub $pr(userflag) ${pr(character)}req pr:prayer
bind pub $pr(userflag) ${pr(character)}reqhelp pr:prayerhelp
bind pub $pr(userflag) ${pr(character)}addreq pr:addprayer
bind pub $pr(masterflag) ${pr(character)}dreq pr:delprayer
bind pub $pr(masterflag) ${pr(character)}ureq pr:updateprayer
bind pub $pr(masterflag) ${pr(character)}raison pr:raisonprayer



proc replace {{args ""}} {
	set switches ""
	for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
		if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
			error "bad switch \"$arg\": must be -nocase, or --"
		}
		if {$switch == "-"} {
			incr i
			break
		}; lappend switches $switch
	}
	set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
	set text [lindex $args $i]
	set substitutions [lindex $args [expr $i+1]]
	set substitutions [split $substitutions]
		if {[info tclversion] >= "8.1"} {
		return [expr {($nocase)?
			[string map -nocase $substitutions $text]:
			[string map $substitutions $text]}]
	}
		set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
	foreach {a b} $substitutions {
		regsub -all -- $re_syntax $a {\\\1} a
		if {$nocase} {regsub -all -nocase -- $a $text $b text} \
		else {regsub -all -- $a $text $b text}
	}; return $text
}

proc mirc_strip {{args ""}} {
	set switches ""
	if {$switches == ""} {set switches all}
	set arg [lindex $args 0]
	set all [expr {([lsearch -exact $switches all] >= 0) ? 1 : 0}]
	set list [list \002 "" \017 "" \026 "" \037 ""]
	regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $arg "" arg
	set arg [replace -- $arg [join $list]]
	return $arg

}

proc pr:filter {data} {
   regsub -all -- \\\" $data \\\\\" data
   regsub -all -- \\\' $data \\\\\' data
   set data [mirc_strip $data]
   return $data
}

# ##################################################################################################
# Procedures
# ##################################################################################################

proc pr:validchannel {channel} {
   global pr ; set valid 0
   foreach channel $pr(channels) { if {$channel == [string tolower $channel]} { set valid 1 }}
   return $valid
}

# Lecture des requêtes 
proc pr:prayer {nick uhost hand channel arg} {
   global pdb
   if {![pr:validchannel $channel]} { return 0 }
   set table "$pdb(prefix)[string range $channel 1 end]" ; set arg [split $arg]
   set sqlhand [mysqlconnect -host $pdb(hostname) -user $pdb(username) -password $pdb(password)]
   mysqluse $sqlhand $pdb(database)
   set count [mysqlsel $sqlhand "SELECT COUNT(*) FROM `$table`" -list]
   set nr [rand $count]
   if {$arg==""} {
      set row [lindex [mysqlsel $sqlhand "SELECT * FROM `$table` ORDER BY id LIMIT $nr,1" -list] 0] ; incr nr
   } elseif {[string is integer $arg]} {
      if {$arg > $count} { set count 0 }
      set row [lindex [mysqlsel $sqlhand "SELECT * FROM `$table` LIMIT [expr $arg - 1],1" -list] 0] ; set nr $arg
   } elseif {[lindex $arg 0] == "-id" && [string is integer [lindex $arg 1]]} {
      set nr [lindex $arg 1]; set row [lindex [mysqlsel $sqlhand "SELECT * FROM `$table` WHERE id LIKE '$nr'" -list] 0]
      if {[lindex $row 1] == ""} { putserv "PRIVMSG $nick :Aucune demande trouvée" } else { putserv "PRIVMSG $nick :Requête id \002$nr\002: [lindex $row 1]" }
      mysqlclose $handle; return
   } else {
      if {[string is integer [lindex $arg end]]} { set nr [expr [lindex $arg end] - 1]; set arg [lrange $arg 0 end-1] }
      set arg [pr:filter $arg]
      set count [mysqlsel $sqlhand "SELECT COUNT(*) FROM `$table` WHERE prayer LIKE '%${arg}%'" -list]
      if {![info exists nr] || $nr > $count} { if {$count > 0} {set nr [rand $count]} else {set nr 0} }
      set row [lindex [mysqlsel $sqlhand "SELECT * FROM `$table` WHERE prayer LIKE '%${arg}%' ORDER BY id LIMIT $nr,1" -list] 0] ; incr nr
   }
   mysqlclose $sqlhand
   if {$count != 0} { putserv "NOTICE $nick :\00314\[\017 \002$nr\002-\002$count\002 \00314\]\[\017 [lindex $row 1] \00314\]\[\017 [lindex $row 4] \00314\]\[\017 [lindex $row 2] \00314\]\[\017 [lindex $row 3] \00314\]\[\017 id:[lindex $row 0] \00314\]\017"
   } else { putserv "PRIVMSG $channel :Aucune demande trouvée" }
}

# Ajout de requête
proc pr:addprayer {nick uhost handle channel arg} {
   global pdb
   if {![pr:validchannel $channel]} { return 0 }
   set arg [pr:filter $arg]
   set table "$pdb(prefix)[string range $channel 1 end]"
   set sqlhand [mysqlconnect -host $pdb(hostname) -user $pdb(username) -password $pdb(password)]
   mysqluse $sqlhand $pdb(database)
   mysqlexec $sqlhand "INSERT INTO `$table` ( `id` , `prayer` , `author` , `date` ) VALUES ('', '$arg', '$nick', NOW( ))"
   mysqlclose $sqlhand
   putserv "PRIVMSG #Staff :\00314\[\017 Requête \00314\]\[\017 $arg \00314\]\[\017 $nick \00314\]\017"
   putserv "PRIVMSG #ViP :\00314\[\017 Requête \00314\]\[\017 $arg \00314\]\[\017 $nick \00314\]\017"
   putcmdlog "<<$nick>> !$handle! Requete ajoutee sur le chan $channel."
}

# Suppression de requête
proc pr:delprayer {nick uhost handle channel arg} {
   global pdb
   if {![pr:validchannel $channel]} { return 0 }
   set table "$pdb(prefix)[string range $channel 1 end]" ; set id ""
   set sqlhand [mysqlconnect -host $pdb(hostname) -user $pdb(username) -password $pdb(password)]
   mysqluse $sqlhand $pdb(database)
   if {[string is integer $arg]} {
     set id [lindex [lindex [mysqlsel $sqlhand "SELECT * FROM `$table` ORDER BY id ASC LIMIT [expr $arg - 1],1;" -list] 0] 0]
   } elseif {[lindex $arg 0] == "-id" && [string is integer [lindex $arg 1]]} {
     set id [lindex $arg 1]
   }
   if {$id != ""} { set result [mysqlexec $sqlhand "DELETE FROM `$table` WHERE `id` = '$id'"] }
   mysqlclose $sqlhand
   if {$result != 0} {
    putserv "PRIVMSG $channel :Requête effacée"
    putcmdlog "<<$nick>> !$handle! Requete effacée sur le chan $channel."
   } else {putserv "PRIVMSG $channel :Pas de requête trouvée" }
}

# Status des requêtes
proc pr:updateprayer {nick uhost handle channel arg} {
   global pdb
   set arg1 [lindex $arg 0]
   set arg2 [lindex $arg 1]
   set sqlhand [mysqlconnect -host $pdb(hostname) -user $pdb(username) -password $pdb(password)]
   mysqluse $sqlhand $pdb(database)
   mysqlexec $sqlhand "UPDATE  `listing`.`pr-ViP` SET  `status` =  '$arg2' WHERE  `pr-ViP`.`id` =$arg1;"
   mysqlclose $sqlhand
   putserv "NOTICE $nick :\00314\[\017 Status de la requête $arg1 en \00307$arg2 \00314\]\017"
   putcmdlog "<<$nick>> !$handle! Changement de status d'une requête depuis $channel."
}

# Raison des requêtes
proc pr:raisonprayer {nick uhost handle channel arg} {
   global pdb
   set arg1 [lindex $arg 0]
   set arg2 [lrange $arg 1 end]
   set sqlhand [mysqlconnect -host $pdb(hostname) -user $pdb(username) -password $pdb(password)]
   mysqluse $sqlhand $pdb(database)
   mysqlexec $sqlhand "UPDATE  `listing`.`pr-ViP` SET  `raison` =  '$arg2' WHERE  `pr-ViP`.`id` =$arg1;"
   mysqlclose $sqlhand
   putserv "NOTICE $nick :\00314\[\017 Requête: $arg1  \00314\]\017 \00314\[\017 Raison de refus: $arg2  \00314\]\017"
   putcmdlog "<<$nick>> !$handle! Ajout d'une raison pour refus d'une requête depuis $channel."
}

# requête help
proc pr:prayerhelp {nick uhost handle chan arg} {
    global pr
    if {![pr:validchannel $chan]} { return 0 }
    putserv "NOTICE $nick :Requête_Script $pr(version) par ifiredmybrain. Commandes:"
    putserv "NOTICE $nick :$pr(character)addreq <la requete avec le nom complet>   $pr(character)prayer \[num|string|-id <id>\]"
    putserv "NOTICE $nick :$pr(character)delreq <num|-id <id>>"
}

putlog "Requete $pr(version) chargé"
