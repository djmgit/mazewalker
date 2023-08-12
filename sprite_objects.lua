require "path_finding"

function load_sprite(path, pos_x, pos_y, scale, shift, sprite_type, animation_time,
                     npc_type, attack_images_path, death_images_path, idle_images_path,
                     pain_images_path, walk_images_path)
    local sprite = {}
    sprite.sprite_type = sprite_type
    if sprite_type == SPRITE_TYPE_STATIC then
        sprite.image = love.graphics.newImage(path)
    elseif sprite_type == SPRITE_TYPE_ANIMATED then
        sprite.current_image = 0
        sprite.image_paths = listdir(path)
        sprite.images = get_images_from_paths(sprite.image_paths)
        sprite.image = sprite.images[sprite.current_image + 1]
        sprite.animation_time = animation_time
        sprite.time_remaining = sprite.animation_time
    elseif sprite_type == SPRITE_TYPE_NPC then
        sprite.state = NPC_STATE_IDLE
        sprite.animations = {}
        sprite.animations.animation_idle = initialise_npc_animation(idle_images_path)
        sprite.animations.animation_walk = initialise_npc_animation(walk_images_path)
        sprite.animations.animation_attack = initialise_npc_animation(attack_images_path)
        sprite.animations.animation_pain = initialise_npc_animation(pain_images_path)
        sprite.animations.animation_death = initialise_npc_animation(death_images_path, false)
        sprite.animation_time = animation_time
        sprite.time_remaining = sprite.animation_time
        sprite.image = sprite.animations.animation_idle.images[sprite.animations.animation_idle.current_image + 1]
        sprite.npc_type = npc_type
        sprite.speed = 1.8
        sprite.size = 10
        sprite.health = 100
        sprite.attack_damage = 10
        sprite.accuracy = 0
        sprite.alive = true
        sprite.pain = false
        sprite.ray_cast_value = false
        sprite.player_dist = 0
        sprite.attack_dist = math.random(1,4)
        sprite.player_search_trigger = false
    end
    sprite.map_x = pos_x
    sprite.map_y = pos_y
    sprite.IMAGE_WIDTH = sprite.image:getWidth()
    sprite.IMAGE_HALF_WIDTH = math.floor(sprite.image:getWidth() / 2)
    sprite.IMAGE_RATIO = sprite.IMAGE_WIDTH / sprite.image:getHeight()
    sprite.object_type = OBJECT_TYPE_SPRITE
    sprite.dx, sprite.dy, sprite.theta, sprite.screen_x, sprite.dist, sprite.norm_dist = 0, 0, 0, 0, 1, 1
    sprite.sprite_half_width = 0
    sprite.SPRITE_SCALE = scale
    sprite.SPRITE_HEIGHT_SHIFT = shift
    table.insert(sprites, sprite)
end

function sprite_map_pos(sprite)
    return math.floor(sprite.map_x), math.floor(sprite.map_y)
end

function sprite_ray_cast(sprite)
    local ox, oy  = player_pos()
    local x_map, y_map = player_map_pos()
    local sprite_x_map, sprite_y_map = sprite_map_pos(sprite)
    if (x_map == sprite_x_map) and (y_map == sprite_y_map) then
        return true
    end

    local ray_angle = sprite.theta
    local depth_hor, depth_vert, delta_depth = 0, 0, 0
    local dx, dy = 0, 0
    local wall_dist_v, wall_dist_h = 0, 0
    local playet_dist_v, player_dist_h = 0, 0

    local sin_a = math.sin(ray_angle)
    local cos_a = math.cos(ray_angle)

    -- horizontal line intersections
    local y_hor = 0
    if sin_a > 0 then
        y_hor, dy = y_map + 1, 1
    else
        y_hor, dy = y_map - 1e-6, -1
    end

    depth_hor = (y_hor - oy) / sin_a
    local x_hor = ox + depth_hor * cos_a

    delta_depth = dy / sin_a
    dx = delta_depth * cos_a

    for i=1, MAX_DEPTH do
        local tile_hor_x, tile_hor_y = math.floor(x_hor), math.floor(y_hor)
        if tile_hor_x == sprite_x_map and tile_hor_y == sprite_y_map then
            player_dist_h = depth_hor
            break
        end
        if check_not_wall(tile_hor_x, tile_hor_y) == false then
            wall_dist_h = depth_hor
            break
        end
        x_hor = x_hor + dx
        y_hor = y_hor + dy
        depth_hor = depth_hor + delta_depth
    end

    -- vertical line intersections
    local x_vert = 0
    if cos_a > 0 then
        x_vert, dx = x_map + 1, 1
    else
        x_vert, dx = x_map - 1e-6, -1
    end

    depth_vert = (x_vert - ox) / cos_a
    local y_vert = oy + depth_vert * sin_a

    delta_depth = dx / cos_a
    dy = delta_depth * sin_a

    for i=1,MAX_DEPTH do
        local tile_vert_x, tile_vert_y = math.floor(x_vert), math.floor(y_vert)
        if tile_vert_x == sprite_x_map and tile_vert_y == sprite_y_map then
            playet_dist_v = depth_vert
            break
        end
        if check_not_wall(tile_vert_x, tile_vert_y) == false then
            wall_dist_v = depth_vert
            break
        end
        x_vert = x_vert + dx
        y_vert = y_vert + dy
        depth_vert = depth_vert + delta_depth
    end

    local player_dist = math.max(player_dist_h, playet_dist_v)
    local wall_dist = math.max(wall_dist_h, wall_dist_v)
    sprite.player_dist = player_dist

    if (0 < player_dist and player_dist < wall_dist) or (wall_dist == 0) then
        return true
    end
    return false
