local exolib = include("exolib.lua")

local BannedWords = {"Test","Testing","TestingBigTime"}

function Koolio( ply )
	PrintTable(BannedWords)
end
hook.Add("PlayerSay", "Koolio", Koolio)