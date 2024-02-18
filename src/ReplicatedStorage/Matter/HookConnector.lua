export type Request<T> = {
    hook: string,
    params: Array<unknown>,
    callback: (T) -> (),
}

local HookConnector = {}
HookConnector.requests = {} :: Dictionary<Request<any>>

return HookConnector
