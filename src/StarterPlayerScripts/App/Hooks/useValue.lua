local React = require(game:GetService("ReplicatedStorage").Packages.React)

type value<T> = {
    current: T,
}

local function useValue<T>(initialValue: T ): value<T>
    return React.useRef(initialValue) :: value<T>
end

return useValue
