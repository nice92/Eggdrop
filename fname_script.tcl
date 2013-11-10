### CONF ### 

# search command 
set fname(cmd) "!fname" 
set rname(cmd) "!rname"
set add(cmd) "!addname"

# channel flag 
set db(flag) "Search" 

# max results 
set db(results) "5" 

# DB INFO 
set db(host) "localhost" 
set db(user) "user" 
set db(pass) "pass" 
set db(name) "name" 
set db(table) "table"

# END CONF 
load /usr/lib/tcltk/mysqltcl-3.051/libmysqltcl3.051.so
bind pub -|- $fname(cmd) fname
bind pub -|- $rname(cmd) rname
bind pub o|o $add(cmd) addname

setudef flag $db(flag) 

proc fname { nick host hand chan arg} { 
	global fname
	global db
		if {![channel get $chan $db(flag)]} { 
		return 0 
	} 
	if {$arg == ""} { 
		putquick "NOTICE $nick :\002Syntax:\017 $fname(cmd) <filename>" 
		return 0 
	} 
	set search [lrange [split $arg] 0 end]
	set partiel [string map { " " "%" } $search] 
	set opt "%"
	set resultat [lindex $opt$partiel$opt]
	set sql(handle) [mysqlconnect -host $db(host) -user $db(user) -password $db(pass) -db $db(name)] 
	set sql(query) [::mysql::query $sql(handle) "SELECT * FROM `$db(table)` WHERE `dirname` LIKE '$resultat' LIMIT $db(results) "]
		if {[::mysql::result $sql(query) rows] < 1} { 
			putquick "NOTICE $nick :Aucun résultat pour \'\002$search\' " 
	} else { 
		while {[set row [::mysql::fetch $sql(query)]] != ""} { 
		set id [lindex $row 0] 
        	set filename [lindex $row 1] 
        	set releasename [lindex $row 2] 
        putquick "NOTICE $nick :\002\00307\[\17 \037Demande:\17 $filename \002\00307]\17"
        putquick "NOTICE $nick :\002\00307\[\17 \037Résultat:\17 $releasename \002\00307]\17"
    } 
  } 
  ::mysql::endquery $sql(query) 
  mysqlclose $sql(handle) 
} 
proc rname { nick host hand chan arg} { 
	global rname
	global db
		if {![channel get $chan $db(flag)]} { 
		return 0 
	} 
	if {$arg == ""} { 
		putquick "NOTICE $nick :\002Syntax:\017 $rname(cmd) <nom de fichier ou release>" 
		return 0 
	} 
	set search [lrange [split $arg] 0 end]
	set partiel [string map { " " "%" } $search] 
	set opt "%"
	set resultat [lindex $opt$partiel$opt]
	set sql(handle) [mysqlconnect -host $db(host) -user $db(user) -password $db(pass) -db $db(name)] 
	set sql(query) [::mysql::query $sql(handle) "SELECT * FROM `$db(table)` WHERE `releasename` LIKE '$resultat' LIMIT $db(results) "]
		if {[::mysql::result $sql(query) rows] < 1} { 
			putquick "NOTICE $nick :Aucun résultat pour \'\002$search\' " 
	} else { 
		while {[set row [::mysql::fetch $sql(query)]] != ""} { 
		set id [lindex $row 0] 
        	set filename [lindex $row 1] 
        	set releasename [lindex $row 2] 
        putquick "NOTICE $nick :\002\00307\[\17 \037Demande:\17 $releasename \002\00307]\17"
        putquick "NOTICE $nick :\002\00307\[\17 \037Résultat:\17 $filename \002\00307]\17"
    } 
  } 
  ::mysql::endquery $sql(query) 
  mysqlclose $sql(handle) 
} 

proc addname { nick host hand chan arg} { 
	global addname
	global db
		if {![channel get $chan $db(flag)]} { 
		return 0 
	} 
	if {$arg == ""} { 
		putquick "NOTICE $nick :\002Syntax:\017 $add(cmd) <filename> <releasename>" 
		return 0 
	} 
	set arg1 [lindex $arg 0]
	set arg2 [lindex $arg 1]
	set sqlhand [mysqlconnect -host $db(host) -user $db(user) -password $db(pass)]
	mysqluse $sqlhand $db(name)
	mysqlexec $sqlhand "UPDATE `$db(name)`.`$db(table)` SET `filename` = '$arg2' WHERE `$db(table)`.`dirname` ='$arg1';"
	mysqlclose $sqlhand
	putquick "NOTICE $nick :Filename rajouté à la base ( $arg1 )-( $arg2 )."
} 
 

putlog "Fname Script par nice92 chargé"