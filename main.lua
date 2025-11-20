local Player = require("player")

local player
local platforms = {}
local portrait 
local Pc = {1920,1080}

function love.load()
    love.window.setTitle("Jump and Run")
    love.window.setMode(Pc[1], Pc[2])

    -- Create player
    player = Player.new(200, 400)

    -- Portrait (optional)
    portrait = love.graphics.newImage("assets/sprites/gokuportrait.png")
    portrait:setFilter("nearest", "nearest")
    -- Platforms
    table.insert(platforms, {x = 0, y = 650, w = Pc[1], h = 50})   -- ground
    table.insert(platforms, {x = 400, y = 500, w = 200, h = 30})
    table.insert(platforms, {x = 700, y = 400, w = 200, h = 30})
end

function love.update(dt)
    -- Update player (horizontal & animation)
   player:update(dt, platforms)

    -- Jump
    if love.keyboard.isDown("space") and player.onGround then
        player.vy = -400
        player.onGround = false
    end


    -- Apply gravity
    player.vy = player.vy + player.gravity * dt

    -- Swept collision: move in small steps to prevent falling through
    local steps = math.ceil(math.abs(player.vy * dt) / 5) -- step max 5px
    local dy = (player.vy * dt) / steps

    for i = 1, steps do
        player.y = player.y + dy
        player.onGround = false

        for _, p in ipairs(platforms) do
            if player.x + player.w > p.x and player.x < p.x + p.w then
                if dy > 0 and player.y + player.h > p.y and player.y + player.h - dy <= p.y then
                    -- Land on platform
                    player.y = p.y - player.h
                    player.vy = 0
                    player.onGround = true
                end
            end
        end

        -- Stop if landed
        if player.onGround then break end
    end

    -- Prevent falling below screen
    if player.y + player.h > Pc[2] then
        player.y = Pc[2] - player.h
        player.vy = 0
        player.onGround = true
    end
end


function love.draw()
    -- Draw portrait
    if portrait then
        love.graphics.draw(portrait, 20, 20, 0, 4, 4)
    end

    -- Draw platforms
    love.graphics.setColor(0.4, 0.8, 1)
    for _, p in ipairs(platforms) do
        love.graphics.rectangle("fill", p.x, p.y, p.w, p.h)
    end
    love.graphics.setColor(1, 1, 1)

    -- Draw player
    player:draw()
end
