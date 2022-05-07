-- <export location>Scripts Menu Folder</export location>-- <export format>Compiled Script</export format>
-- add tags to scripts to assist with automated exports from source control friendly format to compiled script format
--	Created by: Nicholas Parsons
--	Created on: 2/5/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use scriptManagementLib : script "OB Script Management"

on run
	try
		(*
		set theChoice to choose from list (theTags of scriptManagementLib) with prompt "Select a tag to add to the currently frontmost open script in Script Debugger." with title "Tag a Script" OK button name "Tag"
		if theChoice is false then error number -128
		set theChoice to theChoice as text
		
		set {chosenTag, itsContents} to tagAndContents for theChoice
		
		tell application "Script Debugger" to set theDocument to document 1
		tell scriptManagementLib to set existingContents to contentsOfTag from theDocument given tag:chosenTag
		if itsContents = existingContents then display alert "Tag the script again?" message "The script is already tagged as a " & theChoice & "." buttons {"Cancel", "Tag Anyway"} cancel button 1 as warning
		*)
		set {theFormat, theLocation} to chooseTag()
		tell application "Script Debugger" to set theDocument to document 1
		tagTheScript(theDocument, (exportFormatTag of scriptManagementLib), theFormat)
		tagTheScript(theDocument, (exportLocationTag of scriptManagementLib), theLocation)
		tell scriptManagementLib to notifyUser about "Tag added."
	on error errorMessage number errorNumber
		if errorNumber is not -128 then display alert "Error number " & errorNumber message errorMessage
	end try
end run

on tagTheScript(theDocument, theTag, tagContents)
	try
		tell scriptManagementLib to set openingTag to openTag for theTag
		tell scriptManagementLib to set closingTag to closeTag for theTag
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
		set chosenTag to scriptLibraryTag of scriptManagementLib
		set itsContents to true
	else if thisChoice is "Scripts Menu Script" then
		set chosenTag to scriptMenuTag of scriptManagementLib
		set itsContents to true
	else if thisChoice is "Standard Applet" then
		set chosenTag to appletExportTag of scriptManagementLib
		set itsContents to "standard"
	else if thisChoice is "Enhanced Applet" then
		set chosenTag to appletExportTag of scriptManagementLib
		set itsContents to "enhanced"
	end if
	return {chosenTag, itsContents}
end tagAndContents

on chooseTag()
	repeat -- until user makes a choice or cancels
		set theFormat to choose from list (exportFormats of scriptManagementLib) with prompt "In what format should the currently frontmost open script in Script Debugger be exported?" with title "Export Format" OK button name "Next"
		if theFormat is false then error number -128
		set theFormat to theFormat as text
		set theLocation to choose from list (exportLocations of scriptManagementLib) with prompt "Where should the currently frontmost open script in Script Debugger be exported?" with title "Export Location" cancel button name "Back" OK button name "Tag"
		if theLocation is false then
			-- do nothing so that we'll loop back around
		else
			set theLocation to theLocation as text
			exit repeat
		end if
	end repeat
	return {theFormat, theLocation}
end chooseTag

(*

#todo: rather than making boolean properties for script library and script menu, use an export location tag the value of which can effectively be an enum of common constants/locations
#todo: set contents of exportLocationTag with common constants (e.g. same directory, script libraries folder, scripts menu folder, general/default scripts directory which can be configured in user defaults)
#todo: similarly, no need for applet tag – can instead use export format tag the value of which can be another enum of script formats
#todo: a way to change an enhanced applet tag to a standard applet tag and vice-verser
#todo: an option to remove tags (though easy enough to do manually)

*)