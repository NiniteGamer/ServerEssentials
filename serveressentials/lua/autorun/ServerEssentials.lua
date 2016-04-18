--[[ 

	-- AutoWarning system for when people use racial slurs

	-- System to Autopromote users to certain ranks

	-- This addon must be completely customizable

	-- Have a automuting system

	-- Have a anti admin chat spam

	-- Private Message Spy

	-- Work on a way to make the config write itself if possible

	-- Have my anti admin chat spam store if the user has been kicked before and how many times.

--]] 

-- Under here is where it checks if the config file exists if not it will make one in your garrysmod/data folder.
local exolib = include("exolib.lua")

--[[

	This addon is made by NiniteGamer with the use of Exo's Library.

--]]

function makeCfgFile(ply)
	if (file.Exists("serveressentials.txt","DATA")) then -- This is where it checks if the file is created or not
		print("--- DEBUG makeCfgFile ---")
		return
	else
		file.Write("serveressentials.txt", "")
		file.Append("serveressentials.txt","-- ServerEssentials --\n \n-- SPLIT CONFIG --\n \n-- AutoWarn -- \nenabled = true\nracialslurs = {} <- insert racialslurs in there \n-- SPLIT CONFIG --\n \n-- AntiAdminSpam-- \n \n-- SPLIT CONFIG --\n \n-- AutoMute --")
		print("Config file for Server Essentials is made.")
	end
end
hook.Add("Initialize", "makeCfgFile", makeCfgFile)

-- Reading the Config File below (DO NOT CHANGE ANYTHING UNDER HERE UNLESS YOU KNOW WHAT YOU'RE DOING OR HAVE BEEN INSTRUCTED BY NINITEGAMER OR EXO) --
function readCfg(portion)
	textdata = file.Read("serveressentials.txt")
	portions = string.Explode("-- SPLIT CONFIG --", textdata)
	if (portion == "ServerEssentials") then return (portions[1])
	elseif (portion == "AutoWarn") then return (portions[2])
	elseif (portion == "AntiAdminSpam") then return (portions[3])
	elseif (portion == "AutoMute") then return (portions[4])
	end
	print("-- DEBUG ReadCfg --")
end

--Auto Warn Code Below
function AutoWarn(ply, text, public)
	if(file.Exists("serveressentials.txt", "DATA")) then
		print("-- DEBUG AUTOWARN --")
		textdata = readCfg("AutoWarn")
		print("-- DEBUG --")
		RunString(textdata)
		print(enabled)
		PrintTable(racialslurs)
		if (enabled == true) then
			print("-- DEBUG AutoWarn Enabled --")
			textdata = string.Explode("\n", textdata)
			for i, line in ipairs(racialslurs) do
				if(line ~= nil and line ~= "") then
				returnedstring, racialslur = string.gsub(text, line, line)
					if (racialslur > 0) then
						RunConsoleCommand("ulx","asay", "(ServerEssentials) has detected use of racial slur(s) by "..ply:Name().." and is about to be warned.")
						timer.Create("warncountdown"..ply:SteamID(), 5, 1, function() RunConsoleCommand("awarn_warn", ply:SteamID(), warnreason) end)
					end
				end
			end
		end
	end
end
hook.Add("PlayerSay", "AutoWarn", AutoWarn)
--Anti Admin Chat Spam
SpamDetector = {}
function AntiAdminSpam(ply, commandName, translated_args)
	textdata = readCfg("AntiAdminSpam")
	RunString(textdata)
	if (enabled == true) then
		if(commandName == "ulx asay") then
			print(ply:SteamID())
			if(SpamDetector[ply:SteamID()] != nil) then
				SpamDetector[ply:SteamID()] = SpamDetector[ply:SteamID()] + 1
			else
				SpamDetector[ply:SteamID()] = 1
			end
			timer.Create("AntiAdminSpamClear", AdminSpamID, 0, function() SpamDetector = {} end)
			if(SpamDetector[ply:SteamID()] >= amounttokick) then
				ply:Kick("Please do not spam admin chat "..ply:Name().." (ServerEssentials)")
				SpamDetector[ply:SteamID()] = 0
				return false
			end
		end
	end
end
hook.Add("ULibPostTranslatedCommand", "antiadminspam", AntiAdminSpam)
print("-- DEBUG FINAL --")