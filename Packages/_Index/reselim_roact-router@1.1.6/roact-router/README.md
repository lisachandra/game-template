<p align="center">
	<img src=".github/logo.svg" height="170">
	<br><br>
	<a href=""><i>Documentation (TODO)</i></a>
</p>

# Installation

Roact Router searches for a Roact module with the same parent as it. If it doesn't find Roact, it will fail to load.

## With Rojo 0.6.0+

Add this repository as a Git submodule into the directory that you prefer to store your packages in.

```
git submodule add https://github.com/Reselim/roact-router packages/RoactRouter
```

This example assumes your packages directory is "packages".

## Without Rojo

Grab the latest .rbxm file from the [releases page](https://github.com/Reselim/roact-router/releases) and drag it into Studio. Make sure it's under the same parent as Roact.

## Using [roblox-ts](https://github.com/roblox-ts/roblox-ts)

Install with npm:

```
npm i @rbxts/roact-router
```

# License

Roact Router is licensed under the [MIT license](LICENSE).