weapon = {}

function load_weapon(path, scale, animation_time)
    weapon = {}
    weapon.image_paths = listdir(path)
    weapon.images = get_images_from_paths(weapon.image_paths)
    weapon.current_image = 0
    weapon.image = weapon.images[weapon.current_image + 1]
    weapon.reloading = false
    weapon.damage = 50
    weapon.scale = scale
    weapon.animation_time = animation_time
    weapon.time_remaining = weapon.animation_time
    weapon.pos_x = HALF_WINDOW_WIDTH - math.floor(weapon.image:getWidth() * weapon.scale / 2)
    weapon.pos_y = WINDOW_HEIGHT - weapon.image:getHeight() * weapon.scale
end

function animate_shot(dt)
    weapon.time_remaining = weapon.time_remaining - dt
    if weapon.reloading then
        player.shot = false
        if weapon.time_remaining <= 0 then
            weapon.time_remaining = weapon.animation_time
            weapon.current_image = weapon.current_image + 1
            if weapon.current_image == #weapon.images then
                weapon.current_image = 0
                weapon.reloading = false
            end
            weapon.image = weapon.images[weapon.current_image + 1]
        end
    end
end

function weapon_update(dt)
    animate_shot(dt)
end

function weapon_draw()
    love.graphics.draw(weapon.image, weapon.pos_x, weapon.pos_y, nil, 0.5, 0.5)
end

