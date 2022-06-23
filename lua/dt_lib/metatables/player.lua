--- @class Player : Entity
local PLY = FindMetaTable("Player")

-- Get the player's vehicle
function PLY:DT_GetVehicle()
  local veh = self:GetVehicle()
  if IsValid(veh) then
    return veh:DT_ClimbParents()
  else return NULL end
end