--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y

    self.gridWidth = 8 -- x
    self.gridHeight = 8 -- y

    self.level = level

    -- manage intermediate state during matching
    self.matchedTiles = {}
    self.hasMatches = false

    self:initializeTiles()
end

function Board:getTileGivenPixels(x, y)
    local tileSize = 32

    -- handle board offset
    x = x - self.x
    y = y - self.y

    for _, row in pairs(self.tiles) do
        for _, tile in pairs(row) do
            if x >= tile.x and x < (tile.x + tileSize) and y >= tile.y and y < (tile.y + tileSize) then
                return tile
            end
        end
    end

    return nil
end

function Board:initializeTiles()
    self.tiles = {}
    self.hasMatches = false

    for y = 1, self.gridHeight do
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})
        for x = 1, self.gridWidth do
            local tile = self:newTile(x,y)
            table.insert(self.tiles[y], tile)
        end
    end

    while self:calculateMatches() do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

function Board:addMatchedTile(x, y)
    local tile = self.tiles[y][x]
    self.matchedTiles[tile:ID()] = tile
    if tile.shiny then
        for x2 = 1, self.gridWidth do
            local t2 = self.tiles[y][x2]
            self.matchedTiles[t2:ID()] = t2
        end
    end
    self.hasMatches = true
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        self:addMatchedTile(x2, y)
                    end
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                self:addMatchedTile(x, y)
            end
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    for y2 = y - 1, y - matchNum, -1 do
                        self:addMatchedTile(x, y2)
                    end
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                self:addMatchedTile(x, y)
            end
        end
    end

    return self.hasMatches and self.matchedTiles or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for _, tile in pairs(self.matchedTiles) do
        self.tiles[tile.gridY][tile.gridX] = nil
    end

    self.matchedTiles = {}
    self.hasMatches = false
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = self:newTile(x,y)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:newTile(x,y)
    -- create a new tile at X,Y with a random color and variety
    local color = math.random(18)
    local variety = math.random(1, math.min(self.level, 6)) -- no more than 6 varieties, even if level >6
    return Tile(x, y, color, variety)
end

function Board:render(shineFactor)
    if not shineFactor then
        shineFactor = 0
    end

    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y, shineFactor)
        end
    end
end