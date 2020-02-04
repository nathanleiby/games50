Powerup = Class{}

function Powerup:init()
    self.x = 32
    self.y = 64
    self.width = 16 
    self.height = 16
    -- x,y,width,height make something "colliable" with the ball

    -- movement
    self.dx = 0
    self.dy = 40

    -- TODO: do the below on spawn in the game, vs class init 
    self.inPlay = true
    self.timer = 0
end

function Powerup:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        return
    end
    self.y = self.y + self.dy*dt
end

function Powerup:hit()
    self.inPlay = false
    -- TODO: play sound
end

function Powerup:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][1], self.x, self.y)
    end
end