-- <export location>Script Libraries Folder</export location>
-- <export format>Compiled Script</export format>
-- OB Script Management
--	Created by: Nicholas Parsons
--	Created on: 7/5/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

property name : "OB Script Management"
property version : "1.0"
property id : "com.openbooksapp.ob-script-management"

property exportLocationTag : "export location"
property exportLocations : {"Script Libraries Folder", "Scripts Menu Folder", "Same Directory", "Default Scripts Folder"}
property exportFormatTag : "export format"
property exportFormats : {"Compiled Script", "Standard Applet", "Enhanced Applet"}
property theTags : {"Script Library", "Scripts Menu Script", "Standard Applet", "Enhanced Applet"}

-- depricated
property scriptLibraryTag : "script library"
property scriptMenuTag : "script menu"
property appletExportTag : "applet"

on exportLocation for thisScript
	-- return a string representing the path, excluding file name and extension, to the directory where the script should be exported
	try
		set theLocationString to contentsOfTag from thisScript given tag:exportLocationTag
		-- possible options
		-- property exportLocations : {"Script Libraries Folder", "Scripts Menu Folder", "Same Directory", "Default Scripts Folder"}
		if theLocationString is "Script Libraries Folder" then
			tell application "Finder" to set scriptLibrariesFolder to folder "Script Libraries" of (path to library folder from user domain)
			set theDirectoryPath to (scriptLibrariesFolder as text)
		else if theLocationString is "Scripts Menu Folder" then
			tell application "Script Debugger" to set scriptsFolder to scripts menu folder
			set theDirectoryPath to (scriptsFolder as text)
		else if theLocationString is "Same Directory" then
			tell application "Script Debugger" to set theFile to file spec of thisScript
			tell application "Finder" to set theFolder to container of item (theFile as text)
			set theDirectoryPath to theFolder as text
		else if theLocationString is "Default Scripts Folder" then
			-- #todo: use PrefsStorageLib to return value for key "defaultScriptsFolder" or allow user to choose foldre if missing value
			error "This option is not yet supported." number 1000
			set theDirectoryPath to missing value
		end if
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the exportLocation handler of OB Script Management)" number errorNumber
	end try
	return theDirectoryPath
end exportLocation

on exportFormat for thisScript
	try
		set theFormatString to contentsOfTag from thisScript given tag:exportFormatTag
		-- possible options
		-- property exportFormats : {"Compiled Script", "Standard Applet", "Enhanced Applet"}
		using terms from application "Script Debugger"
			if theFormatString is "Compiled Script" then
				set theFormat to compiled script
				(* should also support compiled script bundles
else if theFormatString is then
*)
			else if theFormatString is "Standard Applet" then
				set theFormat to script application
			else if theFormatString is "Enhanced Applet" then
				set theFormat to enhanced application
			end if
		end using terms from
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the exportFormat handler of OB Script Management)" number errorNumber
	end try
	return theFormat
end exportFormat

on isScriptLibrary(theDocument)
	-- depricated (use exportLocationTag instead, the value of which should be Script Library Folder) 
	try
		set isLibrary to contentsOfTag from theDocument given tag:scriptLibraryTag
		if class of isLibrary is not boolean then
			log "Error parsing script library tag"
			set isLibrary to false
		end if
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the isScriptLibrary handler of OB Script Management)" number errorNumber
	end try
	return isLibrary
end isScriptLibrary

on isScriptMenuScript(theDocument)
	-- depricated (use exportLocationTag instead, the value of which should be Scripts Menu Folder) 
	try
		set isMenuItem to contentsOfTag from theDocument given tag:scriptMenuTag
		if class of isMenuItem is not boolean then
			log "Error parsing scripts menu tag"
			set isMenuItem to false
		end if
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the isScriptMenuScript handler of OB Script Management)" number errorNumber
	end try
	return isMenuItem
end isScriptMenuScript

on contentsOfTag from thisScript given tag:theTag as text
	try
		tell application "Script Debugger" to set theSourceCode to source text of thisScript
		set openingTag to openTag for theTag
		set closingTag to closeTag for theTag
		-- #todo: this method will also return the contents of improperly formatted tags e.g. 2 opening tags or 2 closing tags (should change it so only text between opening and closing tags is returned)
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
		error errorMessage & " (thrown in the contentsOfTag handler of OB Script Management)" number errorNumber
	end try
	return tagContents
end contentsOfTag

on changeTagValue to thisValue for theTag given documentID:theDocument
	try
		tell application "Script Debugger" to set theSourceCode to source text of theDocument
		set openingTag to openTag for theTag
		set closingTag to closeTag for theTag
		set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {openingTag, closingTag}}
		try
			set theSourceCode to (text item 1 of theSourceCode) & openingTag & thisValue & closingTag & (text items 3 through -1 of theSourceCode)
			set AppleScript's text item delimiters to saveTID
		on error errorMessage number errorNumber
			set AppleScript's text item delimiters to saveTID
			error errorMessage number errorNumber
		end try
		tell application "Script Debugger" to set source text of theDocument to theSourceCode
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the changeTagValue handler of OB Script Management)" number errorNumber
	end try
end changeTagValue

on openTag for thisTag as text
	return "<" & thisTag & ">"
end openTag

on closeTag for thisTag as text
	return "</" & thisTag & ">"
end closeTag

on notifyUser about thisMessage
	(*
if we do
say thisMessage without waiting until completion
we only hear the notification if the script is run from within SD, otherwise it is siolent
which is odd, as it works fine when run from within an applet
*)
	say thisMessage
end notifyUser
