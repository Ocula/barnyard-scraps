--[[
	@Author: Anna W. <anna@kat.digital> Skylar L. <skylar@kat.digital>
	@Description: Utility to create OutputStream-like behavior from a string of data
	@Date of Creation: 19. 04. 2020

	Copyright 2020 Kat Digital Limited. All Rights Reserved.

	The information contained herein is confidential and proprietary to Kat Digital Ltd., and considered a trade secret
	as defined under civil and criminal statutes. Kat Digital Ltd. shall pursue its civil and criminal remedies in the 
	event of unauthorized use or misappropriation of its trade secrets. Use of this information by anyone other than 
	authorized employees of Kat Digital Ltd. is granted only under a written non-disclosure agreement, expressly 
	prescribing the scope and manner of such use.
--]]


--OutputStream class setup
local OutputStream = {}
OutputStream.__index = OutputStream

--Module dependencies
local CRC32  = require(script.Parent.CRC32)
local Binary = require(script.Parent.Binary)

--Constructor
function OutputStream.new(options)
	return setmetatable({
		Data    = {};
		Length  = 0;
		CRC32   = 0;
		Options = options or {};
	}, OutputStream)
end

--Method to write some binary string
function OutputStream:write(data)
	table.insert(self.Data, tostring(data))
	self.Length += #data
	
	if (self.Options.AppendCRC32) then
		self.CRC32 = CRC32.crc32(data, self.CRC32)
	end
end

--Methods to write discrete data types
function OutputStream:writeByte(n)   self:write(Binary.encodeInt(n, 1)) end
function OutputStream:writeShort(n)  self:write(Binary.encodeInt(n, 2)) end
function OutputStream:writeInt(n)    self:write(Binary.encodeInt(n, 4)) end
function OutputStream:writeFloat(n)  self:write(Binary.encodeFloat(n))  end
function OutputStream:writeDouble(n) self:write(Binary.encodeDouble(n)) end

--Method to get the raw data
function OutputStream:toString()
	if (self.Options.AppendCRC32) then
		table.insert(self.Data, Binary.encodeInt(self.CRC32, 4))
	end
	
	return table.concat(self.Data)
end

--Output API
return OutputStream