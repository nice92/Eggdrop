###########################################
# tvrage LOOKUP SCRIPT (dlx @ linknet)    #
###########################################
# v2.3 - changed the way !today and       #
#        !tomorrow reply for less spam    #
###########################################
# v2.2 - added tvrage(inline) support     #
#        for iPoRn                        #
###########################################
# v2.1 - added time output to !tonight    #
#         and !tomorrow for nogruk        #
###########################################
# v2.0 - new commands !next/!last/	      #
#	     !tonight/!tomorrow               #
###########################################

bind pub - -tv dlx:tvrage:tv
bind pub - -next dlx:tvrage:next
bind pub - -last dlx:tvrage:last
bind pub - -now dlx:tvrage:tonight
bind pub - -demain dlx:tvrage:tomorrow
 
# Channels not to be displayed on !tonight/!tomorrow
set tvrage(excluded_Channels) [list "OWN" "NBC Sports Network" "Fuel TV" "Biography Channel" "HUB" "TV Guide Channel" "Pay-Per-View" "Science Channel" "Ovation TV" "National Geographic Wild" "Discovery Health Channel" "VH1 Classic" "IFC" "Sundance" "HDNet" "OLN" "Logo" "DIRECTV" "Investigation Discovery" "Bravo" "Versus" "TV Land" "History Channel" "ID: Investigation Discovery" "Military Channel" "DIY Network" "WE" "National Geographic Channel" "Travel Channel" "Syndicated" "truTV" "Discovery Velocity" "NHL Network" "Sportsman Channel" "Lifetime" "G4" "Oxygen" "MTV2" "ESPN" "ESPN2" "Nickelodeon" "Disney Channel" "Style" "VH1" "HGTV" "PBS" "Cooking Channel" "Food Network" "TLC" "Discovery Channel" "Spike TV" "E!" "A&E" "Cartoon Network" "Animal Planet"]

# Show the Time of the show?
set tvrage(show_time) "TRUE"

# Show the Episode number of the show?
set tvrage(show_episode) "TRUE"

# Display !tonight and !tomorrow in one line?
# TRUE will squeeze all shows into one line
# FALSE will split them up by channel (DEFAULT)
set tvrage(inline) "FALSE"

