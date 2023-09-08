--Module to handle throttling save/load operations and distribute CPU time evenly across existing tasks
--Written by Anna W.

local CPU_TIME_LIMIT = 0.004 --CPU time limit per frame, in seconds

--Service dependencies
local RunService = game:GetService("RunService")

--Persistent data
local TaskScheduler = {}
local Tasks = {}

--Function to actually perform the throttling
local tStop = nil
function TaskScheduler.throttle()
	--tStop will be nil at the beginning of each frame, so we need to set it here
	if (tStop == nil) then tStop = os.clock() + CPU_TIME_LIMIT end
	
	--Check if the CPU time limit has been exhausted
	if (os.clock() >= tStop) then
		tStop = nil
		
		--We cause the coroutine to exit at this point
		coroutine.yield()
	end
end

--Helper function to get argument information
--Returns the arguments as a table, as well as the total number of arguments
function argInfo(...)
	return { ... }, select("#", ...)
end

--Function to handle the creation of a new task
function TaskScheduler.newTask(func, ...)
	--Create a new coroutine from the function
	local co = coroutine.create(func)
	
	--Get argument data
	local args, nArgs = argInfo(...)
	
	--Create a new BindableEvent that we can fire when the task completes
	local completed = Instance.new("BindableEvent")
	local stepped   = Instance.new("BindableEvent")
	
	--Create a new object for the task
	local task = {
		First         = true;
		Coroutine     = co;
		Args          = args;
		NArgs         = nArgs;
		CompleteEvent = completed;
		SteppedEvent  = stepped;
		
		--These are intended for other modules to interface with the tasks
		Completed     = completed.Event;
		Stepped       = stepped.Event;
	}
	
	--Add the task to the list of currently active tasks
	--We add the task as a key because removing it from the table is more performant this
	--way, because we avoid having to down-shift subsequent elements in an array.
	Tasks[task] = true
	
	--Return the task object
	return task
end

--We now start a coroutine to give all existing tasks some time to complete
local loop = coroutine.wrap(function()
	while true do
		local waited = false
		for task, _ in pairs(Tasks) do
			--Run the coroutine. If this is its first run, pass all function arguments to it as well
			--Otherwise, the coroutine already has all the information it needs and can continue 
			--without extra data
			local ok, err
			if (task.First) then
				ok, err = coroutine.resume(task.Coroutine, unpack(task.Args, 1, task.NArgs))
				task.First = false
			else
				ok, err = coroutine.resume(task.Coroutine)
			end
			
			--Always fire the Stepped event
			task.SteppedEvent:Fire()
			
			--Check if the status is "dead", i.e. if the coroutine has ended with no further tasks to
			--be completed. If so, fire the "completed" event
			if (coroutine.status(task.Coroutine) == "dead") then
				--Pass OK and ERROR variables as well, so the interfacing code can error handle if needed
				task.CompleteEvent:Fire(ok, err)
				Tasks[task] = nil
			end
			
			--Wait one heartbeat
			RunService.Heartbeat:wait()
			waited = true
		end
		
		--If we didn't wait in the for loop, wait here instead
		--We check this condition so we always wait a single heartbeat between task steps,
		--for the sake of consistency
		if (not waited) then
			RunService.Heartbeat:wait()
		end
	end
end)
loop()

--Return module contents
return TaskScheduler
