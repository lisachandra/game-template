type Hooks = any

type connection = {
    disconnect: (self: any) -> (),
}

type signal<T... = ...any> = {
    wait: (self: any) -> T...,
    connect: (self: any, callback: (T...) -> ()) -> connection,
    fire: (self: any, T...) -> (),
}

type PathMatchResults = Dictionary<string>

type PathMatchOptions = {
    exact: boolean?,
}

type Path = {
    match: (self: any, path: string, options: PathMatchOptions?) -> PathMatchResults?,
}

type HistoryEntry = {
	path: string,
	state: any?,
}

type History = {
    onChanged: signal<string, any?>,
    location: HistoryEntry,

    push: (self: any, path: string, state: any?) -> (),
    replace: (self: any, path: string, state: any?) -> (),

    go: (self: any, offset: number) -> (),
	
	goBack: (self: any) -> (),
	goForward: (self: any) -> (),
	goToStart: (self: any) -> (),
	goToEnd: (self: any) -> (),
}

type RouterRendererProps = {
    location: HistoryEntry,
    history: History,
}

type RouteRendererProps = {
	match: PathMatchResults,
	location: HistoryEntry,
	history: History,
}

type Link = RoactElementFn<{
    path: string,
    state: any?,
}>

type Redirect = RoactElementFn<{ path: string }>

type Route = RoactElementFn<any & {
    path: string,
	exact: boolean?,
	alwaysRender: boolean?,

    component: RoactElementFn<any & RouteRendererProps>?,
	render: RoactElementFn<any & RouteRendererProps>?,
}>

type Router = RoactElementFn<{
	history: History?,

	initialEntries: Array<string>?,
	initialIndex: number?,
}>

export type RoactRouter = {
    Router: Router,
    Route: Route,
    Redirect: Redirect,
    Link: Link,

    RouterContext: RoactContext<RouterRendererProps>,
    RouteContext: RoactContext<RouteRendererProps>,

    withRouter: (callback: (value: RouterRendererProps) -> RoactElement) -> RoactElement,
    withRoute: (callback: (value: RouteRendererProps) -> RoactElement) -> RoactElement,

    useHistory: (hooks: Hooks) -> History,
    useLocation: (hooks: Hooks) -> HistoryEntry,
    useParams: (hooks: Hooks) -> PathMatchResults,
    useRouteMatch: (hooks: Hooks, options: PathMatchOptions & { path: string }) -> PathMatchResults,

    History: { new: (intialEntries: Array<string>?, intialIndex: number?) -> History },
    Path: { new: (pattern: string?) -> Path },
}
