# --------------------------------------------------------------------------- #
# Script : google.tcl                                                    
# Auteur : ealexp
#          Certaines parties de ce script ont �t� �crites par MenzAgitat.
# Version : 1.0
# Date de cr�ation : 25 septembre 2010
# Date de derni�re modification : 23 janvier 2011
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# D�pendances :
#    - le package json <= ok
#    - le package http <= ok
#    - Tcl 8.5 <= ok
#    - une version d'Eggdrop sup�rieure ou �gale � 1.6.19 <= ok, c'est 1.8
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Configuration : 
# Le script fonctionnera tr�s bien avec les r�glages par d�faut.
#
# Cependant, vous pouvez modifier : 
#    - le nom des commandes
#    - les flags n�cessaires pour les utiliser
#    - la langue des r�sultats
#    - le nombre de r�sultats affich�s au maximum
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Activation :
# Le script est compos� de fonctionnalit�s activables et d�sactivables
# s�par�ment, toutes d�sactiv�es par d�faut : 
#    - la recherche (flag : google_search)
#    - Google Fight (flag : google_fight)
#    - la m�t�o (flag : google_meteo)
#    - la calculette (flag : google_calc)
#
# Vous devez d'abord activer le script globalement, en tapant
# .chanset #salon +google_global en partyline, puis activer les diff�rentes
# parties s�par�ment.
#
# Exemple : 
# Pour activer la recherche sur le salon #salon, il faut taper
# .chanset #salon +google_search en partyline.
# Pour activer la m�t�o sur le salon #salon, il faut taper
#.chanset #salon +google_meteo en partyline.
# Et ainsi de suite.
#
# Attention : Si le script est d�sactiv� globalement, l'activation s�par�e des
# fonctionnalit�s n'aura plus aucun effet.
#
# Pour #cinema, commandes � taper en partyline :
#
# - Activation du script : .chanset #cinema +google_global
#
# - Activation des fonctionnalit�s :
#
# .chanset #cinema +google_search
# .chanset #cinema +google_fight
# .chanset #cinema +google_meteo
# .chanset #cinema +google_calc
#
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Description : 
# 
# Ce script permet l'utilisation de certains services Google sur IRC.
#
# 1) La recherche
# 
#  Commande : !google <recherche>
#  Exemple : <@ealexp> !google google
#            <@jibe> 96 100 000 r�sultats | Google http://www.google.com/  | Google Maps http://maps.google.com/  | Google Videos http://video.google.com/  | Google.org - Google Technology-Driven Philanthropy http://www.google.org/
#
# 2) Le Google Fight
# 
#  Compare le nombre de r�sultats de deux recherches.
#
#  Commande : !googlefight <recherche1> vs <recherche 2>
#  Exemple : <@ealexp> !googlefight google vs yahoo
#            <@jibe> google bat yahoo avec 96 100 000 r�sultat(s) contre 53 400 000 r�sultat(s)
# 
# 3) La calculatrice
#   
#  Effectue des calculs, ainsi que de nombreuses conversions.
#  
#  /!\ Attention ! Pour que Google reconnaisse l'expression, il faut suivre
#  certaines r�gles : 
#     - Les multiples de l'octet (Ko, Mo, Go, To) doivent �tre �crits avec 
#       une majuscule � leur premi�re lettre.
#       
#       Mauvais : !calc 1GO en MO
#       Bon : !calc 1Go en Mo
#
#     - Les unit�s horaires doivent �tre �crites en minuscules et en
#       toutes lettres.
#
#       Mauvais : !calc 1 H en MN
#       Bon : !calc 1 heure en minute
#
#     - Toutes les autres unit�s doivent �tre �crites en minuscules.
#      
#       Mauvais : !calc 1KM en M
#       Bon : !calc 1km en m
#       
#       Mauvais : !calc 1KG en G
#       Bon : !calc 1kg en g
#   
#       Mauvais : !calc 1H en MN
#       Bon : !calc 1h en mn
#
#     - Les expressions ne doivent �tre �crites qu'en une seule langue.
#
#       Mauvais : !calc 1 heure in minutes
#       Mauvais : !calc 1 hour en minutes
#       Bon : !calc 1 heure en minutes
#       Bon : !calc 1 hour in minutes
#
#  Commande : !calc <expression>
#  Exemples : <@ealexp> !calc 1 + 1 
#             <@jibe> 1 + 1 = 2 
#             
#             <@ealexp> !calc 5 * 3 
#             <@jibe> 5 * 3 = 15
#             
#             <@ealexp> !calc 5 ^ 3 
#             <@jibe> 5^3 = 125 
#
#             <@ealexp> !calc sin(60)
#             <@jibe> sin(60) = -0,304810621
#
#             <@ealexp> !calc 4 - 2 
#             <@jibe> 4 - 2 = 2 
#
#             <@ealexp> !calc 1 minute en heure
#             <@jibe> 1 minute = 0,0166666667 heure
#
#             <@ealexp> !calc 30 minute en heure
#             <@jibe> 30 minute = 0,5 heure
#
#             <@ealexp> !calc 1Go en Mo
#             <@jibe> 1 gigaoctet = 1024 m�gaoctets
#
#             <@ealexp> !calc 1km en m
#             <@jibe> 1 kilom�tre = 1000 m�tres
#
#             <@ealexp> !calc 4% de 1Go
#             <@jibe> 4 % de (1 gigaoctet) = 40,96 m�gaoctets
#
# 4) La m�t�o
#
#  Affiche la m�t�o de la ville demand�e.
#  
#  Commande : !meteo <ville>
#  Exemple : <@ealexp> !meteo Marseille
#            <@jibe> Conditions m�t�orologiques pour Marseilles, Provence-Alpes-C�te d'Azur : Couverture nuageuse partielle | 2� | Humidit� : 60�% | Vent : NO � 23 km/h
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Changements : 
#    - 1.0 : premi�re version
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Licence : 
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------------- #


