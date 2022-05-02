-- <script menu>true</script menu>-- add tags to scripts to assist with automated exports from source control friendly format to compiled script format
--	Created by: Nicholas Parsons
--	Created on: 2/5/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

property scriptLibraryOpenTag : "<script library>"
property scriptLibraryCloseTag : "</script library>"
property scriptMenuOpenTag : "<script menu>"
property scriptMenuCloseTag : "</script menu>"
property theTags : {"Script Library", "Scripts Menu Script"}

on run
	try
		set theChoice to choose from list theTags with prompt "Select a tag to add to the currently frontmost open script in Script Debugger." with title "Tag a Script" OK button name "Tag"
		if theChoice is false then error number -128
		set theChoice to theChoice as text
		tell application "Script Debugger"
			set theDocument to document 1
			set theSource to source text of theDocument
		end tell -- Script Debugger
		
		if theChoice is "Script Library" and isScriptLibrary(theDocument) then
			display alert "Tag the script again?" message "The script is already tagged as a " & theChoice & "." buttons {"Cancel", "Tag Anyway"} cancel button 1 as warning
		end if
		
		if theChoice is "Script Library" then
			set theSource to "-- " & scriptLibraryOpenTag & (true as text) & scriptLibraryCloseTag & return & theSource
		else if theChoice is "Scripts Menu Script" then
			set theSource to "-- " & scriptMenuOpenTag & (true as text) & scriptMenuCloseTag & return & theSource
		end if
		tell application "Script Debugger" to tell theDocument to set the source text to theSource
		say "Tag added."
	on error errorMessage number errorNumber
		if errorNumber is not -128 then display alert "Error number " & errorNumber message errorMessage
	end try
end run

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