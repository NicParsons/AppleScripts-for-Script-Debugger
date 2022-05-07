-- <script menu>true</script menu>
-- add tags to scripts to assist with automated exports from source control friendly format to compiled script format
--	Created by: Nicholas Parsons
--	Created on: 2/5/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

property scriptLibraryTag : "script library"
property scriptMenuTag : "script menu"
property appletExportTag : "applet"
property theTags : {"Script Library", "Scripts Menu Script", "Standard Applet", "Enhanced Applet"}

on run
	try
		set theChoice to choose from list theTags with prompt "Select a tag to add to the currently frontmost open script in Script Debugger." with title "Tag a Script" OK button name "Tag"
		if theChoice is false then error number -128
		set theChoice to theChoice as text
		
		set {chosenTag, itsContents} to tagAndContents for theChoice
		
		tell application "Script Debugger" to set theDocument to document 1
		set existingContents to contentsOfTag from theDocument given tag:chosenTag
		if itsContents = existingContents then display alert "Tag the script again?" message "The script is already tagged as a " & theChoice & "." buttons {"Cancel", "Tag Anyway"} cancel button 1 as warning
		
		tagTheScript(theDocument, chosenTag, itsContents)
		notifyUser about "Tag added."
	on error errorMessage number errorNumber
		if errorNumber is not -128 then display alert "Error number " & errorNumber message errorMessage
	end try
end run

on isScriptLibrary(theDocument)
	try
		set isLibrary to contentsOfTag from theDocument given tag:scriptLibraryTag
		if class of isLibrary is not boolean then
			log "Error parsing script library tag"
			set isLibrary to false
		end if
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the isScriptLibrary handler)" number errorNumber
	end try
	return isLibrary
end isScriptLibrary

on openTag for thisTag as text
	return "<" & thisTag & ">"
end openTag

on closeTag for thisTag as text
	return "</" & thisTag & ">"
end closeTag

on contentsOfTag from thisScript given tag:theTag as text
	try
		tell application "Script Debugger" to set theSourceCode to source text of thisScript
		set openingTag to openTag for theTag
		set closingTag to closeTag for theTag
		set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {openingTag, closingTag}}
		try
			set tagContents to text item 2 of theSourceCode
			set AppleScript's text item delimiters to saveTID
		on error
			set AppleScript's text item delimiters to saveTID
			set tagContents to missing value
		end try
		if tagContents is "true" or tagContents is "false" then set tagContents to tagContents as boolean
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the isScriptLibrary handler)" number errorNumber
	end try
	return tagContents
end contentsOfTag

on tagTheScript(theDocument, theTag, tagContents)
	try
		set openingTag to openTag for theTag
		set closingTag to closeTag for theTag
		set tagString to "-- " & openingTag & (tagContents as text) & closingTag
		tell application "Script Debugger" to set theSource to the source text of theDocument
		set theSource to tagString & return & theSource
		tell application "Script Debugger" to tell theDocument to set the source text to theSource
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the tagTheScript handler)" number errorNumber
	end try
end tagTheScript

on tagAndContents for thisChoice
	if thisChoice is "Script Library" then
		set chosenTag to scriptLibraryTag
		set itsContents to true
	else if thisChoice is "Scripts Menu Script" then
		set chosenTag to scriptMenuTag
		set itsContents to true
	else if thisChoice is "Standard Applet" then
		set chosenTag to appletExportTag
		set itsContents to "standard"
	else if thisChoice is "Enhanced Applet" then
		set chosenTag to appletExportTag
		set itsContents to "enhanced"
	end if
	return {chosenTag, itsContents}
end tagAndContents

on notifyUser about thisMessage
	(*
if we do
say thisMessage without waiting until completion
we only hear the notification if the script is run from within SD, otherwise it is siolent
which is odd, as it works fine when run from within an applet
*)
	say thisMessage
end notifyUser

(* #todo:

* a way to change an enhanced applet tag to a standard applet tag and vice-verser
* an option to remove tags (though easy enough to do manually)

*)