if {[catch {package require http}]} {
	putlog "\002Google\002 : Vous avez besoin du package http pour pouvoir utiliser ce script."
	return
}

if {[catch {package require json}]} {
	putlog "\002Google\002 : Vous avez besoin du package json pour pouvoir utiliser ce script."
	return
}

if {[catch {package require Tcl 8.5}]} {
	putlog "\002Google\002 : Vous avez besoin de Tcl en version 8.5 au moins pour pouvoir utiliser ce script."
	return
}

if {[info commands ::google::uninstall] eq "::google::uninstall"} { ::google::uninstall }

namespace eval google {
	#######################
	#                     #
	#    CONFIGURATION    #
	#                     #
	#######################
	
	# Nom de la commande Google. Vous pouvez en mettre plusieurs, s�par�s par un espace.
	# Valeur par d�faut : {!google}
	variable google_command_name {!google}

	# Flags n�cessaires pour utiliser la commande Google.
	# Valeur par d�faut : "-|-"
	variable google_command_flags "-|-"
	
	# Nom de la commande pour calculer. Vous pouvez en mettre plusieurs, s�par�s par un espace.
	# Valeur par d�faut : {!calc !convert}
	variable calc_command_name {!calc !convert}

	# Flags n�cessaires pour utiliser la commande pour calculer.
	# Valeur par d�faut : "-|-"
	variable calc_command_flags "-|-"
	
	# Nom de la commande Google Fight. Vous pouvez en mettre plusieurs, s�par�s par un espace.
	# Valeur par d�faut : {!googlefight}
	variable googlefight_command_name {!googlefight}

	# Flags n�cessaires pour utiliser la commande Google Fight.
	# Valeur par d�faut : "-|-"
	variable googlefight_command_flags "-|-"

	# Nom de la commande pour la m�t�o. Vous pouvez en mettre plusieurs, s�par�s par un espace.
	# Valeur par d�faut : {!meteo}
	variable meteo_command_name {!meteo}

	# Flags n�cessaires pour utiliser la commande m�t�o.
	# Valeur par d�faut : "-|-"
	variable meteo_command_flags "-|-"

	# Langue des r�sultats.
	# Valeur par d�faut : "fr"
	variable lang "fr"

	# Maximum de r�sultats affich�s. Note : l'API Google retourne au maximum 8 r�sultats.
	# Valeur par d�faut : 4
	variable max_results 4

	# Nombre de caract�res maximal par ligne.
	# Valeur par d�faut : 420
	variable max_line_length 420

