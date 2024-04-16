local History = require(script.History)

export type History = History.History
export type HistoryEntry = History.HistoryEntry

local ReactRouter = table.freeze({
    Router = require(script.Router),
    History = History,
    
    useRouter = require(script.useRouter),

    RouterContext = require(script.RouterContext),
})

return ReactRouter
