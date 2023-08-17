function love.load()
    math.randomseed(os.time())
    WINDOW_WIDTH = 1600
    WINDOW_HEIGHT = 900
    MAZE_HEIGHT = 50
    MAZE_WIDTH = 50
    HALF_WINDOW_WIDTH = math.floor(WINDOW_WIDTH / 2)
    HALF_WINDOW_HEIGHT = math.floor(WINDOW_HEIGHT / 2)
    WINDOW_SCALE = 100
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    
    FOV = math.pi / 3
    HALF_FOV = FOV / 2
    NUM_RAYS = math.floor(WINDOW_WIDTH / 2)
    HALF_NUM_RAYS = math.floor(NUM_RAYS / 2)
    DELTA_ANGLE = FOV / NUM_RAYS
    MAX_DEPTH = 50
    SCALE = WINDOW_WIDTH / NUM_RAYS
    SCREEN_DIST = HALF_WINDOW_WIDTH / math.tan(HALF_FOV)
    PLAYER_SCALE = 8
    PLAYER_MAX_HEALTH = 100
    OBJECT_TYPE_WALL = "WALL"
    OBJECT_TYPE_SPRITE = "SPRITE"
    SPRITE_TYPE_STATIC = "STATIC"
    SPRITE_TYPE_ANIMATED = "ANIMATED"
    SPRITE_TYPE_NPC = "NPC"
    NPC_STATE_IDLE = "NPC_STATE_IDLE"
    NPC_STATE_WALK = "NPC_STATE_WALK"
    NPC_STATE_PAIN = "NPC_STATE_PAIN"
    NPC_STATE_DEATH = "NPC_STATE_DEATH"
    NPC_STATE_ATTACK = "NPC_STATE_ATTACK"
    NPC_TYPE_SOLDIER = "NPC_TYPE_SOLDIER"
    NPC_TYPE_CYBER_DEMON = "NPC_TYPE_CYBER_DEMON"
    NPC_TYPE_CACO_DEMON = "NPC_TYPE_CACO_DEMON"
    NPC_TYPE_DEMON = "NPC_TYPE_DEMON"
    GAME_OVER = false
    FLAG_POS_MAP_X = -1
    FLAG_POS_MAP_Y = -1
    PLAYER_START_X = -1
    PLAYER_START_Y = -1

    TEXTURE_SIZE = 256
    HALF_TEXTURE_SIZE = math.floor(TEXTURE_SIZE / 2)

    MOUSE_SENSITIVITY = 0.03
    MOUSE_MAX_REL = 80
    MOUSE_BORDER_LEFT = 100
    MOUSE_BORDER_RIGHT = WINDOW_WIDTH - MOUSE_BORDER_LEFT
    ENEMY_ICON_SCALE = 60
    EXIT_ICON_SCALE = 60
    level = 1
    flag_taken = false
    mouse_rel_dx = 0
    sky_texture = nil
    blood_screen = nil
    game_over_screen = nil
    sky_offset = 0
    sprites = {}
    maze_holder = nil
    mini_map = nil
    tiles = {}
    map = {}
    enemies_killed = 0
    ray_casting_result = {}
    objects_to_render = {}
    wall_textures = {}
    npc_positions = {}
    sounds = {}
    digits = {}
    graph = {}
    DIGIT_SIZE = 60

    sounds.shotgun_fired = love.audio.newSource("resources/sounds/resources_sound_shotgun.wav", "static")
    sounds.npc_pain = love.audio.newSource("resources/sounds/resources_sound_npc_pain.wav", "static")
    sounds.npc_death = love.audio.newSource("resources/sounds/resources_sound_npc_death.wav", "static")
    sounds.npc_attack = love.audio.newSource("resources/sounds/resources_sound_npc_attack.wav", "static")
    sounds.player_pain = love.audio.newSource("resources/sounds/resources_sound_player_pain.wav", "static")
    love.mouse.setRelativeMode(true)

    require "utils"
    require "maze_generator"
    require "path_finding"
    require "weapon"
    require "object_renderer"
    load_wall_textures()
    require "path_finding"
    require "sprite_objects"

    setup_world()
    require "player"
    init_player()
    require "level_manager"
    require "mod"

