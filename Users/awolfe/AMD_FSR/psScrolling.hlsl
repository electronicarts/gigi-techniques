// Unnamed technique, shader PSScrollingText
/*$(ShaderResources)*/

struct PSInput // AKA VSOutput
{
	float4 position   : SV_POSITION;
	float2 UV         : TEXCOORD0;
	float  depth      : TEXCOORD3;
	uint   instanceId : TEXCOORD4;
	#if OPAQUE_PASS == 1
		float4 positionLastFrame : TEXCOORD5;
		float4 positionThisFrame : TEXCOORD6;
	#endif
};

struct PSOutput
{
	float4 colorTarget : SV_Target0;
    float4 linearDepth : SV_Target1;
	#if OPAQUE_PASS == 1
    	float2 motionVectors : SV_Target2;
	#endif
};

float ScrollTexture(float2 uv, float time)
{
    uint2 dims;
    /*$(Image:lorem.png:RGBA8_Unorm_sRGB:float4:false:true)*/.GetDimensions(dims.x, dims.y);

    uv.y *= float(dims.x) / float(dims.y);

    float2 scrolledUV = uv + float2(0.5f, 0.5f) * time;

    return /*$(Image:lorem.png:RGBA8_Unorm_sRGB:float4:true:true)*/.Sample(linearWrapSampler, scrolledUV).r;
}

PSOutput psmain(PSInput input)
{
    float time = float(/*$(Variable:iFrame)*/) / 60.0f;

    PSOutput ret = (PSOutput)0;
    ret.linearDepth = input.depth;
    ret.colorTarget = float4(ScrollTexture(input.UV, time).xxx, 1.0f);

	if (input.instanceId == 0 && ret.colorTarget.r == 1.0f)
		discard;

	#if OPAQUE_PASS == 1
    	ret.motionVectors = (input.positionLastFrame.xy / input.positionLastFrame.w) - (input.positionThisFrame.xy / input.positionThisFrame.w);	
	#endif

	return ret;
}
/*
Shader Samplers:
	linearWrapSampler filter: MinMagMipLinear addressmode: Wrap
*/
