# --------------------------------------------------------------------------- #
# Script : google.tcl                                                    
# Auteur : ealexp
#          Certaines parties de ce script ont été écrites par MenzAgitat.
# Version : 1.0
# Date de création : 25 septembre 2010
# Date de dernière modification : 23 janvier 2011
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Dépendances :
#    - le package json <= ok
#    - le package http <= ok
#    - Tcl 8.5 <= ok
#    - une version d'Eggdrop supérieure ou égale à 1.6.19 <= ok, c'est 1.8
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Configuration : 
# Le script fonctionnera très bien avec les réglages par défaut.
#
# Cependant, vous pouvez modifier : 
#    - le nom des commandes
#    - les flags nécessaires pour les utiliser
#    - la langue des résultats
#    - le nombre de résultats affichés au maximum
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Activation :
# Le script est composé de fonctionnalités activables et désactivables
# séparément, toutes désactivées par défaut : 
#    - la recherche (flag : google_search)
#    - Google Fight (flag : google_fight)
#    - la météo (flag : google_meteo)
#    - la calculette (flag : google_calc)
#
# Vous devez d'abord activer le script globalement, en tapant
# .chanset #salon +google_global en partyline, puis activer les différentes
# parties séparément.
#
# Exemple : 
# Pour activer la recherche sur le salon #salon, il faut taper
# .chanset #salon +google_search en partyline.
# Pour activer la météo sur le salon #salon, il faut taper
#.chanset #salon +google_meteo en partyline.
# Et ainsi de suite.
#
# Attention : Si le script est désactivé globalement, l'activation séparée des
# fonctionnalités n'aura plus aucun effet.
#
# Pour #cinema, commandes à taper en partyline :
#
# - Activation du script : .chanset #cinema +google_global
#
# - Activation des fonctionnalités :
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
#            <@jibe> 96 100 000 résultats | Google http://www.google.com/  | Google Maps http://maps.google.com/  | Google Videos http://video.google.com/  | Google.org - Google Technology-Driven Philanthropy http://www.google.org/
#
# 2) Le Google Fight
# 
#  Compare le nombre de résultats de deux recherches.
#
#  Commande : !googlefight <recherche1> vs <recherche 2>
#  Exemple : <@ealexp> !googlefight google vs yahoo
#            <@jibe> google bat yahoo avec 96 100 000 résultat(s) contre 53 400 000 résultat(s)
# 
# 3) La calculatrice
#   
#  Effectue des calculs, ainsi que de nombreuses conversions.
#  
#  /!\ Attention ! Pour que Google reconnaisse l'expression, il faut suivre
#  certaines règles : 
#     - Les multiples de l'octet (Ko, Mo, Go, To) doivent être écrits avec 
#       une majuscule à leur première lettre.
#       
#       Mauvais : !calc 1GO en MO
#       Bon : !calc 1Go en Mo
#
#     - Les unités horaires doivent être écrites en minuscules et en
#       toutes lettres.
#
#       Mauvais : !calc 1 H en MN
#       Bon : !calc 1 heure en minute
#
#     - Toutes les autres unités doivent être écrites en minuscules.
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
#     - Les expressions ne doivent être écrites qu'en une seule langue.
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
#             <@jibe> 1 gigaoctet = 1024 mégaoctets
#
#             <@ealexp> !calc 1km en m
#             <@jibe> 1 kilomètre = 1000 mètres
#
#             <@ealexp> !calc 4% de 1Go
#             <@jibe> 4 % de (1 gigaoctet) = 40,96 mégaoctets
#
# 4) La météo
#
#  Affiche la météo de la ville demandée.
#  
#  Commande : !meteo <ville>
#  Exemple : <@ealexp> !meteo Marseille
#            <@jibe> Conditions météorologiques pour Marseilles, Provence-Alpes-Côte d'Azur : Couverture nuageuse partielle | 2° | Humidité : 60 % | Vent : NO à 23 km/h
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# Changements : 
#    - 1.0 : première version
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
	
	# Nom de la commande Google. Vous pouvez en mettre plusieurs, séparés par un espace.
	# Valeur par défaut : {!google}
	variable google_command_name {!google}

	# Flags nécessaires pour utiliser la commande Google.
	# Valeur par défaut : "-|-"
	variable google_command_flags "-|-"
	
	# Nom de la commande pour calculer. Vous pouvez en mettre plusieurs, séparés par un espace.
	# Valeur par défaut : {!calc !convert}
	variable calc_command_name {!calc !convert}

	# Flags nécessaires pour utiliser la commande pour calculer.
	# Valeur par défaut : "-|-"
	variable calc_command_flags "-|-"
	
	# Nom de la commande Google Fight. Vous pouvez en mettre plusieurs, séparés par un espace.
	# Valeur par défaut : {!googlefight}
	variable googlefight_command_name {!googlefight}

	# Flags nécessaires pour utiliser la commande Google Fight.
	# Valeur par défaut : "-|-"
	variable googlefight_command_flags "-|-"

	# Nom de la commande pour la météo. Vous pouvez en mettre plusieurs, séparés par un espace.
	# Valeur par défaut : {!meteo}
	variable meteo_command_name {!meteo}

	# Flags nécessaires pour utiliser la commande météo.
	# Valeur par défaut : "-|-"
	variable meteo_command_flags "-|-"

	# Langue des résultats.
	# Valeur par défaut : "fr"
	variable lang "fr"

	# Maximum de résultats affichés. Note : l'API Google retourne au maximum 8 résultats.
	# Valeur par défaut : 4
	variable max_results 4

	# Nombre de caractères maximal par ligne.
	# Valeur par défaut : 420
	variable max_line_length 420

	#######################################################################
	#                                                                     #
	#    NE RIEN MODIFIER APRÈS CE CADRE SI VOUS NE CONNAISSEZ PAS TCL    #
	#                                                                     #
	#######################################################################	
	
	variable script_name "google"
	variable script_version "1.0"
	variable debug 1
	
	# URL de l'API de recherche.
	variable url "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&%s&hl=%s&rsz=%s"

	# URL de l'API de calcul.
	variable convert_url "http://www.google.com/ig/calculator?%s&hl=%s"
	
	# URL de l'API de météo.
	variable weather_url "http://www.google.com/ig/api?%s&hl=%s"
	
	setudef flag google_global
	setudef flag google_search
	setudef flag google_meteo
	setudef flag google_fight
	setudef flag google_calc

	proc uninstall {args} {
		putlog "Désallocation des ressources de \002$::google::script_name\002..."
		foreach binding [lsearch -inline -all -regexp [binds *[set google [string range [namespace current] 2 end]]*] " \{?(::)?$google"] {
			unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
		}
		namespace delete [namespace current]
	}
}

