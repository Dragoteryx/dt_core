DT_Core = DT_Core or {}

local function Include(path)
  print("[DT] Include '" .. path .. "'")
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

-- Includes a single file
function DT_Core.IncludeFile(path)
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

-- Includes every file in a folder
function DT_Core.IncludeFolder(path)
  local tbl = {}
  for _, file in ipairs(file.Find(path .. "/*.lua", "LUA")) do
    tbl[path .. "/" .. file] = DT_Core.IncludeFile(path .. "/" .. file)
  end
  return tbl
end

-- Recursively includes every file in a folder
function DT_Core.RecursiveInclude(path)
  local tbl = DT_Core.IncludeFolder(path)
  local _, folders = file.Find(path .. "/*", "LUA")
  for _, folder in ipairs(folders) do
    table.Merge(tbl, DT_Core.RecursiveInclude(path .. "/" .. folder))
  end
  return tbl
end

-- Include DT_Core then execute autorun
DT_Core.IncludeFolder("dt/core")
DT_Core.IncludeFolder("dt/core/structs")
DT_Core.IncludeFolder("dt/core/metatables")
DT_Core.IncludeFolder("dt/core/cl_draw")
DT_Core.IncludeFolder("dt/autorun")
DT_Core.IncludeFolder("dt/autorun/server")
DT_Core.IncludeFolder("dt/autorun/client")