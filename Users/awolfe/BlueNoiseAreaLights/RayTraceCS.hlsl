// Unnamed technique, shader RayTraceCS
/*$(ShaderResources)*/

#include "PCG.hlsli"
#include "LDSShuffler.hlsli"
#include "Tonemap.hlsli"

static const float c_rayMaxDist = 5000.0f;
static const float c_rayHitNormalNudge = 0.01f;

// Adapted from my articles on blue noise area light sampling
// * https://blog.demofox.org/2020/05/16/using-blue-noise-for-raytraced-soft-shadows/
// * Using Blue Noise for Ray Traced Soft Shadows, https://www.realtimerendering.com/raytracinggems/rtg2/index.html
// And the importance sampled FAST noise demo / paper
// * https://github.com/electronicarts/importance-sampled-FAST-noise

float2 ReadVec2STTexture(in uint3 px, in Texture2DArray<float2> tex, bool convertToNeg1Plus1 = true)
{
    uint3 dims;
    tex.GetDimensions(dims.x, dims.y, dims.z);

    // Extend the noise texture over time
    uint cycleCount = px.z / dims.z;
    uint shuffleIndex = LDSShuffle1D_GetValueAtIndex(cycleCount, 16384, 10127, 435);
    px.x += shuffleIndex % dims.x;
    px.y += shuffleIndex / dims.x;

    float2 ret = tex[px % dims].rg;

    if (convertToNeg1Plus1)
        ret = ret * 2.0f - 1.0f;

    return ret;
}

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

struct SRayHitInfo
{
    float dist;
    float3 normal;
    float3 albedo;
    float3 emissive;
};

bool RayVsPlane(in float3 rayPos, in float3 rayDir, inout SRayHitInfo info, in float4 plane, in float3 albedo)
{
    float dist = -1.0f;
    float denom = dot(plane.xyz, rayDir);
    if (abs(denom) > 0.001f)
    {
        dist = (plane.w - dot(plane.xyz, rayPos)) / denom;

        if (dist > 0.0f && dist < info.dist)
        {
            info.dist = dist;
            info.normal = plane.xyz;
            info.albedo = albedo;
            return true;
        }
    }
    return false;
}

bool RayVsSphere(in float3 rayPos, in float3 rayDir, inout SRayHitInfo info, in float4 sphere, in float3 albedo)
{
    // get the vector from the center of this sphere to where the ray begins.
    float3 m = rayPos - sphere.xyz;

    //get the dot product of the above vector and the ray's vector
    float b = dot(m, rayDir);

    float c = dot(m, m) - sphere.w * sphere.w;

    //exit if r's origin outside s (c > 0) and r pointing away from s (b > 0)
    if(c > 0.0 && b > 0.0)
        return false;

    //calculate discriminant
    float discr = b * b - c;

    //a negative discriminant corresponds to ray missing sphere
    if(discr < 0.0)
        return false;
    
    //ray now found to intersect sphere, compute smallest t value of intersection
    bool fromInside = false;
    float dist = -b - sqrt(discr);
    if (dist < 0.0f)
    {
        fromInside = true;
        dist = -b + sqrt(discr);
    }
    
    if (dist > 0.0f && dist < info.dist)
    {
        info.dist = dist;
        info.normal = normalize((rayPos + rayDir * dist) - sphere.xyz) * (fromInside ? -1.0f : 1.0f);
        info.albedo = albedo;
        return true;
    }
    
    return false;
}

// checkersGradTriangle() and p() are analytically mipmapped checkerboard pattern from inigo quilez
// https://iquilezles.org/articles/morecheckerfiltering
float2 p(in float2 x)
{
    float2 h = frac(x / 2.0) - 0.5;
    return x * 0.5 + h * (1.0 - 2.0 * abs(h));
}

// return a filtered checkers pattern
float checkersGradTriangle(in float2 uv)
{
    float2 dfdx = float2(0.0f, 0.0f);
    float2 dfdy = float2(0.0f, 0.0f);
    /*$(If:Platform:Interpreter)*/
    dfdx = ddx(uv);
    dfdy = ddy(uv);
    /*$(Endif)*/
    float2 w = max(abs(dfdx), abs(dfdy)) + 0.01;                  // filter kernel
    float2 i = (p(uv + w) - 2.0 * p(uv) + p(uv - w)) / (w * w); // analytical integral (triangle filter)
    return 0.5 - 0.5 * i.x * i.y;                             // xor pattern
}

