local puzzle = {}
puzzle.__index = puzzle

function puzzle.new()
	return {}
end

function puzzle:Initialize() end

return puzzle
