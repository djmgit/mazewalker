function gen_pos(x, y)
    local pos = {}
    pos.x = x
    pos.y = y
    return pos
end

function show()
    local new_pos = {}
    local pos = {}
    local positions = {}
    pos.x = 1
    pos.y = 2
    for _, dir in ipairs(directions) do
        new_pos = add_dir(pos, dir, true)
        if check_not_wall(new_pos.x, new_pos.y) then
            table.insert(positions, new_pos)
        end
    end
end

directions = {}
table.insert(directions, {["x"]=-1, ["y"]=0})
table.insert(directions, {["x"]=0, ["y"]=-1})
table.insert(directions, {["x"]=1, ["y"]=0})
table.insert(directions, {["x"]=0, ["y"]=1})
table.insert(directions, {["x"]=-1, ["y"]=-1})
table.insert(directions, {["x"]=1, ["y"]=-1})
table.insert(directions, {["x"]=1, ["y"]=1})
table.insert(directions, {["x"]=-1, ["y"]=1})

function check_no_npc(pos_x, pos_y)
    if npc_positions[pos_x] == nil then
        return true
    end
    if npc_positions[pos_x][pos_y] == nil then
        return true
    end
    return false
end

function add_dir(pos, dir, show)
    local new_pos = {}
    new_pos.x = pos.x + dir.x
    new_pos.y = pos.y + dir.y
    return new_pos
end

function post_to_key(pos)
    return "" .. tostring(pos.x) .. "_" .. tostring(pos.y)
end

function key_to_pos(key)
    local separator = string.find(key, "_")
    local pos = {}
    pos.x = tonumber(string.sub(key, 1, separator-1))
    pos.y = tonumber(string.sub(key, separator+1))
    return pos
end

function get_path(start_x, start_y, goal_x, goal_y)
    local visited = bfs(start_x, start_y, goal_x, goal_y)
    local goal_pos = {}
    goal_pos.x = goal_x
    goal_pos.y = goal_y
    local step = visited[post_to_key(goal_pos)]
    local path = {}

    table.insert(path, goal_pos)
    while step ~= nil do
        if step.x == start_x and step.y == start_y then
            break
        end
        table.insert(path, step)
        step = visited[post_to_key(step)]
    end
    return path[#path]

end

function bfs(start_x, start_y, goal_x, goal_y)
    local start_pos = {}
    start_pos.x = start_x
    start_pos.y = start_y
    local queue = {}
    local visited = {}
    table.insert(queue, start_pos)

    while #queue ~= 0 do
        local curr_pos = table.remove(queue, 1)
        if (curr_pos.x == goal_x) and (curr_pos.y == goal_y) then
            break
        end
        local reachable_positions = graph[curr_pos.x][curr_pos.y]
        if reachable_positions then
            for _, reachable_pos in ipairs(reachable_positions) do
                if visited[post_to_key(reachable_pos)] == nil and check_no_npc(reachable_pos.x, reachable_pos.y) then
                    table.insert(queue, reachable_pos)
                    visited[post_to_key(reachable_pos)] = curr_pos
                end
            end
        end
    end
    return visited

end

function get_rechable_positions(x, y)
    local positions = {}
    local pos = {}
    pos.x = x
    pos.y = y
    local new_pos = {}
    for _, dir in ipairs(directions) do
        new_pos = add_dir(pos, dir)
        if check_not_wall(new_pos.x, new_pos.y) then
            table.insert(positions, new_pos)
        end
    end
    return positions
end


function get_graph()
    local graph = {}
    local reachable_positions = nil
    for y, row in ipairs(mini_map) do
        for x, column in ipairs(row) do
            if column == 0 then
                reachable_positions = get_rechable_positions(x-1, y-1)
                if graph[x-1] == nil then
                    graph[x-1] = {}
                end
                graph[x-1][y-1] = reachable_positions
            end
        end
    end
    return graph
end
