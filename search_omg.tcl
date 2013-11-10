# search omgwtfnzbs.com's api
# omg_search.v1.tcl
# by doggo #omgwtfnzbs@EFNET
############################
 
package require http
 
bind pub - -omg omgwtfnzb:search
 
proc omgwtfnzb:search {n u h c t} {
 
        #remove colour & junk chars
        regsub -all {\`|\"|'|\$|\'} $t {} t
        regsub -all {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036} $t {} t
 
        # user details for omgwtfnzbs.com
        set username ""
        set api ""
       
        # how many results the bot spits out
        set how_many "10"
 
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
 
        regsub -all {<post>} $xx "\n" xx
        regsub -all {</post>} $xx {} xx
 
        set inc "0"
        foreach xxx [split $xx "\n"] {
        set output [string trim [lindex [split $xxx] 0]]
        if {[string length $output]} {
        incr inc
 
        regexp -nocase {<nzbid>(.*?)</nzbid>} $output match x1
        regexp -nocase {<release>(.*?)</release>} $output match x2
        regexp -nocase {<group>(.*?)</group>} $output match x3
        regexp -nocase {<sizebytes>(.*?)</sizebytes>} $output match x4
        regexp -nocase {<usenetage>(.*?)</usenetage>} $output match x5
        regexp -nocase {<categoryid>(.*?)</categoryid>} $output match x6
        regexp -nocase {<cattext>(.*?)</cattext>} $output match x7
        regexp -nocase {<details>(.*?)</details>} $output match x8
        regexp -nocase {<getnzb>(.*?)</getnzb>} $output match x9
 
        puthelp "NOTICE $n :\002\00304\[\17 $x1 \002\00304]\17 => \002\00304\[\17 $x2 \002\00304]\17 \00314=> \002\00308\[\17 \00314$x7 \002\00308]\17 \00314=> \002\00308\[\17 \00314$x8 \002\00308]\17"
 
 
        if {$inc==$how_many} { break }
        }
 
 
 
}
 
}