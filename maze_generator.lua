wall = 'w'
cell = 'c'
unvisited = "u"
entry = "s"
flag = "f"
door = "d"

function get_maze(width, height)
    local maze_raw = __get_maze(width, height)
    local maze = customise_maze(maze_raw, width, height)
    local occupied = {}
    occupied[pos_to_key(maze.entry_pos[1], maze.entry_pos[2])] = 1
    occupied[pos_to_key(maze.exit_pos[1], maze.exit_pos[2])] = 1
    local npcs = place_npcs(maze, width, height, occupied)
    maze.npcs = npcs
    local lights = place_lights(maze, width, height, occupied)
    maze.lights = lights
    local candles = place_candles(maze, width, height, occupied)
    maze.candles = candles
    print ("number of npcs : ", #maze.npcs)
    print ("number of lights : ", #maze.lights)
    print ("number of candles : ", #maze.candles)
    return maze
end

function __get_maze(width, height)
    local maze = nil
    for i=1, 20 do
        maze = generate_maze(width, height)
        if check_maze(maze, width, height) then
            return maze
        end
    end

    return maze
end

function place_npcs(maze, width, height, occupied)
    local npcs = {}
    for i=1, height do
        for j=1, width do
            if occupied[pos_to_key(i, j)] == nil and can_place_npc(maze, {i, j}, width, height, occupied) then
                table.insert(npcs, {j, i})
                occupied[pos_to_key(i, j)] = 1
                if maze.maze[i][j] ~= 0 then
                    print (i, j)
                end
            end
        end
    end

    return npcs
end

function place_candles(maze, width, height, occupied)
    local candles = {}
    for i=1, height do
        for j=1, width do
            if can_place_candle(maze, {i, j}, width, height, occupied) then
                occupied[pos_to_key(i, j)] = 1
                table.insert(candles, {j, i})
            end
        end
    end

    return candles
end

function can_place_candle(maze, pos, width, height, occupied)
    if math.random(1,10) > 4 then
        return false
    end
    if occupied[pos_to_key(pos[1], pos[2])] == 1 then
        return false
    end
    if maze.maze[pos[1]][pos[2]] ~= 0 then
        return false
    end
    if pos[1] == 1 or pos[1] == height then
        return false
    end
    if pos[2] == 1 or pos[2] == width then
        return false
    end
    if (maze.maze[pos[1]][pos[2]-1] == 1 and maze.maze[pos[1]-1][pos[2]] == 1)
       or (maze.maze[pos[1]-1][pos[2]] == 1 and maze.maze[pos[1]][pos[2]+1] == 1)
       or (maze.maze[pos[1]][pos[2]-1] == 1 and maze.maze[pos[1]+1][pos[2]] == 1)
       or (maze.maze[pos[1]+1][pos[2]] == 1 and maze.maze[pos[1]][pos[2]+1] == 1) then
            return true
       end
end

function place_lights(maze, width, height, occupied)
    local lights = {}
    for i=1, height do
        for j=1, width do
            if can_place_light(maze, {i, j}, width, height, occupied) then
                occupied[pos_to_key(i, j)] = 1
                table.insert(lights, {j, i})
            end
        end
    end

    return lights
end

function can_place_light(maze, pos, width, height, occupied)
    if math.random(1,10) > 4 then
        return false
    end
    if occupied[pos_to_key(pos[1], pos[2])] == 1 then
        return false
    end
    if maze.maze[pos[1]][pos[2]] ~= 0 then
        return false
    end
    if pos[1] == 1 or pos[1] == height then
        return false
    end
    if pos[2] == 1 or pos[2] == width then
        return false
    end
    if maze.maze[pos[1]][pos[2]-1] == 1 and maze.maze[pos[1]][pos[2]+1] == 0 and maze.maze[pos[1]][pos[2]+2] == 0
       or maze.maze[pos[1]][pos[2]+1] == 1 and maze.maze[pos[1]][pos[2]-1] == 0 and maze.maze[pos[1]][pos[2]-2] == 0
       or maze.maze[pos[1]-1][pos[2]] == 1 and maze.maze[pos[1]+1][pos[2]] == 0 and maze.maze[pos[1]+2][pos[2]] == 0
       or maze.maze[pos[1]+1][pos[2]] == 1 and maze.maze[pos[1]-1][pos[2]] == 0 and maze.maze[pos[1]-2][pos[2]] == 0 then
            return true
       end
end

function can_place_npc(maze, pos, width, height, occupied)
    if maze.maze[pos[1]][pos[2]] ~= 0 then
        return false
    end

    if pos[1] == 2 or pos[1] == height-1 then
        return false
    end
    if pos[2] == 2 or pos[2] == width-1 then
        return false
    end
    if math.abs(maze.entry_pos[1] - pos[1]) < 5 then
        return false
    end
    if math.abs(maze.entry_pos[2] - pos[2]) < 5 then
        return false
    end

    if maze.maze[pos[1]][pos[2]+1] == 0 and maze.maze[pos[1]][pos[2]-1] == 0
       and maze.maze[pos[1]-1][pos[2]] == 0 and maze.maze[pos[1]+1][pos[2]] == 0
       and  occupied[pos_to_key(pos[1], pos[2]+1)] == nil and occupied[pos_to_key(pos[1], pos[2]-1)] == nil
       and occupied[pos_to_key(pos[1]-1, pos[2])] == nil and occupied[pos_to_key(pos[1]+1, pos[2])] == nil
       and math.random(1, 10) < 2 then
       --and maze[pos[1]-1][pos[2]-1] == 0 and maze[pos[1]-1][pos[2]+1] == 0
       --and maze[pos[1]+1][pos[2]-1] == 0 and maze[pos[1]+1][pos[2]+1] == 0 then
        return true
    end
    return false
end

function check_maze(maze, width, height)
    local total_cells = width * height
    local free_cells = 0
    for i=1, height do
        for j=1, width do
            if maze[i][j] == cell then
                free_cells = free_cells + 1
            end
        end
    end

    local free_ratio = free_cells / total_cells
    if free_ratio < 0.6 then
        return false
    end
    local entry_door = {}
    local exit_door = {}
    for i=1, width do
        if maze[2][i] == cell then
            entry_door = {1, i}
            break
        end
    end

    for i=width, 1, -1 do
        if maze[height-1][i] == cell then
            exit_door = {height, i}
            break
        end
    end

    if (#entry_door == 0) or (#exit_door == 0) then
        return false
    end

    return true
end

function generate_maze(width, height)
    local maze = {}
    maze = init_maze(maze, width, height)
    

    local starting_width = math.random(1, width)
    local starting_height = math.random(1, height)

    if starting_height == 1 then
        starting_height = starting_height + 1
    end
    if starting_height == height then
        starting_height = starting_height - 1
    end
    if starting_width == 1 then
        starting_width = starting_width + 1
    end
    if starting_width == width then
        starting_width = starting_width - 1
    end

    local walls = {}
    maze[starting_height][starting_width] = cell
    table.insert(walls, {starting_height-1, starting_width})
    table.insert(walls, {starting_height+1, starting_width})
    table.insert(walls, {starting_height, starting_width-1})
    table.insert(walls, {starting_height, starting_width+1})
    maze[starting_height-1][starting_width] = wall
    maze[starting_height+1][starting_width] = wall
    maze[starting_height][starting_width-1] = wall
    maze[starting_height][starting_width+1] = wall

    while #walls ~= 0 do
        local rand_wall = walls[math.random(1, #walls)]
        
        if rand_wall[2] ~= 1 and rand_wall[2] ~= width then
            if maze[rand_wall[1]][rand_wall[2]-1] == unvisited and maze[rand_wall[1]][rand_wall[2]+1] == cell then
                local s_cells = surrounding_cells(maze, rand_wall, height, width)
                if s_cells < 2 then
                    maze[rand_wall[1]][rand_wall[2]] = cell
                    
                    if rand_wall[1] ~= 1 then
                        if maze[rand_wall[1]-1][rand_wall[2]] ~= cell then
                            maze[rand_wall[1]-1][rand_wall[2]] = wall
                        end
                        if not in_walls(walls, {rand_wall[1]-1, rand_wall[2]}) then
                            table.insert(walls, {rand_wall[1]-1, rand_wall[2]})
                        end
                    end
                    if rand_wall[1] ~= height then
                        if maze[rand_wall[1]+1][rand_wall[2]] ~= cell then
                            maze[rand_wall[1]+1][rand_wall[2]] = wall
                        end
                        if not in_walls(walls, {rand_wall[1]+1, rand_wall[2]}) then
                            table.insert(walls, {rand_wall[1]+1, rand_wall[2]})
                        end
                    end
                    if rand_wall[2] ~= 1 then
                        if maze[rand_wall[1]][rand_wall[2]-1] ~= cell then
                            maze[rand_wall[1]][rand_wall[2]-1] = wall
                        end
                        if not in_walls(walls, {rand_wall[1], rand_wall[2]-1}) then
                            table.insert(walls, {rand_wall[1], rand_wall[2]-1})
                        end
                    end
                end
                remove_wall(walls, rand_wall)
                goto prims_iter_done
            end
        end
        if rand_wall[2] ~= width and rand_wall[2] ~= 1 then
            if maze[rand_wall[1]][rand_wall[2]+1] == unvisited and maze[rand_wall[1]][rand_wall[2]-1] == cell then
                local s_cells = surrounding_cells(maze, rand_wall, height, width)
                if s_cells < 2 then
                    maze[rand_wall[1]][rand_wall[2]] = cell

                    if rand_wall[2] ~= width then
                        if maze[rand_wall[1]][rand_wall[2]+1] ~= cell then
                            maze[rand_wall[1]][rand_wall[2]+1] = cell
                        end
                        if not in_walls(walls, {rand_wall[1], rand_wall[2]+1}) then
                            table.insert(walls, {rand_wall[1], rand_wall[2]+1})
                        end
                    end
                    if rand_wall[1] ~= 1 then
                        if maze[rand_wall[1]-1][rand_wall[2]] ~= cell then
                            maze[rand_wall[1]-1][rand_wall[2]] = cell
                        end
                        if not in_walls(walls, {rand_wall[1]-1, rand_wall[2]}) then
                            table.insert(walls, {rand_wall[1]-1, rand_wall[2]})
                        end
                    end
                    if rand_wall[1] ~= height then
                        if maze[rand_wall[1]+1][rand_wall[2]] ~= cell then
                            maze[rand_wall[1]+1][rand_wall[2]] = cell
                        end
                        if not in_walls(walls, {rand_wall[1]+1, rand_wall[2]}) then
                            table.insert(walls, {rand_wall[1]+1, rand_wall[2]})
                        end
                    end
                end
                remove_wall(walls, rand_wall)
                goto prims_iter_done
            end
        end
        if rand_wall[1] ~= 1  and rand_wall[1] ~= height then
            if maze[rand_wall[1]-1][rand_wall[2]] == unvisited and maze[rand_wall[1]+1][rand_wall[2]] == cell then
                local s_cells = surrounding_cells(maze, rand_wall, height, width)
                if s_cells < 2 then
                    maze[rand_wall[1]][rand_wall[2]] = cell
                    if rand_wall[1] ~= 1 then
                        if maze[rand_wall[1]-1][rand_wall[2]] ~= cell then
                            maze[rand_wall[1]-1][rand_wall[2]] = cell
                        end
                        if not in_walls(walls, {rand_wall[1]-1, rand_wall[2]}) then
                            table.insert(walls, {rand_wall[1]-1, rand_wall[2]})
                        end
                    end
                    if rand_wall[2] ~= width then
                        if maze[rand_wall[1]][rand_wall[2]+1] ~= cell then
                            maze[rand_wall[1]][rand_wall[2]+1] = cell
                        end
                        if not in_walls(walls, {rand_wall[1], rand_wall[2]+1}) then
                            table.insert(walls, {rand_wall[1], rand_wall[2]+1})
                        end
                    end
                    if rand_wall[2] ~= 1 then
                        if maze[rand_wall[1]][rand_wall[2]-1] ~= cell then
                            maze[rand_wall[1]][rand_wall[2]-1] = wall
                        end
                        if not in_walls(walls, {rand_wall[1], rand_wall[2]-1}) then
                            table.insert(walls, {rand_wall[1], rand_wall[2]-1})
                        end
                    end
                end
                remove_wall(walls, rand_wall)
                goto prims_iter_done
            end
        end
        if rand_wall[1] ~= height and rand_wall[1] ~= 1 then
            if maze[rand_wall[1]+1][rand_wall[2]] == unvisited and maze[rand_wall[1]-1][rand_wall[2]] == cell then
                local s_cells = surrounding_cells(maze, rand_wall, height, width)
                if s_cells < 2 then
                    maze[rand_wall[1]][rand_wall[2]] = cell
                    if rand_wall[1] ~= height then
                        if maze[rand_wall[1]+1][rand_wall[2]] ~= cell then
                            maze[rand_wall[1]+1][rand_wall[2]] = cell
                        end
                        if not in_walls(walls, {rand_wall[1]+1, rand_wall[2]}) then
                            table.insert(walls, {rand_wall[1]+1, rand_wall[2]})
                        end
                    end
                    if rand_wall[2] ~= width then
                        if maze[rand_wall[1]][rand_wall[2]+1] ~= cell then
                            maze[rand_wall[1]][rand_wall[2]+1] = cell
                        end
                        if not in_walls(walls, {rand_wall[1], rand_wall[2]+1}) then
                            table.insert(walls, {rand_wall[1], rand_wall[2]+1})
                        end
                    end
                    if rand_wall[2] ~= 1 then
                        if maze[rand_wall[1]][rand_wall[2]-1] ~= cell then
                            maze[rand_wall[1]][rand_wall[2]-1] = wall
                        end
                        if not in_walls(walls, {rand_wall[1], rand_wall[2]-1}) then
                            table.insert(walls, {rand_wall[1], rand_wall[2]-1})
                        end
                    end
                end
                remove_wall(walls, rand_wall)
                goto prims_iter_done
            end
        end
        remove_wall(walls, rand_wall)
        ::prims_iter_done::
    end

    for i=1, height do
        for j=1, width do
            if maze[i][j] == unvisited then
                maze[i][j] = wall
            end
        end
    end

    for i=1, height do
        maze[i][1] = wall
        maze[i][width] = wall
    end

    for i=1, width do
        maze[1][i] = wall
        maze[height][i] = wall
    end

    return maze

end

function customise_maze(maze, width, height)
    local entry_pos = {}
    local exit_pos = {}
    local entry_door = {}
    local exit_door = {}

    for i=1, width do
        if maze[2][i] == cell then
            entry_pos = {2, i}
            maze[1][i] = door
            entry_door = {1, i}
            break
        end
    end

    for i=width, 1, -1 do
        if maze[height-1][i] == cell then
            exit_pos = {height-1, i}
            maze[height][i] = door
            exit_door = {height, i}
            break
        end
    end

    do_flood_fill(maze, width, height)
    maze[entry_door[1]][entry_door[2]] = math.random(5, 9)
    maze[exit_door[1]][exit_door[2]] = math.random(5, 9)

    local maze_holder = {}
    maze_holder.maze = pre_process_maze(maze, width, height)
    maze_holder.entry_pos = entry_pos
    maze_holder.exit_pos = exit_pos

    return maze_holder
end

function pre_process_maze(maze, width, height)
    for i=1, height do
        for j=1, width do
            if maze[i][j] == cell then
                maze[i][j] = 0
            end
        end
    end
    return maze
end

function do_flood_fill(maze, width, height)
    local wall_type = 0
    for i=1, height do
        for j=1, width do
            if maze[i][j] == wall then
                flood_fill(maze, width, height, {i, j}, wall_type + 1)
                wall_type = wall_type + 1
                wall_type = wall_type % 4
            end
        end
    end
end

function flood_fill(maze, width, height, start_pos, wall_type)
    local queue = {}
    local visited = {}
    table.insert(queue, start_pos)

    while #queue ~= 0 do
        local pos = table.remove(queue, 1)
        if maze[pos[1]][pos[2]] == wall then
            maze[pos[1]][pos[2]] = wall_type
            visited[pos_to_key(pos[1], pos[2])] = 1
            local neighbours = get_neighbours(maze, width, height, pos)
            for i=1, #neighbours do
                local neighbour = neighbours[i]
                if maze[neighbour[1]][neighbour[2]] == wall and visited[pos_to_key(neighbour[1], neighbour[2])] == nil then
                    table.insert(queue, neighbour)
                end
            end
        end
    end
end

function get_neighbours(maze, width, height, pos)
    local neighbours = {}
    if pos[2] > 1 then
        if maze[pos[1]][pos[2]-1] == wall then
            table.insert(neighbours, {pos[1], pos[2]-1})
        end
    end
    if pos[2] < width then
        if maze[pos[1]][pos[2]+1] == wall then
            table.insert(neighbours, {pos[1], pos[2]+1})
        end
    end
    if pos[1] > 1 then
        if maze[pos[1]-1][pos[2]] == wall then
            table.insert(neighbours, {pos[1]-1, pos[2]})
        end
    end
    if pos[1] < height then
        if maze[pos[1]+1][pos[2]] == wall then
            table.insert(neighbours, {pos[1]+1, pos[2]})
        end
    end
    return neighbours
    
end

function surrounding_cells(maze, rand_wall, height, width)
    local s_cells = 0
    if rand_wall[1] ~= 1 then
        if maze[rand_wall[1]-1][rand_wall[2]] == cell then
            s_cells = s_cells + 1
        end
    end
    if rand_wall[1] ~= height then
        if maze[rand_wall[1]+1][rand_wall[2]] == cell then
            s_cells = s_cells + 1
        end
    end
    if rand_wall[2] ~= 0 then
        if maze[rand_wall[1]][rand_wall[2]-1] == cell then
            s_cells = s_cells + 1
        end
    end
    if rand_wall[2] ~= width then
        if maze[rand_wall[1]][rand_wall[2]+1] == cell then
            s_cells = s_cells + 1
        end
    end

    return s_cells

end

function in_walls(walls, pos)
    for _, wall in ipairs(walls) do
        if wall[1] == pos[1] and wall[2] == pos[2] then
            return true
        end
    end

    return false
end

function remove_wall(walls, pos)
    for i, wall in pairs(walls) do
        if wall[1] == pos[1] and wall[2] == pos[2] then
            table.remove(walls, i)
            break
        end
    end
end

function pos_to_key(height, width)
    return tostring(height)..':'..tostring(width)
end

function key_to_pos(key)
    local delim_pos = string.find(key, ":")
    local height = string.sub(key, 1, delim_pos-1)
    local width = string.sub(key, delim_pos+1)
    return height, width
end

function init_maze(maze, width, height)
    for _=1, height do
        local current_row = {}
        for _=1, width do
            table.insert(current_row, unvisited)
        end
        table.insert(maze, current_row)
    end
    return maze
end

function print_maze(maze, width, height)
    for i=1, height do
        local row = ""
        for j=1, width do
            local item = maze[i][j]
            if item == wall then
                item = "\x1b[1;31;40m"..wall
            end
            if item == cell then
                item = "\x1b[1;32;40m"..cell
            end
            if item == entry then
                item = "\x1b[1;34;40m"..cell
            end
            if item == flag then
                item = "\x1b[1;35;40m"..cell
            end
            row = row..item.." "
        end
        print (row)
    end
end
