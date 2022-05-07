-- <export location>Scripts Menu Folder</export location>
-- <export format>Compiled Script</export format>
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
		set notificationText to "Tag added."
		set {theFormat, theLocation} to chooseTag()
		tell application "Script Debugger" to set theDocument to document 1
		tell scriptManagementLib to set existingContents to contentsOfTag from theDocument given tag:(exportFormatTag of scriptManagementLib)
		if existingContents is missing value then
			tagTheScript(theDocument, (exportFormatTag of scriptManagementLib), theFormat)
		else if existingContents is not theFormat then
			tell scriptManagementLib to changeTagValue to theFormat for (exportFormatTag of scriptManagementLib) given documentID:theDocument
			set notificationText to "Tag updated."
		end if
		tell scriptManagementLib to set existingContents to contentsOfTag from theDocument given tag:(exportLocationTag of scriptManagementLib)
		if existingContents is missing value then
			tagTheScript(theDocument, (exportLocationTag of scriptManagementLib), theLocation)
		else if existingContents is not theLocation then
			tell scriptManagementLib to changeTagValue to theLocation for (exportLocationTag of scriptManagementLib) given documentID:theDocument
			set notificationText to "Tag updated."
		end if
		tell scriptManagementLib to notifyUser about notificationText
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

#todo: an option to remove tags (though easy enough to do manually)

*)