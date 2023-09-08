--[[
	@Author: Anna W. <anna@kat.digital> Skylar L. <skylar@kat.digital>
	@Description: Utility to create InputStream-like behavior from a string of data
	@Date of Creation: 19. 04. 2020

	Copyright 2020 Kat Digital Limited. All Rights Reserved.

	The information contained herein is confidential and proprietary to Kat Digital Ltd., and considered a trade secret
	as defined under civil and criminal statutes. Kat Digital Ltd. shall pursue its civil and criminal remedies in the 
	event of unauthorized use or misappropriation of its trade secrets. Use of this information by anyone other than 
	authorized employees of Kat Digital Ltd. is granted only under a written non-disclosure agreement, expressly 
	prescribing the scope and manner of such use.
--]]


--InputStream class setup
local InputStream = {}
InputStream.__index = InputStream

--Module dependencies
local CRC32  = require(script.Parent.CRC32)
local Binary = require(script.Parent.Binary)

--Constructor
function InputStream.new(data, options)
	options = options or {}
	
	return setmetatable({
		Data     = data;
		Position = 1;
		Options  = options;
		CRC32    = 0;
		Name     = options.Name;
	}, InputStream)
end

--Method to read a given number of bytes
function InputStream:read(nBytes)
	--Return nil if we've reached the end of the InputStream
	if (self.Position > #self.Data) then return nil end
	
	--Return data and increment position
	local out = self.Data:sub(self.Position, self.Position+(nBytes-1))
	self.Position = self.Position + nBytes
	
	--Update CRC32 if needed
	if (self.Options.CalculateCRC32) then
		self.CRC32 = CRC32.crc32(out, self.CRC32)
	end
	
	return out
end

--Method to read a given number of bytes without stepping ahead
function InputStream:lookAhead(nBytes)
	--Return nil if we've reached the end of the InputStream
	if (self.Position > #self.Data) then return nil end
	
	--Return data and increment position
	local out = self.Data:sub(self.Position, self.Position+(nBytes-1))
	return out
end

--Method to skip a given number of bytes
function InputStream:skip(nBytes)
	self.Position = self.Position + nBytes
end

--Method to jump back a number of bytes
function InputStream:jumpBack(nBytes)
	self.Position = math.max(self.Position - nBytes, 1)
end

--Read numeric values
function InputStream:readByte()   return Binary.decodeInt   (self:read(1)) end
function InputStream:readShort()  return Binary.decodeInt   (self:read(2)) end
function InputStream:readInt()    return Binary.decodeInt   (self:read(4)) end
function InputStream:readFloat()  return Binary.decodeFloat (self:read(4)) end
function InputStream:readDouble() return Binary.decodeDouble(self:read(8)) end

--Method to check if we have data
function InputStream:hasData()
	return self.Position <= #self.Data
end

--Method to check how many bytes are available
function InputStream:available()
	return (#self.Data - self.Position) + 1
end

--Method to reset the CRC32
function InputStream:resetCRC32()
	self.CRC32 = 0
end

--Method to check the CRC32
function InputStream:checkCRC32()
	--Get data block name
	local name = self.Name or "Unknown Block"
	
	--Error if CRC32 calculations are not enabled on this stream
	if (not self.Options.CalculateCRC32) then error("Cannot check CRC32 in block '" .. name .. "': CRC32 not enabled") end
	
	--Error if we've reached the end of the InputStream
	if (self.Position > #self.Data) then error("Cannot check CRC32 in block '" .. name .. "': End of stream") end

	--Return data and increment position
	local out = self.Data:sub(self.Position, self.Position+3)
	self.Position = self.Position + 4
	
	--Check CRC32
	local crc = Binary.decodeInt(out)
	assert(crc == self.CRC32, "CRC32 mismatch in block '" .. name .. "': " .. crc .. " ~= " .. self.CRC32)
end

--Method to set a new name for the stream
function InputStream:setName(name)
	self.Name = name
end

--Output API
return InputStream