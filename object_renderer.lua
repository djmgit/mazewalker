function object_renderer_draw()
    draw_background()
    render_game_objects()
    if player.hit == true then
        love.graphics.draw(blood_screen, 0, 0)
    end
    player_draw_health()
    draw_enemies_killed()
    draw_distance_from_exit()
    if GAME_OVER then
        love.graphics.draw(game_over_screen, 0, 0)
    end
end

function draw_enemies_killed()
    local x_offset = 600
    local enemies_killed_str = tostring(enemies_killed)
    local enemy_icon = love.graphics.newImage("resources/sprites/npc/caco_demon/pain/0.png")
    love.graphics.draw(enemy_icon, x_offset, 0, nil, ENEMY_ICON_SCALE/enemy_icon:getWidth(), ENEMY_ICON_SCALE/enemy_icon:getHeight())
    x_offset = x_offset + 120
    for dpos=1, #enemies_killed_str do
        local dchar = string.sub(enemies_killed_str, dpos, dpos)
        local d_texture = digits[tonumber(dchar)+1]
        love.graphics.draw(d_texture, x_offset + (dpos-1) * DIGIT_SIZE, 0, nil, DIGIT_SIZE/d_texture:getWidth(), DIGIT_SIZE/d_texture:getHeight())
    end
end

function draw_distance_from_exit()
    local x_offset = 1200
    local exit_dist = math.sqrt((player.pos_x - FLAG_POS_MAP_X)^2 + (player.pos_y - FLAG_POS_MAP_Y)^2)
    exit_dist = math.floor(exit_dist)
    local exit_dist_str = tostring(exit_dist)
    local exit_icon = love.graphics.newImage("resources/textures/6.png")
    love.graphics.draw(exit_icon, x_offset, 0, nil, EXIT_ICON_SCALE/exit_icon:getWidth(), EXIT_ICON_SCALE/exit_icon:getHeight())
    x_offset = x_offset + 120
    for dpos=1, #exit_dist_str do
        local dchar = string.sub(exit_dist_str, dpos, dpos)
        local d_texture = digits[tonumber(dchar)+1]
        love.graphics.draw(d_texture, x_offset + (dpos-1) * DIGIT_SIZE, 0, nil, DIGIT_SIZE/d_texture:getWidth(), DIGIT_SIZE/d_texture:getHeight())
    end
end

function render_game_objects()
    --[[
        This function is used for drawing sprites/textures on screen. This is called by love.draw in every iteration.
        Before drawing we need to sort the objects by their distances from the player. The object farthest from the player
        should be draws first and the object nearest last.
        Also every object should be scaled to the correct height and width before drawing. Although this is a known thing
        still scaling is done using this simple formula:
        scale = target quantity / original quantity
    ]]
    table.sort(objects_to_render, function(t1, t2) return t1.depth > t2.depth end)
    for ray, render_object in ipairs(objects_to_render) do
        local wall_pos = render_object.wall_pos
        local object_type = render_object.object_type
        if object_type == OBJECT_TYPE_WALL then
            if render_object.projection_height < WINDOW_HEIGHT then
                love.graphics.draw(wall_textures[render_object.texture], render_object.wall_column, wall_pos.pos_x, wall_pos.pos_y, nil, SCALE, render_object.projection_height/wall_textures[render_object.texture]:getHeight())
            else
                love.graphics.draw(wall_textures[render_object.texture], render_object.wall_column, wall_pos.pos_x, wall_pos.pos_y, nil, SCALE, WINDOW_HEIGHT/render_object.texture_height)
            end
        end
        if object_type == OBJECT_TYPE_SPRITE then
            love.graphics.draw(render_object.image, render_object.pos_x, render_object.pos_y, nil, render_object.proj_width / render_object.image:getWidth(), render_object.proj_height / render_object.image:getHeight())
        end
    end
end

function  draw_background()
    sky_offset = (sky_offset + 0.8 * player.rel) % WINDOW_WIDTH
    love.graphics.draw(sky_texture, -sky_offset, 0, nil, WINDOW_WIDTH / sky_texture:getWidth(), HALF_WINDOW_HEIGHT / sky_texture:getHeight())
    love.graphics.draw(sky_texture, -sky_offset + WINDOW_WIDTH, 0, nil, WINDOW_WIDTH / sky_texture:getWidth(), HALF_WINDOW_HEIGHT / sky_texture:getHeight())
    love.graphics.setColor(30/255, 30/255, 30/255)
    love.graphics.rectangle("fill", 0, HALF_WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setColor(1, 1, 1)
end

function load_wall_textures()
    for index = 1, 9 do
        table.insert(wall_textures, love.graphics.newImage('resources/textures/'..index..'.png'))
    end
    sky_texture = love.graphics.newImage('resources/textures/sky.png')
    blood_screen = love.graphics.newImage('resources/textures/blood_screen.png')
    for item=0, 10 do
        table.insert(digits, love.graphics.newImage('resources/textures/digits/'..tostring(item)..".png"))
    end
    game_over_screen = love.graphics.newImage('resources/textures/game_over.png')
end
