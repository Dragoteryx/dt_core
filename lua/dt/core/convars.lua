-- Creates a serverside and clientside ConVar
function DT_Core.ConVar(name, value, flags, ...)
  return CreateConVar(name, value, bit.bor(flags or 0, FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED), ...)
end

if SERVER then

  -- Creates a serverside ConVar
  function DT_Core.ServerConVar(name, value, flags, ...)
    return CreateConVar(name, value, bit.bor(flags or 0, FCVAR_ARCHIVE, FCVAR_NOTIFY), ...)
  end

else

  -- Creates a clientside ConVar
  function DT_Core.ClientConVar(name, value, flags, ...)
    return CreateConVar(name, value, bit.bor(flags or 0, FCVAR_ARCHIVE), ...)
  end

  -- Creates a clientside convar that can be retrieved serverside via Player:GetInfo or Player:GetInfoNum
  function DT_Core.SharedConVar(name, value, flags, ...)
    return CreateConVar(name, value, bit.bor(flags or 0, FCVAR_ARCHIVE, FCVAR_USERINFO), ...)
  end

end