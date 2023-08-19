-- this module is responsible for performing ray casting and coming up with the positions of the objects to
-- render. This was an attempt to understand ray casting first hand. It is indeed an amazing technology
-- which invlolves brilliant use of trigonometry and geometry in general.

-- I have skimmed through lots of online resources to understand the process/alogrithm. Do check the
-- README.md for all the references.

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
    -- Though you might see lots of articles online mentioning that raycasting is the simplest
    -- special case scenario of raytracing, and it might in deed be easy to understand the process
    -- but not so trivial when it comes to actually implementing it.
    -- Since lots of people have already tried explaining the process online, I wont dive into the process
    -- rather I will give an overview of what ray tracing is.

    -- * Its a process of project 2D object into 3D or rather create an illusion of 3D using 2D sprites.
    --   That is the reason raycasting is not considered pure 3D rendering, rather its a pseudo 3D rendering
    --   procees.
    -- * First you start with a map or rather a grid, where some cells/blocks are empty and some are non-empty.
    --   The non empty ones are walls of our maze.
    -- * Next we need to decide the field of view of our player. Field of view is nothing but an angle. The part
    --   of the world that falls within this angle is what our player (or the camera, or we) see and we only render
    --   that much on our screen. Usually pi/3 or 60 degree is a good choice for field of view.
    -- * Next we need to decide at what distance from the camera or the player is the screen located where the objects
    --   will be rendered. 
    --[[                                        A           N          B
                                                 ----------------------- this is the screen
                                                  \         |         /
                                                   \        |        /
                                                    \       |       /
                                                     \      |      /
                                                      \     |     /
                                                       \    |    /
                                                        \   |   /
                                                         \  |  /
                                                          \ | /
                                                           \|/
                                                            O
    ]]
    --   If O is our player and AB is the screen then ON is the screen distance and angle AOB is the field of view and angle NOB is
    --   half of the field of view. Now its clear that AB is nothing but our screen width, that is width of our game window or viewport
    --   whose value we know. And angle NOB is also known. Now tan NOB is NB/ON and hece screen distane or ON is half of screen width
    --   divided by tan of half field of view of FOV.
    --   Hence we have screen dist is half screen width / tan fov/2
    -- * Now comes the interesting part, for every angle within the FOV we cast a ray into the world and try to find the position of the
    --   wall where it hits first and comes to a stop. Now sending a ray for every angle might not be great from the performance side of
    --   the things so we send FOV/2 number of rays and scale whatever we draw accordingly.
    -- * This part I will explain is short and would request to look into the code for details. Now we need to find where does the ray collide
    --   with a wall. There can be two cases, collision with a vertiical surface of a wall or horizontal surface of the wal.
    --[[

                                                ----------------------
                                                    |    |  w |
                                                ----------------------
                                                    |  w |    |
                                                ----------------------
         Lets say we are talking about a grid like the above, every wall (w represents wall) has two vertical surfaces and two
         horizontal surfaces. Now a ray can hit only one vertical surface or one horizontal surface.
    ]]

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
