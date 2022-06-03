-- <export location>Scripts Menu Folder</export location>
-- <export format>Compiled Script</export format>
-- build script
--	Created by: Nicholas Parsons
--	Created on: 27/4/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use scriptManagementLib : script "OB Script Management"

on run
	try
		set saveMessage to ""
		tell application "Script Debugger"
			set theDocument to document 1
			tell theDocument
				if not compiled then
					compile
					set saveMessage to "Compiled, "
				end if
				if modified then
					save
					set saveMessage to saveMessage & "Saved"
				else
					set saveMessage to saveMessage & "Already saved"
				end if
				set theName to name -- of theDocument
				set theVersion to marketing version
			end tell -- document
		end tell -- app
		
		-- export the script to the specified location and in the specified format if it contains a recognisable tag
		tell scriptManagementLib to set theLocation to exportLocation for theDocument
		if theLocation is missing value then -- the script was not tagged with an export location
			tell scriptManagementLib to notifyUser about saveMessage
			return
		end if
		tell scriptManagementLib to set theFormat to exportFormat for theDocument
		set {theName, theExtension} to removeExtension from theName
		set theExtension to formatExtension for theFormat
		set theLocation to theLocation & theName & theExtension
		
		tell scriptManagementLib to set theExportedLocation to contentsOfTag from theDocument given tag:(exportLocationTag of scriptManagementLib)
		set saveMessage to saveMessage & ", exported to " & theExportedLocation
		
		-- using direct export will make UI pop up in Script Debugger that the user will need to confirm
		-- an alternative is to use save instead of export but that means that the currently open document will become the compiled script version, unless we save as run only in which case the UI notification appears as well
		-- for applets, or anything being exported in the same directory with the same extension as the script being exported, we need to use direct export to stop the script being over written
		if theFormat is script application or theFormat is enhanced application then
			set theVersion to confirmVersionNumber for theVersion
			tell application "Script Debugger" to set the marketing version of theDocument to theVersion
			tell application "Script Debugger" to direct export theDocument as theFormat
			set theButton to button returned of (display alert "Increment version number?" message "The current version number is " & theVersion buttons {"Leave as is", "Increment"} default button 2)
			if theButton is "Increment" then tell application "Script Debugger" to set marketing version of theDocument to incrementVersionNumber of me for theVersion
		else
			tell application "Script Debugger" to save theDocument as theFormat in file theLocation with run only
		end if
		tell scriptManagementLib to notifyUser about saveMessage
	on error errorMessage number errorNumber
		if errorNumber is not -128 then display alert "Error saving script" message errorMessage & return & return & "Error number " & errorNumber
	end try
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

on formatExtension for thisFormat
	using terms from application "Script Debugger"
		if thisFormat is compiled script then
			return ".scpt"
		else if thisFormat is text script then
			return ".applescript"
		else if thisFormat is script application or thisFormat is enhanced application then
			return ".app"
		else if thisFormat is bundled compiled script then
			return ".scptd"
		end if
	end using terms from
end formatExtension

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

on confirmVersionNumber for thisVersion
	display dialog "Confirm the version number of this release." default answer thisVersion with title "Release Version" buttons {"Cancel", "Confirm"} cancel button 1 default button 2 with icon note
	return text returned of result
end confirmVersionNumber

on incrementVersionNumber for thisVersion
	set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {"."}}
	try
		set newVersion to (text items 1 through -2 of thisVersion) as text
		set minorVersion to the last text item of thisVersion
		set AppleScript's text item delimiters to saveTID
		if (count of words of minorVersion) > 1 then
			set fixedPart to words 1 through -2 of minorVersion
			set minorVersion to the last word of minorVersion
			set minorVersion to minorVersion as number
			set minorVersion to minorVersion + 1
			set {saveTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {space}}
			set minorVersion to ((fixedPart as text) & (minorVersion as text) as text)
			set AppleScript's text item delimiters to saveTID
		else
			set minorVersion to minorVersion as number
			set minorVersion to minorVersion + 1
			set minorVersion to minorVersion as text
		end if
		set newVersion to newVersion & "." & minorVersion
	on error errorMessage number errorNumber
		set AppleScript's text item delimiters to saveTID
		set newVersion to thisVersion
	end try
	return newVersion
end incrementVersionNumber

(*

#todo: possibly customise export location (at least for general scripts)
#todo: get release notes
#todo: create Mars Edit post
#todo: create email
#todo: move exported .dmg to specified folder
#todo: create appcast

*)