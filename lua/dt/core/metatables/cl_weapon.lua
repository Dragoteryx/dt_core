local WEAP = FindMetaTable("Weapon")

function WEAP:DT_GetNiceName()
	local name = self:GetPrintName()
	if string.StartWith(name, "#") then name = language.GetPhrase(self:GetClass()) end
	if name == "<MISSING SWEP PRINT NAME>" then name = self:GetClass() end
	return name
end