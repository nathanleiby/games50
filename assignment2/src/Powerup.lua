Powerup = Class{}

function Powerup:init(skin)
    self.x = math.random(32, VIRTUAL_WIDTH-32)
    self.y = 64
    self.width = 16
    self.height = 16
    -- x,y,width,height make something "colliable" with the ball

    -- movement
    self.dx = 0
    self.dy = 40

    if skin then
        self.skin = skin
    else
        self.skin = math.random(1,10)
    end

    self.inPlay = true
    self.timer = 0
end

function Powerup:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
        return
    end

    self.y = self.y + self.dy*dt

    -- Remove from play if scrolls past bottom of screen
    if self.y > VIRTUAL_HEIGHT then
        self.inPlay = false
    end
end

function Powerup:hit()
    self.inPlay = false
    -- TODO: play sound
end

function Powerup:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin], self.x, self.y)
    end
end