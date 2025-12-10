// Unnamed technique, shader DistortVideo
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
	uint2 px = DTid.xy;

    uint2 dims;
	Output.GetDimensions(dims.x, dims.y);

    float3 rgb;

	rgb.r = WebCam[(int2(px) + /*$(Variable:OffsetR)*/ + int2(dims)) % dims].r;
	rgb.g = WebCam[(int2(px) + /*$(Variable:OffsetG)*/ + int2(dims)) % dims].g;
	rgb.b = WebCam[(int2(px) + /*$(Variable:OffsetB)*/ + int2(dims)) % dims].b;

    rgb *= /*$(Variable:Tint)*/;

    Output[px] = float4(rgb, 1.0f);
}

/*
Shader Resources:
	Texture WebCam (as SRV)
	Texture Output (as UAV)
*/

