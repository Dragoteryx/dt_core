--- A function that doesn't do anything
function DT_Lib.Noop(...)
  return ...
end

--- Pack a vararg
--- @vararg any
--- @return table, number
function DT_Lib.Pack(...)
  return {...}, select("#", ...)
end

--- Unpack a table of known size
--- @param tbl table @The table to unpack
--- @param size number @The size of the table
--- @param i? number @The starting index
--- @return ...
function DT_Lib.Unpack(tbl, size, i)
  if not isnumber(i) then i = 1 end
  if i < size then
    return tbl[i], DT_Lib.Unpack(tbl, size, i+1)
  elseif i == size then return tbl[i] end
end

--- Cancellable timer with a vararg.
--- @param delay number @The delay in seconds
--- @param func function @The function to call
--- @vararg any
--- @return function cancel @Call this function to cancel the timer
function DT_Lib.Timer(delay, func, ...)
  local cancelled = false
  local args, n = DT_Lib.Pack(...)
  timer.Simple(delay, function()
    if cancelled then return end
    func(DT_Lib.Unpack(args, n))
  end)
  return function()
    cancelled = true
  end
end

--- Line trace with direction arg
function DT_Lib.TraceLine(tr)
  if tr.start and tr.direction and not tr.endpos then
    tr.endpos = tr.start + tr.direction
  end
  local res = util.TraceLine(tr)
  if isnumber(tr.debug) then
    local clr = res.Hit and DT_Lib.CLR_RED or DT_Lib.CLR_GREEN
    debugoverlay.Line(res.StartPos, res.HitPos, tr.debug, clr, true)
  end
  return res
end

--- Hull trace with direction arg
function DT_Lib.TraceHull(tr)
  if tr.start and tr.direction and not tr.endpos then
    tr.endpos = tr.start + tr.direction
  end
  local res = util.TraceHull(tr)
  if isnumber(tr.debug) then
    local clr = res.Hit and DT_Lib.CLR_RED or DT_Lib.CLR_GREEN
    local clr_tr = res.Hit and DT_Lib.CLR_RED_TR or DT_Lib.CLR_GREEN_TR
    debugoverlay.Line(res.StartPos, res.HitPos, tr.debug, clr, false)
    debugoverlay.Box(res.HitPos, tr.mins, tr.maxs, tr.debug, clr_tr)
  end
  return res
end