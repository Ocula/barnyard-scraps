local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Interface = require(Knit.Modules.Interface.get)

local Fusion = require(Knit.Library.Fusion)
--
local Peek = Fusion.peek
local Value, Observer, Computed, ForKeys, ForValues, ForPairs = Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.ForKeys, Fusion.ForValues, Fusion.ForPairs
local New, Children, OnEvent, OnChange, Out, Ref, Cleanup = Fusion.New, Fusion.Children, Fusion.OnEvent, Fusion.OnChange, Fusion.Out, Fusion.Ref, Fusion.Cleanup
local Tween, Spring = Fusion.Tween, Fusion.Spring
local Hydrate = Fusion.Hydrate

return function(props)
    --assert(props.Object, "No object was provided to ViewportFrame!") -- object MUST be provided when this frame is called. 
    local InterfaceController = Knit.GetController("Interface") 

    local Object = props.Object

    if not props.Rotate then 
        props.Rotate = Value(0) 
    end

    local CameraCF = Value(CFrame.new())

    local Camera = New "Camera" {
        Name = "Camera",
        CFrame = CameraCF,
    }

    local WorldModel = New "WorldModel" {
        Name = "WorldModel",

        [Children] = {
            Camera, 
            Object, 
        }
    }

    -- Render Test
    -- TODO: dynamically set what frames are visible to the player or not.

    local _conn

    if not props.Stagnant then 
        _conn = InterfaceController:GetViewportRenderSignal():Connect(function()
            if Peek(props.Visible) == true then 
                props.Rotate:set(Peek(props.Rotate) + 0.01)

                if props.Object then 
                    local objectCFrame, objectSize
                    local object = props.Object 

                    if object.Parent == nil then 
                        _conn:Disconnect()
                    end 

                    if object:IsA("Model") then 
                        if object.PrimaryPart then 
                            objectCFrame = object.PrimaryPart.CFrame
                            objectSize = object:GetExtentsSize()
                        else 
                            _conn:Disconnect()
                        end
                    else 
                        objectCFrame = object.CFrame 
                        objectSize = object.Size 
                    end

                    if objectSize then 
                        local cameraOffset = 5 
                        local fixedOffset = objectSize.Y / 4 

                        if object.Name == "Domino" then 
                            cameraOffset = 0 
                            fixedOffset = 0 
                        end 

                        local fixedPoint = objectCFrame * CFrame.new(0, fixedOffset, 0)
                        local yAngle = Peek(props.Rotate)

                        if props.Radians then 
                            yAngle = math.rad(yAngle) 
                        end 

                        local atCFrame = fixedPoint * CFrame.Angles(0, yAngle - (math.pi / 2),0) * CFrame.new(0,cameraOffset,objectSize.Magnitude)

                        CameraCF:set(CFrame.new(atCFrame.p, fixedPoint.p))
                    else 
                        _conn:Disconnect()
                    end 
                end 
            end
        end)
    end

    if props.Update then
        props.Maid:GiveTask(props.Update:Connect(function(newObject)
            if object then 
                object:Destroy()
            end 

            local newObj = newObject.Object 

            props.Object = newObj 
            object = newObj

            object.Parent = Peek(worldModel) 
            object:SetPrimaryPartCFrame(CFrame.new(0,0,0))

            -- clean object
            for i, v in object:GetChildren() do 
                if v.Name == "CollisionPart" then 
                    v:Destroy() 
                end 
            end 
        end))
    end 

    return New "ViewportFrame" {
        Name = "ViewportFrame",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = props.Size or UDim2.fromScale(1, 1),
        Visible = props.Visible, 
        ZIndex = props.ZIndex or 1,

        CurrentCamera = Camera, 

        Ambient = Color3.new(1,1,1),
        LightDirection = Vector3.new(0,-1,0), 

        [OnEvent "Destroying"] = function()
            if _conn then 
                _conn:Disconnect()
            end 
        end,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.125, 0),
            },

            WorldModel
        }
    }
end 