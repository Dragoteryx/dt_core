DT_Core.NetSender = DT_Core.CreateStruct("DT/NetSender")

function DT_Core.NetReceive(message, struct, func)
	net.Receive(message, function(len, ply)
		func(struct.__read(struct.__raw(), len, ply))
	end)
end

function DT_Core.NetSender:__new(message, value)
	self.__Message = tostring(message)
	self.__Value = value
	self.__Unreliable = false
end

function DT_Core.NetSender:__tostring()
	return "NetSender [message: " .. self:GetMessage() .. "]"
end

function DT_Core.NetSender.__index:GetMessage()
	return self.__Message
end

function DT_Core.NetSender.__index:GetValue()
	return self.__Value
end

function DT_Core.NetSender.__index:IsUnreliable()
	return self.__Unreliable
end

function DT_Core.NetSender.__index:SetUnreliable(unreliable)
	self.__Unreliable = unreliable
	return self
end

if SERVER then

	function DT_Core.NetSender.__index:SendToPlayer(ply)
		net.Start(self:GetMessage(), self:IsUnreliable())
		self:GetValue():__write()
		net.Send(ply)
		return self
	end

	function DT_Core.NetSender.__index:Broadcast()
		net.Start(self:GetMessage(), self:IsUnreliable())
		self:GetValue():__write()
		net.Broadcast()
		return self
	end

else

	function DT_Core.NetSender.__index:SendToServer()
		net.Start(self:GetMessage(), self:IsUnreliable())
		self:GetValue():__write()
		net.SendToServer()
		return self
	end

end