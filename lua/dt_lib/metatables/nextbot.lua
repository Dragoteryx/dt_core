--- @class NextBot : Entity
local NB = FindMetaTable("NextBot")

if SERVER then

  function NB:DT_Jump()
    local seq = self:GetSequence()
    local rate = self:GetPlaybackRate()
    local cycle = self:GetCycle()
    self.loco:Jump()
    self:ResetSequence(seq)
    self:SetPlaybackRate(rate)
    self:SetCycle(cycle)
  end

  function NB:DT_LeaveGround()
    if not self.loco:IsOnGround() then return end
    local jumpHeight = self.loco:GetJumpHeight()
    self.loco:SetJumpHeight(1)
    self:DT_Jump()
    self.loco:SetJumpHeight(jumpHeight)
  end

  function NB:DT_OpposeGravity()
    if self.loco:IsOnGround() then return end
    local vel = self.loco:GetVelocity()
    local grav = Vector(0, 0, self.loco:GetGravity())
    self.loco:SetVelocity(vel + grav*engine.TickInterval())
  end

end