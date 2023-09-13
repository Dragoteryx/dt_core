DT_Core.Promise = DT_Core.CreateStruct()

local PENDING = 0
local FULFILLED = 1
local REJECTED = -1

function DT_Core.Promise:__new(func)
	self.__State = PENDING
	self.__Handlers = {}

	local function fulfill(value)
		if self.__State == PENDING then
			self.__State = FULFILLED
			self.__Value = value
			for _, handler in ipairs(self.__Handlers) do
				handler.onFulfilled(value)
			end
		end
	end

	local function reject(value)
		if self.__State == PENDING then
			self.__State = REJECTED
			self.__Value = value
			for _, handler in ipairs(self.__Handlers) do
				handler.onRejected(value)
			end
		end
	end

	local function resolve(value)
		if DT_Core.Promise.__is(value) then
			value:Done(resolve, reject)
		else fulfill(value) end
	end

	local ok, res = pcall(function() func(resolve, reject) end)
	if not ok then reject(res) end
end

function DT_Core.Promise:__tostring()
	if self.__State == FULFILLED then
		return "Promise [fulfilled: " .. tostring(self.__Value) .. "]"
	elseif self.__State == REJECTED then
		return "Promise [rejected: " .. tostring(self.__Value) .. "]"
	else
		return "Promise [pending]"
	end
end

function DT_Core.Promise.__index:Done(onFulfilled, onRejected)
	if onFulfilled == nil then onFulfilled = function() end end
	if onRejected == nil then onRejected = function() end end
	timer.Simple(0, function()
		if self.__State == FULFILLED then
			onFulfilled(self.__Value)
		elseif self.__State == REJECTED then
			onRejected(self.__Value)
		else
			table.insert(self.__Handlers, {
				onFulfilled = onFulfilled,
				onRejected = onRejected
			})
		end
	end)
end

function DT_Core.Promise.__index:Then(onFulfilled, onRejected)
	return DT_Core.Promise(function(resolve, reject)
		self:Done(function(value)
			if isfunction(onFulfilled) then
				local ok, res = pcall(function()
					resolve(onFulfilled(value))
				end)
				if not ok then reject(res) end
			else resolve(value) end
		end, function(value)
			if isfunction(onRejected) then
				local ok, res = pcall(function()
					resolve(onRejected(value))
				end)
				if not ok then reject(res) end
			else reject(value) end
		end)
	end)
end

function DT_Core.Promise.__index:Catch(onRejected)
	return self:Then(nil, onRejected)
end

function DT_Core.Promise.__index:Finally(onSettled)
	return self:Then(onSettled, onSettled)
end

function DT_Core.Promise.__index:Await(...)
	while self.__State == PENDING do coroutine.yield(...) end
	if self.__State == FULFILLED then
		return self.__Value
	else
		error(self.__Value)
	end
end

function DT_Core.Promise.Resolved(value)
	return DT_Core.Promise(function(resolve, _) resolve(value) end)
end

function DT_Core.Promise.Rejected(value)
	return DT_Core.Promise(function(_, reject) reject(value) end)
end

function DT_Core.Promise.Race(promises)
	return DT_Core.Promise(function(resolve, reject)
		for _, promise in pairs(promises) do
			promise:Done(resolve, reject)
		end
	end)
end

function DT_Core.Promise.All(promises)
	return DT_Core.Promise(function(resolve, reject)
		local remaining = table.Count(promises)
		if remaining == 0 then resolve({})
		else
			local results = {}
			for key, promise in pairs(promises) do
				promise:Done(function(res)
					results[key] = res
					remaining = remaining - 1
					if remaining == 0 then
						resolve(results)
					end
				end, reject)
			end
		end
	end)
end

function DT_Core.Promise.Any(promises)
	return DT_Core.Promise(function(resolve, reject)
		local remaining = table.Count(promises)
		if remaining == 0 then reject({})
		else
			local results = {}
			for key, promise in pairs(promises) do
				promise:Done(resolve, function(err)
					results[key] = err
					remaining = remaining - 1
					if remaining == 0 then
						reject(results)
					end
				end)
			end
		end
	end)
end

function DT_Core.Promise.AllSettled(promises)
	return DT_Core.Promise(function(resolve, _)
		local remaining = table.Count(promises)
		if remaining == 0 then resolve({})
		else
			local results = {}
			for key, promise in pairs(promises) do
				promise:Done(function(res)
					results[key] = {
						status = "fulfilled",
						value = res
					}
					remaining = remaining - 1
					if remaining == 0 then
						resolve(results)
					end
				end, function(err)
					results[key] = {
						status = "rejected",
						error = err
					}
					remaining = remaining - 1
					if remaining == 0 then
						resolve(results)
					end
				end)
			end
		end
	end)
end