	#######################################################################
	#                                                                     #
	#    NE RIEN MODIFIER APR�S CE CADRE SI VOUS NE CONNAISSEZ PAS TCL    #
	#                                                                     #
	#######################################################################	
	
	variable script_name "google"
	variable script_version "1.0"
	variable debug 1
	
	# URL de l'API de recherche.
	variable url "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&%s&hl=%s&rsz=%s"

	# URL de l'API de calcul.
	variable convert_url "http://www.google.com/ig/calculator?%s&hl=%s"
	
	# URL de l'API de m�t�o.
	variable weather_url "http://www.google.com/ig/api?%s&hl=%s"
	
	setudef flag google_global
	setudef flag google_search
	setudef flag google_meteo
	setudef flag google_fight
	setudef flag google_calc

	proc uninstall {args} {
		putlog "D�sallocation des ressources de \002$::google::script_name\002..."
		foreach binding [lsearch -inline -all -regexp [binds *[set google [string range [namespace current] 2 end]]*] " \{?(::)?$google"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		namespace delete [namespace current]
	}
}

# ::google::google_command
#
# Proc�dure principale de la commande !google.

proc ::google::google_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_search]} { return }
	
	# La recherche sous forme de dictionnaire
	set data [search $text]
	
	# Les r�sultats en eux-m�me
	set results [dict get $data results]

	# Le nombre de r�sultats
	set result_count [dict get $data cursor estimatedResultCount]
	
	# On commence � construire le message...
	append privmsg "[c bold $chan][separate_thousands $result_count][c bold $chan] r�sultats[c 7 $chan] | [c endcolor $chan]"

	set counter 0
	foreach result $results {
		# On ajoute le r�sultat en cours
		append privmsg "[c 14 $chan][dict get $result title][c endcolor $chan] [c 12 $chan][c underline $chan][dict get $result url][c underline $chan][c endcolor $chan] "

		# Si le nombre de r�sultats maximum est atteint, on arr�te.
		if {$counter == ($::google::max_results - 1)} {
			break
		} else {
			# Sinon, on rajoute encore un s�parateur au message.
			append privmsg "[c 7 $chan] | [c endcolor $chan]"
		}

		incr counter
	}
	
	# Et finalement on envoie le message.
	foreach line [wrap $privmsg $::google::max_line_length] {
		puthelp "PRIVMSG $chan :$line"
	}
}

# ::google::calc_command
#
# Proc�dure principale pour la commande !calc.

