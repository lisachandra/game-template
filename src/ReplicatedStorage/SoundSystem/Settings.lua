local Settings = {
	Occlusion = {
		MaterialReflect = {
			Grass = 0.15,
			Sand = 0.175,
			Metal = 0.3,
			Plastic = 0.4,
			SmoothPlastic = 0.25,
			WoodPlanks = 0.25,
			Granite = 0.4,
			Brick = 0.15,
			Marble = 0.4,
			Cobblestone = 0.175,
			Concrete = 0.15,
			Wood = 0.25,
			Fabric = 0.05,
			Ice = 0.35,
		},

		Rays = 8,
		Fallback = 0.1,
		FilterDescendants = {},
		RayLength = 20,
		IgnoreWater = true,
		MaxBounce = 3,
	},

	DelaySound = {
		Speed = 343,
	},
}

return Settings
