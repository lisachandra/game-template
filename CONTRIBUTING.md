# Contributing
## Working on game-template
To get started working on game-template, you'll need:
- A purpose (maybe you're fixing, adding or removing something)
- [Wally](https://github.com/UpliftGames/wally)
- [Foreman](https://github.com/Roblox/foreman)
- [Rojo](https://github.com/rojo-rbx/rojo/)
- [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp)

And an intermediate understanding of:
- [Luau](https://luau-lang.org)
- [Type checking](https://luau-lang.org/typecheck)
- [React](https://unix-system.github.io/jsdotlua.github.io/docs/category/react-react-lua)
- [Rodux](https://github.com/Roblox/rodux/)
- [Matter](https://github.com/evaera/matter/)
- [BridgeNet2](https://github.com/ffrostflame/BridgeNet2)
- [Promise](https://github.com/evaera/roblox-lua-promise/)

Then you should:

- Create and publish a new branch from the main branch
- Install required wally packages
- Generate a rojo sourcemap with default.project.json
- Connect to the desired testing place with Rojo and Luau LSP companion plugins

NOTE: Make sure there are no other contributors interacting with the code on the testing place!

## Pull Request
Before you submit a new pull request, check:
- Up-to-date: Ensure your code isn't outdated
- Code Style: Ensure your code follows the [offical Roblox Lua style guide](https://roblox.github.io/lua-style-guide)
- Tests: Ensure your code didn't break any of the game's features
- Analyze: Analyze your code with [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp) (no errors allowed!)
- Squashing: Squash your commits into a single commit with [git's interactive rebase](https://docs.github.com/en/get-started/using-git/about-git-rebase)
