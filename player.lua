local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)

    -- Position & movement
    self.x = x
    self.y = y
    self.frameWidth = 32
    self.frameHeight = 32
    self.scale = 3                 -- sprite scaling
    self.w = self.frameWidth * self.scale   -- collision width
    self.h = self.frameHeight * self.scale  -- collision height
    self.speed = 200
    self.vy = 0
    self.onGround = false

    -- Gravity
    self.gravity = 800

    -- Load sprite sheet
    self.sprite = love.graphics.newImage("assets/sprites/goku_sprite.png")

    -- Build quads
    self:generateQuads()

    -- Animations table
    self.animations = {
        idle = self:createAnimation(1, 4, 0.2),
        run  = self:createAnimation(5, 8, 0.1),
    }

    self.currentAnim = self.animations.idle
    self.animFrame = self.currentAnim.start
    self.animTimer = 0

    return self
end

-- Generate quads from sprite sheet
function Player:generateQuads()
    self.quads = {}
    local sheetWidth, sheetHeight = self.sprite:getWidth(), self.sprite:getHeight()
    local cols = sheetWidth / self.frameWidth
    local rows = sheetHeight / self.frameHeight

    for y = 0, rows - 1 do
        for x = 0, cols - 1 do
            table.insert(self.quads, love.graphics.newQuad(
                x * self.frameWidth,
                y * self.frameHeight,
                self.frameWidth,
                self.frameHeight,
                sheetWidth,
                sheetHeight
            ))
        end
    end
end

-- Create an animation
function Player:createAnimation(startFrame, endFrame, speed)
    return {start = startFrame, finish = endFrame, speed = speed}
end

-- Change current animation
function Player:setAnimation(name)
    if self.currentAnim ~= self.animations[name] then
        self.currentAnim = self.animations[name]
        self.animFrame = self.currentAnim.start
        self.animTimer = 0
    end
end

-- Update player
function Player:update(dt, platforms)
    -- Horizontal movement
    local moving = false
    if love.keyboard.isDown("left", "a") then
        self.x = self.x - self.speed * dt
        self:setAnimation("run")
        moving = true
    elseif love.keyboard.isDown("right", "d") then
        self.x = self.x + self.speed * dt
        self:setAnimation("run")
        moving = true
    else
        self:setAnimation("idle")
    end

    -- Gravity
    self.vy = self.vy + self.gravity * dt

    -- Swept vertical collision
    local futureY = self.y + self.vy * dt
    self.onGround = false

    for _, p in ipairs(platforms) do
        if self.x + self.w > p.x and self.x < p.x + p.w then
            if self.vy >= 0 then
                if self.y + self.h <= p.y and futureY + self.h >= p.y then
                    futureY = p.y - self.h
                    self.vy = 0
                    self.onGround = true
                end
            end
        end
    end

    self.y = futureY

    -- Prevent falling below screen
    if self.y + self.h > 1080 then
        self.y = 1080 - self.h
        self.vy = 0
        self.onGround = true
    end

    -- Animation timer
    self.animTimer = self.animTimer + dt
    if self.animTimer > self.currentAnim.speed then
        self.animTimer = self.animTimer - self.currentAnim.speed
        self.animFrame = self.animFrame + 1
        if self.animFrame > self.currentAnim.finish then
            self.animFrame = self.currentAnim.start
        end
    end
end


-- Draw player
function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite,
        self.quads[self.animFrame],
        self.x,
        self.y,
        0,
        self.scale,
        self.scale
    )
end

return Player
