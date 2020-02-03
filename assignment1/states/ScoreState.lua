--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]

function ScoreState:init()
    self.imageGold = love.graphics.newImage('images/gold.png')
    self.imageSilver = love.graphics.newImage('images/silver.png')
    self.imageBronze = love.graphics.newImage('images/bronze.png')

    -- Must set these during enter(), before render
    self.trophy = nil 
    self.trophyText = nil 
    self.trohpyColor = nil 
end

function ScoreState:enter(params)
    self.score = params.score
    if self.score > 5 then 
        self.trophy = self.imageGold
        self.trophyText = "GOLD PRIZE"
        self.trophyColor = {255, 215, 0}
    elseif self.score > 2 then 
        self.trophy = self.imageSilver
        self.trophyText = "SILVER PRIZE"
        self.trophyColor = {192, 192, 192}
    elseif self.score >= 0 then
        self.trophy = self.imageBronze
        self.trophyText = "BRONZE PRIZE"
        self.trophyColor = {205, 127, 50}
    end


end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')

    -- https://love2d.org/forums/viewtopic.php?t=81620
    -- love.graphics.push()
    -- local scaleFactor = 0.5
    -- love.graphics.scale(scaleFactor, scaleFactor)
    -- love.graphics.draw(trophy, 0/scaleFactor, 0/scaleFactor) 
    -- love.graphics.pop() -- so the scale doesn't affect anything else

    love.graphics.draw(self.trophy, VIRTUAL_WIDTH/2 - self.trophy:getWidth()/2, 180)
    love.graphics.setColor(self.trophyColor)
    love.graphics.printf(self.trophyText, 0, 188, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor({255,255,255}) -- revert color
end