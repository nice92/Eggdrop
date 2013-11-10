### CONF ###

# search command
set db(cmd) "!srt"
set add(cmd) "!addsrt"
# channel flag
set data(flag) "Search"
# max results
set data(results) "5"
# DB INFO
set data(host) "localhost"
set data(user) "user"
set data(pass) "pass"
set data(name) "name"
set data(table) "table"
set table(srt) "table"

# END CONF
load /usr/lib/tcltk/mysqltcl-3.051/libmysqltcl3.051.so
bind pub -|- $db(cmd) srt_efnet
bind pub o|o $add(cmd) addsrt
setudef flag $data(flag)

proc srt_efnet { nick host hand chan arg} {
	global db
	global data
		if {![channel get $chan $data(flag)]} {
		return 0
	}
	if {$arg == ""} {
		putquick "NOTICE $nick :\002Syntax:\017 $srt(cmd) <nombre_de_résultats> <la_recherche> / maximum 3 mots dans la recherche"
		return 0
	}
	set search [lrange [split $arg] 0 end]
	set web [string map { " " "+" } $search]
       putquick "NOTICE $nick :\002\00308\[\17 Sous-Titres.eu \002\00308]\17 ==> \002\00308\[\17 http://www.sous-titres.eu/search.html?q=$web \002\00308]\17"
       putquick "NOTICE $nick :\002\00308\[\17 Addic7ed.com \002\00308]\17 ==> \002\00308\[\17 http://www.addic7ed.com/search.php?search=$web&Submit=Rechercher \002\00308]\17"
	set partiel [string map { " " "%" } $search] 
	set opt "%"
	set resultat [lindex $opt$partiel$opt]
	set sql(handle) [mysqlconnect -host $data(host) -user $data(user) -password $data(pass) -db $data(name)]
	set sql(query) [::mysql::query $sql(handle) "SELECT * FROM `$data(table)` WHERE `srt` LIKE '$resultat' ORDER BY `id` DESC LIMIT $data(results) "] 
	if {[::mysql::result $sql(query) rows] < 1} {
		putquick "NOTICE $nick :Heu... non j'ai rien"
	} else {
		while {[set row [::mysql::fetch $sql(query)]] != ""} {
        set sites [lindex $row 1]
        set srt [lindex $row 2]
        set liens [lindex $row 3]
        putquick "NOTICE $nick :\002\00308\[\17 $sites \002\00308]\17 ==> \002\00308\[\17 $srt \002\00308]\17 ==> \002\00308\[\17 $liens \002\00308]\17"
    }
  }
  ::mysql::endquery $sql(query)
  mysqlclose $sql(handle)
}
proc addsrt { nick host hand chan arg} { 
	global addsrt
	global data
		if {![channel get $chan $data(flag)]} { 
		return 0 
	} 
	if {$arg == ""} { 
		putquick "NOTICE $nick :\002Syntax:\017 $add(cmd) <nom de fichier ou release>" 
		return 0 
	} 
	set arg1 [lindex $arg 0]
	set arg2 [lindex $arg 1]
	set arg3 [lindex $arg end]
	set sqlhand [mysqlconnect -host $data(host) -user $data(user) -password $data(pass)]
	mysqluse $sqlhand $data(name)
	mysqlexec $sqlhand "INSERT INTO `$data(table)` ( `field` , `field` , `field` , `field`) VALUES ('', '$arg1', '$arg2', '$arg3')"
	mysqlclose $sqlhand
	putquick "NOTICE nice92 :SRT rajouté à la base ( $arg1 )-( $arg2 )-( $arg3 )."
} 

putlog "SRT Script chargé"