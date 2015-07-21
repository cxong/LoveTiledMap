# LoveTiledMap

Load and draw [Tiled maps (TMX)](http://www.mapeditor.org/) for [LÖVE](https://love2d.org/), based on https://love2d.org/wiki/TiledMapLoader

Sample code (see main.lua):

    require "tiledmap"
    TiledMap_Load("path/to/map.tmx")
    love.graphics.print('Tiled map size: ' .. gMapWidth .. ',' .. gMapHeight, 50, 50)
    love.graphics.print('Tile size: ' .. gTileWidth .. ',' .. gTileHeight, 50, 100)
    TiledMap_DrawNearCam(100, 100)

## Changes to TiledMapLoader

- Support arbitrary tile sizes
- Support CSV encoding
- Add tile and map size
- Fix camera position

## License

MIT

## Samples

Samples courtesy of:

- [LPC Tile Atlas](http://opengameart.org/content/lpc-tile-atlas)
- [DawnLike - 16x16 Universal Rogue-like tileset v1.8](http://opengameart.org/content/dawnlike-16x16-universal-rogue-like-tileset-v18)
- [Abandonauts 8x8 tile assets](http://opengameart.org/content/abandonauts-8x8-tile-assets)