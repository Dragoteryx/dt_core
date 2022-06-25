--- @class Entity
local ENT = FindMetaTable("Entity")

-- Entities that are
-- considered as valid "targets"
function ENT:DT_IsTarget()
  if self.DT_Target then return true end
  if self:IsPlayer() then return true end
  if self:IsNextBot() then return true end
  if self:IsNPC() then return true end
  return false
end

--- Cancellable timer with a vararg that expires if the entity isn't valid.
--- @param delay number @The delay in seconds
--- @param func function @The function to call
--- @vararg any
--- @return function cancel @Call this function to cancel the timer
function ENT:DT_Timer(delay, func, ...)
  return DT_Lib.Timer(delay, function(...)
    if not IsValid(self) then return end
    func(self, ...)
  end, ...)
end

-- Checks for collisions before
-- setting an entity's position
function ENT:DT_SafeSetPos(pos)
  local tr = self:DT_TraceHull({start = pos, endpos = pos})
  if tr.Hit then return false end
  self:SetPos(pos)
  return true
end

-- Get the entity's "player color"
function ENT:DT_GetPlayerColor()
  return isfunction(self.GetPlayerColor)
    and self:GetPlayerColor():ToColor()
    or nil
end

-- Set the entity's "player color"
-- Only works on some models (mostly playermodels)
function ENT:DT_SetPlayerColor(color)
  local vec = color:ToVector()
  if self:IsPlayer() then
    self:SetPlayerColor(vec)
  else
    function self.GetPlayerColor() return vec end
    if SERVER then
      net.Start("DT/SetPlayerColor")
      net.WriteEntity(self)
      net.WriteColor(color)
      net.Broadcast()
    end
  end
end

function ENT:DT_TraceLine(tr)
  if not tr.start then tr.start = self:GetPos() end
  if not tr.collisiongroup then tr.collisiongroup = self:GetCollisionGroup() end
  if not tr.filter then tr.filter = { self } end
  if self:IsNextBot() and not tr.mask then
    tr.mask = self:GetSolidMask()
  end
  return DT_Lib.TraceLine(tr)
end

function ENT:DT_TraceHull(tr)
  if not tr.start then tr.start = self:GetPos() end
  if not tr.collisiongroup then tr.collisiongroup = self:GetCollisionGroup() end
  if not tr.filter then tr.filter = { self } end
  local mins, maxs = self:GetCollisionBounds()
  if not tr.mins then tr.mins = mins end
  if not tr.maxs then tr.maxs = maxs end
  if self:IsNextBot() then
    if tr.step then tr.mins.z = self.loco:GetStepHeight() end
    if not tr.mask then tr.mask = self:GetSolidMask() end
  end
  return DT_Lib.TraceHull(tr)
end

function ENT:DT_LoopkupActivity(act)
  if not istable(self.__DT_LoopkupActivity) then
    self.__DT_LoopkupActivity = {}
  end
  if self.__DT_LoopkupActivity[act] then
    return self.__DT_LoopkupActivity[act]
  else
    for i in pairs(self:GetSequenceList()) do
      if self:GetSequenceActivityName(i) == act then
        local id = self:GetSequenceActivity(i)
        self.__DT_LoopkupActivity[act] = id
        return id
      end
    end
    self.__DT_LoopkupActivity[act] = ACT_INVALID
    return ACT_INVALID
  end
end

-- Recursively climbs up the parent chain
function ENT:DT_ClimbParents()
  local parent = self:GetParent()
  if not IsValid(parent) then return self
  else return parent:DT_ClimbParents() end
end