proc ::google::calc_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_calc]} { return }
	
	# On cr�e la requ�te.
	set query [::http::formatQuery q [clean_input $text]]
	
	# On envoie la requ�te.
	set token [::http::geturl [format $::google::convert_url $query $::google::lang]]

	# Et on r�cup�re les r�sultats.
	set data [::http::data $token]
	set data [string_filter $data]
	::http::cleanup $token
	
	# before : l'expression donn�e par l'utilisateur
	# after : l'expression telle qu'�valu�e par Google
	# error : s'il y a eu une erreur
	# icc : si l'expression donn�e par l'utilisateur a �t� modifi�e
	regexp {\{lhs: "(.*?)",rhs: "(.*?)",error: "(.*?)",icc: (.*?)\}} $data dummy before after error icc
	
	if {(![info exists before]) || (![info exists after]) || (![info exists error]) || (![info exists icc])} {
		puthelp "PRIVMSG $chan :[c 14 $chan]Erreur : Google a renvoy� une r�ponse incorrecte.[c endcolor $chan]"
		return
	}

	# On traite les �ventuelles erreurs.
	switch -glob -- $error {
		"" {# Aucune erreur}
		"0" {# Aucune erreur}

		"Error evaluating operation" {
			# Unit�s incompatibles
			puthelp "PRIVMSG $chan :[c 14 $chan]Impossible d'�valuer l'expression. V�rifiez, par exemple, que vous n'avez pas essay� d'additionner des m�tres et des kilogrammes.[c endcolor $chan]"
			return
		}

		"Numerical Error" {
			# Un des termes ne peut pas �tre calcul�
			puthelp "PRIVMSG $chan :[c 14 $chan]Un des termes de l'expression ne peut pas �tre calcul�. V�rifiez qu'il n'y a pas de bases ou d'exposants trop grands ou des divisions par 0.[c endcolor $chan]"
			return
		}

		"Parse error around *" {
			# Impossible d'analyser l'expression
			puthelp "PRIVMSG $chan :[c 14 $chan]Il y a une erreur de syntaxe dans l'expression pr�s de : [lindex [split $error] 3]"
			return
		}
		
		"Parse error in query. *" {
			# Erreur de syntaxe
			puthelp "PRIVMSG $chan :[c 14 $chan]Il y a une erreur de syntaxe dans l'expression. Les termes sont : [lrange [split $error] 7 end]"
			return
		}

		default {
			# Erreur g�n�rique
			puthelp "PRIVMSG $chan :[c 14 $chan]Erreur de calcul. V�rifiez que les noms d'unit�s et de fonctions sont corrects. Les multiples de l'octet doivent �tre �crits avec leur premi�re lettre en majuscule. Toutes les autres unit�s doivent �tre �crites en minuscules. Les unit�s horaires doivent �tre �crites en toutes lettres et en minuscules.[c endcolor $chan]"
			putlog $error
			return

		}
	}
	
	# On envoie le message.
	puthelp "PRIVMSG $chan :[c 14 $chan]$before[c endcolor $chan] [c 7 $chan]=[c endcolor $chan] [c 14 $chan]$after[c endcolor $chan]"
}

# ::google::googlefight_command
#
# Proc�dure principale de la commande !googlefight.

proc ::google::googlefight_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_fight]} { return }
	
	# On r�cup�re les deux recherches.
	if {![regexp {^(.*?) vs (.*?)$} $text dummy search_1 search_2]} {
		puthelp "PRIVMSG $chan :[c 14 $chan]Utilisation : $::google::googlefight_command_name <mot 1> vs <mot 2>[c endcolor $chan]"
		return
	}

	# On r�cup�re les deux nombres de r�sultats.
	set result_count_1 [dict get [search $search_1] cursor estimatedResultCount]
	set result_count_2 [dict get [search $search_2] cursor estimatedResultCount]
	
	# On cr�e le mod�le du message � envoyer.
	set privmsg_template "[c bold $chan]%s[c bold $chan] [c 14 $chan]bat[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]avec[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]r�sultat(s)[c endcolor $chan] [c 14 $chan]contre[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]r�sultat(s)[c endcolor $chan]"
	set tied_privmsg_template "[c bold $chan]%s[c bold $chan] [c 14 $chan]est � �galit� avec[c endcolor $chan] [c bold $chan]%s[c bold $chan][c 14 $chan], tous les deux ayant[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]r�sultat(s)[c endcolor $chan]"

	if {$result_count_1 > $result_count_2} {
		set privmsg [format $privmsg_template $search_1 $search_2 [separate_thousands $result_count_1] [separate_thousands $result_count_2]]

		puthelp "PRIVMSG $chan :$privmsg"
	} elseif {$result_count_1 < $result_count_2} {
		set privmsg [format $privmsg_template $search_2 $search_1 [separate_thousands $result_count_2] [separate_thousands $result_count_1]]

		puthelp "PRIVMSG $chan :$privmsg"
	} else {
		set privmsg [format $tied_privmsg_template $search_1 $search_2 [separate_thousands $result_count_1]]

		puthelp "PRIVMSG $chan :$privmsg"
	}
	
}

# ::google::meteo_command
#
# Proc�dure principale de la commande !meteo

