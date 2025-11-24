local Player = {}
Player.__index = Player

-----------------------------
-- ANIMATION HELPERS FIRST --
-----------------------------

function Player:createAnimation(startFrame, finishFrame, speed, facing)
    return {start = startFrame, finish = finishFrame, speed = speed, facing = facing}
end

function Player:setAnimation(name)
    if self.currentAnim ~= self.animations[name] then
        self.currentAnim = self.animations[name]
        self.animFrame = self.currentAnim.start
        self.animTimer = 0
    end
end

----------------
-- CONSTRUCTOR --
----------------

function Player.new(x, y)
    local self = setmetatable({}, Player)

    self.x = x
    self.y = y
    self.frameWidth = 32
    self.frameHeight = 46
    self.scale = 3
    self.w = self.frameWidth * self.scale
    self.h = self.frameHeight * self.scale

    self.speed = 200
    self.vy = 0
    self.gravity = 800
    self.jumpForce = -400
    self.onGround = false
    self.facing = 1 -- 1 = right, -1 = left

    -- Load sprite
    self.sprite = love.graphics.newImage("assets/sprites/goku_sprite.png")
    self.sprite:setFilter("nearest", "nearest")

    -- Build quads
    self:generateQuads()

    -- Animations with natural facing of the frame
    -- Adjust the facing for your sheet frames: "right" or "left"
    self.animations = {
        idle = self:createAnimation(1, 3, 0.2, "right"),
        run  = self:createAnimation(4, 6, 0.2, "left"),
        jump = self:createAnimation(7, 9, 0.2, "right") 
    }

    self.currentAnim = self.animations.idle
    self.animFrame = self.currentAnim.start
    self.animTimer = 0

    return self
end

------------------------
-- QUAD GENERATION    --
------------------------

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

------------------------
-- MAIN UPDATE LOOP   --
------------------------

function Player:update(dt, platforms)
    local moving = false

    -- Movement
    if love.keyboard.isDown("left", "a") then
        self.x = self.x - self.speed * dt
        self.facing = -1
        if self.onGround then self:setAnimation("run") end
        moving = true

    elseif love.keyboard.isDown("right", "d") then
        self.x = self.x + self.speed * dt
        self.facing = 1
        if self.onGround then self:setAnimation("run") end
        moving = true
    end

    if not moving and self.onGround then
        self:setAnimation("idle")
    end

    -- Jump input
    if love.keyboard.isDown("space") and self.onGround then
        self.vy = self.jumpForce
        self.onGround = false
        self:setAnimation("jump")
    end

    -- Gravity
    self.vy = self.vy + self.gravity * dt

    -- Collision
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

    if not self.onGround then
        self:setAnimation("jump")
    end

    -- Animation ticking
    self.animTimer = self.animTimer + dt
    if self.animTimer > self.currentAnim.speed then
        self.animTimer = self.animTimer - self.currentAnim.speed
        self.animFrame = self.animFrame + 1
        if self.animFrame > self.currentAnim.finish then
            self.animFrame = self.currentAnim.start
        end
    end
end

------------------
-- DRAW PLAYER  --
------------------

function Player:draw()
    love.graphics.setColor(1, 1, 1)

    local anim = self.currentAnim
    local naturalFacing = anim.facing or "right"

    -- Flip only if player facing opposite of natural frame
    local flip = false
    if (self.facing == 1 and naturalFacing == "left") or
       (self.facing == -1 and naturalFacing == "right") then
        flip = true
    end

    local sx = flip and -self.scale or self.scale
    local sy = self.scale
    local ox = self.frameWidth / 2
    local oy = self.frameHeight / 2

    love.graphics.draw(
        self.sprite,
        self.quads[self.animFrame],
        self.x + self.w / 2,
        self.y + self.h / 2,
        0,
        sx,
        sy,
        ox,
        oy
    )
end

return Player