if SERVER then
  util.AddNetworkString("DT/SetPlayerColor")

  -- Returns an entity's disposition
  -- Compatible with the most used NPC bases
  function ENT:DT_GetDisposition(ent)
    if not IsValid(ent) then return D_ER
    elseif self == ent then return D_NU
    elseif self.DT_NextBot then return D_HT
    elseif self:GetClass() == "neo_replicator_melon" then
      return D_HT
    elseif self:GetClass() == "dr_kleaner" then
      return self.EstFou and D_HT or D_NU
    elseif self:IsNPC() then
      return self:Disposition(ent)
    elseif self.IsDrGNextbot then
      return self:GetRelationship(ent, true)
    elseif self.IV04NextBot then
      local disp = self:CheckRelationships(ent)
      if disp == "friend" then return D_LI
      elseif disp == "foe" then return D_HT
      else return D_NU end
    elseif self:IsPlayer() then
      if not ent:IsPlayer() then
        return ent:Disposition(self)
      else
        local myTeam = self:Team()
        local entTeam = ent:Team()
        if myTeam == TEAM_CONNECTING or entTeam == TEAM_CONNECTING
        or myTeam == TEAM_UNASSIGNED or entTeam == TEAM_UNASSIGNED
        or myTeam == TEAM_SPECTATOR or entTeam == TEAM_SPECTATOR then return D_NU
        elseif myTeam == entTeam then return D_LI
        else return D_HT end
      end
    end
    return D_NU
  end

  -- Dissolve an entity (when hit by a combine ball)
  function ENT:DT_Dissolve(type)
    if self:IsFlagSet(FL_DISSOLVING) then return true end
    local dissolver = ents.Create("env_entity_dissolver")
    if not IsValid(dissolver) then return false end
    if self:GetName() == "" then
      self:SetName("ent_"..self:GetClass().."_"..self:GetCreationID().."_dissolved")
    end
    dissolver:SetKeyValue("dissolvetype", tostring(type or 0))
    dissolver:Fire("dissolve", self:GetName())
    dissolver:Remove()
    return true
  end

  -- Adds the entity's death to the killfeed
  function ENT:DT_AddDeathNotice(attacker, inflictor)
    if self:IsPlayer() then
      hook.Run("PlayerDeath", self, inflictor, attacker)
    else hook.Run("OnNPCKilled", self, attacker, inflictor) end
  end

  -- Create a ragdoll based on this entity
  function ENT:DT_CreateRagdoll(dmginfo)
    if not util.IsValidRagdoll(self:GetModel()) then return NULL end
    local ragdoll = ents.Create("prop_ragdoll")
    if not IsValid(ragdoll) then return NULL end
    ragdoll:SetPos(self:GetPos())
    ragdoll:SetAngles(self:GetAngles())
    ragdoll:SetModel(self:GetModel())
    ragdoll:SetSkin(self:GetSkin())
    ragdoll:SetColor(self:GetColor())
    ragdoll:SetModelScale(self:GetModelScale())
    ragdoll:SetBloodColor(self:GetBloodColor())
    local playerColor = self:DT_GetPlayerColor()
    if playerColor then
      ragdoll:DT_SetPlayerColor(playerColor)
    end
    for i = 0, #self:GetBodyGroups()-1 do
      ragdoll:SetBodygroup(i, self:GetBodygroup(i))
    end
    ragdoll:Spawn()
    for i = 0, ragdoll:GetPhysicsObjectCount()-1 do
      local phys = ragdoll:GetPhysicsObjectNum(i)
      if not IsValid(phys) then continue end
      local bone = ragdoll:TranslatePhysBoneToBone(i)
      local pos, ang = self:GetBonePosition(bone)
      phys:SetPos(pos)
      phys:SetAngles(ang)
    end
    if dmginfo then
      local phys = ragdoll:GetPhysicsObject()
      phys:SetVelocity(self:GetVelocity())
      local force = dmginfo:GetDamageForce()
      local pos = dmginfo:GetDamagePosition()
      if IsValid(phys) and isvector(force) and isvector(pos) then
        phys:ApplyForceOffset(force, pos)
      end
      if dmginfo:IsDamageType(DMG_BURN) then ragdoll:Ignite(10) end
      if dmginfo:IsDamageType(DMG_DISSOLVE) then ragdoll:DT_Dissolve() end
    end
    ragdoll:SetOwner(self)
    hook.Run("CreateEntityRagdoll", self, ragdoll)
    return ragdoll
  end

  -- Create a ragdoll based on this entity, and remove the entity
  function ENT:DT_BecomeRagdoll(dmginfo)
    if self:IsPlayer() then
      if not self:Alive() then return NULL
      else self:KillSilent() end
    else self:Remove() end
    if not self:IsFlagSet(FL_TRANSRAGDOLL)
    and not (dmginfo and dmginfo:IsDamageType(DMG_REMOVENORAGDOLL)) then
      if not self:IsPlayer() then self:AddFlags(FL_TRANSRAGDOLL) end
      local ragdoll = self:DT_CreateRagdoll(dmginfo)
      if IsValid(ragdoll) and not self:IsPlayer() then
        cleanup.ReplaceEntity(self, ragdoll)
        undo.ReplaceEntity(self, ragdoll)
      end
      return ragdoll
    else return NULL end
  end

  -- Get the entity's actual velocity
  function ENT:DT_GetVelocity()
    if self:IsNextBot() then
      return self.loco:GetVelocity()
    elseif self:IsNPC() and self:IsOnGround() then
      return self:GetMoveVelocity()
    else return self:GetVelocity() end
  end

else

  net.Receive("DT/SetPlayerColor", function()
    local ent = net.ReadEntity()
    local color = net.ReadColor()
    if IsValid(ent) then
      ent:DT_SetPlayerColor(color)
    end
  end)

end