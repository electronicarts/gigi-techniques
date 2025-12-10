// Unnamed technique, shader MakeVideo
/*$(ShaderResources)*/

#include "Shared.hlsli"

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 px = DTid.xy;

    float iTime = float(/*$(Variable:AudioOutSampleWindowStart)*/) / float(/*$(Variable:AudioOutSampleRate)*/);

    float TIME_SCALE = /*$(Variable:TimeScale)*/;
	float ENVELOPE_TIME = 0.1 / TIME_SCALE;

    uint2 dims;
	Output.GetDimensions(dims.x, dims.y);
	float2 iResolution = float2(dims);

    float A = /*$(Variable:ControlPoint1)*/;
	float B = /*$(Variable:ControlPoint2)*/;
	float C = /*$(Variable:ControlPoint3)*/;
	float D = /*$(Variable:ControlPoint4)*/;

    float aspectRatio = iResolution.x / iResolution.y;
    float2 percent = float2(px) / iResolution.xy;
    percent = ((percent - 0.5f) * 1.5f) + 0.5f;
    percent.x *= aspectRatio;
    percent.y = 1.0f - percent.y;

    // show the ball moving across the curve
    float3 color = float3(1.0, 1.0, 1.0);
    float ballX = frac(iTime / TIME_SCALE);
    float ballY = max(0.0, min(1.0, F(float2(ballX, 0.0), A, B, C, D)));
    float dist = SDFCircle(percent, float2(ballX, ballY));
    if (dist < 2.0 * EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(2.0 * EDGE, 2.0 * EDGE + SMOOTH, dist);
        color *= lerp(float3(0.0, 1.0, 1.0), float3(1.0, 1.0, 1.0), dist);
    }

    dist = SDFCircle(percent, float2(0.0, A));
    if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE, EDGE + SMOOTH, dist);
        color *= lerp(float3(1.0, 0.0, 0.0), float3(1.0, 1.0, 1.0), dist);
    }

    dist = SDFCircle(percent, float2(0.33, B));
    if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE, EDGE + SMOOTH, dist);
        color *= lerp(float3(0.0, 1.0, 0.0), float3(1.0, 1.0, 1.0), dist);
    }

    dist = SDFCircle(percent, float2(0.66, C));
    if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE, EDGE + SMOOTH, dist);
        color *= lerp(float3(1.0, 1.0, 0.0), float3(1.0, 1.0, 1.0), dist);
    }

    dist = SDFCircle(percent, float2(1.0, D));
    if (dist < EDGE + SMOOTH)
    {
        dist = max(dist, 0.0);
        dist = smoothstep(EDGE, EDGE + SMOOTH, dist);
        color *= lerp(float3(0.0, 0.0, 1.0), float3(1.0, 1.0, 1.0), dist);
    }

    dist = SDF(percent, A, B, C, D);
    if (dist < EDGE + SMOOTH)
    {
        dist = smoothstep(EDGE - SMOOTH, EDGE + SMOOTH, dist);
        color *= (percent.x >= 0.0 && percent.x <= 1.0) ? dist.xxx : float3(0.75f, 0.75f, 0.75f);
    }

    Output[px] = float4(color, 1.0);
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