proc ::google::meteo_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_meteo]} { return }

	# On cr�e la requ�te.
	set query [::http::formatQuery weather $text]
	
	# On envoie la requ�te.
	set token [::http::geturl [format $::google::weather_url $query $::google::lang]]

	# Et on r�cup�re les r�sultats.
	set data [string_filter [::http::data $token] let_tags]
	::http::cleanup $token

	# Oui, j'aimerais bien avoir un parser XML.

	# On extrait le "c�ur" de la r�ponse.
	if {![regexp {<\?xml version="1.0"\?><xml_api_reply version="(?:.*?)"><weather module_id="(?:.*?)" tab_id="(?:.*?)" mobile_row="(?:.*?)" mobile_zipped="(?:.*?)" row="(?:.*?)" section="(?:.*?)" >(.*)</weather></xml_api_reply>} $data dummy answer]} {
		# Google a renvoy� une mauvaise r�ponse.
		puthelp "PRIVMSG $chan :[c 14 $chan]Google a renvoy� une r�ponse mal format�e. 1[c endcolor $chan]"

		return
	}
	
	# On v�rifie s'il n'y a pas eu d'erreur.
	if {[regexp {<problem_cause data="(.*?)"/>} $answer dummy error]} {
		puthelp "PRIVMSG $chan :[c 14 $chan]$error[c endcolor $chan]"
		return
	}

	if {![regexp {<city data="(.*?)"/>(?:.*?)<current_conditions><condition data="(.*?)"/><temp_f data="(?:.*?)"/><temp_c data="(.*?)"/><humidity data="(.*?)"/><icon data="(?:.*?)"/><wind_condition data="(.*?)"/></current_conditions>} $data dummy city_name condition temperature humidity wind]} {
		# Google a renvoy� une mauvaise r�ponse.
		puthelp "PRIVMSG $chan :[c 14 $chan]Google a renvoy� une r�ponse mal format�e. 2[c endcolor $chan]"

		return
	}
	
	puthelp "PRIVMSG $chan :Conditions m�t�orologiques pour [c bold $chan]$city_name[c bold $chan] : $condition [c 7 $chan]|[c endcolor $chan] ${temperature}� [c 7 $chan]|[c endcolor $chan] $humidity [c 7 $chan]|[c endcolor $chan] $wind"
	return
}

# ::google::search
#
# Effectue une recherche et renvoie le JSON converti en un dictionnaire.

proc ::google::search {text} {
	# On formate la requ�te.
	set query [::http::formatQuery q $text]
	
	# On l'envoie.
	set token [::http::geturl [format $::google::url $query $::google::lang $::google::max_results]]

	# On r�cup�re les donn�es.
	set data [::http::data $token]
	::http::cleanup $token
	
	# On la convertit en un dictionnaire.
	set results [::json::json2dict $data]
	set results [dict get $results responseData]
	
	# On la nettoie et on la retourne.
	return [string_filter $results]
}

# ::google::clean_input
#
# Nettoie une expression pour qu'elle puisse �tre comprise par Google.

proc ::google::clean_input {text} {
	# On enl�ve les s�parateurs de milliers des nombres.
	set text [remove_spaces $text]

	return [string trim $text]
}

# ::google::remove_spaces
#
# Enl�ve les s�parateurs de milliers d'un nombre.

proc ::google::remove_spaces {text} {
	return [regsub -all {(\d+)\s(?=\d)} $text {\1}]
}

# ::google::separate_thousands
#
# Effectue exactement le travail inverse de la derni�re proc�dure : 
# s�pare les milliers d'un nombre fourni par des espaces.

proc ::google::separate_thousands {number} {
	# Ici, pour s�parer les milliers, on renverse d'abord la cha�ne.
	# La cha�ne "1000000" deviendra donc "0000001".
	#
	# Ensuite, on met un espace tous les trois caract�res, gr�ce � une regexp.
	# � ce stade l�, la cha�ne est devenue "000 000 1"
	#
	# Puis on renverse encore une fois la cha�ne.
	# On a donc "1 000 000". Les milliers sont bien s�par�s.
	#
	# Puis on retourne la cha�ne ainsi obtenue, en prenant bien soin d'enlever
	# les espaces au d�but ou � la fin.

	return [string trim [string reverse [regsub -all {\d{3}} [string reverse $number] {& }]]]
}

# ::google::wrap
#
# Coupe une cha�ne tous les $width caract�res.
# Si elle peut, elle coupe entre deux mots, sinon, elle peut couper un mot en
# deux.

proc ::google::wrap {text {width 1}} {
	incr width -1
	set text [string trim $text]
	set text_length [string length $text]
	
	if {$width < 0} {
		error "width doit �tre positif"
	}
	
	if {$text_length <= $width} {
		return [list $text]
	} else {
		set cursor 0
		while {$cursor < $text_length} {
			if {([set cut_index [::tcl::string::last " " $text [expr {$cursor+$width}]]] == -1) || ($cut_index <= $cursor) || ($text_length - $cursor < $width)} {
			    set cut_index [expr {$cursor + $width}]
			}

			lappend output [::tcl::string::range $text $cursor $cut_index]
			set cursor [expr {$cut_index+1}]
		}   
		return $output
	}   
}

