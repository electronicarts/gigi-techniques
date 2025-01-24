// Unnamed technique, shader DoLightingCS
/*$(ShaderResources)*/

#include "PBR.hlsl"

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 px = DTid.xy;
    float3 albedo = /*$(Image:gbuffer_albedo_4933.png:RGBA8_Unorm_sRGB:float4:true)*/[px].rgb;

    // TODO: need a better way of dealing with empty pixels! like when we have the gbuffer, look for the clear value.
    if (albedo.x == 0.0f && albedo.y == 0.0f && albedo.z == 0.0f)
    {
        // TODO: can put skybox here when we can get a screen ray direction (using the camera!)
        return;
    }

    float3 normal = normalize(/*$(Image:gbuffer_normal_4933.png:RGBA8_Unorm:float4:false)*/[px].rgb * 2.0f - 1.0f);
    float3 AO = /*$(Image:ssao_4933.png:RGBA8_Unorm:float:false)*/[px];

    // TODO: need all these. includes needing depth and camera info
    float3 worldPos = float3(0.0f, 0.0f, 0.0f);
    float3 cameraPos = float3(0.0f, 0.0f, 10.0f); 
    float metallic = 0.0f;
    float roughness = 1.0f;
    float scalarF0 = c_F0;

    // Get reverse view direction (from world to camera)
    float3 V = normalize(cameraPos - worldPos);

	// Get the reflection direction
	float3 R = reflect(-V, normal);

    // Directional light
    float3 lightDir = normalize(/*$(Variable:DirLightDir)*/);
    float3 lightColor = /*$(Variable:DirLightColor)*/ * /*$(Variable:DirLightIntensity)*/;
    float3 litPixel = DirectionalLight(worldPos, normal, V, -lightDir, lightColor, albedo, metallic, roughness, scalarF0) * AO;

    // IBL
    {
        switch(/*$(Variable:Skybox)*/)
        {
            case Skyboxes::Vasa:
            {
                TextureCube<float4> DiffuseIBL   = /*$(ImageCube:../Skyboxes/Vasa/VasaDiffuse%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL0 = /*$(ImageCube:../Skyboxes/Vasa/Vasa0Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL1 = /*$(ImageCube:../Skyboxes/Vasa/Vasa1Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL2 = /*$(ImageCube:../Skyboxes/Vasa/Vasa2Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL3 = /*$(ImageCube:../Skyboxes/Vasa/Vasa3Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL4 = /*$(ImageCube:../Skyboxes/Vasa/Vasa4Specular%s.png:RGBA8_UNorm:float4:true)*/;
                litPixel += IBL(normal, V, R, albedo, metallic, roughness, c_F0, /*$(Image2D:../Textures/splitsum.png:RGBA8_UNorm:float4:false)*/, DiffuseIBL, SpecularIBL0, SpecularIBL1, SpecularIBL2, SpecularIBL3, SpecularIBL4, LinearWrap) * AO;
                break;
            }
            case Skyboxes::AshCanyon:
            {
                TextureCube<float4> DiffuseIBL   = /*$(ImageCube:../Skyboxes/AshCanyon/AshCanyonDiffuse%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL0 = /*$(ImageCube:../Skyboxes/AshCanyon/AshCanyon0Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL1 = /*$(ImageCube:../Skyboxes/AshCanyon/AshCanyon1Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL2 = /*$(ImageCube:../Skyboxes/AshCanyon/AshCanyon2Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL3 = /*$(ImageCube:../Skyboxes/AshCanyon/AshCanyon3Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL4 = /*$(ImageCube:../Skyboxes/AshCanyon/AshCanyon4Specular%s.png:RGBA8_UNorm:float4:true)*/;
                litPixel += IBL(normal, V, R, albedo, metallic, roughness, c_F0, /*$(Image2D:../Textures/splitsum.png:RGBA8_UNorm:float4:false)*/, DiffuseIBL, SpecularIBL0, SpecularIBL1, SpecularIBL2, SpecularIBL3, SpecularIBL4, LinearWrap) * AO;
                break;
            }
            case Skyboxes::Marriot:
            {
                TextureCube<float4> DiffuseIBL   = /*$(ImageCube:../Skyboxes/Marriot/MarriotDiffuse%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL0 = /*$(ImageCube:../Skyboxes/Marriot/Marriot0Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL1 = /*$(ImageCube:../Skyboxes/Marriot/Marriot1Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL2 = /*$(ImageCube:../Skyboxes/Marriot/Marriot2Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL3 = /*$(ImageCube:../Skyboxes/Marriot/Marriot3Specular%s.png:RGBA8_UNorm:float4:true)*/;
                TextureCube<float4> SpecularIBL4 = /*$(ImageCube:../Skyboxes/Marriot/Marriot4Specular%s.png:RGBA8_UNorm:float4:true)*/;
                litPixel += IBL(normal, V, R, albedo, metallic, roughness, c_F0, /*$(Image2D:../Textures/splitsum.png:RGBA8_UNorm:float4:false)*/, DiffuseIBL, SpecularIBL0, SpecularIBL1, SpecularIBL2, SpecularIBL3, SpecularIBL4, LinearWrap) * AO;
                break;
            }
        }
    }

    // Ambient light
    litPixel += /*$(Variable:AmbientLightColor)*/ * /*$(Variable:AmbientLightIntensity)*/;

    Output[px] = float4(litPixel, 1.0f);
}