end

function setup_world()
    maze_holder = get_maze(MAZE_WIDTH, MAZE_HEIGHT)
    mini_map = maze_holder.maze
    PLAYER_START_X = maze_holder.entry_pos[2] - 1 + 0.5
    PLAYER_START_Y = maze_holder.entry_pos[1] - 1 + 0.5
    FLAG_POS_MAP_X = maze_holder.exit_pos[2] - 1
    FLAG_POS_MAP_Y = maze_holder.exit_pos[1] - 1
    tiles = get_tiles()
    map = get_map()
    graph = get_graph()

    for _, candle_pos in ipairs(maze_holder.candles) do
        load_sprite("resources/sprites/static_sprites/candlebra.png", candle_pos[1]-0.5, candle_pos[2]-0.5, 0.7, 0.27, SPRITE_TYPE_STATIC)
    end
    for index, light_pos in ipairs(maze_holder.lights) do
        local light_colors = {"green_torch", "red_torch"}
        load_sprite("resources/sprites/animated_sprites/"..light_colors[(index%2)+1], light_pos[1]-0.5, light_pos[2]-0.5, 0.7, 0.27, SPRITE_TYPE_ANIMATED, 0.125)
    end
    for _, npc_pos in ipairs(maze_holder.npcs) do
        local npc_types = {"soldier", "cyber_demon", "caco_demon"}
        local npc_type = npc_types[math.random(1, #npc_types)]
        load_sprite(nil, npc_pos[1]-0.5, npc_pos[2]-0.5, 0.6, 0.38, SPRITE_TYPE_NPC, 0.2, NPC_TYPE_SOLDIER,
                    "resources/sprites/npc/"..npc_type.."/attack",
                    "resources/sprites/npc/"..npc_type.."/death",
                    "resources/sprites/npc/"..npc_type.."/idle",
                    "resources/sprites/npc/"..npc_type.."/pain",
                    "resources/sprites/npc/"..npc_type.."/walk")
    end
    load_weapon("resources/sprites/weapon/shotgun", 0.4, 0.15)
end



function get_map()
    local map = {}
    for _, tile in ipairs(tiles) do
        if map[tile.x] == nil then
            map[tile.x] = {}
        end
        map[tile.x][tile.y] = tile.tile_type
    end

    return map
end

function get_tiles()
    local tiles = {}
    for row_index, row in ipairs(mini_map) do
        for column_index, elem in ipairs(row) do
            if elem ~= 0 then
                local tile = {}
                tile.x = column_index - 1
                tile.y = row_index - 1
                tile.tile_type = elem
                table.insert(tiles, tile)
            end
        end
    end
    return tiles
end

function love.mousemoved(pos_x, pos_y, dx, dy, istouch)
    mouse_rel_dx = dx
    if pos_x < MOUSE_BORDER_LEFT or pos_x > MOUSE_BORDER_RIGHT then
        love.mouse.setPosition(HALF_WINDOW_WIDTH, HALF_WINDOW_HEIGHT)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        sounds.shotgun_fired:play()
        single_fire()
    end
end

function love.update(dt)
    if not GAME_OVER then
        player_update(dt)
        ray_casting_update()
        sprites_update(dt)
        weapon_update(dt)
        check_flag_reached()
        --print ()
        --local d = math.sqrt((player.pos_x - FLAG_POS_MAP_X)^2 + (player.pos_y - FLAG_POS_MAP_Y)^2)
        --print (d)
    end
end

function love.draw()
    object_renderer_draw()
    if not GAME_OVER then
       weapon_draw()
    end
    --love.graphics.setColor(0, 0, 1)
    --for _, tile in ipairs(tiles) do
        --love.graphics.rectangle("line", tile.x*WINDOW_SCALE, tile.y*WINDOW_SCALE, 100, 100)
    --end
    --player_draw()
    --draw_npc()
end
