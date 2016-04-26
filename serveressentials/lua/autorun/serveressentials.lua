exolib = include("exolib.lua")
function readCfg(portion)
	textdata = file.Read("serveressentials.txt")
	portions = string.Explode("-- SPLIT CONFIG --", textdata)
	if (portion == "ServerEssentials") then return (portions[1])
	elseif (portion == "AutoCensor") then return (portions[2])
	elseif (portion == "AntiAdminChatSpam") then return (portions[3])
	elseif (portion == "GhosterBuster") then return (portions[4])
	elseif (portion == "AntiChatSpam") then return (portions[5])
	elseif (portion == "TopDonator") then return (portions[6])
	elseif (portion == "KarmaChecker") then return (portions[7])
	elseif (portion == "KarmaCheatDetect") then return (portions[8])
	elseif (portion == "AntiRadioSpam") then return (portions[9])
	end
end
function infoPrinter()
	ServerLog("ServerEssentials: Version 1.2.0")
end 
function autoCensor(ply, text, public)
	textdata = readCfg("AutoCensor")
	RunString(textdata)
	if (autocensorenabled == true) then
		for i, line in ipairs(bannedwords) do
			if(line ~= nil and line ~= "") then
			returnedstring, bannedword = string.gsub(string.lower(text), line, line)
				if (bannedword > 0) then
					RunConsoleCommand("ulx","asay", "ServerEssentials: has detected use a banned word by "..ply:Name().."")
					if (warnenabled == true) then
						timer.Create("warncountdown"..ply:SteamID(), timetowarn, 1, function() RunConsoleCommand("awarn_warn", ply:SteamID(), "ServerEssentials: "..warnreason) end)
					end
					if (muteenabled == true) then
						RunConsoleCommand("ulx","mute",ply:Name())
						timer.Create("timetounmutewarn"..ply:SteamID(), timetounmuteawarn, function() RunConsoleCommand("ulx","unmute", ply:Name()) end)
					end
					return(false)
				end
			end
		end
	end
end
SpamDetector = {}
function antiadminSpam(ply, commandName, translated_args)
	textdata = readCfg("AntiAdminChatSpam")
	RunString(textdata)
	if (antiadminspamenabled == true) then
		if(commandName == "ulx asay") then
			if(SpamDetector[ply:SteamID()] != nil) then
				SpamDetector[ply:SteamID()] = SpamDetector[ply:SteamID()] + 1
			else
				SpamDetector[ply:SteamID()] = 1
			end
			timer.Create("AntiAdminSpamClear", resetadminspam, 0, function() SpamDetector = {} end)
			if(SpamDetector[ply:SteamID()] >= amounttokick) then
				if(kickenabled == true) then
					ply:Kick("ServerEssentials: has detected chat spam by you "..ply:Name().." you've been automatically disconnected from the server.")
					SpamDetector[ply:SteamID()] = 0
					return false
				else
					ply:PrintMessage(HUD_PRINTTALK,"Please refrain from spamming admin chat the staff team will get to you when it's your turn.")
				end
			end
		end
	end
end
function ghosterBuster(ply, commandName, translated_args)
	textdata = readCfg("GhosterBuster")
	RunString(textdata)
	if(ghosterbusterenabled == true) then
		if(commandName == "ulx psay") then
			ply2 = translated_args[2]
			msg = translated_args[3]
			for i, line in ipairs(alertwords) do
				if(line ~= nil and line ~= "") then
				returnedstring, alertword = string.gsub( string.lower(msg), line, line)
					if(alertword > 0) then
						if(ply:Alive() == false and ply2:Alive() == true) then
							RunConsoleCommand("ulx","asay","GhosterBuster: has detected potential ghosting by "..ply:Name().." to "..ply2:Name()..": '"..msg.."'")
							if(warnenabled == true) then
								timer.Create("warntimer"..ply:SteamID(),warntimeramount,1, function() RunConsoleCommand("awarn_warn",ply:SteamID(), "GhosterBuster: "..ply:Name().." "..warnreasongb) end)
							end
						else
							if(ply:IsSpec() == true and ply2:Alive() == true) then
								RunConsoleCommand("ulx","asay","GhosterBuster: has detected potential ghosting by "..ply:Name().." to "..ply2:Name()..": '"..msg.."'")
								if(warnenabled == true) then
									timer.Create("warntimer"..ply:SteamID(),warntimeramount,1, function() RunConsoleCommand("awarn_warn",ply:SteamID(), "GhosterBuster: "..ply:Name().." "..warnreasongb) end)
								end
							else
								RunConsoleCommand("ulx","asay","GhosterBuster: "..ply:Name().." has been detected using a alert word in a psay to "..ply2:Name()..": '"..msg.."'")
							end
						end
					end
				end
				staff = exolib.checkPlayerRanks(psaysee,player.GetAll())
				for i, line in ipairs(staff) do end
				if(psayseeenabled == true) then
					if(alertword > 0) then
						return
					else
						for i, player in ipairs(staff) do player:PrintMessage(HUD_PRINTTALK,"ServerEssentials: "..ply:Name().." to "..ply2:Name()..": '"..msg.."'") end
					end
				break end
			end
		end
	end
