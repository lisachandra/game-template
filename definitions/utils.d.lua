export type table = { [any]: any }

export type PrimitiveTypes = number | string | boolean | table
export type Dictionary<T> = { [string]: T}
export type Array<T> = { T }
