// Unnamed technique, shader MakeRNGCS
/*$(ShaderResources)*/

#include "PCG.hlsli"

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 px = DTid.xy;

    uint3 rngSeed = uint3(px, /*$(Variable:iFrame)*/);

    if (!/*$(Variable:PerPixel)*/)
        rngSeed.xy = uint2(0x1337, 0xbeef);

    if (!/*$(Variable:Animate)*/)
        rngSeed.z = 0;

    uint rngState = HashInit(rngSeed);

    float3 color = float3(0.0f, 0.0f, 0.0f);
    if (/*$(Variable:Color)*/)
    {
        color = float3(
            RandomFloat01(rngState),
            RandomFloat01(rngState),
            RandomFloat01(rngState)
		);
	}
    else
    {
        color = RandomFloat01(rngState).xxx;
	}

    Output[px] = float4(color, 1.0f);
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
