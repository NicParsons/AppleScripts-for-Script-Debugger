-- <script menu>true</script menu>
-- build script
--	Created by: Nicholas Parsons
--	Created on: 27/4/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

on run
	set saveMessage to ""
	tell application "Script Debugger"
		set scriptsFolder to scripts menu folder
		set theDocument to document 1
		tell theDocument
			if not compiled then compile
			if modified then
				save
				set saveMessage to "Saved"
			else
				set saveMessage to "Already saved"
			end if
			set theName to name -- of theDocument
			set scriptType to script type -- of theDocument
		end tell -- document
		if scriptType is not text script then
			notifyUser about saveMessage
			return
		end if
	end tell -- app
	
	set {theName, theExtension} to removeExtension from theName
	
	-- check if it is a script library and #todo: is in a git repo
	-- and, if it is, export it
	-- not yet sure how I'll check to see if it's in a git repo (check if the container folder contains a .git directory?)
	-- but for now I'll just export anything that contains a boolean value of treu inside the tag <script library></script library>, presumably inside a comment, and is not in the user's Script Libraries directory
	-- using direct export will make UI pop up in Script Debugger that the user will need to confirm
	-- an alternative is to use save instead of export but that means that the currently open document will become the compiled script version
	if isScriptLibrary(theDocument) and not isInScriptLibrariesFolder(theDocument) then
		tell application "Finder" to set theDestination to folder "Script Libraries" of (path to library folder from user domain)
		set theDestination to (theDestination as text) & theName & ".scpt"
		tell application "Script Debugger" to save theDocument as compiled script in file theDestination with run only
		set saveMessage to saveMessage & ", exported as script library"
	else if isScriptsMenuScript(theDocument) then
		set theDestination to (scriptsFolder as text) & theName
		set theDestination to (theDestination as text) & ".scpt"
		tell application "Script Debugger" to save theDocument as compiled script in file theDestination with run only
		set saveMessage to saveMessage & ", exported as scripts menu script"
	end if
	notifyUser about saveMessage
end run

on removeExtension from theFileName
	-- could probably do this with fewer lines of code using AppleScript text item delimiters
	-- or using Finder (I believe Finder items have name and extension properties)
	set reversedName to reverse of characters of theFileName
	set reversedName to reversedName as text
	set theOffset to the offset of "." in reversedName
	set truncatedName to characters (theOffset + 1) through -1 of reversedName
	set truncatedName to truncatedName as text
	set nameMinusExtension to reverse of characters of truncatedName
	set nameMinusExtension to nameMinusExtension as text
	log nameMinusExtension
	set theExtension to characters 1 through (theOffset - 1) of reversedName
	set theExtension to theExtension as text
	set theExtension to (reverse of characters of theExtension) as text
	return {nameMinusExtension, theExtension}
end removeExtension

on isScriptLibrary(theDocument)
	try
		tell application "Script Debugger" to set theSourceCode to source text of theDocument
		set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {"<script library>", "</script library>"}}
		try
			set libraryTag to text item 2 of theSourceCode
			set AppleScript's text item delimiters to saveTID
		on error
			set AppleScript's text item delimiters to saveTID
			set libraryTag to "false"
		end try
		try
			set isLibrary to libraryTag as boolean
		on error -- poorly formatted or unintentional tags, as in this script
			log "Error parsing script library tag"
			set isLibrary to false
		end try
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the isScriptLibrary handler)" number errorNumber
	end try
	return isLibrary
end isScriptLibrary

on isInScriptLibrariesFolder(theDocument)
	try
		tell application "Script Debugger" to set theFile to file spec of theDocument
		set POSIXPath to POSIX path of theFile
		set libraryPath to path to library folder from user domain
		set libraryPath to POSIX path of libraryPath
		set libraryPath to libraryPath & "Script Libraries/"
		return POSIXPath begins with libraryPath
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the isInScriptLibrariesFolder handler)" number errorNumber
	end try
end isInScriptLibrariesFolder

on isScriptsMenuScript(theDocument)
	try
		tell application "Script Debugger" to set theSourceCode to source text of theDocument
		set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {"<script menu>", "</script menu>"}}
		try
			set theTag to text item 2 of theSourceCode
			set AppleScript's text item delimiters to saveTID
		on error
			set AppleScript's text item delimiters to saveTID
			set theTag to "false"
		end try
		try
			set isMenuItem to theTag as boolean
		on error -- poorly formatted or unintentional tags, as in this script
			log "Error parsing scripts menu tag"
			set isMenuItem to false
		end try
	on error errorMessage number errorNumber
		error errorMessage & " (thrown in the isScriptsMenuScript handler)" number errorNumber
	end try
	return isMenuItem
end isScriptsMenuScript

on notifyUser about thisMessage
	say thisMessage
end notifyUser