type LockedOrActiveUpdateFn = (self: any, update_id: number, update_data: table) -> ()
type NextQuery<T = table> = (self: any) -> Profile<T> 
type UnrealeasedHandler = "ForceLoad" | "Steal"
type Date = (DateTime | number)

type GetLockedOrActiveUpdates = (self: any) -> table
type ListenToNewLockedOrActiveUpdate = (self: any, listener: LockedOrActiveUpdateFn) -> RBXScriptConnection
type ClearOrLockUpdate = (self: any, update_id: number) -> ()

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
    AddActiveUpdate: (self: any, update_data: table) -> (),
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
    IsActive: (self: any) -> boolean,
    GetMetaTag: (self: any, tag_name: string) -> PrimitiveTypes?,
    Reconcile: (self: any) -> (),
    ListenToRelease: (self: any, listener: (place_id: number, job_id: number) -> ()) -> RBXScriptConnection,
    Release: (self: any) -> (),
    ListenToHopReady: (self: any, listener: () -> ()) -> RBXScriptConnection,
    AddUserId: (self: any, user_id: number) -> (),
    RemoveUserId: (self: any, user_id: number) -> (),
    Identify: (self: any) -> string,
    SetMetaTag: (self: any, tag_name: string, value: PrimitiveTypes) -> (),
    Save: (self: any) -> (),
    ClearGlobalUpdates: (self: any) -> (),
    OverwriteAsync: (self: any) -> (),
}

type ProfileStore<T = table> = {
    LoadProfileAsync: (
        self: any,
        profile_key: string,
        unrealeased_handler: (UnrealeasedHandler | (place_id: number, job_id: number) -> UnrealeasedHandler & ("Repeat" | "Cancel"))?
    ) -> Profile<T>,
    GlobalUpdateProfileAsync: (
        self: any,        
        profile_key: string,
        update_handler: (self: any, global_updates: UpdateHandlerGlobalUpdates) -> ()
    ) -> GlobalUpdates?,
    ViewProfileAsync: (self: any, profile_key: string, version: string?) -> Profile<T>?,
    ProfileVersionQuery: (
        self: any,
        profile_key: string,
        sort_direction: Enum.SortDirection?,
        min_date: Date?, max_date: Date?
    ) -> ProfileVersionQuery<T>,
    WipeProfileAsync: (self: any, profile_key: string) -> boolean,
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
