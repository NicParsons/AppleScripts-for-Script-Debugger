-- build script
--	Created by: Nicholas Parsons
--	Created on: 27/4/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- names (minus extension) for scripts that should be saved to Script Debugger's scripts menu
property scriptMenuScripts : {"Save Script Debugger Scripts", "Show todos in Script Debugger"}

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
		
		-- check if it is a script library and #todo: is in a git repo
		-- and, if it is, export it
		set theFile to file spec
		set theName to name
	end tell -- document
end tell -- app
set theName to removeExtension from theName
set POSIXFile to POSIX path of theFile

-- not yet sure how I'll check to see if it's in a git repo
-- but for now I'll just export anything that is in a Script Libraries folder that does not have a parent directory called Library
if POSIXFile contains "/Script Libraries/" and POSIXFile does not contain "/Library/" then
	tell application "Finder" to set theDestination to folder "Script Libraries" of (path to library folder from user domain)
	set theDestination to (theDestination as text) & theName & ".scpt"
	tell application "Script Debugger" to save theDocument as compiled script in file theDestination without run only
else if theName is in scriptMenuScripts then
	set theDestination to (scriptsFolder as text) & theName
	set theDestination to (theDestination as text) & ".scpt"
	tell application "Script Debugger" to save theDocument as compiled script in file theDestination with run only
end if

say saveMessage

on removeExtension from theFileName
	set reversedName to reverse of characters of theFileName
	set reversedName to reversedName as text
	set theOffset to the offset of "." in reversedName
	set truncatedName to characters (theOffset + 1) through -1 of reversedName
	set truncatedName to truncatedName as text
	set nameMinusExtension to reverse of characters of truncatedName
	set nameMinusExtension to nameMinusExtension as text
	log nameMinusExtension
	return nameMinusExtension
end removeExtension