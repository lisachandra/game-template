export type table = { [any]: any }

export type PrimitiveTypes = number | string | boolean | table
export type Dictionary<T> = { [string]: T}
export type Map<T, U> = { [T]: U }
export type Array<T> = { T }
