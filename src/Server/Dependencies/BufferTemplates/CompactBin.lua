--Written by Anna W.
--Module to handle compactly storing CFrame data

local CompactBin = {}

function CompactBin.toQuaternion(cframe)
	--Get CFrame components
	local x, y, z,
	m00, m01, m02,
	m10, m11, m12,
	m20, m21, m22 = cframe:components()
	
	--The following code isn't mine, but was taken from:
	--http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
	local tr = m00 + m11 + m22
	
	if (tr > 0) then
		local S = math.sqrt(tr+1.0) * 2; --S=4*qw 
		
		return {
			qw = 0.25 * S;
			qx = (m21 - m12) / S;
			qy = (m02 - m20) / S; 
			qz = (m10 - m01) / S; 
		}
	elseif ((m00 > m11) and (m00 > m22)) then 
		local S = math.sqrt(1.0 + m00 - m11 - m22) * 2; --S=4*qx 
		
		return {
			qw = (m21 - m12) / S;
			qx = 0.25 * S;
			qy = (m01 + m10) / S; 
			qz = (m02 + m20) / S; 
		}
	elseif (m11 > m22) then
		local S = math.sqrt(1.0 + m11 - m00 - m22) * 2; --S=4*qy
		
		return {
			qw = (m02 - m20) / S;
			qx = (m01 + m10) / S; 
			qy = 0.25 * S;
			qz = (m12 + m21) / S; 
		}
	else 
		local S = math.sqrt(1.0 + m22 - m00 - m11) * 2; --S=4*qz
		
		return {
			qw = (m10 - m01) / S;
			qx = (m02 + m20) / S;
			qy = (m12 + m21) / S;
			qz = 0.25 * S;
		}
	end
end

--Function to convert from quaternion to rotation matrix
function CompactBin.fromQuaternion(quaternion)
	--Get quaternion components
	local qw = quaternion.qw
	local qx = quaternion.qx
	local qy = quaternion.qy
	local qz = quaternion.qz
	
	--The following code isn't mine, but was taken from:
	--http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
	
	local m00 = 1 - 2*qy^2 - 2*qz^2;
	local m01 = 2*qx*qy - 2*qz*qw;
	local m02 = 2*qx*qz + 2*qy*qw;
	local m10 = 2*qx*qy + 2*qz*qw;
	local m11 = 1 - 2*qx^2 - 2*qz^2;
	local m12 = 2*qy*qz - 2*qx*qw;
	local m20 = 2*qx*qz - 2*qy*qw;
	local m21 = 2*qy*qz + 2*qx*qw;
	local m22 = 1 - 2*qx^2 - 2*qy^2;
	
	return CFrame.new(
		0, 0, 0,
		m00, m01, m02,
		m10, m11, m12,
		m20, m21, m22
	)
end

function CompactBin.compressQuaternion(quaternion)
	--Map the range[-1, 1] of all values to [0, 255]
	local w = math.floor(65535 * (quaternion.qw+1)/2 + 0.5)
	local x = math.floor(65535 * (quaternion.qx+1)/2 + 0.5)
	local y = math.floor(65535 * (quaternion.qy+1)/2 + 0.5)
	local z = math.floor(65535 * (quaternion.qz+1)/2 + 0.5)
	
	return string.char(
		math.floor(w/256),
		math.floor(w%256),
		math.floor(x/256),
		math.floor(x%256),
		math.floor(y/256),
		math.floor(y%256),
		math.floor(z/256),
		math.floor(z%256)
	)
end

function CompactBin.decompressQuaternion(bytes)
	--Retrieve original data
	local w0, w1, x0, x1, y0, y1, z0, z1 = string.byte(bytes, 1, 8)
	
	local w = w0*256 + w1
	local x = x0*256 + x1
	local y = y0*256 + y1
	local z = z0*256 + z1
	
	--Calculate as close as possible to the original values
	w = (w*2/65535) - 1
	x = (x*2/65535) - 1
	y = (y*2/65535) - 1
	z = (z*2/65535) - 1
	
	--Calculate magnitude of the 4D vector
	local length = math.sqrt(w^2 + x^2 + y^2 + z^2)
	
	--Generate new normalized quaternion
	return {
		qw = w/length;
		qx = x/length;
		qy = y/length;
		qz = z/length;
	}
end

function CompactBin.compressVector3(vec)
	--Map the range [-125, 125] to [0, 65535]
	local x = math.clamp(math.floor(65535 * (vec.x+125)/250 + 0.5), 0, 65535)
	local y = math.clamp(math.floor(65535 * (vec.y+125)/250 + 0.5), 0, 65535)
	local z = math.clamp(math.floor(65535 * (vec.z+125)/250 + 0.5), 0, 65535)
	
	return string.char(
		math.floor(x/256),
		math.floor(x%256),
		math.floor(y/256),
		math.floor(y%256),
		math.floor(z/256),
		math.floor(z%256)
	)
end

function CompactBin.decompressVector3(bytes)
	--Retrieve original data
	local x0, x1, y0, y1, z0, z1 = string.byte(bytes, 1, 6)
	
	local x = x0*256 + x1
	local y = y0*256 + y1
	local z = z0*256 + z1
	
	--Calculate as close as possible to the original value
	x = (x*250/65535) - 125
	y = (y*250/65535) - 125
	z = (z*250/65535) - 125
	
	return Vector3.new(x, y, z)
end

return CompactBin