SRayHitInfo RayVsScene(in float3 rayPos, in float3 rayDir, bool shadowRay)
{
    SRayHitInfo hitInfo = (SRayHitInfo)0;
    hitInfo.dist = c_rayMaxDist;

    // the floor
    if (RayVsPlane(rayPos, rayDir, hitInfo, float4(0.0f, 1.0f, 0.0f, 0.0f), float3(0.2f, 0.2f, 0.2f)))
    {
        float3 hitPos = rayPos + rayDir * hitInfo.dist;
        float2 uv = hitPos.xz / 100.0f;
        float shade = lerp(0.8f, 0.4f, checkersGradTriangle(uv));
        hitInfo.albedo = float3(shade, shade, shade);
    }

    // some floating spheres to cast shadows
    RayVsSphere(rayPos, rayDir, hitInfo, float4(-60.0f, 10.0f, 0.0f, 10.0f), float3(1.0f, 0.0f, 1.0f));
    RayVsSphere(rayPos, rayDir, hitInfo, float4(-30.0f, 20.0f, 0.0f, 10.0f), float3(1.0f, 0.0f, 0.0f));
    RayVsSphere(rayPos, rayDir, hitInfo, float4(0.0f, 30.0f, 0.0f, 10.0f), float3(0.0f, 1.0f, 0.0f));
    RayVsSphere(rayPos, rayDir, hitInfo, float4(30.0f, 40.0f, 0.0f, 10.0f), float3(0.0f, 0.0f, 1.0f));
    RayVsSphere(rayPos, rayDir, hitInfo, float4(60.0f, 50.0f, 0.0f, 10.0f), float3(1.0f, 1.0f, 0.0f));

    // the light
    if (/*$(Variable:PosLightEnabled)*/ && !shadowRay)
    {
        const float3 c_lightPos = /*$(Variable:PosLightPosition)*/;
        const float c_lightRadius = /*$(Variable:PosLightRadius)*/;
        const float3 c_lightDir = /*$(Variable:PosLightShineDir)*/;
        const float c_cosThetaOuter = /*$(Variable:PosLightShineCosThetaOuter)*/;
        const float c_cosThetaInner = /*$(Variable:PosLightShineCosThetaInner)*/;
        if (RayVsSphere(rayPos, rayDir, hitInfo, float4(c_lightPos, c_lightRadius), float3(0.0f, 0.0f, 0.0f)))
        {
            float3 hitPos = rayPos + rayDir * hitInfo.dist;
            float3 toLight = (c_lightPos - hitPos);
            float3 lightDir = normalize(toLight);
            float angleAtten = dot(lightDir, -c_lightDir);
            angleAtten = smoothstep(c_cosThetaOuter, c_cosThetaInner, angleAtten);
            hitInfo.emissive = angleAtten * /*$(Variable:PosLightColor)*/ * /*$(Variable:PosLightBrightness)*/ * 10.0f;
        }
    }

    return hitInfo;
}

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 px = DTid.xy;

    uint2 renderSize;
    Output.GetDimensions(renderSize.x, renderSize.y);

    // Get the world position
    float2 screenPos = (float2(px)+0.5f) / float2(renderSize) * 2.0 - 1.0;
    screenPos.y = -screenPos.y;
    float4 world = mul(float4(screenPos, 1.0f, 1.0f), /*$(Variable:InvViewProjMtx)*/);
    world.xyz /= world.w;

    // calculate the ray
    float3 rayPos = /*$(Variable:CameraPos)*/;
    float3 rayDir = normalize(world.xyz - rayPos);

    // Get the skybox as the starting color
    float2 uv = SampleSphericalMap(rayDir);
    //float3 color = /*$(ImageZ:Arches_E_PineTree_3k.hdr:RGBA32_Float:float4:false)*/.SampleLevel(texSampler, uv, 0).rgb;
	float3 color = /*$(Image:Arches_E_PineTree_3k.png:RGBA8_Unorm_sRGB:float4:false)*/.SampleLevel(texSampler, uv, 0).rgb;

    uint rngState = HashInit(uint3(px, /*$(Variable:FrameIndex)*/));

    SRayHitInfo hitInfo = RayVsScene(rayPos, rayDir, false);
    if (hitInfo.dist < c_rayMaxDist)
    {
        // Ambient light
        color = /*$(Variable:AmbientLight)*/ * hitInfo.albedo;

        // Emissive light
        color += hitInfo.emissive;

        // Directional light
        if (/*$(Variable:DirLightEnabled)*/)
        {
            const float3 c_lightDir = normalize(-/*$(Variable:DirLightDirection)*/);
            float3 lightTangent = abs(dot(c_lightDir, float3(0.0f, 1.0f, 0.0f))) < 0.5f
                                      ? cross(c_lightDir, float3(0.0f, 1.0f, 0.0f))
                                      : cross(c_lightDir, float3(1.0f, 0.0f, 0.0f))
            ;
            lightTangent = normalize(lightTangent);

            float3 lightBitangent = normalize(cross(lightTangent, c_lightDir));
            float3 shadowRayPos = rayPos + rayDir * hitInfo.dist + hitInfo.normal * c_rayHitNormalNudge;

            for (int i = 0; i < /*$(Variable:DirLightSampleCount)*/; ++i)
            {
                float2 diskPoint = float2(0.0f, 0.0f);
                switch (/*$(Variable:NoiseType)*/)
                {
                    case NoiseTypes::White:
                    {
                        float2 uv = float2(RandomFloat01(rngState), RandomFloat01(rngState));
                        float pointRadius = /*$(Variable:DirLightRadius)*/ * sqrt(uv.x);
                        float pointAngle = uv.y * 2.0f * c_pi;
                        diskPoint = float2(pointRadius * cos(pointAngle), pointRadius * sin(pointAngle));
                        break;
                    }
                    case NoiseTypes::FAST:
                    {
                        uint3 sampleIndex = uint3(px, /*$(Variable:FrameIndex)*/ * /*$(Variable:DirLightSampleCount)*/ + i);
                        float2 uv = ReadVec2STTexture(sampleIndex, /*$(Image2DArray:FASTUniformSquare/vector2_uniform_gauss1_0_Gauss10_separate05_%i.png:RG8_UNorm:float2:false:false)*/, false);
                        float pointRadius = /*$(Variable:DirLightRadius)*/ * sqrt(uv.x);
                        float pointAngle = uv.y * 2.0f * c_pi;
                        diskPoint = float2(pointRadius * cos(pointAngle), pointRadius * sin(pointAngle));
                        break;
                    }
                    case NoiseTypes::FAST_IS:
                    {
                        uint3 sampleIndex = uint3(px, /*$(Variable:FrameIndex)*/ * /*$(Variable:DirLightSampleCount)*/ + i);
                        diskPoint = /*$(Variable:DirLightRadius)*/ * ReadVec2STTexture(sampleIndex, /*$(Image2DArray:FASTUniformCircle/UniformCircle_%i.png:RG8_UNorm:float2:false:false)*/, true);
                        break;
                    }
                }

                float3 shadowRayDir = normalize(c_lightDir + diskPoint.x * lightTangent + diskPoint.y * lightBitangent);
                SRayHitInfo shadowRayHitInfo = RayVsScene(shadowRayPos, shadowRayDir, true);

                if (shadowRayHitInfo.dist >= c_rayMaxDist)
                {
                    float dp = clamp(dot(shadowRayDir, hitInfo.normal), 0.0f, 1.0f);
                    color += dp * hitInfo.albedo * /*$(Variable:DirLightColor)*/ * /*$(Variable:DirLightBrightness)*/ / float(/*$(Variable:DirLightSampleCount)*/);
                }
            }
        }

        // Positional light
        if (/*$(Variable:PosLightEnabled)*/)
        {
            float3 shadowRayPos = rayPos + rayDir * hitInfo.dist + hitInfo.normal * c_rayHitNormalNudge;

            const float3 c_lightDir = normalize(/*$(Variable:PosLightPosition)*/ - shadowRayPos);

            float3 lightTangent = abs(dot(c_lightDir, float3(0.0f, 1.0f, 0.0f))) < 0.5f
                                      ? cross(c_lightDir, float3(0.0f, 1.0f, 0.0f))
                                      : cross(c_lightDir, float3(1.0f, 0.0f, 0.0f))
            ;
            lightTangent = normalize(lightTangent);

            float3 lightBitangent = normalize(cross(lightTangent, c_lightDir));

            for (int i = 0; i < /*$(Variable:PosLightSampleCount)*/; ++i)
            {
                float2 diskPoint = float2(0.0f, 0.0f);
                switch (/*$(Variable:NoiseType)*/)
                {
                    case NoiseTypes::White:
                    {
                        float2 uv = float2(RandomFloat01(rngState), RandomFloat01(rngState));
                        float pointRadius = /*$(Variable:PosLightRadius)*/ * sqrt(uv.x);
                        float pointAngle = uv.y * 2.0f * c_pi;
                        diskPoint = float2(pointRadius * cos(pointAngle), pointRadius * sin(pointAngle));
                        break;
                    }
                    case NoiseTypes::FAST:
                    {
                        uint3 sampleIndex = uint3(px, /*$(Variable:FrameIndex)*/ * /*$(Variable:PosLightSampleCount)*/ + i);
                        float2 uv = ReadVec2STTexture(sampleIndex, /*$(Image2DArray:FASTUniformSquare/vector2_uniform_gauss1_0_Gauss10_separate05_%i.png:RG8_UNorm:float2:false:false)*/, false);
                        float pointRadius = /*$(Variable:PosLightRadius)*/ * sqrt(uv.x);
                        float pointAngle = uv.y * 2.0f * c_pi;
                        diskPoint = float2(pointRadius * cos(pointAngle), pointRadius * sin(pointAngle));
                        break;
                    }
                    case NoiseTypes::FAST_IS:
                    {
                        uint3 sampleIndex = uint3(px, /*$(Variable:FrameIndex)*/ * /*$(Variable:PosLightSampleCount)*/ + i);
                        diskPoint = /*$(Variable:PosLightRadius)*/ * ReadVec2STTexture(sampleIndex, /*$(Image2DArray:FASTUniformCircle/UniformCircle_%i.png:RG8_UNorm:float2:false:false)*/, true);
                        break;
                    }
                }

                float3 shadowRayTarget = /*$(Variable:PosLightPosition)*/ + diskPoint.x * lightTangent + diskPoint.y * lightBitangent;
                float3 shadowRayDir = normalize(shadowRayTarget - shadowRayPos);
                SRayHitInfo shadowRayHitInfo = RayVsScene(shadowRayPos, shadowRayDir, true);

                if (shadowRayHitInfo.dist >= c_rayMaxDist)
                {
                    float angleAtten = dot(shadowRayDir, -normalize(/*$(Variable:PosLightShineDir)*/));
                    angleAtten = smoothstep(/*$(Variable:PosLightShineCosThetaOuter)*/, /*$(Variable:PosLightShineCosThetaInner)*/, angleAtten);

                    float dp = clamp(dot(shadowRayDir, hitInfo.normal), 0.0f, 1.0f);
                    color += angleAtten * dp * hitInfo.albedo * /*$(Variable:PosLightColor)*/ * /*$(Variable:PosLightBrightness)*/ / float(/*$(Variable:PosLightSampleCount)*/);
                }
            }
        }
    }
    else
    {
        // Show the directional light source
        if (/*$(Variable:DirLightEnabled)*/)
        {
            const float3 c_lightDir = normalize(-/*$(Variable:DirLightDirection)*/);
            float3 lightTangent = abs(dot(c_lightDir, float3(0.0f, 1.0f, 0.0f))) < 0.5f
                                      ? cross(c_lightDir, float3(0.0f, 1.0f, 0.0f))
                                      : cross(c_lightDir, float3(1.0f, 0.0f, 0.0f))
            ;
            lightTangent = normalize(lightTangent);

            float3 shadowRayDir = normalize(c_lightDir + lightTangent * /*$(Variable:DirLightRadius)*/);

            float dp = dot(c_lightDir, shadowRayDir);

            if (dot(rayDir, c_lightDir) >= dp)
            {
                color = /*$(Variable:DirLightColor)*/ * /*$(Variable:DirLightBrightness)*/ * 10.0f;
            }
        }
    }

    // Temporal filtering
    if (/*$(Variable:CameraChanged)*/ || bool(/*$(Variable:ResetAccum)*/) || /*$(Variable:FrameIndex)*/ < 10)
    {
        Accum[px] = float4(color, 1.0f);
    }
    else
    {
        switch (/*$(Variable:TemporalFilter)*/)
        {
            case TemporalFilters::None: Accum[px] = float4(color, 1.0f); break;
            case TemporalFilters::EMA:
            {
                float3 oldColor = Accum[px].rgb;
                color = lerp(oldColor, color, /*$(Variable:EMAAlpha)*/);
                Accum[px] = float4(color, 1.0f);
                break;
            }
            case TemporalFilters::MonteCarlo:
            {
                float4 oldColor = Accum[px].rgba;
                float sampleCount = oldColor.a;
                color = lerp(oldColor.rgb, color, 1.0f / sampleCount);
                Accum[px] = float4(color, sampleCount + 1.0f);
                break;
            }
        }
    }

    // Exposure and tonemapping
    float exposure = pow(2.0f, /*$(Variable:ExposureFStops)*/);
    color = max(color * exposure, float3(0.0f, 0.0f, 0.0f));
    switch (/*$(Variable:ToneMapping)*/)
    {
        case ToneMappingOperation::None: break;
        case ToneMappingOperation::Reinhard_Simple: color = Reinhard(color); break;
        case ToneMappingOperation::ACES_Luminance: color = ACESFilm(color); break;
        case ToneMappingOperation::ACES: color = ACESFitted(color); break;
    }

    // Apply exposure and convert from linear to sRGB
    Output[px] = float4(LinearToSRGB(color), 1.0f);
}

/*
Shader Resources:
    Texture Output (as UAV)
    Texture Accum (as UAV)
*/
