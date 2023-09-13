local MIXIN_CLASS = {}
function DT_Core.Mixin(class)
  return {[MIXIN_CLASS] = class}
end

local MIXINS = {}
for _, mixin in pairs(DT_Core.RecursiveInclude("dt/mixins")) do
  if not istable(mixin) or not isstring(mixin[MIXIN_CLASS]) then continue end
  table.insert(MIXINS, table.Copy(mixin))
end

local function MixinApplier(lib)
  return function(tbl, class)
    for _, mixin in ipairs(MIXINS) do
      local mixinClass = mixin[MIXIN_CLASS]
      if class == mixinClass or lib.IsBasedOn(class, mixinClass) then
        for key, value in pairs(mixin) do
          if key == MIXIN_CLASS then continue end
          local oldValue = tbl[key]
          if isfunction(oldValue) then
            tbl[key] = function(self, ...)
              return value(self, oldValue, ...)
            end
          end
        end
      end
    end
  end
end

local ApplySENTMixins = MixinApplier(scripted_ents)
local ApplySWEPMixins = MixinApplier(weapons)

local SENTOnLoaded = scripted_ents.OnLoaded
function scripted_ents.OnLoaded()
  for class, tbl in pairs(scripted_ents.GetList()) do
    ApplySENTMixins(tbl.t, class)
  end

  SENTOnLoaded()
  hook.Add("PreRegisterSENT", "DT/ApplySENTMixins", function(ENT, class)
    ApplySENTMixins(ENT, class)
  end)
end

local SWEPOnLoaded = weapons.OnLoaded
function weapons.OnLoaded()
  for class, tbl in pairs(weapons.GetList()) do
    ApplySWEPMixins(tbl.t, class)
  end

  SWEPOnLoaded()
  hook.Add("PreRegisterSWEP", "DT/ApplySWEPMixins", function(SWEP, class)
    ApplySWEPMixins(SWEP, class)
  end)
end