DT_Core.Iterator = DT_Core.Struct()

function DT_Core.Iterator:__new(next)
	self.Next = next
end

function DT_Core.Iterator:__call()
	return self:Next()
end

function DT_Core.Iterator:__len()
	return self:Count()
end

function DT_Core.Iterator:__tostring()
	return "Iterator [next: " .. tostring(self.Next) .. "]"
end

function DT_Core.Iterator.FromCoroutine(func)
	local thr = coroutine.create(func)
	return DT_Core.Iterator(function()
		if coroutine.status(thr) == "suspended" then
			local ok, res = coroutine.resume(thr)
			if not ok then error(res)
			else return res end
		end
	end)
end

function DT_Core.Iterator.__index:Map(map)
	return DT_Core.Iterator.FromCoroutine(function()
		for value in self do
			local mapped = map(value)
			if mapped ~= nil then coroutine.yield(mapped)
			else error("cannot map to a nil value") end
		end
	end)
end

function DT_Core.Iterator.__index:MapWhile(mapWhile)
	return DT_Core.Iterator.FromCoroutine(function()
		for value in self do
			local mapped = mapWhile(value)
			if mapped == nil then return
			else coroutine.yield(mapped) end
		end
	end)
end

function DT_Core.Iterator.__index:Filter(filter)
	return DT_Core.Iterator.FromCoroutine(function()
		for value in self do
			if filter(value) then
				coroutine.yield(value)
			end
		end
	end)
end

function DT_Core.Iterator.__index:FilterMap(filterMap)
	return DT_Core.Iterator.FromCoroutine(function()
		for value in self do
			local mapped = filterMap(value)
			if mapped ~= nil then
				coroutine.yield(mapped)
			end
		end
	end)
end

function DT_Core.Iterator.__index:Flatten()
	return DT_Core.Iterator.FromCoroutine(function()
		for iter in self do
			for value in iter do
				coroutine.yield(value)
			end
		end
	end)
end

function DT_Core.Iterator.__index:FlatMap(flatMap)
	return self:Map(flatMap):Flatten()
end

function DT_Core.Iterator.__index:SkipWhile(skipWhile)
	return DT_Core.Iterator.FromCoroutine(function()
		for value in self do
			if not skipWhile(value) then
				coroutine.yield(value)
				break
			end
		end
		for value in self do
			coroutine.yield(value)
		end
	end)
end

function DT_Core.Iterator.__index:Skip(n)
	return self:SkipWhile(function()
		local m = n
		n = n - 1
		return m > 0
	end)
end

function DT_Core.Iterator.__index:TakeWhile(takeWhile)
	return DT_Core.Iterator.FromCoroutine(function()
		for value in self do
			if takeWhile(value) then
				coroutine.yield(value)
			else return end
		end
	end)
end

function DT_Core.Iterator.__index:Take(n)
	return self:TakeWhile(function()
		local m = n
		n = n - 1
		return m > 0
	end)
end

function DT_Core.Iterator.__index:Unique()
	return DT_Core.Iterator.FromCoroutine(function()
		local yielded = {}
		for value in self do
			if not yielded[value] then
				coroutine.yield(value)
				yielded[value] = true
			end
		end
	end)
end

function DT_Core.Iterator.__index:Enumerate()
	local n = 1
	return self:Map(function(value)
		local m = n
		n = n + 1
		return {
			value = value,
			n = m
		}
	end)
end

function DT_Core.Iterator.__index:Inspect(inspect)
	return self:Map(function(value)
		inspect(value)
		return value
	end)
end

function DT_Core.Iterator.__index:Find(find)
	for value in self do
		if find(value) then return value end
	end
	return nil
end

function DT_Core.Iterator.__index:FindMap(findMap)
	for value in self do
		local mapped = findMap(value)
		if mapped ~= nil then return mapped end
	end
	return nil
end

function DT_Core.Iterator.__index:Any(any)
	for value in self do
		if any(value) then return true end
	end
	return false
end

function DT_Core.Iterator.__index:All(all)
	for value in self do
		if not all(value) then return false end
	end
	return true
end

function DT_Core.Iterator.__index:Fold(acc, fold)
	for value in self do acc = fold(acc, value) end
	return acc
end

function DT_Core.Iterator.__index:Reduce(reduce)
	return self:Fold(self(), reduce)
end

function DT_Core.Iterator.__index:Sum()
	return self:Reduce(function(a, b)
		return a + b
	end)
end

function DT_Core.Iterator.__index:Product()
	return self:Reduce(function(a, b)
		return a * b
	end)
end

function DT_Core.Iterator.__index:Concat()
	return self:Reduce(function(a, b)
		return a .. b
	end)
end

function DT_Core.Iterator.__index:Min(cmp)
	if cmp == nil then cmp = function(a, b) return b > a end end
	return self:Reduce(function(a, b)
		if cmp(a, b) then return a else return b end
	end)
end

function DT_Core.Iterator.__index:Max(cmp)
	if cmp == nil then cmp = function(a, b) return b > a end end
	return self:Reduce(function(a, b)
		if cmp(a, b) then return b else return a end
	end)
end

function DT_Core.Iterator.__index:Nth(n)
	return self:Skip(n - 1)()
end

function DT_Core.Iterator.__index:Last()
	return self:Reduce(function(_, value)
		return value
	end)
end

function DT_Core.Iterator.__index:Collect()
	return self:Fold({}, function(tbl, value)
		table.insert(tbl, value)
		return tbl
	end)
end

function DT_Core.Iterator.__index:Sorted(sort)
	local tbl = self:Collect()
	table.sort(tbl, sort)
	return DT_Core.Ipairs(tbl)
end

function DT_Core.Iterator.__index:Randomized()
	local tbl = self:Collect()
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return DT_Core.Ipairs(tbl)
end

function DT_Core.Iterator.__index:Random()
	return self:Randomized()()
end

function DT_Core.Iterator.__index:ForEach(func)
	for value in self do func(value) end
end

function DT_Core.Iterator.__index:Count()
	return self:Fold(0, function(n) return n + 1 end)
end