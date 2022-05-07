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
	end tell -- app
	
	-- currently we only support exporting text scripts but should eventually remove this limitation
	if scriptType is not text script then
		tell scriptManagementLib to notifyUser about saveMessage
		return
	end if
	
	-- export the script to the specified location and in the specified format if it contains a recognisable tag
	tell scriptManagementLib to set theLocation to exportLocation for theDocument
	tell scriptManagementLib to set theFormat to exportFormat for theDocument
	set {theName, theExtension} to removeExtension from theName
	set theExtension to formatExtension for theFormat
	set theLocation to theLocation & theName & theExtension
	
	tell scriptManagementLib to set theExportedLocation to contentsOfTag from theDocument given tag:(exportLocationTag of scriptManagementLib)
	set saveMessage to saveMessage & ", exported to " & theExportedLocation
	
	-- using direct export will make UI pop up in Script Debugger that the user will need to confirm
	-- an alternative is to use save instead of export but that means that the currently open document will become the compiled script version, unless we save as run only in which case the UI notification appears as well
	tell application "Script Debugger" to save theDocument as theFormat in file theLocation with run only
	tell scriptManagementLib to notifyUser about saveMessage
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

(*

#todo: export scripts tagged as applets
#todo: possibly customise export location
#todo: increment version number
#todo: specify version as beta or not
#todo: get release notes
#todo: create Mars Edit post
#todo: create email
#todo: move exported .dmg to specified folder
#todo: create appcast

*)