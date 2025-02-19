#include <iostream>

#include "Plugin.hpp"
#include "glm/fwd.hpp"

using namespace uevr;

std::unique_ptr<Stalker2VR> g_plugin = std::make_unique<Stalker2VR>();

namespace SDK {
    enum class ERelativeTransformSpace : uint8_t
    {
        RTS_World                                = 0,
        RTS_Actor                                = 1,
        RTS_Component                            = 2,
        RTS_ParentBoneSpace                      = 3,
        RTS_MAX                                  = 4,
    };

    struct FQuat
    {
        double X;
        double Y;
        double Z;
        double W;
    };
    struct FVector
    {
        double X;
        double Y;
        double Z;
    };
    struct FTransform
    {
        FQuat Rotation;
        FVector Translation;
        unsigned __int8 Pad_38[8];
        FVector Scale3D;
        unsigned __int8 Pad_58[8];
    };

    struct SceneComponent_GetSocketTransform final
    {
        API::FName                                   InSocketName;                                      // 0x0000(0x0008)(Parm, ZeroConstructor, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)
        ERelativeTransformSpace                       TransformSpace;                                    // 0x0008(0x0001)(Parm, ZeroConstructor, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)
        uint8_t                                         Pad_9[0x7];                                        // 0x0009(0x0007)(Fixing Size After Last Property [ Dumper-7 ])
        FTransform                             ReturnValue;                                       // 0x0010(0x0060)(Parm, OutParm, ReturnParm, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)
    };
    static_assert(sizeof(SceneComponent_GetSocketTransform) == 0x70, "Size mismatch");
    static_assert(offsetof(SceneComponent_GetSocketTransform, ReturnValue) == 0x10, "Offset mismatch");

    struct SceneComponent_GetSocketLocation final
    {
    public:
        API::FName                                   InSocketName;                                      // 0x0000(0x0008)(Parm, ZeroConstructor, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)
        FVector                                ReturnValue;                                       // 0x0008(0x0018)(Parm, OutParm, ZeroConstructor, ReturnParm, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)
    };
    static_assert(alignof(SceneComponent_GetSocketLocation) == 0x000008, "Wrong alignment on SceneComponent_GetSocketLocation");
    static_assert(sizeof(SceneComponent_GetSocketLocation) == 0x000020, "Wrong size on SceneComponent_GetSocketLocation");
    static_assert(offsetof(SceneComponent_GetSocketLocation, InSocketName) == 0x000000, "Member 'SceneComponent_GetSocketLocation::InSocketName' has a wrong offset!");
    static_assert(offsetof(SceneComponent_GetSocketLocation, ReturnValue) == 0x000008, "Member 'SceneComponent_GetSocketLocation::ReturnValue' has a wrong offset!");

    // Function Engine.SceneComponent.GetSocketQuaternion
    // 0x0030 (0x0030 - 0x0000)
    struct alignas(0x10) SceneComponent_GetSocketQuaternion final
    {
    public:
        API::FName                                   InSocketName;                                      // 0x0000(0x0008)(Parm, ZeroConstructor, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)
        uint8_t                                         Pad_8[0x8];                                        // 0x0008(0x0008)(Fixing Size After Last Property [ Dumper-7 ])
        FQuat                                  ReturnValue;                                       // 0x0010(0x0020)(Parm, OutParm, ReturnParm, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)
    };
    static_assert(alignof(SceneComponent_GetSocketQuaternion) == 0x000010, "Wrong alignment on SceneComponent_GetSocketQuaternion");
    static_assert(sizeof(SceneComponent_GetSocketQuaternion) == 0x000030, "Wrong size on SceneComponent_GetSocketQuaternion");
    static_assert(offsetof(SceneComponent_GetSocketQuaternion, InSocketName) == 0x000000, "Member 'SceneComponent_GetSocketQuaternion::InSocketName' has a wrong offset!");
    static_assert(offsetof(SceneComponent_GetSocketQuaternion, ReturnValue) == 0x000010, "Member 'SceneComponent_GetSocketQuaternion::ReturnValue' has a wrong offset!");

}


Stalker2VR::~Stalker2VR() {

}

API::UObject* get_weapon_in_hands() {
    struct {
        API::UClass* c;
        API::TArray<API::UObject*> return_value{};
    } component_params;
    component_params.c = API::get()->find_uobject<API::UClass>(L"Class /Script/Engine.SkeletalMeshComponent");

    const auto pawn = API::get()->get_local_pawn(0);

    if (component_params.c != nullptr && pawn != nullptr) {
        // either or.
        pawn->call_function(L"K2_GetComponentsByClass", &component_params);

        if (component_params.return_value.empty()) {
            API::get()->log_error("Failed to find any SkeletalMeshComponents");
        }

        for (auto mesh : component_params.return_value) {
            auto name = mesh->get_fname()->to_string();
            if(name.contains(L"WeaponInHands")) {
                return mesh;
            }
        }
    } else {
        API::get()->log_error("Failed to find SkeletalMeshComponent class or local pawn");
    }
    return nullptr;
}

SDK::FTransform get_socket_transform(API::UObject* mesh, std::wstring_view socket_name, uint8_t transform_space = 0) {
    {
        SDK::SceneComponent_GetSocketTransform socket_params{};

        socket_params.InSocketName = API::FName{socket_name};
        socket_params.TransformSpace = (SDK::ERelativeTransformSpace)transform_space;
        mesh->call_function(L"GetSocketTransform", &socket_params);
        return socket_params.ReturnValue;
    }
}

SDK::FTransform* Stalker2VR::on_get_weapon_forward(/*SDK::APC*/void* actor, SDK::FTransform* out_transform,/* this flag is not used in any way*/ int8_t type) {
    auto original_fn = g_plugin->m_original_on_get_weapon_forward;
    auto res = original_fn(actor, out_transform, type);

    auto weapon = get_weapon_in_hands();
    if(weapon) {
        /* another candidate is AimSocket */
        auto socket_transform = get_socket_transform(weapon, L"Muzzle", 0);
        res->Rotation = socket_transform.Rotation;
        res->Translation = socket_transform.Translation;
    }
    return res;
}

void Stalker2VR::on_initialize() {
    PLUGIN_LOG_ONCE("Stalker2VR::on_initialize()");
    hook();
}

void Stalker2VR::hook() {
    auto apc = (API::UClass*)API::get()->find_uobject(L"Class /Script/Stalker2.PC");
    auto obj = apc->get_class_default_object();
    auto vtable = *(uintptr_t**)obj;
    auto source_of_damage = vtable[306];
    m_on_get_weapon_forward_hook_id = API::get()->param()->functions->register_inline_hook((void*)source_of_damage, (void*)&on_get_weapon_forward, (void**)&m_original_on_get_weapon_forward);
    if(m_on_get_weapon_forward_hook_id == -1) {
        PLUGIN_LOG_ONCE_ERROR("Failed to hook on_get_weapon_forward");
    }

}

