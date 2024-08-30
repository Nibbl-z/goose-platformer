# Goose Platformer (Online Levels Edition!)

Goose Platformer is a platformer game with a level editor. And a goose. That's it.

This branch has online level support! The server currently has to be self hosted and can be found in the `server` folder. Install the `express` package from npm and then run `node .` to run the server. The server's .goose files are stored in `server/gooseFiles`.

Created levels are saved in AppData > Roaming > goose-platformer.

### Controls:

- A/D to move
- Space to jump
- R to restart at last checkpoint
- Escape to pause
  
### Installation:

You can find this version of the game in the [releases tab](https://github.com/Nibbl-z/goose-platformer/releases/tag/v1.0.0-online-levels). Unzip `GoosePlatformer.zip` it and run the .exe to run the game. Unzip `GoosePlatformerServer.zip` and run `node .` to run the online level server. It's that simple! 