# ::google::google_command
#
# Procédure principale de la commande !google.

proc ::google::google_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_search]} { return }
	
	# La recherche sous forme de dictionnaire
	set data [search $text]
	
	# Les résultats en eux-même
	set results [dict get $data results]

	# Le nombre de résultats
	set result_count [dict get $data cursor estimatedResultCount]
	
	# On commence à construire le message...
	append privmsg "[c bold $chan][separate_thousands $result_count][c bold $chan] résultats[c 7 $chan] | [c endcolor $chan]"

	set counter 0
	foreach result $results {
		# On ajoute le résultat en cours
		append privmsg "[c 14 $chan][dict get $result title][c endcolor $chan] [c 12 $chan][c underline $chan][dict get $result url][c underline $chan][c endcolor $chan] "

		# Si le nombre de résultats maximum est atteint, on arrête.
		if {$counter == ($::google::max_results - 1)} {
			break
		} else {
			# Sinon, on rajoute encore un séparateur au message.
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
# Procédure principale pour la commande !calc.

proc ::google::calc_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_calc]} { return }
	
	# On crée la requête.
	set query [::http::formatQuery q [clean_input $text]]
	
	# On envoie la requête.
	set token [::http::geturl [format $::google::convert_url $query $::google::lang]]

	# Et on récupère les résultats.
	set data [::http::data $token]
	set data [string_filter $data]
	::http::cleanup $token
	
	# before : l'expression donnée par l'utilisateur
	# after : l'expression telle qu'évaluée par Google
	# error : s'il y a eu une erreur
	# icc : si l'expression donnée par l'utilisateur a été modifiée
	regexp {\{lhs: "(.*?)",rhs: "(.*?)",error: "(.*?)",icc: (.*?)\}} $data dummy before after error icc
	
	if {(![info exists before]) || (![info exists after]) || (![info exists error]) || (![info exists icc])} {
		puthelp "PRIVMSG $chan :[c 14 $chan]Erreur : Google a renvoyé une réponse incorrecte.[c endcolor $chan]"
		return
	}

	# On traite les éventuelles erreurs.
	switch -glob -- $error {
		"" {# Aucune erreur}
		"0" {# Aucune erreur}

		"Error evaluating operation" {
			# Unités incompatibles
			puthelp "PRIVMSG $chan :[c 14 $chan]Impossible d'évaluer l'expression. Vérifiez, par exemple, que vous n'avez pas essayé d'additionner des mètres et des kilogrammes.[c endcolor $chan]"
			return
		}

		"Numerical Error" {
			# Un des termes ne peut pas être calculé
			puthelp "PRIVMSG $chan :[c 14 $chan]Un des termes de l'expression ne peut pas être calculé. Vérifiez qu'il n'y a pas de bases ou d'exposants trop grands ou des divisions par 0.[c endcolor $chan]"
			return
		}

		"Parse error around *" {
			# Impossible d'analyser l'expression
			puthelp "PRIVMSG $chan :[c 14 $chan]Il y a une erreur de syntaxe dans l'expression près de : [lindex [split $error] 3]"
			return
		}
		
		"Parse error in query. *" {
			# Erreur de syntaxe
			puthelp "PRIVMSG $chan :[c 14 $chan]Il y a une erreur de syntaxe dans l'expression. Les termes sont : [lrange [split $error] 7 end]"
			return
		}

		default {
			# Erreur générique
			puthelp "PRIVMSG $chan :[c 14 $chan]Erreur de calcul. Vérifiez que les noms d'unités et de fonctions sont corrects. Les multiples de l'octet doivent être écrits avec leur première lettre en majuscule. Toutes les autres unités doivent être écrites en minuscules. Les unités horaires doivent être écrites en toutes lettres et en minuscules.[c endcolor $chan]"
			putlog $error
			return

		}
	}
	
	# On envoie le message.
	puthelp "PRIVMSG $chan :[c 14 $chan]$before[c endcolor $chan] [c 7 $chan]=[c endcolor $chan] [c 14 $chan]$after[c endcolor $chan]"
}

# ::google::googlefight_command
#
# Procédure principale de la commande !googlefight.

proc ::google::googlefight_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_fight]} { return }
	
	# On récupère les deux recherches.
	if {![regexp {^(.*?) vs (.*?)$} $text dummy search_1 search_2]} {
		puthelp "PRIVMSG $chan :[c 14 $chan]Utilisation : $::google::googlefight_command_name <mot 1> vs <mot 2>[c endcolor $chan]"
		return
	}

	# On récupère les deux nombres de résultats.
	set result_count_1 [dict get [search $search_1] cursor estimatedResultCount]
	set result_count_2 [dict get [search $search_2] cursor estimatedResultCount]
	
	# On crée le modèle du message à envoyer.
	set privmsg_template "[c bold $chan]%s[c bold $chan] [c 14 $chan]bat[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]avec[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]résultat(s)[c endcolor $chan] [c 14 $chan]contre[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]résultat(s)[c endcolor $chan]"
	set tied_privmsg_template "[c bold $chan]%s[c bold $chan] [c 14 $chan]est à égalité avec[c endcolor $chan] [c bold $chan]%s[c bold $chan][c 14 $chan], tous les deux ayant[c endcolor $chan] [c bold $chan]%s[c bold $chan] [c 14 $chan]résultat(s)[c endcolor $chan]"

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
# Procédure principale de la commande !meteo

