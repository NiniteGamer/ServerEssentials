--[[ 

	-- AutoWarning system for when people use racial slurs 

	-- System to Autopromote users to certain ranks

	-- This addon must be completely customizable

	-- Have a automuting system

	-- Have a anti admin chat spam

	-- Private Message Spy

	-- Work on a way to make the config write itself if possible

	-- Have my anti admin chat spam store if the user has been kicked before and how many times.

	-- If the user has been kicked more times that day than allowed in config it will automatically ban them for how long is set in the config

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
		file.Append("serveressentials.txt","-- ServerEssentials --\n-- SPLIT CONFIG --\n-- AutoWarn -- \nenabled = true\nracialslurs = {} <- insert racialslurs in there \n-- SPLIT CONFIG --\n-- AntiAdminSpam-- \nenabled = true\nAdminSpamID = 5\namounttokick = 5\n-- SPLIT CONFIG --\n-- AutoMute --\nenabled = true\n-- SPLIT CONFIG --\n-- NameChangeAlert --")
		print("Config file made in your GarrysMod/Data folder for Server Essentials")
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
	elseif (portion == "NameChange") then return (portions[5])
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
AmountOfKicks = {}
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
 				if(AmountOfKicks[ply:SteamID()] != nil) then
					AmountOfKicks[ply:SteamID()] = AmountOfKicks[ply:SteamID()] + 1
				else
					AmountOfKicks[ply:SteamID()] = 1
				end 
				ply:Kick("Please do not spam admin chat "..ply:Name().." (ServerEssentials)")
				PrintTable(AmountofKicks)
				SpamDetector[ply:SteamID()] = 0
				return false
			end
			timer.Create("AdminChatBanClear", 86400, 0, function() AmountofKicks = {} end)
--[[ 			if(amountofkicks[ply:SteamID()] >= amounttoban) then
				RunConsoleCommand("ulx","banid", ply:SteamID(), banlength, "You've been banned by Server Essentials for constant admin chat spam.")
				amountofkicks[ply:SteamID()] = 0
				return false
			end--]] 
		end
	end
end
hook.Add("ULibPostTranslatedCommand", "antiadminspam", AntiAdminSpam)
print("-- DEBUG FINAL --")
function NameChange( ply, oldName, newName )
	OldPlyName = oldName
	print(OldPlyName)
	NewPlyName = newName
	print(NewPlyName)
	if (enabled == true) then
		if(OldPlyName != NewPlyName) then
			RunConsoleCommand("ullx","asay", "(ServerEssentials) has detected that "..OldPlyName.." has changed their name to this "..NewPlyName)
		end
	end
end
hook.Add("ULibPlayerNameChanged", "NameChanged", NameChange)