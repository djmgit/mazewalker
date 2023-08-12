function check_flag_reached()
    local player_map_x, player_map_y = player_map_pos()
    local flag_pos_map_x, flag_pos_map_y = FLAG_POS_MAP_X, FLAG_POS_MAP_Y
    if player_map_x == flag_pos_map_x and player_map_y == flag_pos_map_y then
        flag_taken = true
        print ("player", player_map_x, player_map_y, "flag", flag_pos_map_x, flag_pos_map_y)
        print ("level done")
        transition_level()
    end
end

function transition_level()
    print ("level done")
    FLAG_POS_MAP_X = -1
    FLAG_POS_MAP_Y = -1
    remove_all_sprites()
end

function remove_all_sprites()
    for index = #sprites, 1, -1 do
        table.remove(sprites, index)
    end
end