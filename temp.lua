function gen_pos(x, y)
    local pos = {}
    pos.x = x
    pos.y = y
    return pos
end

function show()
    local pos = {}
    local positions = {}
    pos = gen_pos(1,2)
    table.insert(positions, pos)
    pos = gen_pos(3,4)
    table.insert(positions, pos)

    for _, p in ipairs(positions) do
        print (p)
    end
end

show()