end
chatspamdetector = {}
function antichatSpam(ply, text, public)
	textdata = readCfg("AntiChatSpam")
	RunString(textdata)
	if(antichatspamenabled == true) then
		if(chatspamdetector[ply:SteamID()] != nil) then
			chatspamdetector[ply:SteamID()] = chatspamdetector[ply:SteamID()] + 1
		else
			chatspamdetector[ply:SteamID()] = 1
		end
		timer.Create("AntiChatSpamClear", timetochatspamreset, 0, function() chatspamdetector = {} end)
		if(chatspamdetector[ply:SteamID()] >= amounttomute) then
			RunConsoleCommand("ulx","mute", ply:Name())
			timer.Create("TimeToUnmute"..ply:SteamID(), timetounmute, 1, function() RunConsoleCommand("ulx","unmute",ply:Name()) end)
			if(hudprintenable == true) then
				ply:PrintMessage(HUD_PRINTTALK,"ServerEssentials: "..ply:Name().." You have been muted for "..timetounmute.." seconds for chat spam.")
			end
			if(asaytoadminacs == true) then
				RunConsoleCommand("ulx","asay","ServerEssentials: "..ply:Name().." has been muted for chat spam and will be unmuted in "..timetounmute.." seconds.")
			end
			chatspamdetector[ply:SteamID()] = 0
			return(false)
		end
	end
end
function topDonator(ply, text, public)
	textdata = readCfg("TopDonator")
	RunString(textdata)
	if(topdonatorenabled == true) then
		ply:PrintMessage(HUD_PRINTTALK,"This months top donator is "..topdonatorplayer.."!")
	end
end
function karmaChecker(ply)
	textdata = readCfg("KarmaChecker")
	RunString(textdata)
	if(karmacheckerenabled == true) then
		if(printkarmatoplayer == true) then
			ply:PrintMessage(HUD_PRINTTALK, "ServerEssentials: "..ply:Name().." you currently have "..math.Round(ply:GetLiveKarma(), 0).." karma")
		end
		if(printtoadminskarma == true) then
			if ply:GetLiveKarma() <= 500 then
				RunConsoleCommand("ulx","asay","ServerEssentials: "..ply:Name().." has "..math.Round(ply:GetLiveKarma(),0).." karma left.")
			end
		end
	end
end
function karmacheatDetector(ply)
	textdata = readCfg("KarmaCheatDetect")
	RunString(textdata)
	if(karmacheatdetectenabled == true) then
		if(ply:GetLiveKarma() > karmalimit) then
			RunConsoleCommand("ulx","asay","(ServerEssentials) has detected potential cheating by "..ply:Name().." they have more than the allowed karma limit.")
			if(autokick == true) then
				timer.Create("karmacheatkicktimer", timetokick, 1, function() RunConsoleCommand("ulx","kick",ply:SteamID(),"ServerEssentials: has detected you're using possible cheats/hacks you've been automatically kicked from the game.") end)
				ServerLog("ServerEssentials: has kicked "..ply:Name().." for having above the allowed karma limited.\n")
			end
			if(autoban == true) then
				timer.Create("karmacheatbantimer", timetoban, 1, function() RunConsoleCommand("ulx","banid",ply:SteamID(),lengthofban,"ServerEssentials: has detected you're using possible cheats/hacks you've been automatically banned from the game. You've been banned for "..lengthofban.. " minute(s)\n You can appeal at "..website) end)
				ServerLog("ServerEssentials: has banned "..ply:Name().." for having above the allowed karma limited.\n")
			end
		end
	end
end
radiospamdetector = {}
function antiradioSpam(ply, cmd_name, cmd_target)
	textdata = readCfg("AntiRadioSpam")
	RunString(textdata)
	if(antiradiospamenabled == true) then
		if(radiospamdetector[ply:SteamID()] != nil) then
			radiospamdetector[ply:SteamID()] = radiospamdetector[ply:SteamID()] + 1
		else
			radiospamdetector[ply:SteamID()] = 1
		end
		timer.Create("antiradiospamtimer", timetoradiospamreset, 0, function() radiospamdetector = {} end)
		if(radiospamdetector[ply:SteamID()] >= radiospamlimit) then
			ply:PrintMessage(HUD_PRINTTALK,"Please do not spam chat with radio commands.")
			timer.Create("antiradiospamdecay", timetoradiospamreset, 0, function() radiospamdetector = {} end)
			if(radiospamwarn == true) then
				if(radiospamdetector[ply:SteamID()] >= radiospamwarnlimit) then
					RunConsoleCommand("awarn_warn",ply:SteamID(),"(ServerEssentials) "..ply:Name().." please do not spam chat with radio commands.")
					radiospamdetector[ply:SteamID()] = 0
				end
			end
		end
	end
end
function serveressentialschat(ply, text, public)
	if(string.sub( string.lower(text), 1, 21) == "!serveressentialsinfo") then
		PrintMessage(HUD_PRINTTALK, "The server is running ServerEssentials version 1.2.0")
		return(false)
	end
end
--[[ function topdonatorsetplayer(ply, text, public)
	if(string.sub( string.lower(text), 1, 14) == "!settopdonator") then
		arg = string.gsub(text,"!settopdonator ","")
		topdonatorplayer = arg
		ply:PrintMessage(HUD_PRINTTALK,"You've set "..arg.." as the top donator")
		return(false)
	end
end--]] 
hook.Add("PlayerSay","topdonatorsetplayer", topdonatorsetplayer)
hook.Add("PlayerSay","serveressnetialschatcommand", serveressentialschat)
hook.Add("TTTPlayerRadioCommand","antiradiospam", antiradioSpam)
hook.Add("PlayerSpawn","KarmaCheats", karmacheatDetector)
hook.Add("PlayerSpawn","KarmaPenatlyChecker", karmaChecker) 
hook.Add("PlayerInitialSpawn","topdonator", topDonator)
hook.Add("Initialize","InfoPrinter", infoPrinter)
hook.Add("PlayerSay","AntiChatSpam", antichatSpam)
hook.Add("ULibPostTranslatedCommand", "antiadminspam", AntiAdminSpam)
hook.Add("ULibPostTranslatedCommand", "PsaySpy", ghosterBuster)
hook.Add("PlayerSay","AutoCensor", autoCensor)