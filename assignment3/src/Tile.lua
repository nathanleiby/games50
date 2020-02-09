--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

-- used by Tile class
-- but managed here so we can keep all the shining in sync


function Tile:init(x, y, color, variety, shiny)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- shiny versions of blocks that will destroy an entire row on match, granting points for each block in the row
    self.shiny = shiny or false
    self.shiny = math.random() > 0.90 -- true -- math.random() > 0.9 -- TODO: testing 123
    if self.shiny then
        print("TILE x=" .. x .. " , y=" .. y .. " is shiny")

        self.shinyShader = love.graphics.newShader[[
            extern number factor = 0;
            extern number tx = 0;
            extern number ty = 0;
            vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
                vec4 pixel = Texel(texture, texture_coords); // current pixel color

                if(texture_coords.x > factor && texture_coords.y > factor){
                    return pixel;
                } else {
                    pixel.r = 1 - pixel.r;
                    pixel.g = 1 - pixel.g;
                    pixel.b = 1 - pixel.b;
                    return pixel;
                }
            }
        ]]

        -- TODO: initialize the shader with tx and ty, so it can reason about texture_coords
        -- for a given piece of the tilesheet (https://love2d.org/forums/viewtopic.php?t=81716)
        --
        -- self.shinyShader.send()
    end
end

function Tile:render(x, y, shineFactor)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    if self.shiny then
        self.shinyShader:send("factor", shineFactor)
        love.graphics.setShader(self.shinyShader)
    end
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    love.graphics.setShader()
end

function Tile:ID()
    return "x=" .. self.gridX .. ",y=" .. self.gridY
end