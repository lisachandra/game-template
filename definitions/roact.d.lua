type Type = "Binding" | "Element" | "HostChangeEvent" | "HostEvent" | "VirtualNode" | "VirtualTree"
type Children = typeof(newproxy(false))
type None = typeof(newproxy(false))
type Ref = typeof(newproxy(false))
type Event = typeof(newproxy(false))
type Change = typeof(newproxy(false))

export type RoactTree = typeof(newproxy(false))
export type RoactElement = typeof(newproxy(false))
export type RoactFragment = typeof(newproxy(false))

export type RoactElementFn<P> = (props: P) -> RoactElement

export type RoactBinding<T> = {
    getValue: (self: any) -> T,
    map: (self: any, mappingFunction: (value: T) -> any) -> RoactBinding<T>,
}

export type RoactRef<T> = {
    getValue: (self: any) -> T,
}

export type RoactContext<T> = {
    Provider: RoactElementFn<{ value: T }>,
    Consumer: RoactElementFn<{ render: (value: T) -> RoactElement }>,
}

export type RoactComponent = {
    defaultProps: table,
    
    validateProps: (self: any, props: table) -> (false, string) | true,
    init: (self: any, initialProps: table) -> (),
    getDerivedStateFromProps: (nextProps: table, lastState: table) -> table,
    shouldUpdate: (self: any, nextProps: table, nextState: table) -> boolean,
    willUpdate: (self: any, nextProps: table, nextState: table) -> (),
    render: (self: any) -> RoactElement,
    didUpdate: (self: any, previousProps: table, previousState: table) -> (),
    didMount: (self: any) -> (),
    willUnmount: (self: any) -> (),
    
    setState: (self: any, state: table | (prevState: table, props: table) -> table) -> (),
    getElementTraceback: (self: any) -> string?,
}

export type Roact = {
    createElement: <P>(
        component: RoactElementFn<P> | string,
        props: P?,
        children: { [string | number]: RoactElement }?
    ) -> RoactElement,
    createFragment: (elements: { [string | number]: RoactElement }) -> RoactFragment,
    createContext: <T>(defaultValue: T) -> RoactContext<T>,
    mount: (element: RoactElement, parent: Instance?, key: string?) -> RoactTree,
    unmount: (tree: RoactTree) -> (),
    createBinding: <T>(initialValue: T) -> (RoactBinding<T>, (newValue: T) -> ()),
    joinBindings: <T>(bindings: T) -> RoactBinding<T>,
    createRef: <T>() -> RoactRef<T>,
    forwardRef: <P, T>(render: (props: P, ref: RoactRef<T>) -> RoactElement) -> RoactElement,
    setGlobalConfig: (configValues: {
        typeChecks: boolean?,
        internalTypeChecks: boolean?,
        elementTracing: boolean?,
        propValidation: boolean?,
    }) -> (),

    Component: { extend: (componentName: string) -> RoactComponent },
    PureComponent: { extend: (componentName: string) -> RoactComponent },
    Portal: RoactElementFn<{ target: Instance }>,

    Children: Children,
    Ref: Ref,
    Event: { [string]: Event },
    Change: { [string]: Change },
    None: None,
    Type: {
        of: (value: any) -> Type,
    },
}
