for _index, module in pairs(script.Systems:GetChildren()) do
	task.defer(require, module)
end
