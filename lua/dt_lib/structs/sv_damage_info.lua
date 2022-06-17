--- @class DT_Lib.DamageInfo
DT_Lib.DAMAGE_INFO = {}

--- Creates a read-only Lua version of CTakeDamageInfo.
--- This is used to store damage information for multiple ticks.
--- @param dmginfo? CTakeDamageInfo @The damage to base this on
--- @return DT_Lib.DamageInfo
function DT_Lib.DamageInfo(dmginfo)
  dmginfo = dmginfo or DamageInfo()
  local ldmginfo = setmetatable({}, {__index = DT_Lib.DAMAGE_INFO})
  ldmginfo.AmmoType = dmginfo:GetAmmoType()
  ldmginfo.Attacker = dmginfo:GetAttacker()
  ldmginfo.BaseDamage = dmginfo:GetBaseDamage()
  ldmginfo.Damage = dmginfo:GetDamage()
  ldmginfo.DamageBonus = dmginfo:GetDamageBonus()
  ldmginfo.DamageCustom = dmginfo:GetDamageCustom()
  ldmginfo.DamageForce = dmginfo:GetDamageForce()
  ldmginfo.DamagePosition = dmginfo:GetDamagePosition()
  ldmginfo.DamageType = dmginfo:GetDamageType()
  ldmginfo.Inflictor = dmginfo:GetInflictor()
  ldmginfo.MaxDamage = dmginfo:GetMaxDamage()
  ldmginfo.ReportedPosition = dmginfo:GetReportedPosition()
  return ldmginfo
end

function DT_Lib.DAMAGE_INFO:GetAmmoType()
  return self.AmmoType
end
function DT_Lib.DAMAGE_INFO:GetAttacker()
  return self.Attacker
end
function DT_Lib.DAMAGE_INFO:GetBaseDamage()
  return self.BaseDamage
end
function DT_Lib.DAMAGE_INFO:GetDamage()
  return self.Damage
end
function DT_Lib.DAMAGE_INFO:GetDamageBonus()
  return self.DamageBonus
end
function DT_Lib.DAMAGE_INFO:GetDamageCustom()
  return self.DamageCustom
end
function DT_Lib.DAMAGE_INFO:GetDamageForce()
  return self.DamageForce
end
function DT_Lib.DAMAGE_INFO:GetDamagePosition()
  return self.DamagePosition
end
function DT_Lib.DAMAGE_INFO:GetDamageType()
  return self.DamageType
end
function DT_Lib.DAMAGE_INFO:GetInflictor()
  return self.Inflictor
end
function DT_Lib.DAMAGE_INFO:GetMaxDamage()
  return self.MaxDamage
end
function DT_Lib.DAMAGE_INFO:GetReportedPosition()
  return self.ReportedPosition
end
function DT_Lib.DAMAGE_INFO:IsDamageType(type)
  return bit.band(self.DamageType, type) == self.DamageType
end
function DT_Lib.DAMAGE_INFO:IsBulletDamage()
  return self:IsDamageType(DMG_BULLET)
end
function DT_Lib.DAMAGE_INFO:IsExplosionDamage()
  return self:IsDamageType(DMG_BLAST)
end
function DT_Lib.DAMAGE_INFO:IsFallDamage()
  return self:IsDamageType(DMG_FALL)
end

--- Converts a DT_Lib.DamageInfo to a CTakeDamageInfo
--- @return CTakeDamageInfo
function DT_Lib.DAMAGE_INFO:ToUserdata()
  local dmginfo = DamageInfo()
  dmginfo:SetAmmoType(self.AmmoType)
  if IsValid(self.Attacker) then dmginfo:SetAttacker(self.Attacker) end
  dmginfo:SetBaseDamage(self.BaseDamage)
  dmginfo:SetDamage(self.Damage)
  dmginfo:SetDamageBonus(self.DamageBonus)
  dmginfo:SetDamageCustom(self.DamageCustom)
  dmginfo:SetDamageForce(self.DamageForce)
  dmginfo:SetDamagePosition(self.DamagePosition)
  dmginfo:SetDamageType(self.DamageType)
  if IsValid(self.Inflictor) then dmginfo:SetInflictor(self.Inflictor) end
  dmginfo:SetMaxDamage(self.MaxDamage)
  dmginfo:SetReportedPosition(self.ReportedPosition)
  return dmginfo
end