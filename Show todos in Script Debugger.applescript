--
--	Created by: Nicholas Parsons
--	Created on: 27/4/2022
--
--	Copyright © 2022 Nicholas Parsons, All Rights Reserved
--

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application "Script Debugger"
	set theDocument to the document 1
	set theCode to source text of theDocument
	set theTitle to name of theDocument
end tell -- app
set theParagraphs to every paragraph of theCode
set theToDoItems to {}
repeat with theParagraph in theParagraphs
	if theParagraph contains "#todo" then set the end of theToDoItems to theParagraph
end repeat
repeat -- to work around timeout errors
	try
		with timeout of 600 seconds
			set theChoice to choose from list theToDoItems with prompt "All the lines marked with “#todo”." with title theTitle with empty selection allowed
		end timeout
		exit repeat
	on error errorMessage number errorNumber
		display alert "Error " & errorNumber message errorMessage
		exit repeat
	end try
end repeat