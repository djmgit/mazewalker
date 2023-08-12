player = {}
player.pos_x = PLAYER_START_X
player.pos_y = PLAYER_START_Y
player.speed = 4
player.angle = 0
player.angular_speed = 1
player.shot = false
player.health = PLAYER_MAX_HEALTH
player.hit = false

function player_pos()
    return player.pos_x, player.pos_y
end

function check_not_wall(pos_x, pos_y)
    if map[pos_x] == nil then
        return true
    end
    if map[pos_x][pos_y] == nil then
        return true
    end
    
    return false
end

function player_get_damage(damage)
    player.health = player.health - damage
    sounds.player_pain:play()
    check_game_over()
end

function check_game_over()
    if player.health < 1 then
        GAME_OVER = true
    end
end

function move(dt)
    local sin_a = math.sin(player.angle)
    local cos_a = math.cos(player.angle)
    local distance = player.speed * dt
    local dtheta = player.angular_speed * dt

    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then
        dx = distance * cos_a
        dy = distance * sin_a
    end

    if love.keyboard.isDown("s") then
        dx = -distance * cos_a
        dy = -distance * sin_a
    end

    if love.keyboard.isDown("a") then
        dx = distance * sin_a
        dy = -distance * cos_a
    end

    if love.keyboard.isDown("d") then
        dx = -distance * sin_a
        dy = distance * cos_a
    end
    if check_not_wall(math.floor(player.pos_x + dx*PLAYER_SCALE), math.floor(player.pos_y)) then
        player.pos_x = player.pos_x + dx
    end

    if check_not_wall(math.floor(player.pos_x), math.floor(player.pos_y + dy*PLAYER_SCALE)) then
        player.pos_y = player.pos_y + dy
    end

    if love.keyboard.isDown("left") then
        player.angle = player.angle - dtheta
    end

    if love.keyboard.isDown("right") then
        player.angle = player.angle + dtheta
    end

    -- player.angle = player.angle % (math.pi * 2)

end

function mouse_moved(dt)
    local mouse_x = love.mouse.getX()
    if mouse_x < MOUSE_BORDER_LEFT or mouse_x > MOUSE_BORDER_RIGHT then
        love.mouse.setPosition(HALF_WINDOW_WIDTH, HALF_WINDOW_HEIGHT)
    end
    player.rel = math.max(-MOUSE_MAX_REL, math.min(MOUSE_MAX_REL, mouse_rel_dx))
    player.angle = player.angle + player.rel * MOUSE_SENSITIVITY * dt
    mouse_rel_dx = 0

end

function player_map_pos()
    return math.floor(player.pos_x), math.floor(player.pos_y)
end

function player_update(dt)
    move(dt)
    mouse_moved(dt)
end

function player_draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(player.pos_x*WINDOW_SCALE, player.pos_y*WINDOW_SCALE, player.pos_x*WINDOW_SCALE + WINDOW_WIDTH*math.cos(player.angle),
                      player.pos_y*WINDOW_SCALE + WINDOW_WIDTH*math.sin(player.angle))
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", player.pos_x*WINDOW_SCALE, player.pos_y*WINDOW_SCALE, 15)

end

function single_fire()
    if player.shot == false and weapon.reloading == false then
        player.shot = true
        weapon.reloading = true
    end
end

function player_draw_health()
    local health_str = tostring(player.health)
    for dpos=1, #health_str do
        local dchar = string.sub(health_str, dpos, dpos)
        local d_texture = digits[tonumber(dchar)+1]
        love.graphics.draw(d_texture, (dpos-1) * DIGIT_SIZE, 0, nil, DIGIT_SIZE/d_texture:getWidth(), DIGIT_SIZE/d_texture:getHeight())
    end
    love.graphics.draw(digits[11], #health_str * DIGIT_SIZE, 0, nil,  DIGIT_SIZE/digits[10]:getWidth(), DIGIT_SIZE/digits[10]:getHeight())
end

