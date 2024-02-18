local TweenService = game:GetService("TweenService")
local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local LuauPolyfill = require(Packages.LuauPolyfill)
local Promise = require(Packages.Promise)
local Rodux = require(Shared.Rodux)
local Matter = require(Shared.Matter)

local world: Matter.World?

export type Promise<T> = LuauPolyfill.Promise<T> & { cancel: (self: Promise<T>) -> () }
export type Character = Model & { Head: BasePart, Torso: BasePart, PrimaryPart: BasePart, HumanoidRootPart: BasePart }
export type humanoid = Humanoid & { RootPart: BasePart, Animator: Animator, Parent: Character }

local Utils = {}
local MathUtils = {}
Utils.Math = MathUtils

function Utils.GetWorld(entityId: number?): Matter.World
    if not world then
        local state: Rodux.ServerState = Rodux.store:getState()
        world = state.world
    end

    local world: Matter.World = world :: any

    if entityId then
        return (world:contains(entityId) and world) :: Matter.World
    end

    return world
end

function Utils.WaitForHumanoid(Character: Model): Promise<humanoid>
    return Promise.new(function(resolve)
        resolve(Character:WaitForChild("Humanoid"))
    end)
end

function Utils.GetHumanoid(Player: Instance): humanoid?
	local Character = Player:IsA("Player") and Player.Character or Player
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid"); if Humanoid then
		if Humanoid:GetState() == Enum.HumanoidStateType.Dead or not Humanoid.RootPart then
			return
		end
	end

	return Humanoid :: any
end

function Utils.LoadAnimation(Humanoid: humanoid, Animation: Animation): Promise<AnimationTrack>
    return Promise.new(function(resolve)
        resolve(Humanoid.Animator:LoadAnimation(Animation))
    end)
end

function Utils.LerpWithTransform(alpha_increment: number, event: RBXScriptSignal, transform: (number) -> ()): () -> ()
    local alpha = 0
    local connection = event:Connect(function()
        transform(alpha)
        alpha += alpha_increment
    end)

    return function()
        connection:Disconnect()
    end
end

function Utils.Tween(event: RBXScriptSignal, info: TweenInfo, f: (number) -> ())
    local start = os.clock()
    local resolve

    local connection; connection = event:Connect(function()
        local elapsed = os.clock() - start; if elapsed <= info.Time then
            f(TweenService:GetValue(elapsed / info.Time, info.EasingStyle, info.EasingDirection))
        else
            resolve()
            connection:Disconnect()
        end
    end)

    return Promise.new(function(resolveFunc, _reject, onCancel)
        onCancel(function()
            connection:Disconnect()
        end)

        resolve = resolveFunc
    end) :: Promise<nil>
end

function MathUtils.lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function MathUtils.round(n: number, decimals: number): number
    local power = 10 ^ decimals
    return math.floor(n * power) / power
end

function MathUtils.map(value: number, fromMin: number, fromMax: number, toMin: number, toMax: number): number
    return ((value - fromMin) * (toMax - toMin)) / (fromMax - fromMin) + toMin
end

function MathUtils.weightRandom(selections: Array<number>): number
	local chances = 0

	for _index, chance in selections do
		chances += chance
	end

	local number = Random.new():NextNumber(0, chances)

	for index, chance in selections do
		chances -= chance

		if number > chances then
			return index
		end
	end

	return #selections
end

return Utils
