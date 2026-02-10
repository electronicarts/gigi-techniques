Struct_Materials Material_MaterialBuffer(StructuredBuffer<Struct_Materials> MaterialsBuffer, int materialID, float2 uv0, float2 uv1, float2 uv2, float2 uv3, out float3 normal, out float occlusion,
    float2 uv0ddx = float2(0.0f, 0.0f), float2 uv0ddy = float2(0.0f, 0.0f), float2 uv1ddx = float2(0.0f, 0.0f), float2 uv1ddy = float2(0.0f, 0.0f),
    float2 uv2ddx = float2(0.0f, 0.0f), float2 uv2ddy = float2(0.0f, 0.0f), float2 uv3ddx = float2(0.0f, 0.0f), float2 uv3ddy = float2(0.0f, 0.0f))
{
    Struct_Materials ret = (Struct_Materials)0;
    ret.baseColor = float4(1.f, 1.f, 1.f, 1.f);
    ret.emissive = float3(0.f, 0.f, 0.f);
    ret.metallic = float(0.f);
    ret.roughness = float(1.f);
    ret.alphaMode = int(0);
    ret.alphaCutoff = float(0.f);
    ret.doubleSided = int(1);

    normal = float3(0.0f, 0.0f, 1.0f);
    occlusion = 1.0f;

    float normalScale = 1.0f;
    float occlusionStrength = 1.0f;

    uint materialCount, materialStride;
    MaterialsBuffer.GetDimensions(materialCount, materialStride);

    if (materialID < 0 || materialID >= materialCount)
        return ret;

    // Read material data from the buffer
    ret = MaterialsBuffer[materialID];

    // Sample the textures
    switch(materialID)
    {
        // arch_stone_wall_01
        case 0:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\arch_stone_wall_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\arch_stone_wall_01_Roughnessarch_stone_wall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\arch_stone_wall_01_Roughnessarch_stone_wall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\arch_stone_wall_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // stone_trims_01
        case 1:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\stone_trims_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\stone_trims_01_Roughnessstone_trims_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\stone_trims_01_Roughnessstone_trims_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\stone_trims_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // brickwall_02
        case 2:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\brickwall_02_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\brickwall_02_Roughnessbrickwall_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\brickwall_02_Roughnessbrickwall_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\brickwall_02_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // metal_door
        case 3:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\metal_door_01_BaseColor_png.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\metal_door_01_Roughnessmetal_door_01_Metalness_png.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\metal_door_01_Roughnessmetal_door_01_Metalness_png.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\metal_door_01_Normal_png.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // floor_01
        case 4:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\floor_tiles_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\floor_tiles_01_Roughnessfloor_tiles_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\floor_tiles_01_Roughnessfloor_tiles_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\floor_tiles_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // stones_01_tile
        case 5:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\stone_01_tile_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\stone_01_tile_Roughnessstone_01_tile_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\stone_01_tile_Roughnessstone_01_tile_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\stone_01_tile_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // stones_2ndfloor
        case 6:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\stones_2ndfloor_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\stones_2ndfloor_01_Roughnessstones_2ndfloor_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\stones_2ndfloor_01_Roughnessstones_2ndfloor_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\stones_2ndfloor_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // brickwall_02.001
        case 7:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\brickwall_02_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\brickwall_02_Roughnessbrickwall_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\brickwall_02_Roughnessbrickwall_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\brickwall_02_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // ceiling_plaster_02.001
        case 8:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\ceiling_plaster_02_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\ceiling_plaster_02_Roughnessceiling_plaster_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\ceiling_plaster_02_Roughnessceiling_plaster_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\ceiling_plaster_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // window_frame_01
        case 9:
        {
            normalScale = (float)0.5;
            ret.baseColor *= /*$(Image2D:"SponzaNew\window_frame_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\window_frame_01_Roughnesswindow_frame_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\window_frame_01_Roughnesswindow_frame_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\window_frame_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // stone_trims_02
        case 11:
        {
            normalScale = (float)0.3;
            ret.baseColor *= /*$(Image2D:"SponzaNew\stone_trims_02_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\stone_trims_02_Roughnessstone_trims_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\stone_trims_02_Roughnessstone_trims_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\stone_trims_02_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // ceiling_plaster_02
        case 12:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\ceiling_plaster_02_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\ceiling_plaster_02_Roughnessceiling_plaster_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\ceiling_plaster_02_Roughnessceiling_plaster_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\ceiling_plaster_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // column_1stfloor
        case 13:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\col_1stfloor_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\col_1stfloor_Roughnesscol_1stfloor_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\col_1stfloor_Roughnesscol_1stfloor_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\col_1stfloor_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // column_head_1stfloor
        case 14:
        {
            normalScale = (float)0.5;
            ret.baseColor *= /*$(Image2D:"SponzaNew\col_head_1stfloor_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\col_head_1stfloor_Roughnesscol_head_1stfloor_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\col_head_1stfloor_Roughnesscol_head_1stfloor_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\col_head_1stfloor_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // brickwall_01.001
        case 15:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\brickwall_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\brickwall_01_Roughnessbrickwall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\brickwall_01_Roughnessbrickwall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\brickwall_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // ornament_lion
        case 18:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\lionhead_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\lionhead_01_Roughnesslionhead_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\lionhead_01_Roughnesslionhead_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\lionhead_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // door_stoneframe_02
        case 19:
        {
            normalScale = (float)0.5;
            ret.baseColor *= /*$(Image2D:"SponzaNew\door_stoneframe_02_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\door_stoneframe_02_Roughnessdoor_stoneframe_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\door_stoneframe_02_Roughnessdoor_stoneframe_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\door_stoneframe_02_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // door_stoneframe_01
        case 20:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\door_stoneframe_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\door_stoneframe_01_Roughnessdoor_stoneframe_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\door_stoneframe_01_Roughnessdoor_stoneframe_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\door_stoneframe_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // brickwall_01
        case 21:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\brickwall_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\brickwall_01_Roughnessbrickwall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\brickwall_01_Roughnessbrickwall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\brickwall_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // wood_door_01
        case 22:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\wood_door_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\wood_door_01_Roughnesswood_door_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\wood_door_01_Roughnesswood_door_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\wood_door_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // wood_01
        case 23:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\wood_tile_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\wood_tile_01_Roughnesswood_tile_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\wood_tile_01_Roughnesswood_tile_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\wood_tile_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // ceiling_plaster_01
        case 24:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\ceiling_plaster_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\ceiling_plaster_01_Roughnessceiling_plaster_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\ceiling_plaster_01_Roughnessceiling_plaster_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\ceiling_plaster_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // column_brickwall_01
        case 25:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\col_brickwall_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\col_brickwall_01_Roughnesscol_brickwall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\col_brickwall_01_Roughnesscol_brickwall_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\col_brickwall_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // column_head_2ndfloor_03
        case 26:
        {
            normalScale = (float)0.6;
            ret.baseColor *= /*$(Image2D:"SponzaNew\col_head_2ndfloor_03_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\col_head_2ndfloor_03_Roughnesscol_head_2ndfloor_03_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\col_head_2ndfloor_03_Roughnesscol_head_2ndfloor_03_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\col_head_2ndfloor_03_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // column_head_2ndfloor_02
        case 27:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\col_head_2ndfloor_02_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\col_head_2ndfloor_02_Roughnesscol_head_2ndfloor_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\col_head_2ndfloor_02_Roughnesscol_head_2ndfloor_02_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\col_head_2ndfloor_02_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // roof_tiles_01
        case 28:
        {
            normalScale = (float)0.3;
            ret.baseColor *= /*$(Image2D:"SponzaNew\roof_tiles_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\roof_tiles_01_Roughnessroof_tiles_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\roof_tiles_01_Roughnessroof_tiles_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\roof_tiles_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // ornament_01
        case 29:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\ornament_01_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\ornament_01_Roughnessornament_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\ornament_01_Roughnessornament_01_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\ornament_01_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // Mat_curtain_01
        case 30:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\curtain_fabric_red_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\curtain_fabric_Roughnesscurtain_fabric_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\curtain_fabric_Roughnesscurtain_fabric_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\curtain_fabric_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // Mat_curtain_03
        case 31:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\curtain_fabric_blue_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\curtain_fabric_Roughnesscurtain_fabric_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\curtain_fabric_Roughnesscurtain_fabric_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\curtain_fabric_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }

        // Mat_curtain_02
        case 32:
        {
            ret.baseColor *= /*$(Image2D:"SponzaNew\curtain_fabric_green_BaseColor.dds":Any:float4:true:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgba;
            ret.metallic *= /*$(Image2D:"SponzaNew\curtain_fabric_Roughnesscurtain_fabric_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).b;
            ret.roughness *= /*$(Image2D:"SponzaNew\curtain_fabric_Roughnesscurtain_fabric_Metalness.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).g;
            normal = /*$(Image2D:"SponzaNew\curtain_fabric_Normal.dds":Any:float4:false:true)*/.SampleGrad(/*$(Sampler:linear:linear:linear:wrap)*/, uv0, uv0ddx, uv0ddy).rgb * 2.0f - 1.0f;
            break;
        }
    }

    normal = normalize((normal * 2.0f - 1.0f) * float3(normalScale, normalScale, 1.0f));
    ret.baseColor.rgb = lerp(ret.baseColor.rgb, ret.baseColor.rgb * occlusion, occlusionStrength);

    return ret;
};