# ::google::c
# 
# V�rifie que les codes couleurs sont autoris�s sur le salon pass� en
# argument et renvoie le code couleur demand�.

proc ::google::c {code chan} {
	if {[string match *c* [lindex [split [getchanmode $chan]] 0]] || $code eq ""} {
		return ""
	}
	
	switch -- $code {
		"bold" {
			return \002
		}

		"underline" {
			return \037
		}

		"endcolor" {
			return \003
		}

		default {
			return \003$code
		}
	}
}

# ::google::string_filter
#
# Nettoie les r�ponses envoy�s par Google.

proc ::google::string_filter {str {let_tags no}} {
	# Pour convertir la cha�ne depuis UTF-8 vers l'encodage du syst�me
	set str [encoding convertfrom utf-8 $str]
	
	# On remplace \x3c et \x3e par leurs caract�res correspondants.
	# Cela ne peut pas �tre fait par subst, car Google renvoie parfois
	# \x3e68, ce qui correspond pour Google � >68, mais pour Tcl � \x68...
	set str [string map -nocase {
		"\\x3c" "<"
		"\\x3e" ">"
	} $str]
	
	# Ensuite, on substitue tous les autres codes d'�chappement.
	set str [subst -nocommands -novariables $str]
	
	# On substitue aussi les codes d'�chappement HTML.
	set str [string map -nocase {
		"&agrave;"    "�"   "&agrave;"    "�"   "&aacute;"    "�"   "&acirc;"     "�"
		"&atilde;"    "�"   "&auml;"      "�"   "&aring;"     "�"   "&aelig;"     "�"
		"&ccedil;"    "�"   "&egrave;"    "�"   "&eacute;"    "�"   "&ecirc;"     "�"
		"&euml;"      "�"   "&igrave;"    "�"   "&iacute;"    "�"   "&icirc;"     "�"
		"&iuml;"      "�"   "&eth;"       "�"   "&ntilde;"    "�"   "&ograve;"    "�"
		"&oacute;"    "�"   "&ocirc;"     "�"   "&otilde;"    "�"   "&ouml;"      "�"
		"&divide;"    "�"   "&oslash;"    "�"   "&ugrave;"    "�"   "&uacute;"    "�"
		"&ucirc;"     "�"   "&uuml;"      "�"   "&yacute;"    "�"   "&thorn;"     "�"
		"&yuml;"      "�"   "&quot;"      "\""  "&amp;"       "&"   "&euro;"      "�"
		"&oelig;"     "�"   "&Yuml;"      "�"   "&nbsp;"      " "   "&iexcl;"     "�"
		"&cent;"      "�"   "&pound;"     "�"   "&curren;"    "�"   "&yen;"       "�"
		"&brvbar;"    "�"   "&brkbar;"    "�"   "&sect;"      "�"   "&uml;"       "�"
		"&die;"       "�"   "&copy;"      "�"   "&ordf;"      "�"   "&laquo;"     "�"
		"&not;"       "�"   "&shy;"       "�-"  "&reg;"       "�"   "&macr;"      "�"
		"&hibar;"     "�"   "&deg;"       "�"   "&plusmn;"    "�"   "&sup2;"      "�"
		"&sup3;"      "�"   "&acute;"     "�"   "&micro;"     "�"   "&para;"      "�"
		"&middot;"    "�"   "&cedil;"     "�"   "&sup1;"      "�"   "&ordm;"      "�"
		"&raquo;"     "�"   "&frac14;"    "�"   "&frac12;"    "�"   "&frac34;"    "�"
		"&iquest;"    "�"   "&Agrave;"    "�"   "&Aacute;"    "�"   "&Acirc;"     "�"
		"&Atilde;"    "�"   "&Auml;"      "�"   "&Aring;"     "�"   "&AElig;"     "�"
		"&Ccedil;"    "�"   "&Egrave;"    "�"   "&Eacute;"    "�"   "&Ecirc;"     "�"
		"&Euml;"      "�"   "&Igrave;"    "�"   "&Iacute;"    "�"   "&Icirc;"     "�"
		"&Iuml;"      "�"   "&ETH;"       "�"   "&Dstrok;"    "�"   "&Ntilde;"    "�"
		"&Ograve;"    "�"   "&Oacute;"    "�"   "&Ocirc;"     "�"   "&Otilde;"    "�"
		"&Ouml;"      "�"   "&times;"     "�"   "&Oslash;"    "�"   "&Ugrave;"    "�"
		"&Uacute;"    "�"   "&Ucirc;"     "�"   "&Uuml;"      "�"   "&Yacute;"    "�"
		"&THORN;"     "�"   "&szlig;"     "�"   "\r"          "\n"  "\t"          ""
		"&#039;"      "\'"  "&#39;"       "\'"
		"&#34;"       "\'"  "&#38;"       "&"   "#91;"        "\("  "&#92;"       "\/"
		"&#93;"       ")"   "&#123;"      "("   "&#125;"      ")"   "&#163;"      "�"
		"&#168;"      "�"   "&#169;"      "�"   "&#171;"      "�"   "&#173;"      "�"
		"&#174;"      "�"   "&#180;"      "�"   "&#183;"      "�"   "&#185;"      "�"
		"&#187;"      "�"   "&#188;"      "�"   "&#189;"      "�"   "&#190;"      "�"
		"&#192;"      "�"   "&#193;"      "�"   "&#194;"      "�"   "&#195;"      "�"
		"&#196;"      "�"   "&#197;"      "�"   "&#198;"      "�"   "&#199;"      "�"
		"&#200;"      "�"   "&#201;"      "�"   "&#202;"      "�"   "&#203;"      "�"
		"&#204;"      "�"   "&#205;"      "�"   "&#206;"      "�"   "&#207;"      "�"
		"&#208;"      "�"   "&#209;"      "�"   "&#210;"      "�"   "&#211;"      "�"
		"&#212;"      "�"   "&#213;"      "�"   "&#214;"      "�"   "&#215;"      "�"
		"&#216;"      "�"   "&#217;"      "�"   "&#218;"      "�"   "&#219;"      "�"
		"&#220;"      "�"   "&#221;"      "�"   "&#222;"      "�"   "&#223;"      "�"
		"&#224;"      "�"   "&#225;"      "�"   "&#226;"      "�"   "&#227;"      "�"
		"&#228;"      "�"   "&#229;"      "�"   "&#230;"      "�"   "&#231;"      "�"
		"&#232;"      "�"   "&#233;"      "�"   "&#234;"      "�"   "&#235;"      "�"
		"&#236;"      "�"   "&#237;"      "�"   "&#238;"      "�"   "&#239;"      "�"
		"&#240;"      "�"   "&#241;"      "�"   "&#242;"      "�"   "&#243;"      "�"
		"&#244;"      "�"   "&#245;"      "�"   "&#246;"      "�"   "&#247;"      "�"
		"&#248;"      "�"   "&#249;"      "�"   "&#250;"      "�"   "&#251;"      "�"
		"&#252;"      "�"   "&#253;"      "�"   "&#254;"      "�"
	} $str]
	
	if {$let_tags ne "let_tags"} {
		# On remplace la balise "exposant" par ^
		regsub -all {<sup>(.*?)</sup>} $str {^\1} str

		# Et on supprime toutes les autres balises HTML.
		regsub -all {<[^>]+>} $str "" str
	}

	return $str
}

namespace eval ::google {	
	###############
	#             #
	#    BINDS    #
	#             #
	###############
	
	bind evnt -|- prerehash ::google::uninstall

	# !google
	foreach ::google::name $::google::google_command_name {
		bind pub $::google::google_command_flags $::google::name ::google::google_command
	}

	# !calc
	foreach ::google::name $::google::calc_command_name {
		bind pub $::google::calc_command_flags $::google::name ::google::calc_command
	}

	# !googlefight
	foreach ::google::name $::google::googlefight_command_name {
		bind pub $::google::googlefight_command_flags $::google::name ::google::googlefight_command
	}

	# !meteo
	foreach ::google::name $::google::meteo_command_name {
		bind pub $::google::meteo_command_flags $::google::name ::google::meteo_command
	}
}