end

function initialise_npc_animation(images_path, loop)
    local animation = {}
    animation.images_path = listdir(images_path)
    animation.images = get_images_from_paths(animation.images_path)
    animation.current_image = 0
    if loop == nil then
        loop = true
    end
    animation.loop = loop
    return animation
end

function get_sprite_projection(sprite)
    local proj = SCREEN_DIST / sprite.norm_dist * sprite.SPRITE_SCALE
    sprite.proj_width, sprite.proj_height = proj * sprite.IMAGE_RATIO, proj
    sprite.sprite_half_width = math.floor(sprite.proj_width / 2)

    local height_shift = sprite.proj_height * sprite.SPRITE_HEIGHT_SHIFT
    sprite.pos_x, sprite.pos_y = sprite.screen_x - sprite.sprite_half_width, HALF_WINDOW_HEIGHT - math.floor(sprite.proj_height / 2) + height_shift
    table.insert(objects_to_render, sprite)
end

function get_sprite(sprite, dt)
    local dx = sprite.map_x - player.pos_x
    local dy = sprite.map_y - player.pos_y
    sprite.dx, sprite.dy = dx, dy
    sprite.theta = math.atan2(dy, dx)

    local delta = sprite.theta - player.angle
    if (dx > 0 and player.angle > math.pi) or (dx < 0 and dy < 0) then
        delta = delta + (2 * math.pi)
    end

    local delta_rays = delta / DELTA_ANGLE
    sprite.screen_x = (HALF_NUM_RAYS + delta_rays) * SCALE

    sprite.dist = math.sqrt(dx^2 + dy^2)
    sprite.norm_dist = sprite.dist * math.cos(delta)
    sprite.depth = sprite.norm_dist
    if -sprite.IMAGE_WIDTH < sprite.screen_x and sprite.screen_x < (WINDOW_WIDTH + sprite.IMAGE_WIDTH) and sprite.norm_dist > 0.1 then
        get_sprite_projection(sprite)
    end

    if sprite.sprite_type == SPRITE_TYPE_ANIMATED then
        sprite.time_remaining = sprite.time_remaining - dt
        if sprite.time_remaining <= 0 then
            sprite.time_remaining = sprite.animation_time
            sprite.current_image = (sprite.current_image + 1) % #sprite.images
            sprite.image = sprite.images[sprite.current_image + 1]
        end
    elseif sprite.sprite_type == SPRITE_TYPE_NPC then
        sprite.time_remaining = sprite.time_remaining - dt
        if sprite.alive then
            sprite.can_see_player = sprite_ray_cast(sprite)
            check_npc_hit(sprite)
            if sprite.pain then
                sprite.state = NPC_STATE_PAIN
            elseif sprite.can_see_player then
                sprite.player_search_trigger = true

                if sprite.player_dist < sprite.attack_dist then
                    sprite.state = NPC_STATE_ATTACK
                    npc_attack(sprite)
                else
                    sprite.state = NPC_STATE_WALK
                    npc_move(sprite, dt)
                end
            elseif sprite.player_search_trigger then
                npc_move(sprite, dt)
            else
                sprite.state = NPC_STATE_IDLE
            end
        else
            sprite.state = NPC_STATE_DEATH
        end
        if sprite.time_remaining <= 0 then
            sprite.time_remaining = sprite.animation_time
            local current_animation = get_sprite_animation(sprite)
            current_animation.current_image = current_animation.current_image + 1
            if current_animation.current_image == #current_animation.images then
                if current_animation.loop then
                    current_animation.current_image = 0
                else
                    current_animation.current_image = #current_animation.images - 1
                end
            end
            sprite.image = current_animation.images[current_animation.current_image + 1]
            if sprite.pain then
                sprite.pain = false
            end
        end
    end
