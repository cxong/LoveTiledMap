-- small demo for TiledMap loader
require "tiledmap"

gKeyPressed = {}
gCamX,gCamY = 100,100

function loadMap(path)
  TiledMap_Load(path)
  gCamX,gCamY = gMapWidth * gTileWidth / 2, gMapHeight * gTileHeight / 2
end

function love.load()
	loadMap("map/map01.tmx")
end

function love.keyreleased( key )
	gKeyPressed[key] = nil
end

function love.keypressed( key, unicode ) 
	gKeyPressed[key] = true 
	if (key == "escape") then os.exit(0) end
	if (key == " ") then -- space = next mal
		gMapNum = (gMapNum or 1) + 1
		if (gMapNum > 3) then gMapNum = 1 end
		loadMap(string.format("map/map%02d.tmx",gMapNum))
	end
end

function love.update( dt )
	local s = 500*dt
	if (gKeyPressed.up) then gCamY = gCamY - s end
	if (gKeyPressed.down) then gCamY = gCamY + s end
	if (gKeyPressed.left) then gCamX = gCamX - s end
	if (gKeyPressed.right) then gCamX = gCamX + s end
  -- Keep camera within map bounds
  gCamX = math.min(math.max(gCamX, 0), gMapWidth * gTileWidth)
  gCamY = math.min(math.max(gCamY, 0), gMapHeight * gTileHeight)
end

function love.draw()
  love.graphics.print('arrow-keys=scroll, space=next map', 50, 50)
	love.graphics.setBackgroundColor(0x80,0x80,0x80)
	TiledMap_DrawNearCam(gCamX,gCamY)
end
