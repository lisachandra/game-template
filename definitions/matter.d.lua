type None = typeof(newproxy(false))
type Plasma = any

type Component<T> = (data: table?) -> ComponentInstance<T>
type ComponentInstance<T> = typeof(setmetatable({} :: {
    patch: (self: any, newData: table) -> T,
}, {} :: {
    __index: T,
}))

type QueryResult<T...> = () -> (number, T...)

--[[
type QueryResult<T...> = typeof(setmetatable({}, {} :: {
    __iter: (self: any) -> (() -> (number, T...)),
    __index: {
        without: (self: any, ...any) -> (() -> (number, T...)),
        snapshot: (self: any) -> (() -> (number, T...)),
        next: (self: any) -> (number, T...),
    },
}))
]]

type ChangeRecord<T> = {
    old: ComponentInstance<T>?,
    new: ComponentInstance<T>?,
}

type WorldGetOrRemove =
	(<T>(self: any, id: number, Component<T>) -> ComponentInstance<T>)
	& (<T, U>(
		self: any,
		id: number,
		Component<T>,
		Component<U>
	) -> (ComponentInstance<T>, ComponentInstance<U>))
	& (<T, U, V>(
		self: any,
		id: number,
		Component<T>,
		Component<U>,
		Component<V>,
		...any
	) -> (ComponentInstance<T>, ComponentInstance<U>, ComponentInstance<V>))

type WorldQuery =
	(<T>(self: any, Component<T>) -> QueryResult<ComponentInstance<T>>)
	& (<T, U>(
		self: any,
		Component<T>,
		Component<U>
	) -> QueryResult<ComponentInstance<T>, ComponentInstance<U>>)
	& (<T, U, V>(
		self: any,
		Component<T>,
		Component<U>,
		Component<V>
	) -> QueryResult<ComponentInstance<T>, ComponentInstance<U>, ComponentInstance<V>>)
	& (<T, U, V, W>(
		self: any,
		Component<T>,
		Component<U>,
		Component<V>,
		Component<W>,
		...any
	) -> QueryResult<
		ComponentInstance<T>,
		ComponentInstance<U>,
		ComponentInstance<V>,
		ComponentInstance<W>
	>)

type SystemTable = {
    system: (...any) -> (),
    event: string?,
    priority: number?,
    after: { System }?
}

type System = SystemTable | (...any) -> ()

type World = typeof(setmetatable({}, {} :: {
    __iter: (self: any) -> (() -> (number, { [Component<any>]: ComponentInstance<any> })),
    __index: {
        spawn: (self: any, ...any) -> number,
        spawnAt: (self: any, id: number, ...any) -> number,
        replace: (self: any, id: number, ...any) -> (),
        despawn: (self: any, id: number) -> (),
        clear: (self: any) -> (),
        contains: (self: any, id: number) -> boolean,
        insert: (self: any, id: number, ...any) -> (),
        size: (self: any) -> number,
        queryChanged: <T>(self: any, componentToTrack: Component<T>) -> (() -> (number, ChangeRecord<T>)),
    
        get: WorldGetOrRemove,
        query: WorldQuery,
        remove: WorldGetOrRemove,
    },
}))

type Loop = {
    scheduleSystems: (self: any, systems: { System }) -> (),
    scheduleSystem: (self: any, system: System) -> (),
    evictSystem: (self: any, system: System) -> (),
    replaceSystem: (self: any, old: System, new: System) -> (),
    begin: (self: any, events: Dictionary<RBXScriptSignal>) -> Dictionary<RBXScriptSignal>,
    addMiddleware: (self: any, middleware: (nextFn: () -> (), event: string) -> (() -> ())) -> (),
}

type Debugger = {
    authorize: (player: Player) -> boolean?,
    findInstanceFromEntity: (entityId: number) -> Instance?,

    show: (self: any) -> (),
    hide: (self: any) -> (),
    toggle: (self: any) -> (),
    autoInitialize: (self: any, loop: Loop) -> (),
    replaceSystem: (self: any, old: System, new: System) -> (),
    switchToClientView: (self: any) -> (),
    switchToServerView: (self: any) -> (),
    update: (self: any) -> (),
    getWidgets: (self: any) -> Plasma,

    enabled: boolean,
}

export type Matter = {
    World: { new: () -> World },
    Loop: { new: (...any) -> Loop },

    component: <T>(name: string?, data: T?) -> Component<T>,

    useEvent: (instance: any, event: any) -> (() -> (number, ...any)),
    useDeltaTime: () -> number,
    useThrottle: (seconds: number, discriminator: any?) -> boolean,
    log: (...any) -> (),
    useHookState: <T>(discriminator: any?, cleanup: ((storage: T) -> boolean?)?) -> T,

    None: None,

    Debugger: { new: (plasma: Plasma) -> Debugger },
}
