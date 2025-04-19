local function find_required_object(name)
    local obj = uevr.api:find_uobject(name)
    if not obj then
        error("Cannot find " .. name)
        return nil
    end

    return obj
end

local function find_static_class(name)
    local cl = find_required_object(name)
    if cl and cl.get_class_default_object then
        return cl:get_class_default_object()
    end
    return nil
end

return {
    find_required_object = find_required_object,
    find_static_class = find_static_class
}