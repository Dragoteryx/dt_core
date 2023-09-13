function DT_Core.CalcLinearTrajectory(options)
  
end

function DT_Core.CalcBallisticTrajectory(options)
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