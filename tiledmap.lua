-- loader for "tiled" map editor maps (.tmx,xml-based) http://www.mapeditor.org/
-- supports multiple layers
-- NOTE : function ReplaceMapTileClass (tx,ty,oldTileType,newTileType,fun_callback) end
-- NOTE : function TransmuteMap (from_to_table) end -- from_to_table[old]=new
-- NOTE : function GetMousePosOnMap () return gMouseX+gCamX-gScreenW/2,gMouseY+gCamY-gScreenH/2 end

kMapTileTypeEmpty = 0
local floor = math.floor
local ceil = math.ceil

function TiledMap_Load (filepath)
	spritepath_removeold = "../"
	spritepath_prefix = ""
	gTileGfx = {}
	
	local tiletype,layers = TiledMap_Parse(filepath)
	gMapLayers = layers
	for first_gid,path in pairs(tiletype) do 
		path = spritepath_prefix .. string.gsub(path,"^"..string.gsub(spritepath_removeold,"%.","%%."),"")
		local raw = love.image.newImageData(path)
		local w,h = raw:getWidth(),raw:getHeight()
		local gid = first_gid
		for y=0,floor(h/gTileHeight)-1 do
		for x=0,floor(w/gTileWidth)-1 do
			local sprite = love.image.newImageData(gTileWidth,gTileHeight)
			sprite:paste(raw,0,0,x*gTileWidth,y*gTileHeight,gTileWidth,gTileHeight)
			gTileGfx[gid] = love.graphics.newImage(sprite)
			gid = gid + 1
		end
		end
	end
end

function TiledMap_GetMapTile (tx,ty,layerid) -- coords in tiles
	local row = gMapLayers[layerid][ty]
	return row and row[tx] or kMapTileTypeEmpty
end

function TiledMap_DrawNearCam (camx,camy)
	camx,camy = floor(camx),floor(camy)
	local screen_w = love.graphics.getWidth()
	local screen_h = love.graphics.getHeight()
	local minx,maxx = floor((camx-screen_w/2)/gTileWidth),ceil((camx+screen_w/2)/gTileWidth)
	local miny,maxy = floor((camy-screen_h/2)/gTileHeight),ceil((camy+screen_h/2)/gTileHeight)
	for z = 1,#gMapLayers do
	for x = minx,maxx do
	for y = miny,maxy do
		local gfx = gTileGfx[TiledMap_GetMapTile(x + 1, y + 1, z)]
		if (gfx) then 
			local sx = x*gTileWidth - camx + screen_w/2
			local sy = y*gTileHeight - camy + screen_h/2
			love.graphics.draw(gfx,sx,sy) -- x, y, r, sx, sy, ox, oy
		end
	end
	end
	end
end


-- ***** ***** ***** ***** ***** xml parser


-- LoadXML from http://lua-users.org/wiki/LuaXml
function LoadXML(s)
  local function LoadXML_parseargs(s)
    local arg = {}
    string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
  	arg[w] = a
    end)
    return arg
  end
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=LoadXML_parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=LoadXML_parseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[stack.n].label)
  end
  return stack[1]
end


-- ***** ***** ***** ***** ***** parsing the tilemap xml file

local function getTilesets(node)
	local tiles = {}
	for k, sub in ipairs(node) do
		if (sub.label == "tileset") then
			tiles[tonumber(sub.xarg.firstgid)] = sub[1].xarg.source
		end
	end
	return tiles
end

local function getLayers(node)
	local layers = {}
	for k, sub in ipairs(node) do
		if (sub.label == "layer") then --  and sub.xarg.name == layer_name
			local layer = {}
			table.insert(layers,layer)
			width = tonumber(sub.xarg.width)
			i = 1
			j = 1
      local function addTile(gidString)
        if (j == 1) then
					layer[i] = {}
				end
				layer[i][j] = tonumber(gidString)
				j = j + 1
				if j > width then
					j = 1
					i = i + 1
				end
      end
      local data = sub[1]
      if data.xarg.encoding == "csv" then
        for l in string.gmatch(data[1], "([^,]+)") do
          addTile(l)
        end
      else
        for l, child in ipairs(data) do
          addTile(child.xarg.gid)
				end
			end
		end
	end
	return layers
end

function TiledMap_Parse(filename)
	local xml = LoadXML(love.filesystem.read(filename))
  gTileWidth, gTileHeight = 16, 16
  gMapWidth, gMapHeight = 0, 0
  for k, sub in ipairs(xml) do
    if sub.label == "map" then
      gMapWidth = tonumber(sub.xarg.width)
      gMapHeight = tonumber(sub.xarg.height)
      gTileWidth = tonumber(sub.xarg.tilewidth)
      gTileHeight = tonumber(sub.xarg.tileheight)
      local tiles = getTilesets(sub)
      local layers = getLayers(sub)
      return tiles, layers
    end
  end
  return nil, nil
end

