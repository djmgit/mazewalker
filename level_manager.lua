function check_flag_reached()
    local player_map_x, player_map_y = player_pos()
    local flag_pos_map_x, flag_pos_map_y = FLAG_POS_MAP_X, FLAG_POS_MAP_Y
    local distance_from_exit = math.sqrt((player_map_x - flag_pos_map_x)^2 + (player_map_y - flag_pos_map_y)^2)
    if distance_from_exit < 1 then
        transition_level()
    end
end

function transition_level()
    FLAG_POS_MAP_X = -1
    FLAG_POS_MAP_Y = -1
    remove_all_sprites()
    setup_world()
    init_player()
end

function remove_all_sprites()
    for index = #sprites, 1, -1 do
        table.remove(sprites, index)
    end
end