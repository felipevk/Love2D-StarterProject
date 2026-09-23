# Love2D Starter Project

A lightweight starter project for building games with [LÖVE](https://love2d.org/) and Lua.

It includes a basic project structure, commonly used libraries, and some helper scripts for quickly starting and building a game.

## Starting a New Project

The recommended way to use this repository is as a GitHub template.

On GitHub, click:

```text
Use this template → Create a new repository
```

This creates a new repository containing the starter project files without copying the original commit history.

You can then clone your new repository normally:

```bash
git clone https://github.com/yourname/MyNewGame.git
```

If you clone this repository directly instead, Git will keep `Love2D-StarterProject` configured as the `origin` remote.


### Running the Game

On Windows, simply run:

```text
Game/run_game.bat
```

This launches the project using the included LÖVE 11.5 runtime.

Alternatively, you can run the game manually:

```bash
love Game
```

## Project Features

The project provides support for things such as:

* Rooms / game states
* Game objects and areas
* Input handling
* Timers
* Cameras
* Physics
* Resource loading
* Sprite animation
* Tiled maps

## Creating Game Objects

Game objects live inside:

```text
Game/objects/
```

A helper script is provided to generate a new object based on the project's `GameObject` class.

From inside the `Game` directory, run:

```bash
create_gameObject.bat Player
```

This creates:

```text
objects/Player.lua
```

with the basic object structure already set up:

```lua
local Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)
end

function Player:update(dt)
    Player.super.update(self, dt)
end

function Player:draw()

end

function Player:destroy()
    Player.super.destroy(self)
end

return Player
```

Replace `Player` with the name of the object you want to create.

## Rooms

Rooms represent different game states or scenes and are stored in:

```text
Game/rooms/
```

To switch to another room:

```lua
gotoRoom("RoomName")
```

## Building for Windows

The repository includes scripts for creating `.love` packages and standalone Windows builds:

```text
build-love-win64.bat
build-standalone-win64.bat
```

The build scripts require `7z.exe` to be available from the command line.

## License

MIT