proc dlx:tvrage:tv { nick host hand chan arg } {
	package require http
    set prefix "\002\0037(TVRage)\003\002 "
 
    set arg [string map { " " "%20" } $arg]
 
    set url "http://services.tvrage.com/tools/quickinfo.php?show=$arg"
    set page [http::data [http::geturl $url]]
 
    regexp {Show Name@([A-Za-z 0-9\&\':]+)} $page gotname show_name
    regexp {Show URL@http://www.tvrage.com/([A-Za-z_0-9/-]+)} $page goturl show_url
    regexp {Premiered@([0-9]+)} $page gotpremiere show_premiered
    regexp {Latest Episode@([0-9x]+)\^([A-Za-z0-9 -\`\"\'\&:\.,]+)\^([A-Za-z0-9/]+)} $page gotlatest latest_ep latest_ep_title latest_ep_date
    set gotnext [regexp {Next Episode@([0-9x]+)\^([A-Za-z0-9 -\`\"\'\&:.,]+)\^([A-Za-z0-9/]+)} $page gotnext next_ep next_ep_title next_ep_date]
    regexp {Country@([A-Za-z]+)} $page gotcountry show_country
    regexp {Status@([A-Za-z/ ]+)} $page gotstatus show_status
    regexp {Classification@([A-Za-z ]+)} $page gotclassification show_classification
    set gotgenres [regexp {Genres@([A-Za-z |]+)} $page gotgenres show_genres]
    regexp {Network@([A-Za-z 0-9]+)} $page gotnetwork show_network
    regexp {Airtime@([A-Za-z, 0-9:]+)} $page gotairtime show_airtime
 
    set show_url "http://www.tvrage.com/$show_url"
    if { $gotgenres == 0 } { set show_genres "N/A" }
    if { $gotnext == 0 } {
            set next_ep "00x00"
            set next_ep_title "-N/A-"
            set next_ep_date "not available"
 }
	putquick "PRIVMSG $chan :$prefix \00314$show_name |\00314 \00307Dernier épisode:\00307 \00314$latest_ep_title ($latest_ep)($latest_ep_date) |\00314 \00307Prochain épisode:\00307 \00314$next_ep_title ($next_ep)($next_ep_date) |\00314 \00307Genre:\00307 \00314$show_genres |\00314 \00307Status:\00307 \00314$show_status |\00314 \00307Network:\00307 \00314$show_network |\00314 \00307URL\00307 \00314$show_url\00314"
}

proc dlx:tvrage:next { nick host hand chan arg } {
	package require http
    set prefix "\002\0037(TVrage) ->\003\002 "
    set arg [string map { " " "_" } $arg]
 
    set url "http://services.tvrage.com/tools/quickinfo.php?show=$arg"
    set page [http::data [http::geturl $url]]
 
    regexp {Show Name@([A-Za-z 0-9\&\':]+)} $page gotname show_name
    set gotnext [regexp {Next Episode@([0-9x]+)\^([A-Za-z0-9 -\`\"\'\&:.,]+)\^([A-Za-z0-9/]+)} $page gotnext next_ep next_ep_title next_ep_date]
    regexp {Airtime@([A-Za-z, 0-9:]+)} $page gotairtime show_airtime

    if { $gotnext == 0 } {
		putquick "PRIVMSG $chan :$prefix Le prochain épisode de \002$show_name\002 n'est pas encore programmée."
    } else {
	putquick "PRIVMSG $chan :$prefix Le prochain épisode de \002$show_name\002 est \002$next_ep_title \[$next_ep\]\002, il sera diffusé \002$show_airtime\002 \002$next_ep_date\002"
	}
}
 
proc dlx:tvrage:last { nick host hand chan arg } {
	package require http
    set prefix "\002\0037(TVrage) ->\003\002 "
    set arg [string map { " " "_" } $arg]
 
    set url "http://services.tvrage.com/tools/quickinfo.php?show=$arg"
    set page [http::data [http::geturl $url]]
 
    regexp {Show Name@([A-Za-z 0-9\&\':]+)} $page gotname show_name
    regexp {Latest Episode@([0-9x]+)\^([A-Za-z0-9 -\`\"\'\&:\.,]+)\^([A-Za-z0-9/]+)} $page gotlatest latest_ep latest_ep_title latest_ep_date
    set gotnext [regexp {Next Episode@([0-9x]+)\^([A-Za-z0-9 -\`\"\'\&:.,]+)\^([A-Za-z0-9/]+)} $page gotnext next_ep next_ep_title next_ep_date]
 
	putquick "PRIVMSG $chan :$prefix Le dernier épisode de \002$show_name\002 était \002$latest_ep_title $latest_ep\ \002 a été diffusé le \002$latest_ep_date\002"
}

proc dlx:tvrage:tonight { nick host hand chan arg } {
	global tvrage
	if { [info exists chans] } { unset chans }
	package require http
	set prefix "\002\0037(TVrage)\003\002 "
	set schedule [http::data [http::geturl "http://services.tvrage.com/tools/quickschedule.php"]]

	set end [string first "\n\n" $schedule]
	set today [string range $schedule 0 $end]

	putquick "PRIVMSG $chan :$prefix Programmation du Jour:"

	set showList "$prefix "

	foreach line [split $today "\n"] {
		set found_time [regexp {\[TIME\](.*)\[\/TIME\]} $line found_time time]
		set found_show [regexp {\[SHOW\](.*)\^(.*)\^(.*)\^(.*)\[\/SHOW\]} $line found_show show_channel show_name show_ep show_url]
		if { $found_show && [lsearch -exact $tvrage(excluded_Channels) $show_channel] == -1 } {
			if { $tvrage(inline) } {
				append showList "$show_name ($show_ep) - "
			} else {
				if {$tvrage(show_time)} { append chans($show_channel) "\00307$time: " }
				append chans($show_channel) "\002\00314$show_name\002 "
				if {$tvrage(show_episode)} { append chans($show_channel) "($show_ep) " }
			}
		}
	}
	if { $tvrage(inline) } {
		set showList [string range $showList 0 [expr [string length $showList] - 3]]
		putquick "PRIVMSG $chan :$showList"
	} else {
		set chanlist [array names chans]
		foreach x $chanlist {
			putquick "PRIVMSG $chan :$x\: $chans($x)"
		}
	}
}

proc dlx:tvrage:tomorrow { nick host hand chan arg } {
	global tvrage
	if { [info exists chans] } { unset chans }
	package require http
	set prefix "\002\0037(TVrage)\003\002 "
	set schedule [http::data [http::geturl "http://services.tvrage.com/tools/quickschedule.php"]]

	set start [string first "\n\n" $schedule]
	set schedule [string range $schedule [expr $start+3] end]

	set end [string first "\n\n" $schedule]
	set tomorrow [string range $schedule 0 $end]

	putquick "PRIVMSG $chan :$prefix Programmation de Demain:"

	set showList "$prefix "

	foreach line [split $tomorrow "\n"] {
		set found_time [regexp {\[TIME\](.*)\[\/TIME\]} $line found_time time]
		set found_show [regexp {\[SHOW\](.*)\^(.*)\^(.*)\^(.*)\[\/SHOW\]} $line found_show show_channel show_name show_ep show_url]
		if { $found_show && [lsearch -exact $tvrage(excluded_Channels) $show_channel] == -1 } {
			if { $tvrage(inline) == "TRUE" } {
				append showList "$show_name ($show_ep) - "
			} else {
				if {$tvrage(show_time)} { append chans($show_channel) " \00307$time: " }
				append chans($show_channel) "\002\00314$show_name\002 "
				if {$tvrage(show_episode)} { append chans($show_channel) "($show_ep) " }
			}
		}
	}
	if { $tvrage(inline) == "TRUE" } {
		set showList [string range $showList 0 [expr [string length $showList] - 3]]
		putquick "PRIVMSG $chan :$showList"
	} else {
		set chanlist [array names chans]
		foreach x $chanlist {
			putquick "PRIVMSG $chan :$x\: $chans($x)"
		}
	}
}

putlog "dlx-tvrage_v2.3.tcl loaded. enjoy!"