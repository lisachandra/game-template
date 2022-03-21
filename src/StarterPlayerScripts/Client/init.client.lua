local Players = game:GetService("Players")

local Player = Players.LocalPlayer

if not Player.Character then
	Player.CharacterAdded:Wait()
end

for _i, module in pairs(script.Systems:GetChildren()) do
	task.defer(require, module)
end
