#pragma once

#include <windows.h>

#include <memory>
#include "uevr/API.hpp"
#include "uevr/Plugin.hpp"
#include <utility/PointerHook.hpp>

#define PLUGIN_LOG_ONCE(...) { \
    static bool _logged_ = false; \
    if (!_logged_) { \
        _logged_ = true; \
        API::get()->log_info(__VA_ARGS__); \
    } }

#define PLUGIN_LOG_INFO(...) { \
        API::get()->log_info(__VA_ARGS__); \
    }

#define PLUGIN_LOG_ONCE_ERROR(...) { \
    static bool _logged_ = false; \
    if (!_logged_) { \
        _logged_ = true; \
        API::get()->log_error(__VA_ARGS__); \
    } }

// Global accessor for our plugin.
class Stalker2VR;
extern std::unique_ptr<Stalker2VR> g_plugin;

namespace SDK {
    struct FTransform;
}


class Stalker2VR : public uevr::Plugin {
public:
    Stalker2VR() = default;
    virtual ~Stalker2VR();

    void on_initialize() override;
private:
    static SDK::FTransform *on_get_weapon_forward(void *actor, SDK::FTransform *out_transform, int8_t type);
    void hook();

    int32_t m_on_get_weapon_forward_hook_id{};
    using func_t = decltype(Stalker2VR::on_get_weapon_forward);
    func_t* m_original_on_get_weapon_forward{};

};