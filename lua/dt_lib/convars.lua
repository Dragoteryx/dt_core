-- Creates a serverside and clientside ConVar
function DT_Lib.ConVar(name, value, ...)
  return CreateConVar(name, value, FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, ...)
end

-- Creates a serverside ConVar
function DT_Lib.ServerConVar(name, value, ...)
  if CLIENT then return end
  return CreateConVar(name, value, FCVAR_ARCHIVE + FCVAR_NOTIFY, ...)
end

-- Creates a clientside ConVar
function DT_Lib.ClientConVar(name, value, ...)
  if SERVER then return end
  return CreateConVar(name, value, FCVAR_ARCHIVE, ...)
end

-- Creates a clientside convar that can be
-- retrieved serverside via ply.GetInfo or ply.GetInfoNum
function DT_Lib.SharedClientConVar(name, value, ...)
  if SERVER then return end
  return CreateConVar(name, value, FCVAR_ARCHIVE + FCVAR_USERINFO, ...)
end