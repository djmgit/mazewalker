
function ray_cast()
    local ox, oy  = player_pos()
    local x_map, y_map = player_map_pos()

    local ray_angle = player.angle - HALF_FOV + 1e-4
    local depth_hor, depth_vert, delta_depth = 0, 0, 0
    local dx, dy = 0, 0
    local texture_hor, texture_vert, texture = 0, 0, 0
    local offset = 0
    for ray = 0,NUM_RAYS-1 do
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
            if check_not_wall(tile_hor_x, tile_hor_y) == false then
                texture_hor = map[tile_hor_x][tile_hor_y]
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
            if check_not_wall(tile_vert_x, tile_vert_y) == false then
                texture_vert = map[tile_vert_x][tile_vert_y]
                break
            end
            x_vert = x_vert + dx
            y_vert = y_vert + dy
            depth_vert = depth_vert + delta_depth
        end

        local depth = 0
        if depth_vert < depth_hor then
            depth = depth_vert
            texture = texture_vert
            y_vert = y_vert % 1
        else
            depth = depth_hor
        end

        depth = depth * math.cos(player.angle - ray_angle)

        local projection_height = SCREEN_DIST / (depth + 1e-4)
        local color_scale = 1 + depth ^ 5 * 0.00002
        love.graphics.setColor(1 / color_scale, 1 / color_scale, 1 / color_scale)
        love.graphics.rectangle("fill", ray * SCALE, HALF_WINDOW_HEIGHT - math.floor(projection_height/2), SCALE, projection_height)


        --love.graphics.setColor(1, 1, 0)
        --love.graphics.line(ox*WINDOW_SCALE, oy*WINDOW_SCALE, ox*WINDOW_SCALE + depth*cos_a*WINDOW_SCALE, oy*WINDOW_SCALE+depth*sin_a*WINDOW_SCALE)
    
        ray_angle = ray_angle + DELTA_ANGLE
    end
end

function ray_casting_update(dt)
    ray_cast()
end
