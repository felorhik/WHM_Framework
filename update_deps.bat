ECHO off

SET curDir=%~dp0
IF %curDir:~-1%==\ SET curDir=%curDir:~0,-1%

svn checkout https://repos.wowace.com/wow/libstub/tags/1.0 "%curDir%\libs\LibStub"
svn checkout https://repos.wowace.com/wow/callbackhandler/trunk/CallbackHandler-1.0 "%curDir%\libs\CallbackHandler-1.0"
svn checkout https://repos.wowace.com/wow/ace3/trunk/AceAddon-3.0 "%curDir%\libs\AceAddon-3.0"
svn checkout https://repos.wowace.com/wow/ace3/trunk/AceDB-3.0 "%curDir%\libs\AceDB-3.0"
svn checkout https://repos.wowace.com/wow/ace3/trunk/AceConsole-3.0 "%curDir%\libs\AceConsole-3.0"
svn checkout https://repos.wowace.com/wow/ace3/trunk/AceConfigRegistry-3.0 "%curDir%\libs\AceConfigRegistry-3.0"
svn checkout https://repos.wowace.com/wow/ace3/trunk/AceConfigDialog-3.0 "%curDir%\libs\AceConfigDialog-3.0"
svn checkout https://repos.wowace.com/wow/ace3/trunk/AceEvent-3.0 "%curDir%\libs\AceEvent-3.0"
svn checkout https://repos.wowace.com/wow/ace3/trunk/AceTimer-3.0 "%curDir%\libs\AceTimer-3.0"

PAUSE