export type Actions<U> = Dictionary<(context: U, event: table) -> U?>

export type States<T = string, U = table> = {
    states: Map<T, States<T, U>>,
    on: Dictionary<{
        actions: { string },
        target: T,
    }>,
}

export type Machine<T = string, U = table> = {
    id: string,
    initial: T,
    context: U,

    states: Map<T, States<T, U>>,
}

export type Storage<T = string, U = table> = {
    initiated: boolean,
    actions: Actions<U>,
}

local Machine = {}

return Machine
