DT_Core.Lock = DT_Core.Struct()

function DT_Core.Lock:__new(name)
	self.__Name = tostring(name or "")
	self.__Locked = false
end

function DT_Core.Lock:__tostring()
	return "Lock '" .. self:GetName() .. "' [locked: " .. tostring(self:IsLocked()) .. "]"
end

function DT_Core.Lock.__index:GetName()
	return self.__Name
end

function DT_Core.Lock.__index:IsLocked()
	return self.__Locked
end

function DT_Core.Lock.__index:Acquire(...)
	if self:IsLocked() then
		if not coroutine.running() then
			error("tried to acquire already acquired lock '" .. self:GetName() .. "'")
		else
			while self:IsLocked() do
				coroutine.yield(...)
			end
		end
	end

	self.__Locked = true
end

function DT_Core.Lock.__index:TryAcquire()
	if not self:IsLocked() then
		self.__Locked = true
		return true
	else return false end
end

function DT_Core.Lock.__index:Release()
	self.__Locked = false
end