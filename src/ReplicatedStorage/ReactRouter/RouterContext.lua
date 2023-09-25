local ReplicatedStorage = script.Parent.Parent.Parent

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)

local History = require(script.Parent.History)

type context = {
    location: History.HistoryEntry,
    history: History.History
}

return React.createContext({} :: context)
