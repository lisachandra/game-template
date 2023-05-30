type LockedOrActiveUpdateFn = (update_id: number, update_data: table) -> ()
type NextQuery<T = table> = () -> Profile<T> 
type UnrealeasedHandler = "ForceLoad" | "Steal"
type Date = (DateTime | number)

type GetLockedOrActiveUpdates = () -> table
type ListenToNewLockedOrActiveUpdate = (listener: LockedOrActiveUpdateFn) -> RBXScriptConnection
type ClearOrLockUpdate = (update_id: number) -> ()

type GlobalUpdates = {
    GetActiveUpdates: GetLockedOrActiveUpdates,
    GetLockedUpdates: GetLockedOrActiveUpdates,
}

type ProfileGlobalUpdates = GlobalUpdates & {
    ListenToNewActiveUpdate: ListenToNewLockedOrActiveUpdate,
    ListenToNewLockedUpdate: ListenToNewLockedOrActiveUpdate,
    LockActiveUpdate: ClearOrLockUpdate,
    ClearLockedUpdate: ClearOrLockUpdate,
}

type UpdateHandlerGlobalUpdates = GlobalUpdates & {
    AddActiveUpdate: (update_data: table) -> (),
    ChangeActiveUpdate: LockedOrActiveUpdateFn,
    ClearActiveUpdate: ClearOrLockUpdate,
}

type ProfileVersionQuery<T = table> = {
    Next: NextQuery<T>,
    NextAsync: NextQuery<T>,
}

type ProfileMetaData = {
    ProfileCreateTime: number,
    SessionLoadCount: number,
    MetaTags: table,
    ActiveSession: table?,
    MetaTagsLatest: table,
}

type Profile<T = table> = {
    Data: T,
    UserIds: Array<number>,
    MetaData: ProfileMetaData,
    MetaTagsUpdated: RBXScriptSignal<table>,
    RobloxMetaData: table,
    KeyInfo: DataStoreKeyInfo,
    KeyInfoUpdated: RBXScriptSignal<DataStoreKeyInfo>,
    GlobalUpdates: ProfileGlobalUpdates,
    IsActive: () -> boolean,
    GetMetaTag: (tag_name: string) -> PrimitiveTypes?,
    Reconcile: () -> (),
    ListenToRelease: (listener: (place_id: number, job_id: number) -> ()) -> RBXScriptConnection,
    Release: () -> (),
    ListenToHopReady: (listener: () -> ()) -> RBXScriptConnection,
    AddUserId: (user_id: number) -> (),
    RemoveUserId: (user_id: number) -> (),
    Identify: () -> string,
    SetMetaTag: (tag_name: string, value: PrimitiveTypes) -> (),
    Save: () -> (),
    ClearGlobalUpdates: () -> (),
    OverwriteAsync: () -> (),
}

type ProfileStore<T = table> = {
    LoadProfileAsync: (
        profile_key: string,
        unrealeased_handler: (UnrealeasedHandler | (place_id: number, job_id: number) -> UnrealeasedHandler & ("Repeat" | "Cancel"))?
    ) -> Profile<T>,
    GlobalUpdateProfileAsync: (profile_key: string, update_handler: (global_updates: UpdateHandlerGlobalUpdates) -> ()) -> GlobalUpdates?,
    ViewProfileAsync: (profile_key: string, version: string?) -> Profile<T>?,
    ProfileVersionQuery: (profile_key: string, sort_direction: Enum.SortDirection?, min_date: Date?, max_date: Date?) -> ProfileVersionQuery<T>,
    WipeProfileAsync: (profile_key: string) -> boolean,
}

export type ProfileService = {
    ServiceLocked: boolean,
    IssueSignal: RBXScriptSignal<string, string, string>,
    CorruptionSignal: RBXScriptSignal<string, string>,
    CriticalStateSignal: RBXScriptSignal<boolean>,
    GetProfileStore: <T>(
        profile_store_key: string | { Name: string?, Scope: string? },
        profile_template: T
    ) -> ProfileStore<T> & { Mock: ProfileStore<T> },
}
