local TARGETS = {}

function DT_Core.IterTargets()
	return DT_Core.Ipairs(TARGETS)
end

function DT_Core.GetTargets()
	return DT_Core.IterTargets():Collect()
end

hook.Add("OnEntityCreated", "DT/AddToTargets", function(ent)
	ent:DT_Timer(0, function()
		if ent:DT_IsTarget() then
			table.insert(TARGETS, ent)
			ent:CallOnRemove("DT/RemoveFromTargets", function()
				table.RemoveByValue(TARGETS, ent)
				hook.Run("DT/TargetRemoved", ent)
			end)
			hook.Run("DT/NewTarget", ent)
		end
	end)
end)