end

function get_sprite_animation(sprite)
    if sprite.state == NPC_STATE_IDLE then
        return sprite.animations.animation_idle
    elseif sprite.state == NPC_STATE_ATTACK then
        return sprite.animations.animation_attack
    elseif sprite.state == NPC_STATE_PAIN then
        return sprite.animations.animation_pain
    elseif sprite.state == NPC_STATE_WALK then
        return sprite.animations.animation_walk
    else
        return sprite.animations.animation_death
    end
end

function check_npc_hit(npc)
    if player.shot and npc.can_see_player then
        if HALF_WINDOW_WIDTH - npc.sprite_half_width < npc.screen_x and npc.screen_x < HALF_WINDOW_WIDTH + npc.sprite_half_width then
            sounds.npc_pain:play()
            player.shot = false
            npc.pain = true
            npc.health = npc.health - weapon.damage
            check_npc_health(npc)
        end
    end
end

function npc_attack(sprite)
    sounds.npc_attack:play()
    local r = math.random()
    if r < sprite.accuracy then
        player_get_damage(sprite.attack_damage)
        player.hit = true
    end

end

function check_npc_health(npc)
    if npc.health < 1 then
        enemies_killed = enemies_killed + 1
        print (enemies_killed)
        npc.alive = false
        sounds.npc_death:play()
    end
end

function draw_ray_cast(sprite)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", sprite.map_x * WINDOW_SCALE, sprite.map_y * WINDOW_SCALE, 15)
    if sprite_ray_cast(sprite) then
        love.graphics.line(sprite.map_x * 100, sprite.map_y * 100, player.pos_x * 100, player.pos_y * 100)
    end

end

function npc_check_not_wall(pos_x, pos_y)
    if map[pos_x] == nil then
        return true
    end
    if map[pos_x][pos_y] == nil then
        return true
    end
    
    return false
end

function npc_move(npc, dt)
    local player_map_pos_x, player_map_pos_y = player_map_pos()
    local next_pos = get_path(math.floor(npc.map_x), math.floor(npc.map_y), player_map_pos_x, player_map_pos_y)
    local next_pos_x, next_pos_y = next_pos.x, next_pos.y
    if check_no_npc(next_pos_x, next_pos_y) then
        local angle = math.atan2(next_pos_y + 0.5 - npc.map_y, next_pos_x + 0.5 - npc.map_x)
        local dx = math.cos(angle) * npc.speed * dt
        local dy = math.sin(angle) * npc.speed * dt
        
        if npc_check_not_wall(math.floor(npc.map_x + dx*npc.size), math.floor(npc.map_y)) then
            npc.map_x = npc.map_x + dx
        end

        if npc_check_not_wall(math.floor(npc.map_x), math.floor(npc.map_y + dy*npc.size)) then
            npc.map_y = npc.map_y + dy
        end
    end
end

function sprites_update(dt)
    npc_positions = {}
    player.hit =false
    for _, sprite in ipairs(sprites) do
        if sprite.sprite_type == SPRITE_TYPE_NPC and sprite.alive == true then
            if npc_positions[math.floor(sprite.map_x)] == nil then
                npc_positions[math.floor(sprite.map_x)] = {}
            end
            npc_positions[math.floor(sprite.map_x)][math.floor(sprite.map_y)] = 1
        end
    end
    for _, sprite in ipairs(sprites) do
        get_sprite(sprite, dt)
    end
end

function draw_npc()
    for _, npc in ipairs(sprites) do
        if npc.sprite_type == SPRITE_TYPE_NPC then
            love.graphics.circle("fill", npc.map_x * WINDOW_SCALE, npc.map_y * WINDOW_SCALE, 15)
    
        end
    end
end