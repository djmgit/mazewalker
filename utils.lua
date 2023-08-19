function listdir(path)
    local file_paths = {}
    local files = io.popen("ls " .. path)
    for filename in files:lines() do
        table.insert(file_paths, path .. "/" .. filename)
    end
    files:close()
    return file_paths
end

function get_images_from_paths(image_paths)
    local images = {}
    for _, image_path in ipairs(image_paths) do
        local image = love.graphics.newImage(image_path)
        table.insert(images, image)
    end
    return images
end

function check_not_wall(pos_x, pos_y)
    if map[pos_x] == nil then
        return true
    end
    if map[pos_x][pos_y] == nil then
        return true
    end
    
    return false
end
