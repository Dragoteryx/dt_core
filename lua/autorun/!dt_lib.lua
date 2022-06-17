DT_Lib = DT_Lib or {}

local function Include(path)
  print("[DT] Include '"..path.."'")
  return include(path)
end

local function ServerClient(path)
  local server = true
  local client = true
  for _, str in ipairs(string.Explode("[/\\]", path, true)) do
    if str == "server" or string.StartWith(str, "sv_") then client = false end
    if str == "client" or string.StartWith(str, "cl_") then server = false end
  end
  return server, client
end

-- Include a file
function DT_Lib.IncludeFile(path)
  local server, client = ServerClient(path)
  if server and not client then
    if SERVER then return Include(path) end
  elseif client and not server then
    if SERVER then AddCSLuaFile(path) end
    if CLIENT then return Include(path) end
  elseif server and client then
    if SERVER then AddCSLuaFile(path) end
    return Include(path)
  end
end

-- Include every file in a folder
function DT_Lib.IncludeFolder(path)
  local tbl = {}
  for _, file in ipairs(file.Find(path.."/*.lua", "LUA")) do
    tbl[path.."/"..file] = DT_Lib.IncludeFile(path.."/"..file)
  end
  return tbl
end

-- Recursively include everything in a folder
function DT_Lib.RecursiveInclude(path)
  local tbl = DT_Lib.IncludeFolder(path)
  local _, folders = file.Find(path.."/*", "LUA")
  for _, folder in ipairs(folders) do
    table.Merge(tbl, DT_Lib.RecursiveInclude(path.."/"..folder))
  end
  return tbl
end

-- Include everything else
DT_Lib.IncludeFolder("dt_lib")
DT_Lib.IncludeFolder("dt_lib/structs")
DT_Lib.IncludeFolder("dt_lib/autorun")
DT_Lib.IncludeFolder("dt_lib/autorun/server")
DT_Lib.IncludeFolder("dt_lib/autorun/client")
DT_Lib.IncludeFolder("dt_lib/metatables")