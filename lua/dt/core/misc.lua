-- A function that doesn't do anything
function DT_Core.Noop(...)
	return ...
end

-- Pack a vararg
function DT_Core.Pack(...)
	return {...}, select("#", ...)
end

-- Unpack a table of known size
function DT_Core.Unpack(tbl, size, i)
	if not isnumber(i) then i = 1 end
	if i < size then
		return tbl[i], DT_Core.Unpack(tbl, size, i + 1)
	elseif i == size then
		return tbl[i]
	end
end

-- Cancellable timer with a vararg
function DT_Core.Timer(delay, func, ...)
	local cancelled = false
	local args, n = DT_Core.Pack(...)
	timer.Simple(delay, function()
		if cancelled then return end
		func(DT_Core.Unpack(args, n))
	end)
	return function()
		cancelled = true
	end
end

-- Line trace with direction arg
function DT_Core.TraceLine(tr)
	if tr.start and tr.direction and not tr.endpos then
		tr.endpos = tr.start + tr.direction
	end
	local res = util.TraceLine(tr)
	if isnumber(tr.debug) then
		local clr = res.Hit and Color(255, 0, 0) or Color(0, 255, 0)
		debugoverlay.Line(res.StartPos, res.HitPos, tr.debug, clr, true)
	end
	return res
end

-- Hull trace with direction arg
function DT_Core.TraceHull(tr)
	if tr.start and tr.direction and not tr.endpos then
		tr.endpos = tr.start + tr.direction
	end
	local res = util.TraceHull(tr)
	if isnumber(tr.debug) then
		local clr = res.Hit and Color(255, 0, 0) or Color(0, 255, 0)
		local clr_tr = res.Hit and Color(255, 0, 0, 0) or Color(0, 255, 0, 0)
		debugoverlay.Line(res.StartPos, res.HitPos, tr.debug, clr, false)
		debugoverlay.Box(res.HitPos, tr.mins, tr.maxs, tr.debug, clr_tr)
	end
	return res
end

function DT_Core.CreateStruct()
	local mt = setmetatable({__index = {}}, {
		__call = function(self, ...)
			if not isfunction(self.__new) then
				error("this type cannot be constructed")
			else
				local value = self.__raw()
				return value, self.__new(value, ...)
			end
		end
	})

	function mt.__raw()
		return setmetatable({}, mt)
	end
	function mt.__is(value)
		return getmetatable(value) == mt
	end

	return mt
end

function DT_Core.SpawnThread(func, ...)
	local args, n = DT_Core.Pack(...)
	return DT_Core.Promise(function(resolve, reject)
		local id
		repeat
			id = "DT/Thread:" .. tostring(math.random())
		until not timer.Exists(id)

		local thread = coroutine.create(function()
			local ok, res = pcall(function() func(DT_Core.Unpack(args, n)) end)
			if ok then resolve(res)
			else reject(res) end
		end)

		timer.Create(id, 0, 0, function()
			local status = coroutine.status(thread)
			if status == "suspended" then
				coroutine.resume(thread)
			elseif status == "dead" then
				timer.Remove(id)
			end
		end)
	end)
end

function DT_Core.Match(value, match, default)
	local case = match[value]
	if isfunction(case) then
		return case(value)
	elseif isfunction(default) then
		return default(value)
	end
end

function DT_Core.Fetch(request)
	if isstring(request) then
		return DT_Core.Fetch({
			url = request,
			method = "GET"
		})
	else
		return DT_Core.Promise(function(resolve, reject)
			if not HTTP(request) then reject("HTTP request failed")
			else
				request.failure = reject
				request.success = function(code, body, headers)
					resolve({ code = code, body = body, headers = headers })
				end
			end
		end)
	end
end

function DT_Core.Range(from, to, step)
	if to == nil then to = math.huge end
	if step == nil then step = 1 end
	return DT_Core.Iterator(function()
		local current = from
		from = from + step
		if current <= to then
			return current
		else return nil end
	end)
end

function DT_Core.Ipairs(tbl)
	return DT_Core.Iterator.FromCoroutine(function()
		for _, value in ipairs(tbl) do
			coroutine.yield(value)
		end
	end)
end

function DT_Core.Pairs(tbl)
	return DT_Core.Iterator.FromCoroutine(function()
		for key, value in pairs(tbl) do
			coroutine.yield({ key = key, value = value })
		end
	end)
end

function DT_Core.Repeat(value)
	return DT_Core.Iterator(function()
		return value
	end)
end

function DT_Core.Empty()
	return DT_Core.Repeat(nil)
end

function DT_Core.Once(value)
	return DT_Core.Repeat(value):Take(1)
end