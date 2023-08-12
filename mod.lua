function ray_casting_update()
    ray_cast()
    get_objects_to_render()
end

function get_objects_to_render()
    objects_to_render = {}
    for ray_index, ray_cast_obj in ipairs(ray_casting_result) do
        local ray = ray_index - 1
        local texture = wall_textures[ray_cast_obj.texture]
        local render_object = {}
        render_object.object_type = OBJECT_TYPE_WALL

        if ray_cast_obj.projection_height < WINDOW_HEIGHT then
            local wall_column = love.graphics.newQuad(ray_cast_obj.offset*(texture:getWidth() - SCALE), 0, SCALE, texture:getHeight(), texture:getWidth(), texture:getHeight())
            local wall_pos = {}
            wall_pos.pos_x = ray * SCALE
            wall_pos.pos_y = HALF_WINDOW_HEIGHT - math.floor(ray_cast_obj.projection_height / 2)

            render_object.depth = ray_cast_obj.depth
            render_object.wall_column = wall_column
            render_object.wall_pos = wall_pos
            render_object.texture = ray_cast_obj.texture
            render_object.projection_height = ray_cast_obj.projection_height
            render_object.scale_by = ray_cast_obj.projection_height
        else
            local texture_height = texture:getHeight() * WINDOW_HEIGHT / ray_cast_obj.projection_height
            local wall_column = love.graphics.newQuad(ray_cast_obj.offset*(texture:getWidth() - SCALE), math.floor(texture:getHeight() / 2) - math.floor(texture_height / 2), SCALE, texture_height, texture:getWidth(), texture:getHeight())
            local wall_pos = {}
            wall_pos.pos_x = ray * SCALE
            wall_pos.pos_y = 0

            render_object.depth = ray_cast_obj.depth
            render_object.wall_column = wall_column
            render_object.wall_pos = wall_pos
            render_object.texture = ray_cast_obj.texture
            render_object.projection_height = ray_cast_obj.projection_height
            render_object.scale_by = WINDOW_HEIGHT
            render_object.texture_height = texture_height
        end
        table.insert(objects_to_render, render_object)

    end

end

function ray_cast()
    local ox, oy  = player_pos()
    local x_map, y_map = player_map_pos()

    local ray_angle = player.angle - HALF_FOV + 1e-4
    local depth_hor, depth_vert, delta_depth = 0, 0, 0
    local dx, dy = 0, 0
    local texture_hor, texture_vert, texture = 0, 0, 0
    local offset = 0
    ray_casting_result = {}
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
            offset = y_vert
            if cos_a <= 0 then
                offset = 1 - y_vert
            end
        else
            depth = depth_hor
            texture = texture_hor
            x_hor = x_hor % 1
            offset = 1 - x_hor
            if sin_a <= 0 then
                offset = x_hor
            end

        end

        depth = depth * math.cos(player.angle - ray_angle)
        local projection_height = SCREEN_DIST / (depth + 1e-4)
        local ray_cast_obj = {}
        ray_cast_obj.depth = depth
        ray_cast_obj.projection_height = projection_height
        ray_cast_obj.texture = texture
        ray_cast_obj.offset = offset
        table.insert(ray_casting_result, ray_cast_obj)
    
        ray_angle = ray_angle + DELTA_ANGLE
    end
end
