local ReplicatedStorage = script.Parent.Parent

local Packages = ReplicatedStorage.Packages

local BridgeNet2 = require(Packages.BridgeNet2)

local REMOTES = {
    "MatterReplication",

    "Time",
}

export type ClientBridge = typeof(BridgeNet2.ClientBridge(""))
export type ServerBridge = typeof(BridgeNet2.ServerBridge(""))

export type Bridges<T> = {
    MatterReplication: T,
    
    Time: T,
}

local Bridges: Dictionary<any> = {}

for _index, key in REMOTES do
    Bridges[key] = BridgeNet2.ReferenceBridge(key)
end

return Bridges
