local function find_required_object(name)
    local obj = uevr.api:find_uobject(name)
    if not obj then
        error("Cannot find " .. name)
        return nil
    end

    return obj
end

local function find_static_class(name)
    local c = find_required_object(name)
    return c:get_class_default_object()
end