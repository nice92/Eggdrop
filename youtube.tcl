# YouTube (Eggdrop/Tcl), Version 1.3
#
# (c) creative (QuakeNet - #computerbase), 15. Feb. 2012
#
# This program is free software: you can redistribute it and / or modify it under the
# terms of the GNU General Public License, see http://www.gnu.org/licenses/gpl.html.
#
# Example:
# <bo2000> like her new video https://www.youtu.be/kfVsfOSbJY0
# <eggbert> [Y] Rebecca Black - Friday - Official Music Video, 17.09.2011 (O 1.8)
#
# Notice:
# !youtube (on|off) enables or disables script for active channel (flags "mno" only)

setudef flag youtube

bind pubm - *youtu.be/* YouTube
bind pubm - *youtube.com/watch*v=* YouTube
bind pub mno|mno !youtube YouTube-Settings

proc YouTube {nick host hand chan text} {

	if {[channel get $chan youtube]} {
		set y_api "http://gdata.youtube.com/feeds/api/videos/"
		set y_odf "%d.%m.%Y"

		if {[catch {package require http 2.5}]} {
			putlog "YouTube: package http 2.5 or above required"
		} else {

			if {[regexp -nocase {(^|[ ]{1})(https{0,1}:\/\/(www\.){0,1}|www\.)(youtu\.be\/|youtube\.com\/watch[^ ]{1,}v=)([A-Za-z0-9_-]{11})} $text - - - - - y_vid]} {

				if {[catch {set y_con [::http::geturl $y_api$y_vid -headers [list {GData-Version} {2}] -timeout 5000]}]} {
					putlog "YouTube: connection error (e. g. host not found / reachable)"
				} elseif {[::http::status $y_con] == "ok"} {
					set y_data [::http::data $y_con]
					catch {::http::cleanup $y_con}
				} else {
					putlog "YouTube: connection error (e. g. time out / no data received)"
					catch {::http::cleanup $y_con}
				}

			}

		}

	}

	if {[info exists y_data]} {

		if {[regexp -nocase {<title>(.{1,})<\/title>} $y_data - y_data_t]} {
			set y_data_t [string map -nocase [list {&quot;} {"} {&amp;} {&} {&lt;} {<} {&gt;} {>}] $y_data_t]
			regsub -all -nocase {[ ]{1,}} $y_data_t { } y_data_t
		} else {
			putlog "YouTube: parsing error (<title>, $y_api$y_vid)"
		}

		if {[regexp -nocase {<published>([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.000Z)<\/published>} $y_data - y_data_p]} {
			set y_data_p [clock scan $y_data_p -format %Y-%m-%dT%H:%M:%S.000Z]
			set y_data_p [clock format $y_data_p -format $y_odf]
		} else {
			putlog "YouTube: parsing error (<published>, $y_api$y_vid)"
		}

		if {[regexp -nocase {<gd:rating average='([0-9]{1}\.[0-9]{1,})'} $y_data - y_data_r]} {
			set y_data_r [format %.1f $y_data_r]
			set y_data_r "([encoding convertto utf-8 \u00D8] $y_data_r)"
		} else {
			set y_data_r "([encoding convertto utf-8 \u00D8] NR)"
		}

		if {[info exists y_data_t] && [info exists y_data_p] && [info exists y_data_r]} {
			putserv "privmsg $chan :\[YouTube\] $y_data_t"
		}

	}

}

proc YouTube-Settings {nick host hand chan text} {

	if {![channel get $chan youtube] && $text == "on"} {
		catch {channel set $chan +youtube}
		putserv "notice $nick :YouTube: enabled for $chan"
		putlog "YouTube: script enabled (by $nick for $chan)"
	} elseif {[channel get $chan youtube] && $text == "off"} {
		catch {channel set $chan -youtube}
		putserv "notice $nick :YouTube: disabled for $chan"
		putlog "YouTube: script disabled (by $nick for $chan)"
	} else {
		putserv "notice $nick :YouTube: !youtube (on|off) enables or disables script for active channel"
	}

}

putlog "YouTube 1.3 chargé"