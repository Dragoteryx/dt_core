--- @class DT_Lib.TrajectoryOptions
--- @field target Vector @The target's position
--- @field velocity? Vector @The target's velocity

--- @class DT_Lib.LinearTrajectoryOptions : DT_Lib.TrajectoryOptions
--- @field speed number @The speed of the projectile

--- @param options DT_Lib.LinearTrajectoryOptions
function DT_Lib.CalcLinearTrajectory(options)
  
end

--- @class DT_Lib.BallisticTrajectoryOptions : DT_Lib.TrajectoryOptions
--- @field magnitude? number @The magnitude of the trajectory
--- @field pitch? number @The pitch of the trajectory
--- @field gravity? number @The gravity

--- @param options DT_Lib.BallisticTrajectoryOptions
function DT_Lib.CalcBallisticTrajectory(options)
  if isvector(options.velocity) then
    -- TODO
  else
    local gravity = options.gravity or physenv.GetGravity()
    local magnitude, pitch = options.magnitude, options.pitch
    if isnumber(magnitude) and not isnumber(pitch) then
      
    elseif isnumber(pitch) and not isnumber(magnitude) then
    
    end
  end
end