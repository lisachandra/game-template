type None = typeof(newproxy(false))
type Plasma = any

type Component<T> = (self: any, ...any) -> ((data: T?) -> T)

type ComponentInstance<T> = {
    patch: (self: any, newData: T) -> T,
}

type QueryResult<T...> = typeof(setmetatable({} :: {
    without: (self: any, ...any) -> QueryResult<T...>,
    snapshot: (self: any) -> QueryResult<T...>,
    next: (self: any) -> (number, T...),
}, {} :: {
    __iter: (self: any) -> (() -> (number, T...)),
}))

type ChangeRecord<T> = {
    old: T?,
    new: T?,
}

type WorldGetOrRemove =
	(<T>(self: any, id: number, Component<T>) -> T)
	& (<T, U>(
		self: any,
		id: number,
		Component<T>,
		Component<U>
	) -> (T, ComponentInstance<U>))
	& (<T, U, V>(
		self: any,
		id: number,
		Component<T>,
		Component<U>,
		Component<V>,
		...any
	) -> (T, ComponentInstance<U>, ComponentInstance<V>))

type WorldQuery =
	(<T>(self: any, Component<T>) -> QueryResult<T>)
	& (<T, U>(
		self: any,
		Component<T>,
		Component<U>
	) -> QueryResult<T, ComponentInstance<U>>)
	& (<T, U, V>(
		self: any,
		Component<T>,
		Component<U>,
		Component<V>
	) -> QueryResult<T, ComponentInstance<U>, ComponentInstance<V>>)
	& (<T, U, V, W>(
		self: any,
		Component<T>,
		Component<U>,
		Component<V>,
		Component<W>,
		...any
	) -> QueryResult<
		T,
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

type Events = { [string]: RBXScriptSignal }

type World = typeof(setmetatable({} :: {
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
}, {} :: {
    __iter: (self: any) -> ((() -> (number, { [any]: any })), World),
}))

type Loop = {
    scheduleSystems: (self: any, systems: { System }) -> (),
    scheduleSystem: (self: any, system: System) -> (),
    evictSystem: (self: any, system: System) -> (),
    replaceSystem: (self: any, old: System, new: System) -> (),
    begin: (self: any, events: Events) -> Events,
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

    useEvent: (instance: Instance, event: string | RBXScriptSignal) -> (() -> (number, ...any)),
    useDeltaTime: () -> number,
    useThrottle: (seconds: number, discriminator: string?) -> boolean,
    log: (...any) -> (),
    useHookState: <T>(discriminator: string?, cleanup: ((storage: T) -> boolean?)?) -> T,

    None: None,

    Debugger: { new: (plasma: Plasma) -> Debugger },
}
