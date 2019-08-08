-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'
TITLE='BulletHell'
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
SPEED = 200
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

object = {x=0, y=0, dx=0, dy=0, height = 10, width=10}
player = shallowcopy(object)
player.x = 10
player.y = 10
player.dx = 0
player.dy = 0

bullet = shallowcopy(object)
bullet.height = 6
bullet.width = 30
bulletSpeed = SPEED

bullets={}
noBullets = 10
for i=1,noBullets do
  bullets[i] = shallowcopy(bullet)
  bullets[i].x = math.random(1,VIRTUAL_WIDTH)
  bullets[i].y = math.random(1,VIRTUAL_HEIGHT)
  bullets[i].dx = math.random(1,bulletSpeed)
  bullets[i].dy = math.random(1,bulletSpeed)
end

function collision(rect1, rect2)
    if rect1.x > rect2.x + rect2.width or
     rect1.x + rect1.width  < rect2.x or
     rect1.y > rect2.y + rect2.height or
     rect1.y + rect1.height < rect2.y then
     return false
    else
     return true
    end
end
gameState = 'play'
function updateBullets(dt)
    for i=1,noBullets do
        update = Boundary(bullets[i])
        if update.left == true then
            bullets[i].dx = math.random(1,bulletSpeed)
        elseif update.right == true then
            bullets[i].dx = -math.random(1,bulletSpeed)
        end
        if update.top == true then
            bullets[i].dy = math.random(bulletSpeed/2,bulletSpeed)
        elseif update.bottom == true then
            bullets[i].dy = -math.random(bulletSpeed/2,bulletSpeed)
        end
        bullets[i].x = bullets[i].x + bullets[i].dx * dt
        bullets[i].y = bullets[i].y + bullets[i].dy * dt
        if collision(player, bullets[i]) then
            gameState='dead'
            bullets[i].x = math.random(1,VIRTUAL_WIDTH)
            bullets[i].y = math.random(1,VIRTUAL_HEIGHT)
        end
    end
end
function bulletsRender()
    for i=1,noBullets do
        --love.graphics.rectangle('fill', bullets[i].x, bullets[i].y, bullets[i].width, bullets[i].height)
        love.graphics.setFont(smallFont)
        love.graphics.printf("Danger",bullets[i].x, bullets[i].y, bullets[i].width, 'center')
    end
end


function Boundary(object)
    left = false
    right = false
    if object.x < 0 and object.dx < 0 then
        object.x = 0
        left = true
    elseif object.x > VIRTUAL_WIDTH and object.dx > 0 then
        object.x = VIRTUAL_WIDTH
        right = true
    end
    
    top = false
    bottom = false
    if object.y < 0 and object.dy < 0 then
        object.y = 0
        top = true
    elseif object.y > VIRTUAL_HEIGHT and object.dy > 0 then
        object.y = VIRTUAL_HEIGHT
        bottom = true
    end
    return {left=left, right=right, top=top, bottom=bottom}
end


function love.load()
    -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text 
    -- and graphics; try removing this function to see the difference!
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle(TITLE)
    math.randomseed(os.time())
    
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('font.ttf', 16)
    love.graphics.setFont(mediumFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end
function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    --Boundaries
    update = Boundary(player)
    --player.x = update.x
    --player.y = update.y
    
   if love.keyboard.isDown('w') then
        player.dy = -SPEED
    elseif love.keyboard.isDown('s') then
        player.dy = SPEED
    else
        player.dy = 0
    end
   if love.keyboard.isDown('a') then
        player.dx = -SPEED
    elseif love.keyboard.isDown('d') then
        player.dx = SPEED
    else
        player.dx = 0
    end
    player.x = player.x + player.dx * dt
    player.y = player.y + player.dy * dt
    
    updateBullets(dt)
    
end
--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    end
    if key == 'enter' or key == 'return'then
        -- function LÖVE gives us to terminate application
        gameState = 'play'
    end
end



function love.draw()
    push:apply('start')
    if gameState == 'play' then
        love.graphics.setFont(mediumFont)
        love.graphics.printf(TITLE, 0, VIRTUAL_HEIGHT / 2 - 8, VIRTUAL_WIDTH, 'center')
        love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)
        --love.graphics.printf('You',0,player.y, player.x,'center')
        bulletsRender()
    elseif gameState == 'dead' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('crap', 0, VIRTUAL_HEIGHT / 2 - 8, VIRTUAL_WIDTH, 'center')
    end
    push:apply('end')
end
