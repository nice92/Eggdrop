##############################################################################################
##  ##     rottentomato.tcl for eggdrop by Ford_Lawnmower irc.geekshed.net #Script-Help ##  ##
##############################################################################################
## To use this script you must set channel flag +rotten (ie .chanset #chan +rotten)         ##
##############################################################################################
##############################################################################################
##  ##                             Start Setup.                                         ##  ##
##############################################################################################
## Change rotten_cmdchar to the character you want to use.                                  ##
set rotten_cmdchar "!"
## Change rotten_lang to the 2 digit language code you want to use                          ##
set rotten_lang "en"
proc rotten {nick host hand chan rottensite rottenurl rottensearch} {
  if {[lsearch -exact [channel info $chan] +rotten] != -1} {
## Change the characters between the "" below to change the logo shown with each result.    ##
    set rottenlogo "\002\00307\[RottenTomatoes\]\017"
## Change the format codes between the "" below to change the color/state of the text.      ##
    set rottentext "\00314"
## Change the format codes between the "" below to change the color/state of the tags.      ##
    set rottentags "\017\002"
## Change the format codes between the "" below to change the color/state of the links.     ##
    set rottenlinks "\037"
## You may adjust how the results are printed by changing line1, line2 and line3            ##
## Valid items are as follows: cast genre director link imdblink title audiencescore        ##
## audiencerating criticrating criticconsensus criticscore synopsis date mpaarating         ## 
    set line1 "title date genre director cast mpaarating"
    set line2 "criticrating criticscore audiencescore"
    set line3 "synopsis"
    set line4 "link imdblink"
##############################################################################################
##  ##                           End Setup.                                              ## ##
##############################################################################################
    if {[catch {set rottenSock [socket -async $rottensite 80]} sockerr]} {
      putserv "PRIVMSG $chan :$rottensite $rottenurl $sockerr error"
      return 0
      } else {
      puts $rottenSock "GET $rottenurl HTTP/1.0"
      puts $rottenSock "Host: $rottensite"
      puts $rottenSock "User-Agent: Opera 9.6"
      puts $rottenSock ""
      flush $rottenSock
      set rottenimdblink ""
      set rottentitle ""
      set rottencast ""
      set rottensynopsis ""
      set rottengenre ""
      set rottendirector ""
      set rottencriticrating ""
      set rottenlink ""
      set rottentitle ""
      set rottenmpaarating ""
      set rottencriticscore ""
      set rottendate ""
      set rottenaudiencerating ""
      set rottenaudiencescore ""
      set rottencriticconsensus ""
      while {![eof $rottenSock]} {
        set rottenvar " [gets $rottenSock] "
        if {[regexp {may refer to:} $rottenvar] || [regexp {HTTP\/1\.0 403} $rottenvar]} {
           putserv "PRIVMSG $chan :\002Nothing found on rotten! Please refine your search and check your spelling."
           close $rottenSock
	   return 0
        } 
        if {[string match "*\"total\":0*" $rottenvar]} {
          putlog "Nothing found"
        } 
        if {[string match "*\"error\":\"Could not find a movie with the specified id\"*" $rottenvar]} {
          set rottenurl "/api/public/v1.0/movies.json?apikey=rtchpv52u3vmrs497ux275an&q=${rottensearch}&page_limit=1&page=1"
          close $rottenSock
          rotten $nick $host $hand $chan $rottensite $rottenurl $rottensearch
          return 0
        } 
        if {[regexp {"synopsis":"(.*?)"\x2c"} $rottenvar match rottensynopsis]} {
          if {$rottensynopsis != ""} {
            set rottensynopsis "${rottentags}Synopsis:\017 ${rottentext}${rottensynopsis}\017"
          }
        } 
        if {[regexp {"critics_rating":"(.*?)"\x2c"} $rottenvar match rottencriticrating]} {
          set rottencriticrating "${rottentags}Critics Rating:\017 ${rottentext}${rottencriticrating}\017"
        }
        if {[regexp {"mpaa_rating":"(.*?)"\x2c"} $rottenvar match rottenmpaarating]} {
          set rottenmpaarating "${rottentags}MPAA Rating:\017 ${rottentext}${rottenmpaarating}\017"
        } 
        if {[regexp {"genres":\x5b(.*?)\x5d\x2c"} $rottenvar match rottengenre]} {
          set rottengenre "${rottentags}Genre:\017 ${rottentext}${rottengenre}\017"
        } 
        if {[regexp {"critics_consensus":"(.*?)"\x2c"} $rottenvar match rottencriticconsensus]} {
          set rottencriticconsensus "${rottentags}Critics Consensus:\017 ${rottentext}${rottencriticconsensus}\017"
        } 
        if {[regexp {"release_dates":\x7b(.*?)\x7d\x2c} $rottenvar match rottendate]} {
          set rottendate "${rottentags}Release Date:\017 ${rottentext}${rottendate}\017"
        }
        if {[regexp {\{"id":(\d*)\x2c} $rottenvar match rottenlink]} {
          set rottenlink "${rottentags}Link:\017 ${rottentext}${rottenlinks}http://rottentomatoes.com/m/${rottenlink}/\017"
        }
        if {[regexp {\{"id":"(\d*)"\x2c} $rottenvar match rottenlink]} {
          set rottenlink "${rottentags}Link:\017 ${rottentext}${rottenlinks}http://rottentomatoes.com/m/${rottenlink}/\017"
        }
        if {[regexp {"title":(.*?)\x2c} $rottenvar match rottentitle]} {
          set rottentitle "${rottentags}Title:\017 ${rottentext}${rottentitle}\017"
        } 
        if {[regexp {"year":(.*?)\x2c} $rottenvar match rottenyear]} {
          set rottenyear "${rottentags}Year:\017 ${rottentext}${rottenyear}\017"
        } 
        if {[regexp {"runtime":(.*?)\x2c} $rottenvar match rottenruntime]} {
          set rottenruntime "${rottentags}Runtime:\017 ${rottentext}${rottenruntime}\017"
        } 
        if {[regexp {"critics_score":(.*?)\x2c} $rottenvar match rottencriticscore]} {
          set rottencriticscore "${rottentags}Critic Score:\017 ${rottentext}${rottencriticscore}\017"
        } 
        if {[regexp {"audience_rating":(.*?)\x2c} $rottenvar match rottenaudiencerating]} {
          set rottenaudiencerating "${rottentags}Audience Rating:\017 ${rottentext}${rottenaudiencerating}\017"
        } 
        if {[regexp {"audience_score":(.*?)\x7d\x2c} $rottenvar match rottenaudiencescore]} {
          set rottenaudiencescore "${rottentags}Audience Score:\017 ${rottentext}${rottenaudiencescore}\017"
        } 
        if {[regexp {"name":"(.*?)"} $rottenvar match rottencast]} {
          set rottencast [regexp -all -inline {"name":(".*?")} $rottenvar]
          set rottencast "Cast: $rottencast"
          set counter 0
          set rottentemp ""
          foreach i $rottencast {
            if {$counter && ![expr $counter % 2]} {
              set rottentemp "${rottentemp}[rotteniif $rottentemp "\,"]${i}"
            }
            incr counter
          }
          set rottencast "${rottentags}Cast:\017 ${rottentext}${rottentemp}\017"
        } 
        if {[regexp {"abridged_directors":\x5b\x7b(.*?)\x7d\x5d} $rottenvar match rottendirector]} {
          set rottendirector "${rottentags}Director:\017 ${rottentext}[string map {\"name\": " " \} "" \{ ""} $rottendirector]\017"
        }
        if {[regexp {"imdb":"(.*?)"} $rottenvar match rottenimdblink]} {
          set rottenimdblink "${rottentags}IMDb:\017 ${rottentext}${rottenlinks}http://www.imdb.com/title/tt${rottenimdblink}/\017"
        }
        if {[string match "*\"id\":*" $rottenvar]} {
          if {$line1 != ""} {
            rottenmsg $chan $rottenlogo $rottentext [subst [regsub -all -nocase {(\S+)} $line1 {$rotten\1}]]
          }
          if {$line2 != ""} {
            rottenmsg $chan $rottenlogo $rottentext [subst [regsub -all -nocase {(\S+)} $line2 {$rotten\1}]]
          }
          if {$line3 != ""} {
            rottenmsg $chan $rottenlogo $rottentext [subst [regsub -all -nocase {(\S+)} $line3 {$rotten\1}]]
          }
          if {$line4 != ""} {
            rottenmsg $chan $rottenlogo $rottentext [subst [regsub -all -nocase {(\S+)} $line4 {$rotten\1}]]
          }
        }
      }
    }
      close $rottenSock
      return 0 
  }
}
proc rottenround {num} {
  return [expr {round($num)}]
}
proc rottenmsg {chan logo textf text} {
  set text [rottentextsplit $text 50]
  set counter 0
  while {$counter <= [llength $text]} {
    if {[lindex $text $counter] != ""} {
      putserv "PRIVMSG $chan :${logo} ${textf}[lindex $text $counter]"
    }
    incr counter
  }
}
proc googlerottensearch {nick host hand chan search} {
  global rotten_lang
  if {[lsearch -exact [channel info $chan] +rotten] != -1} {
    set googlerottensite "www.google.com"
    set googlerottensearch [string map {{ } \%20} "${search}"]
    set googlerottenurl "/search?q=${googlerottensearch}+site:imdb.com&rls=${rotten_lang}&hl=${rotten_lang}"
    if {[catch {set googlerottenSock [socket -async $googlerottensite 80]} sockerr]} {
      putserv "PRIVMSG $chan :$googlerottensite $googlerottenurl $sockerr error"
      return 0
    } else {
      puts $googlerottenSock "GET $googlerottenurl HTTP/1.0"
      puts $googlerottenSock "Host: $googlerottensite"
      puts $googlerottenSock "User-Agent: Opera 9.6"
      puts $googlerottenSock ""
      flush $googlerottenSock
      while {![eof $googlerottenSock]} {
        set googlerottenvar " [gets $googlerottenSock] "
	if {[regexp {<cite>.*?imdb\.com\/title\/tt(.*?)\/} $googlerottenvar match googlerottenurl]} {
          set rottensite "api.rottentomatoes.com"
          set rottenurl "/api/public/v1.0/movie_alias.json?apikey=rtchpv52u3vmrs497ux275an&type=imdb&id=${googlerottenurl}"
          rotten $nick $host $hand $chan $rottensite $rottenurl $googlerottensearch
          close $googlerottenSock
	  return 0
	}
      }
      putserv "PRIVMSG $chan :\002Nothing found on rotten! Please refine your search and check your spelling."
      close $googlerottenSock
      return 0 
    }
  }
}
proc rotteniif {test do} {
   if {$test != 0 && $test != ""} {
     return $do
   } else {
     return ""
   }
}
proc rottentextsplit {text limit} {
  set text [split $text " "]
  set tokens [llength $text]
  set start 0
  set return ""
  while {[llength [lrange $text $start $tokens]] > $limit} {
    incr tokens -1
    if {[llength [lrange $text $start $tokens]] <= $limit} {
      lappend return [join [lrange $text $start $tokens]]
      set start [expr $tokens + 1]
      set tokens [llength $text]
    }
  }
  lappend return [join [lrange $text $start $tokens]]
  return $return
}
proc rottenhex {decimal} { return [format %x $decimal] }
proc rottendecimal {hex} { return [expr 0x$hex] }
proc rottendehex {string} {
  regsub -all {^\{|\}$} $string "" string
  set string [subst [regsub -nocase -all {\&#x([0-9a-f]{1,3});} $string {[format %c [rottendecimal \1]]}]]
  set string [subst [regsub -nocase -all {\&#([0-9]{1,3});} $string {[format %c \1]}]]
  set string [string map {&quot; \" &middot; · &amp; & <b> \002 </b> \002} $string]
  return $string
}
proc rottenstrip {string} {
  regsub -all {<[^<>]+>} $string "" string
  regsub -all {\[\d+\]} $string "" string
  return $string
}
bind pub - [string trimleft $rotten_cmdchar]rotten googlerottensearch
bind pub - [string trimleft $rotten_cmdchar]rt googlerottensearch
bind pub - [string trimleft $rotten_cmdchar]tomato googlerottensearch
setudef flag rotten
putlog "RottenTomatoes par Ford_Lawnmower chargé"