###############################################################################
#  Name:                                        Youtube Title
#  Author:                                      jotham.read@gmail.com
#  Credits:                                     tinyurl proc taken from
#                                                  tinyurl.tcl by jer@usa.com.
#                                               design inspiration from
#                                                  youtube.tcl by Mookie.
#  Eggdrop Version:     1.6.x
#  TCL version 8.1.1 or newer http://wiki.tcl.tk/450
#
#  Changes:
#  0.5 01/02/09
#    Added better error reporting for restricted youtube content.
#  0.4 10/11/09
#    Changed title scraping method to use the oembed api.
#    Added crude JSON decoder library.
#  0.3 02/03/09
#    Fixed entity decoding problems in return titles.
#    Added customisable response format.
#    Fixed rare query string bug.
###############################################################################
#
#  Configuration
#
###############################################################################

# Maximum time to wait for youtube to respond
set youtube(timeout)            "30000"
# Youtube oembed location to use as source for title queries. It is best to use
# nearest youtube location to you.  For example http://uk.youtube.com/oembed
set youtube(oembed_location)    "http://www.youtube.com/oembed"
# Use tinyurl service to create short version of youtube URL. Values can be
# 0 for off and 1 for on.
set youtube(tiny_url)           1
# Response Format
# %botnick%         Nickname of bot
# %post_nickname%   Nickname of person who posted youtube link
# %title%           Title of youtube link
# %youtube_url%     URL of youtube link
# %tinyurl%         Tiny URL for youtube link. tiny_url needs to be set above.
# Example:
#   set youtube(response_format) "\"%title%\" ( %tinyurl% )"
set youtube(response_format) "Titre Youtube: \"%title%\""
# Bind syntax, alter as suits your needs
bind pubm - * public_youtube
# Pattern used to patch youtube links in channel public text
set youtube(pattern) {http://.*youtube.*/watch\?(.*)v=([A-Za-z0-9_\-]+)}
# This is just used to avoid recursive loops and can be ignored.
set youtube(maximum_redirects)  2
# The maximum number of characters from a youtube title to print
set youtube(maximum_title_length) 256
###############################################################################

package require http

set gTheScriptVersion "0.5"

proc note {msg} {
  putlog "% $msg"
}

###############################################################################

proc make_tinyurl {url} {
 if {[info exists url] && [string length $url]} {
  if {[regexp {http://tinyurl\.com/\w+} $url]} {
   set http [::http::geturl $url -timeout 9000]
   upvar #0 $http state ; array set meta $state(meta)
   ::http::cleanup $http ; return $meta(Location)
  } else {
   set http [::http::geturl "http://tinyurl.com/create.php" \
     -query [::http::formatQuery "url" $url] -timeout 9000]
   set data [split [::http::data $http] \n] ; ::http::cleanup $http
   for {set index [llength $data]} {$index >= 0} {incr index -1} {
    if {[regexp {href="http://tinyurl\.com/\w+"} [lindex $data $index] url]} {
     return [string map { {href=} "" \" "" } $url]
 }}}}
 error "failed to get tiny url."
}

###############################################################################

proc flat_json_decoder {info_array_name json_blob} {
   upvar 1 $info_array_name info_array
   # 0 looking for key, 1 inside key, 2 looking for value, 3 inside value 
   set kvmode 0
   set cl 0
   set i 1 
   set length [string length $json_blob]
   while { $i < $length } {
      set c [string index $json_blob $i]
      if { [string equal $c "\""] && [string equal $cl "\\"] == 0 } {
         if { $kvmode == 0 } {
            set kvmode 1
            set start [expr $i + 1]
         } elseif { $kvmode == 1 } {
            set kvmode 2
            set name [string range $json_blob $start [expr $i - 1]]
         } elseif { $kvmode == 2 } {
            set kvmode 3
            set start [expr $i + 1]
         } elseif { $kvmode == 3 } {
            set kvmode 0
            set info_array($name) [string range $json_blob $start [expr $i - 1]]
         }
      }
      set cl $c
      incr i 1
   }
}

proc filter_title {blob} {
   # Try and convert escaped unicode
   set blob [subst -nocommands -novariables $blob]
   set blob [string trim $blob]
   set blob
}

proc extract_title {json_blob} {
   global youtube
   array set info_array {}
   flat_json_decoder info_array $json_blob
   if { [info exists info_array(title)] } {
      set title [filter_title $info_array(title)]
   } else {
      error "Failed to find title.  JSON decoding failure?"
   }
   if { [string length $title] > $youtube(maximum_title_length) - 1 } {
      set title [string range $title 0 $youtube(maximum_title_length)]"..."
   } elseif { [string length $title] == 0 } {
      set title "No usable title."
   }
   return $title
}

###############################################################################

proc fetch_title {youtube_uri {recursion_count 0}} {
    global youtube
    if { $recursion_count > $youtube(maximum_redirects) } {
        error "maximum recursion met."
    }
    set query [http::formatQuery url $youtube_uri]
    set response [http::geturl "$youtube(oembed_location)?$query" -timeout $youtube(timeout)]
    upvar #0 $response state
    foreach {name value} $state(meta) {
        if {[regexp -nocase ^location$ $name]} {
            return [fetch_title $value [incr recursion_count]]
        }
    }
	if [expr [http::ncode $response] == 401] {
		error "Location contained restricted embed data."
	} else {
	    set response_body [http::data $response]
	    http::cleanup $response
	    return [extract_title $response_body]
	}
}

proc public_youtube {nick userhost handle channel args} {
    global youtube botnick
    if {[regexp -nocase -- $youtube(pattern) $args match fluff video_id]} {
        note "Fetching title for $match."
        if {[catch {set title [fetch_title $match]} error]} {
            note "Failed to fetch title: $error"
        } else {
            set tinyurl $match
            if { $youtube(tiny_url) == 1 && \
              [catch {set tinyurl [make_tinyurl $match]}]} {
               note "Failed to make tiny url for $match."
            }
            set tokens [list %botnick% $botnick %post_nickname% \
                $nick %title% "$title" %youtube_url% \
                "$match" %tinyurl% "$tinyurl"]
            set result [string map $tokens $youtube(response_format)]
            putserv "PRIVMSG $channel :$result" 
        }
    }
}

###############################################################################

note "youtube_title$gTheScriptVersion: loaded";

