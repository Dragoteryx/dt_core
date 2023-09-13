local NB = FindMetaTable("NextBot")

function NB:DT_Jump(jumpHeight)
  if not self.loco:IsOnGround() then return end
  local oldJumpHeight = self.loco:GetJumpHeight()
  local seq = self:GetSequence()
  local rate = self:GetPlaybackRate()
  local cycle = self:GetCycle()
  self.loco:SetJumpHeight(jumpHeight)
  self.loco:Jump()
  self.loco:SetJumpHeight(oldJumpHeight)
  self:ResetSequence(seq)
  self:SetPlaybackRate(rate)
  self:SetCycle(cycle)
end

function NB:DT_CounteractGravity()
  if self.loco:IsOnGround() then return end
  local vel = self.loco:GetVelocity()
  local grav = Vector(0, 0, self.loco:GetGravity())
  self.loco:SetVelocity(vel + grav * engine.TickInterval())
end