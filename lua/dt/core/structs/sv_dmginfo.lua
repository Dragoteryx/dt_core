DT_Core.DamageInfo = DT_Core.Struct()

-- Creates a read-only Lua version of CTakeDamageInfo
function DT_Core.DamageInfo:__new(dmginfo)
  dmginfo = dmginfo or DamageInfo()
  self.__AmmoType = dmginfo:GetAmmoType()
  self.__Attacker = dmginfo:GetAttacker()
  self.__BaseDamage = dmginfo:GetBaseDamage()
  self.__Damage = dmginfo:GetDamage()
  self.__DamageBonus = dmginfo:GetDamageBonus()
  self.__DamageCustom = dmginfo:GetDamageCustom()
  self.__DamageForce = dmginfo:GetDamageForce()
  self.__DamagePosition = dmginfo:GetDamagePosition()
  self.__DamageType = dmginfo:GetDamageType()
  self.__Inflictor = dmginfo:GetInflictor()
  self.__MaxDamage = dmginfo:GetMaxDamage()
  self.__ReportedPosition = dmginfo:GetReportedPosition()
end

function DT_Core.DamageInfo.__index:GetAmmoType()
  return self.__AmmoType
end
function DT_Core.DamageInfo.__index:GetAttacker()
  return self.__Attacker
end
function DT_Core.DamageInfo.__index:GetBaseDamage()
  return self.__BaseDamage
end
function DT_Core.DamageInfo.__index:GetDamage()
  return self.__Damage
end
function DT_Core.DamageInfo.__index:GetDamageBonus()
  return self.__DamageBonus
end
function DT_Core.DamageInfo.__index:GetDamageCustom()
  return self.__DamageCustom
end
function DT_Core.DamageInfo.__index:GetDamageForce()
  return self.__DamageForce
end
function DT_Core.DamageInfo.__index:GetDamagePosition()
  return self.__DamagePosition
end
function DT_Core.DamageInfo.__index:GetDamageType()
  return self.__DamageType
end
function DT_Core.DamageInfo.__index:GetInflictor()
  return self.__Inflictor
end
function DT_Core.DamageInfo.__index:GetMaxDamage()
  return self.__MaxDamage
end
function DT_Core.DamageInfo.__index:GetReportedPosition()
  return self.__ReportedPosition
end
function DT_Core.DamageInfo.__index:IsDamageType(dmgtype)
  return bit.band(self.__DamageType, dmgtype) == dmgtype
end
function DT_Core.DamageInfo.__index:IsBulletDamage()
  return self:IsDamageType(DMG_BULLET)
end
function DT_Core.DamageInfo.__index:IsExplosionDamage()
  return self:IsDamageType(DMG_BLAST)
end
function DT_Core.DamageInfo.__index:IsFallDamage()
  return self:IsDamageType(DMG_FALL)
end

-- Converts a DT_Core.DamageInfo to a CTakeDamageInfo
function DT_Core.DamageInfo.__index:ToCTakeDamageInfo()
  local dmginfo = DamageInfo()
  dmginfo:SetAmmoType(self:GetAmmoType())
  dmginfo:SetBaseDamage(self:GetBaseDamage())
  dmginfo:SetDamage(self:GetDamage())
  dmginfo:SetDamageBonus(self:GetDamageBonus())
  dmginfo:SetDamageCustom(self:GetDamageCustom())
  dmginfo:SetDamageForce(self:GetDamageForce())
  dmginfo:SetDamagePosition(self:GetDamagePosition())
  dmginfo:SetDamageType(self:GetDamageType())
  dmginfo:SetMaxDamage(self:GetMaxDamage())
  dmginfo:SetReportedPosition(self:GetReportedPosition())

  local attacker = self:GetAttacker()
  local inflictor = self:GetInflictor()
  if IsValid(attacker) then dmginfo:SetAttacker(attacker) end
  if IsValid(inflictor) then dmginfo:SetInflictor(inflictor) end
  return dmginfo
end