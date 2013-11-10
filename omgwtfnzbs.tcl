# 2012-07-12
# api.omgwtfnzbs.com
# version 1.0
# doggo #omgwtfnzbs@EFNET
# nzb search n get script for http://api.omgwtfnzbs.com
#######################################################
 
package require http
package require tdom
bind pub - -omg omgwtfnzb:search
bind pub - !get omgwtfnzb:getnzb
bind pub - !helpomg omgwtfnzb:cmds
 
 
#show a little help
proc omgwtfnzb:cmds {n u h c t} {
 
        puthelp "privmsg $c :-omg <some terms>"
        puthelp "privmsg $c :!get <release name>"
 
}
 
 
#parse xml results from omgwtfnzbs api
proc omgwtfnzb:search {n u h c t} {
 
        set flood_set "5"
        variable flood
        if {[info exists flood(lasttime,$n)] && [expr $flood(lasttime,$n) + $flood_set] > [clock seconds]} {
        puthelp "privmsg $c :You can use only 1 command in $flood_set seconds $n. Wait [expr $flood_set - [expr [clock seconds] - $flood(lasttime,$n)]] seconds and try again.";return
        }
 
        #remove colour & junk chars
        regsub -all {\`|\"|'|\$|\'} $t {} t
        regsub -all {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036} $t {} t
 
        # user details for ogwtfnzbs.com
        set username "user"
        set api "api"
       
        # how many results the bot spits out
        set how_many "7"
 
        # do not edit below unless you know what your doing
        # script starts here
 
        set t [string map { " " "%20" } $t]
        set str "http://api.omgwtfnzbs.org/xml/?search=$t&user=$username&api=$api"
 
        ::http::config -useragent "Mozilla/5.0 (X11; U; Linux i686; ru-RU; rv:1.8.1) Gecko/2006101023 Firefox/2.0"
        set data [::http::geturl $str -timeout 5000]
        set xx [::http::data $data]
        ::http::cleanup $xx
 
        regexp -nocase {\{(.*?)\}} $xx match err
 
        if {[info exists err]} {
        puthelp "privmsg $c :$err";return
        }
 
        regsub -all {<xml version="1.0" encoding="ISO-8859-1">} $xx {} xx
        regsub -all {<search_req>} $xx {} xx
        regsub -all {</search_req>} $xx {} xx
        regsub -all {</xml>} $xx {} xx
        set xx [string map { "&amp;" "&" } $xx]
 
        regsub -all {\n} $xx {} xx
        regsub -all {<info>} $xx "\n" xx
        regsub -all {</info>} $xx {} xx
        regsub -all {<post>} $xx "\n" xx
        regsub -all {</post>} $xx {} xx
 
        set inc "0"
        foreach xxx [split $xx "\n"] {
        set output [string trim [lindex [split $xxx] 0]]
        if {[string length $output]} {
        incr inc
 
        regexp -nocase {<nzbid>(.*?)</nzbid>} $output match x5
        regexp -nocase {<release>(.*?)</release>} $output match x6
        regexp -nocase {<sizebytes>(.*?)</sizebytes>} $output match x8
        regexp -nocase {<usenetage>(.*?)</usenetage>} $output match x9
        regexp -nocase {<categoryid>(.*?)</categoryid>} $output match x10
        regexp -nocase {<details>(.*?)</details>} $output match x13
 
        set cat [omgwtfnzb:cats $x6]
        set bytesize [omgwtfnzb:bytesize $x4]
        set timeago [omgwtfnzb:timeago $x5]
 
 
        puthelp "privmsg $c :$cat \002\00304\[\17 $x1 \002\00304]\17 \002\00304\[\17 $x2 \002\00304]\17 $bytesize $timeago \00314$x9"

        if {$inc==$how_many} { break }
        }
   set flood(lasttime,$n) [clock seconds]
   }
 
}
 
 
#grab a single nzb from the release name
proc omgwtfnzb:getnzb {n u h c t} {
 
        set flood_set "10"
        variable flood
        if {[info exists flood(lastnzb,$n)] && [expr $flood(lastnzb,$n) + $flood_set] > [clock seconds]} {
        puthelp "privmsg $c :You can use only 1 command in $flood_set seconds $n. Wait [expr $flood_set - [expr [clock seconds] - $flood(lastnzb,$n)]] seconds and try again or use the website.";return
        }
 
        #remove colour & junk chars
        regsub -all {\`|\"|'|\$|\'} $t {} t
        regsub -all {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036} $t {} t
 
        # user details for ogwtfnzbs.com
        set username "ceny"
        set api "2ef248c04979d6b3a7b283ec3dc32cca"
       
        # how many results the bot spits out
        set how_many "1"
 
        # do not edit below unless you know what your doing
        # script starts here
 
        set t [string map { " " "%20" } $t]
        set str "http://api.omgwtfnzbs.org/xml/?search=$t&user=$username&api=$api"
 
        ::http::config -useragent "Mozilla/5.0 (X11; U; Linux i686; ru-RU; rv:1.8.1) Gecko/2006101023 Firefox/2.0"
        set data [::http::geturl $str -timeout 5000]
        set xx [::http::data $data]
        ::http::cleanup $xx
 
        regexp -nocase {\{(.*?)\}} $xx match err
 
        if {[info exists err]} {
        puthelp "privmsg $c :$err";return
        }
 
        regsub -all {<xml version="1.0" encoding="ISO-8859-1">} $xx {} xx
        regsub -all {<search_req>} $xx {} xx
        regsub -all {</search_req>} $xx {} xx
        regsub -all {</xml>} $xx {} xx
        set xx [string map { "&amp;" "&" } $xx]
 
        regsub -all {\n} $xx {} xx
        regsub -all {<info>} $xx "\n" xx
        regsub -all {</info>} $xx {} xx
        regsub -all {<post>} $xx "\n" xx
        regsub -all {</post>} $xx {} xx
 
        set inc "0"
        foreach xxx [split $xx "\n"] {
        set output [string trim [lindex [split $xxx] 0]]
        if {[string length $output]} {
        incr inc
 
        regexp -nocase {<release>(.*?)</release>} $output match x2
        regexp -nocase {<getnzb>(.*?)</getnzb>} $output match x13
 
        exec curl -s -H "Accept: application/xml" -H "Content-Type: application/xml" -X GET "$x13" -o $x2.nzb
 
        if {[file exists $x2.nzb]} {
        dccsend $x2.nzb $n
        exec rm $x2.nzb
        } else {
        puthelp "privmsg $c :something went wierd... try again"
        }
 
        if {$inc==$how_many} { break }
 
        }
   set flood(lastnzb,$n) [clock seconds]
   }
}
 
 
#convert bytes to human readable
proc omgwtfnzb:bytesize {data} {
       
        if {[expr $data / 1024] >= 1} {set return_data "\[[string range "[expr $data / 1024.0]" 0 [expr [string length "[expr $data / 1024]"]+ 2] ] KB\]"};
        if {[expr $data / 1048576] >= 1} {set return_data "\[[string range "[expr $data / 1048576.0]" 0 [expr [string length "[expr $data / 1048576]"]+ 2] ] MB\]"};
        if {[expr $data / 1073741824] >= 1} {set return_data "\[[string range "[expr $data / 1073741824.0]" 0 [expr [string length "[expr $data / 1073741824]"]+ 2] ] GB\]"};
 
return $return_data
 
}
 
 
#get the age of the nzb
proc omgwtfnzb:timeago {data} {
 
        set now [unixtime]
		incr now -$data
        set then [duration $now]       
        regsub -nocase -all -- { seconds|seconds} $then "s" then
        regsub -nocase -all -- { second|second} $then "s" then
        regsub -nocase -all -- { minutes|minutes} $then "m" then
        regsub -nocase -all -- { minute|minute} $then "m" then
        regsub -nocase -all -- { hours|hours} $then "h" then
        regsub -nocase -all -- { hour|hour} $then "h" then
        regsub -nocase -all -- { days|days} $then "d" then
        regsub -nocase -all -- { day|day} $then "d" then
        regsub -nocase -all -- { weeks|weeks} $then "w" then
        regsub -nocase -all -- { week|week} $then "w" then
        regsub -nocase -all -- { months|months} $then "m" then
        regsub -nocase -all -- { month|month} $then "m" then
        regsub -nocase -all -- { years|years} $then "y" then
        regsub -nocase -all -- { year|year} $then "y" then
 
        set return_ago "\[$then old\]"
 
return $return_ago
 
}
 
 
#return the cat name from catid
proc omgwtfnzb:cats {data} {
       
        set iscat $data
 
                array set cats {
                        1 "\00307\[apps-pc\]\003"
                        2 "\00307\[apps-mac\]\003"
                        3 "\00306\[music-other\]\003"
                        4 "\00307\[apps-linux\]\003"
                        5 "\00307\[apps-phone\]\003"
                        6 "\00307\[apps-other\]\003"
                        7 "\00306\[music-mp3\]\003"
                        8 "\00306\[music-mvid\]\003"
                        9 "\00315\[other-ebook\]\003"
                        10 "\00315\[other-extras-fills\]\003"
                        11 "\00315\[other-other\]\003"
                        12 "\00304\[games-pc\]\003"
                        13 "\00304\[games-mac\]\003"
                        14 "\00304\[games-other\]\003"
                        15 "\00310\[movies-sd\]\003"
                        16 "\00310\[movies-hd\]\003"
                        17 "\00310\[movies-dvd\]\003"
                        18 "\00310\[movies-other\]\003"
                        19 "\00308\[tv-sd\]\003"
                        20 "\00308\[tv-hd]\003"
                        21 "\00308\[tv-other\]\003"
                        22 "\00306\[music-flac\]\003"
                        23 "\00313\[xxx-Others\]\003"
                        24 "\00313\[xxx-hd-clips\]\003"
                        25 "\00313\[xxx-sd-clips\]\003"
                        26 "\00313\[xxx-movies-sd\]\003"
                        27 "\00313\[xxx-movies-hd\]\003"
                        28 "\00313\[xxx-dvd\]\003"
                }
 
                foreach { catnum catagorey } [array get cats] {
 
                        if { $iscat == $catnum } {
                                set return_cat [string toupper $catagorey]
                                break
                        }
                     }
 
return $return_cat
 
}
 
putlog "Omgwtfnzbs.tcl chargé"