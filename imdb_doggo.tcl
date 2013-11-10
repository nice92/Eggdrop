# 04/04/2012 
# by doggo #omgwtfnzbs @ EFNET 
# drop in and try this script ;) all feedback is welcome 

namespace eval imdb  { 
namespace eval api { 

#trigger to search by ttid  
variable info_tttrig "-tt" 

#title search trigger 
variable info_strig "-imdb" 

#channel to work in 
variable imdb_channel "#chan" 


variable ttsearch_url "http://www.omdbapi.com/?i" 
variable titlesearch_url "http://www.omdbapi.com/?t" 
variable pub "PRIVMSG $imdb::api::imdb_channel" 
variable info_htrig "??imdb" 

} 

bind pub -|- $imdb::api::info_tttrig imdb::imdb_evaluate::evaluate_imdb 
bind pub -|- $imdb::api::info_strig imdb::imdb_evaluate_search::search_evaluate_imdb 
bind pub -|- $imdb::api::info_htrig imdb::imdb_helper::helper_imdb 


# get info from ttid proc 
namespace eval imdb_evaluate { 
proc evaluate_imdb {nick hand host chan titleid} { 

set titleid [stripcodes bcruag $titleid] 
set ttid [lindex [split $titleid] 0] 
set action "" 
set action [lindex [split $titleid] 1] 

if {$ttid==""} {putquick "$imdb::api::pub :Usage: $imdb::api::info_ttrig tt1899353";return} 
if {![regexp {^tt([0-9]+)$} $ttid match imdbid] } {putquick "$imdb::api::pub :Error: not a valid ttid";return} 

catch {set http [::http::geturl $imdb::api::ttsearch_url=tt$imdbid -timeout 15000]} error 
set information [::http::data $http] 
::http::cleanup $http 
regexp -nocase {response\"\:\"(.*?)\"} $information match response 

if {![info exists response]} {putquick "$imdb::api::pub :$imdb::api::ttsearch_url=tt$imdbid timed out.. recommence dans peu de temps ";return} 
if {![string match "True" $response]} {putquick "$imdb::api::pub :Erreur: IMDb ID inconnu";return} 

::imdb::imdb_trigger::trigger_imdb $information $action 

  } 
} 


# get info from title search proc 
namespace eval imdb_evaluate_search { 
proc search_evaluate_imdb {nick hand host chan search_text} { 

set search_term [stripcodes bcruag $search_text] 
set do_search [lrange [split $search_term] 0 end] 
set imdbswitch "" 

if {$do_search==""} {putquick "$imdb::api::pub :Usage: $imdb::api::info_strig Mission Impossible";return} 

if {[regexp -nocase {^([A-Za-z0-9\s]+)\s\-\-([a-z]+)$} $do_search match imdbsearch imdbswitch]} { 

catch {set http [::http::geturl $imdb::api::titlesearch_url=[string map { " " "+" } $imdbsearch] -timeout 15000]} error 
set information [::http::data $http] 
::http::cleanup $http 

regexp -nocase {response\"\:\"(.*?)\"} $information match response 

if {![info exists response]} {putquick "$imdb::api::pub :Error: $imdb::api::titlesearch_url=[string map { " " "+" } $imdbsearch] timed out.. try again in a bit ";return} 
if {![string match "True" $response]} {putquick "$imdb::api::pub :Error: 0 Results for $imdbsearch";return} 

::imdb::imdb_trigger::trigger_imdb $information $imdbswitch 

} elseif {[regexp {^([A-Za-z0-9\s]+)$} $do_search match imdbsearch]} { 

catch {set http [::http::geturl $imdb::api::titlesearch_url=[string map { " " "+" } $imdbsearch] -timeout 15000]} error 
set information [::http::data $http] 
::http::cleanup $http 

regexp -nocase {response\"\:\"(.*?)\"} $information match response 

if {![info exists response]} {putquick "$imdb::api::pub :Error: $imdb::api::titlesearch_url=[string map { " " "+" } $imdbsearch] timed out.. try again in a bit ";return} 
if {![string match "True" $response]} {putquick "$imdb::api::pub :Error: 0 Results for $imdbsearch";return} 

::imdb::imdb_trigger::trigger_imdb $information $imdbswitch 

} else {putquick "$imdb::api::pub :Erreur: bad input";return} 

  } 
} 


# parse the returned jason proc 
namespace eval imdb_trigger { 
proc trigger_imdb {api_response type} { 

set information [lindex $api_response 0] 
set action [lindex $type 0] 

regexp -nocase {title\"\:\"(.*?)\"} $information match titre
regexp -nocase {year\"\:\"(.*?)\"} $information match annee
regexp -nocase {rated\"\:\"(.*?)\"} $information match rated 
regexp -nocase {released\"\:\"(.*?)\"} $information match date 
regexp -nocase {genre\"\:\"(.*?)\"} $information match genre
regexp -nocase {director\"\:\"(.*?)\"} $information match realisateur
regexp -nocase {writer\"\:\"(.*?)\"} $information match scenariste
regexp -nocase {actors\"\:\"(.*?)\"} $information match acteurs
regexp -nocase {plot\"\:\"(.*?)\"} $information match synopsis 
regexp -nocase {poster\"\:\"(.*?)\"} $information match affiche 
regexp -nocase {runtime\"\:\"(.*?)\"} $information match duree 
regexp -nocase {rating\"\:\"(.*?)\"} $information match note 
regexp -nocase {votes\"\:\"(.*?)\"} $information match votes 
regexp -nocase {ID\"\:\"(.*?)\"} $information match id 

switch -exact -- [string tolower $action] { 

"titre" { 
        putquick "$imdb::api::pub :\00312\[IMDB Titre\]\017 $titre" 
} 

"annee" { 
        putquick "$imdb::api::pub :\00312\[IMDB Année\]\017 $annee" 
} 

"date" { 
        putquick "$imdb::api::pub :\00312\[IMDB Date\]\017 $date" 
} 

"genre" { 
        putquick "$imdb::api::pub :\00312\[IMDB Genre\]\017 $genre" 
} 

"realisateur" { 
        putquick "$imdb::api::pub :\00312\[IMDB Réalisteur\]\017 $realisateur" 
} 

"scenariste" { 
        putquick "$imdb::api::pub :\00312\[IMDB Scénariste\]\017 $scenariste" 
} 

"acteurs" { 
        putquick "$imdb::api::pub :\00312\[IMDB Acteurs\]\017 $acteurs" 
} 

"synopsis" { 
        putquick "$imdb::api::pub :\00312\[IMDB Synopsis\]\017 $synopsis" 
} 

"affiche" { 
        putquick "$imdb::api::pub :\00312\[IMDB Affiche\]\017 $affiche" 
} 

"duree" { 
        putquick "$imdb::api::pub :\00312\[IMDB Durée\]\017 $duree" 
} 

"note" { 
        putquick "$imdb::api::pub :\00312\[IMDB Note\]\017 $note/10" 
} 

"votes" { 
        putquick "$imdb::api::pub :\00312\[IMDB Votes\]\017 $votes" 
} 

"tt" { 
        putquick "$imdb::api::pub :\00312\[IMDB Id\]\017 $id" 
} 

default { 
        putquick "$imdb::api::pub :\00312\[Titre\]\017 $titre \00314($id)\017 \00312\[Genre\]\017 $genre \00312\[Note\]\017 $note/10 ($votes votes) \00312\[Durée\]\017 $duree \00312\[Année\]\017 $annee \00312\[Date\]\017 $date" 
        putquick "$imdb::api::pub :\00312\[Synopsis\]\017 $synopsis" 
        putquick "$imdb::api::pub :\00312\[Réalisateur\]\017 $realisateur \00312\[Scénariste\]\017 $scenariste \00312\[Acteurs\]\017 $acteurs" 
        putquick "$imdb::api::pub :\00312\[Affiche\]\017 $affiche" 
      } 
    } 
  } 
} 


# usage helper proc 
namespace eval imdb_helper {
proc helper_imdb {nick hand host chan text} {
        putquick "$imdb::api::pub :[Search IMDB Id\] $imdb::api::info_tttrig tt0234215 | ou | $imdb::api::info_tttrig tt0234215 switch"
        putquick "$imdb::api::pub :[Search Titres\] $imdb::api::info_strig the matrix reloaded | ou | $imdb::api::info_strig the matrix reloaded --switch"
        putquick "$imdb::api::pub :[Search Switches\] titre annee date genre realisateur scenariste acteurs synopsis affiche duree note votes tt | pas de switch = spam :D"
  } 
} 


#//end all 
}