proc ::google::meteo_command {nick host handle chan text} {
	if {![channel get $chan google_global] || ![channel get $chan google_meteo]} { return }

	# On crée la requête.
	set query [::http::formatQuery weather $text]
	
	# On envoie la requête.
	set token [::http::geturl [format $::google::weather_url $query $::google::lang]]

	# Et on récupère les résultats.
	set data [string_filter [::http::data $token] let_tags]
	::http::cleanup $token

	# Oui, j'aimerais bien avoir un parser XML.

	# On extrait le "cœur" de la réponse.
	if {![regexp {<\?xml version="1.0"\?><xml_api_reply version="(?:.*?)"><weather module_id="(?:.*?)" tab_id="(?:.*?)" mobile_row="(?:.*?)" mobile_zipped="(?:.*?)" row="(?:.*?)" section="(?:.*?)" >(.*)</weather></xml_api_reply>} $data dummy answer]} {
		# Google a renvoyé une mauvaise réponse.
		puthelp "PRIVMSG $chan :[c 14 $chan]Google a renvoyé une réponse mal formatée. 1[c endcolor $chan]"

		return
	}
	
	# On vérifie s'il n'y a pas eu d'erreur.
	if {[regexp {<problem_cause data="(.*?)"/>} $answer dummy error]} {
		puthelp "PRIVMSG $chan :[c 14 $chan]$error[c endcolor $chan]"
		return
	}

	if {![regexp {<city data="(.*?)"/>(?:.*?)<current_conditions><condition data="(.*?)"/><temp_f data="(?:.*?)"/><temp_c data="(.*?)"/><humidity data="(.*?)"/><icon data="(?:.*?)"/><wind_condition data="(.*?)"/></current_conditions>} $data dummy city_name condition temperature humidity wind]} {
		# Google a renvoyé une mauvaise réponse.
		puthelp "PRIVMSG $chan :[c 14 $chan]Google a renvoyé une réponse mal formatée. 2[c endcolor $chan]"

		return
	}
	
	puthelp "PRIVMSG $chan :Conditions météorologiques pour [c bold $chan]$city_name[c bold $chan] : $condition [c 7 $chan]|[c endcolor $chan] ${temperature}° [c 7 $chan]|[c endcolor $chan] $humidity [c 7 $chan]|[c endcolor $chan] $wind"
	return
}

