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
    getValue: (self: RoactBinding<T>) -> T,
    map: (self: RoactBinding<T>, mappingFunction: (value: T) -> any) -> RoactBinding<T>,
}

export type RoactRef<T> = {
    getValue: (self: RoactRef<T>) -> T,
}

export type Roact = {
    createElement: <P>(
        component: RoactElementFn<P> | string,
        props: P?,
        children: { [string | number]: RoactElement }?
    ) -> RoactElement,
    createFragment: (elements: { [string | number]: RoactElement }) -> RoactFragment,
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
        propValidation: boolean?
    }) -> (),

    Children: Children,
    Ref: Ref,
    Event: { [string]: Event },
    Change: { [string]: Change },
    None: None,
    Type: {
        of: (value: any) -> Type,
    },

    Portal: RoactElementFn<{ target: Instance }>,
}
