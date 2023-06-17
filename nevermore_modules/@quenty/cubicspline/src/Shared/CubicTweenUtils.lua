--[=[
	Utility functions to do a cubic spline. Don't use this directly.
	@class CubicTweenUtils
]=]

local CubicTweenUtils = {}

--[=[
	Constants to be multiplied as p0*a0 + v0*a1 + p1*a2 + v1*a3
	@param l number
	@param t number
	@return number -- a0
	@return number -- a1
	@return number -- a2
	@return number -- a3
]=]
function CubicTweenUtils.getConstants(l, t)
	local r = l - t
	local a0 = r*r*(r + 3*t)/(l*l*l)
	local a1 = r*r*t/(l*l)
	local a2 = t*t*(t + 3*r)/(l*l*l)
	local a3 = -t*t*r/(l*l)

	return a0, a1, a2, a3
end

--[=[
	@param l number
	@param t number
	@return number -- a0
	@return number -- a1
	@return number -- a2
	@return number -- a3
]=]
function CubicTweenUtils.getDerivativeConstants(l, t)
	local r = l - t
	local b0 = -6*r*t/(l*l*l)
	local b1 = r*(r - 2*t)/(l*l)
	local b2 = 6*r*t/(l*l*l)
	local b3 = t*(t - 2*r)/(l*l)

	return b0, b1, b2, b3
end

--[=[
	Applies the constants for the given nodes
	@param c0 number
	@param c1 number
	@param c2 number
	@param c3 number
	@param a T
	@param u T
	@param b T
	@param v T
	@return T
]=]
function CubicTweenUtils.applyConstants(c0, c1, c2, c3, a, u, b, v)
	return c0*a + c1*u + c2*b + c3*v
end

--[=[
	Tweens betweeen nodes
	@param a T
	@param u T
	@param b T
	@param v T
	@param l number
	@param t number
	@return T
]=]
function CubicTweenUtils.tween(a, u, b, v, l, t)
	local a0, a1, a2, a3 = CubicTweenUtils.getConstants(l, t)

	return a0*a + a1*u + a2*b + a3*v
end

--[=[
	Computes acceleration
	@param a T
	@param u T
	@param b T
	@param v T
	@param l number
	@return T
]=]
function CubicTweenUtils.getAcceleration(a, u, b, v, l)
	return (12*(b - a)*(b - a) - 12*l*(b - a)*(u + v) + 4*l*l*(u*u + u*v + v*v))/(l*l*l)
end

return CubicTweenUtils