# ::google::search
#
# Effectue une recherche et renvoie le JSON converti en un dictionnaire.

proc ::google::search {text} {
	# On formate la requête.
	set query [::http::formatQuery q $text]
	
	# On l'envoie.
	set token [::http::geturl [format $::google::url $query $::google::lang $::google::max_results]]

	# On récupère les données.
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
# Nettoie une expression pour qu'elle puisse être comprise par Google.

proc ::google::clean_input {text} {
	# On enlève les séparateurs de milliers des nombres.
	set text [remove_spaces $text]

	return [string trim $text]
}

# ::google::remove_spaces
#
# Enlève les séparateurs de milliers d'un nombre.

proc ::google::remove_spaces {text} {
	return [regsub -all {(\d+)\s(?=\d)} $text {\1}]
}

# ::google::separate_thousands
#
# Effectue exactement le travail inverse de la dernière procédure : 
# sépare les milliers d'un nombre fourni par des espaces.

proc ::google::separate_thousands {number} {
	# Ici, pour séparer les milliers, on renverse d'abord la chaîne.
	# La chaîne "1000000" deviendra donc "0000001".
	#
	# Ensuite, on met un espace tous les trois caractères, grâce à une regexp.
	# À ce stade là, la chaîne est devenue "000 000 1"
	#
	# Puis on renverse encore une fois la chaîne.
	# On a donc "1 000 000". Les milliers sont bien séparés.
	#
	# Puis on retourne la chaîne ainsi obtenue, en prenant bien soin d'enlever
	# les espaces au début ou à la fin.

	return [string trim [string reverse [regsub -all {\d{3}} [string reverse $number] {& }]]]
}

# ::google::wrap
#
# Coupe une chaîne tous les $width caractères.
# Si elle peut, elle coupe entre deux mots, sinon, elle peut couper un mot en
# deux.

proc ::google::wrap {text {width 1}} {
	incr width -1
	set text [string trim $text]
	set text_length [string length $text]
	
	if {$width < 0} {
		error "width doit être positif"
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
# Vérifie que les codes couleurs sont autorisés sur le salon passé en
# argument et renvoie le code couleur demandé.

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
# Nettoie les réponses envoyés par Google.

proc ::google::string_filter {str {let_tags no}} {
	# Pour convertir la chaîne depuis UTF-8 vers l'encodage du système
	set str [encoding convertfrom utf-8 $str]
	
	# On remplace \x3c et \x3e par leurs caractères correspondants.
	# Cela ne peut pas être fait par subst, car Google renvoie parfois
	# \x3e68, ce qui correspond pour Google à >68, mais pour Tcl à \x68...
	set str [string map -nocase {
		"\\x3c" "<"
		"\\x3e" ">"
	} $str]
	
	# Ensuite, on substitue tous les autres codes d'échappement.
	set str [subst -nocommands -novariables $str]
	
	# On substitue aussi les codes d'échappement HTML.
	set str [string map -nocase {
		"&agrave;"    "à"   "&agrave;"    "à"   "&aacute;"    "á"   "&acirc;"     "â"
		"&atilde;"    "ã"   "&auml;"      "ä"   "&aring;"     "å"   "&aelig;"     "æ"
		"&ccedil;"    "ç"   "&egrave;"    "è"   "&eacute;"    "é"   "&ecirc;"     "ê"
		"&euml;"      "ë"   "&igrave;"    "ì"   "&iacute;"    "í"   "&icirc;"     "î"
		"&iuml;"      "ï"   "&eth;"       "ð"   "&ntilde;"    "ñ"   "&ograve;"    "ò"
		"&oacute;"    "ó"   "&ocirc;"     "ô"   "&otilde;"    "õ"   "&ouml;"      "ö"
		"&divide;"    "÷"   "&oslash;"    "ø"   "&ugrave;"    "ù"   "&uacute;"    "ú"
		"&ucirc;"     "û"   "&uuml;"      "ü"   "&yacute;"    "ý"   "&thorn;"     "þ"
		"&yuml;"      "ÿ"   "&quot;"      "\""  "&amp;"       "&"   "&euro;"      "€"
		"&oelig;"     "œ"   "&Yuml;"      "Ÿ"   "&nbsp;"      " "   "&iexcl;"     "¡"
		"&cent;"      "¢"   "&pound;"     "£"   "&curren;"    "¤"   "&yen;"       "¥"
		"&brvbar;"    "¦"   "&brkbar;"    "¦"   "&sect;"      "§"   "&uml;"       "¨"
		"&die;"       "¨"   "&copy;"      "©"   "&ordf;"      "ª"   "&laquo;"     "«"
		"&not;"       "¬"   "&shy;"       "­-"  "&reg;"       "®"   "&macr;"      "¯"
		"&hibar;"     "¯"   "&deg;"       "°"   "&plusmn;"    "±"   "&sup2;"      "²"
		"&sup3;"      "³"   "&acute;"     "´"   "&micro;"     "µ"   "&para;"      "¶"
		"&middot;"    "·"   "&cedil;"     "¸"   "&sup1;"      "¹"   "&ordm;"      "º"
		"&raquo;"     "»"   "&frac14;"    "¼"   "&frac12;"    "½"   "&frac34;"    "¾"
		"&iquest;"    "¿"   "&Agrave;"    "À"   "&Aacute;"    "Á"   "&Acirc;"     "Â"
		"&Atilde;"    "Ã"   "&Auml;"      "Ä"   "&Aring;"     "Å"   "&AElig;"     "Æ"
		"&Ccedil;"    "Ç"   "&Egrave;"    "È"   "&Eacute;"    "É"   "&Ecirc;"     "Ê"
		"&Euml;"      "Ë"   "&Igrave;"    "Ì"   "&Iacute;"    "Í"   "&Icirc;"     "Î"
		"&Iuml;"      "Ï"   "&ETH;"       "Ð"   "&Dstrok;"    "Ð"   "&Ntilde;"    "Ñ"
		"&Ograve;"    "Ò"   "&Oacute;"    "Ó"   "&Ocirc;"     "Ô"   "&Otilde;"    "Õ"
		"&Ouml;"      "Ö"   "&times;"     "×"   "&Oslash;"    "Ø"   "&Ugrave;"    "Ù"
		"&Uacute;"    "Ú"   "&Ucirc;"     "Û"   "&Uuml;"      "Ü"   "&Yacute;"    "Ý"
		"&THORN;"     "Þ"   "&szlig;"     "ß"   "\r"          "\n"  "\t"          ""
		"&#039;"      "\'"  "&#39;"       "\'"
		"&#34;"       "\'"  "&#38;"       "&"   "#91;"        "\("  "&#92;"       "\/"
		"&#93;"       ")"   "&#123;"      "("   "&#125;"      ")"   "&#163;"      "£"
		"&#168;"      "¨"   "&#169;"      "©"   "&#171;"      "«"   "&#173;"      "­"
		"&#174;"      "®"   "&#180;"      "´"   "&#183;"      "·"   "&#185;"      "¹"
		"&#187;"      "»"   "&#188;"      "¼"   "&#189;"      "½"   "&#190;"      "¾"
		"&#192;"      "À"   "&#193;"      "Á"   "&#194;"      "Â"   "&#195;"      "Ã"
		"&#196;"      "Ä"   "&#197;"      "Å"   "&#198;"      "Æ"   "&#199;"      "Ç"
		"&#200;"      "È"   "&#201;"      "É"   "&#202;"      "Ê"   "&#203;"      "Ë"
		"&#204;"      "Ì"   "&#205;"      "Í"   "&#206;"      "Î"   "&#207;"      "Ï"
		"&#208;"      "Ð"   "&#209;"      "Ñ"   "&#210;"      "Ò"   "&#211;"      "Ó"
		"&#212;"      "Ô"   "&#213;"      "Õ"   "&#214;"      "Ö"   "&#215;"      "×"
		"&#216;"      "Ø"   "&#217;"      "Ù"   "&#218;"      "Ú"   "&#219;"      "Û"
		"&#220;"      "Ü"   "&#221;"      "Ý"   "&#222;"      "Þ"   "&#223;"      "ß"
		"&#224;"      "à"   "&#225;"      "á"   "&#226;"      "â"   "&#227;"      "ã"
		"&#228;"      "ä"   "&#229;"      "å"   "&#230;"      "æ"   "&#231;"      "ç"
		"&#232;"      "è"   "&#233;"      "é"   "&#234;"      "ê"   "&#235;"      "ë"
		"&#236;"      "ì"   "&#237;"      "í"   "&#238;"      "î"   "&#239;"      "ï"
		"&#240;"      "ð"   "&#241;"      "ñ"   "&#242;"      "ò"   "&#243;"      "ó"
		"&#244;"      "ô"   "&#245;"      "õ"   "&#246;"      "ö"   "&#247;"      "÷"
		"&#248;"      "ø"   "&#249;"      "ù"   "&#250;"      "ú"   "&#251;"      "û"
		"&#252;"      "ü"   "&#253;"      "ý"   "&#254;"      "þ"
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
