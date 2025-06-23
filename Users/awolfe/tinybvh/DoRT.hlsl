// tinybvh technique, shader DoRT
/*$(ShaderResources)*/

#include "PBR.hlsli"
#include "BVHTraverse.hlsli"

// from https://learnopengl.com/PBR/IBL/Diffuse-irradiance
float2 SampleSphericalMap(float3 v)
{
    const float2 invAtan = float2(0.1591f, 0.3183f);
    float2 uv = float2(atan2(v.z, v.x), asin(-v.y));
    uv *= invAtan;
    uv += 0.5;
    return uv;
}

float3 LinearToSRGB(float3 linearCol)
{
    float3 sRGBLo = linearCol * 12.92;
    float3 sRGBHi = (pow(abs(linearCol), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
    float3 sRGB;
    sRGB.r = linearCol.r <= 0.0031308 ? sRGBLo.r : sRGBHi.r;
    sRGB.g = linearCol.g <= 0.0031308 ? sRGBLo.g : sRGBHi.g;
    sRGB.b = linearCol.b <= 0.0031308 ? sRGBLo.b : sRGBHi.b;
    return sRGB;
}

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 dims;
    Output.GetDimensions(dims.x, dims.y);

    uint2 px = DTid.xy;

    // Get screen position of pixel
    float2 screenPos = (float2(px) + 0.5f) / float2(dims) * 2.0 - 1.0;
    screenPos.y = -screenPos.y;

    // Get a world space position of the pixel
    float4 world = mul(float4(screenPos, 0.9f, 1), /*$(Variable:InvViewProjMtx)*/);
    world.xyz /= world.w;

    // Calculate ray
    float3 rayPos = /*$(Variable:CameraPos)*/;
    float3 rayDir = normalize(world.xyz - rayPos);
    float3 rayDirRecip = rcp(rayDir);

    // Initialize the output color to the skybox color
    float3 color = /*$(Image:Arches_E_PineTree_3k.png:RGBA32_Float:float4:false)*/.SampleLevel(texSampler, SampleSphericalMap(rayDir), 0).rgb;
    //float3 color = float3(rayDir);

    switch (/*$(Variable:ViewMode)*/)
    {
        case ViewModes::Shaded:
        case ViewModes::Normals:
        case ViewModes::Distance:
        case ViewModes::Barycentrics:
        {
            RayVsBVHResult result;
            switch (/*$(Variable:RayTestAgainst)*/)
            {
                case RayTestAgainsts::BVHSeparate: result = RayVsMesh_BVH(BVHNodes, TriIndices, Vertices, rayPos, rayDir, rayDirRecip, /*$(Variable:TMax)*/); break;
                case RayTestAgainsts::BVHCombined: result = RayVsMesh_BVH(BVHCombinedData, rayPos, rayDir, rayDirRecip, /*$(Variable:TMax)*/); break;
                case RayTestAgainsts::NoBVH: result = RayVsMesh_BruteForce(Vertices, rayPos, rayDir, /*$(Variable:TMax)*/); break;
            }

            if (result.distance >= 0.0f)
            {
                // The triangle index is in the same order as the vertex buffer used to make the BVH.
                // So, if you have a richer vertex buffer, with normals, tangents, colors, uvs, etc, you could
                // use result.triangleIndex to look up into that too.
                // result.barycentrics is what is used to interpolate those values across the triangle.
                float3 A = Vertices[result.triangleIndex * 3 + 0].xyz;
                float3 B = Vertices[result.triangleIndex * 3 + 1].xyz;
                float3 C = Vertices[result.triangleIndex * 3 + 2].xyz;

                float3 AB = B - A;
                float3 AC = C - A;

                float3 normal = normalize(cross(AB, AC));

                switch (/*$(Variable:ViewMode)*/)
                {
                    case ViewModes::Normals: color = normal; break;
                    case ViewModes::Distance: color = float3(result.distance / /*$(Variable:DistanceDivider)*/, 0.0f, 0.0f); break;
                    case ViewModes::Barycentrics: color = float3(result.barycentrics, 0.0f); break;
                    case ViewModes::Shaded:
                    {
                        // Material Properties
                        float3 basecolor = /*$(Variable:Albedo)*/;
                        float roughness = /*$(Variable:Roughness)*/;
                        float specularlevel = /*$(Variable:SpecularLevel)*/;
                        float metalic = /*$(Variable:Metalic)*/;

                        // Directional lighting
                        float3 lightColor = /*$(Variable:LightColor)*/ * /*$(Variable:LightBrightness)*/;
                        float3 lightDirection = normalize(-/*$(Variable:LightDirection)*/);
                        float3 irradiance = max(dot(lightDirection, normal), 0.0) * lightColor;
                        float3 brdf = microfacetBRDF(lightDirection, -rayDir, normal, metalic, roughness, basecolor, specularlevel);
                        float3 radiance = irradiance * brdf;

                        // Ambient lighting
                        radiance += /*$(Variable:AmbientColor)*/ * /*$(Variable:AmbientBrightness)*/;

                        color = radiance;
                    }
                }
            }
            break;
        }
        case ViewModes::Occluded:
        {
            bool isOccluded = false;
            switch (/*$(Variable:RayTestAgainst)*/)
            {
                case RayTestAgainsts::BVHSeparate: isOccluded = IsOccluded_BVH(BVHNodes, TriIndices, Vertices, rayPos, rayDir, rayDirRecip, /*$(Variable:TMax)*/); break;
                case RayTestAgainsts::BVHCombined: isOccluded = IsOccluded_BVH(BVHCombinedData, rayPos, rayDir, rayDirRecip, /*$(Variable:TMax)*/); break;
                case RayTestAgainsts::NoBVH: isOccluded = IsOccluded_BruteForce(Vertices, rayPos, rayDir, /*$(Variable:TMax)*/); break;
            }

            if (isOccluded)
                color = float3(0.2f, 0.2f, 0.2f);

            break;
        }
        case ViewModes::Cost:
        {
            color = float3(1.0f, 0.0f, 0.0f);

            RayVsBVHResult result;
            switch (/*$(Variable:RayTestAgainst)*/)
            {
                case RayTestAgainsts::BVHSeparate: color.x = BVHCost(BVHNodes, TriIndices, Vertices, rayPos, rayDir, rayDirRecip, /*$(Variable:TMax)*/) / /*$(Variable:CostDivider)*/; break;
                case RayTestAgainsts::BVHCombined: color.x = BVHCost(BVHCombinedData, rayPos, rayDir, rayDirRecip, /*$(Variable:TMax)*/) / /*$(Variable:CostDivider)*/; break;
                case RayTestAgainsts::NoBVH: break;
            }

            break;
        }
    }

    Output[px] = float4(LinearToSRGB(color), 1.0f);
}

/*
Shader Resources:
    Buffer Vertices (as SRV)
    Buffer TriIndices (as SRV)
    Buffer BVHNodes (as SRV)
    Buffer BVHCombinedData (as SRV)
    Texture Output (as UAV)
*/
