// Unnamed technique, shader PS
/*$(ShaderResources)*/

/*$(Embed:Materials.hlsl)*/

struct PSInput // AKA VSOutput
{
	float4 position   : SV_POSITION;
	float2 UV0        : TEXCOORD0;
	float2 UV1        : TEXCOORD1;
	float2 UV2        : TEXCOORD2;
	float2 UV3        : TEXCOORD3;
	float3 normal     : TEXCOORD4;
	int    materialID : TEXCOORD5;
	float  depth      : TEXCOORD6;
	#if OPAQUE_PASS == 1
		float4 positionLastFrame : TEXCOORD7;
		float4 positionThisFrame : TEXCOORD8;
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

float4 ReadAlbedo(float2 UV, in Texture2D<float4> albedo, in Texture2D<float> transparency)
{
	float4 ret;
    ret.rgb = albedo.SampleBias(linearWrapSampler, UV, /*$(Variable:LODBias)*/).rgb;
    ret.a = transparency.SampleBias(linearWrapSampler, UV, /*$(Variable:LODBias)*/);
	return ret;
}

float4 ReadAlbedo(float2 UV, in Texture2D<float4> albedo)
{
    float4 ret;
    ret.rgb = albedo.SampleBias(linearWrapSampler, UV, /*$(Variable:LODBias)*/).rgb;
	ret.a = 1.0f;
	return ret;
}


PSOutput psmain(PSInput input)
{
	PSOutput ret = (PSOutput)0;
	ret.linearDepth = input.depth;

    // Material Properties
    float3 matNormal = float3(0.0f, 0.0f, 1.0f);
    float matOcclusion = 1.0f;
    Struct_Materials material = Material_MaterialBuffer(MaterialBuffer, input.materialID, input.UV0, input.UV1, input.UV2, input.UV3, matNormal, matOcclusion, ddx(input.UV0), ddy(input.UV0), ddx(input.UV1), ddy(input.UV1), ddx(input.UV2), ddy(input.UV2), ddx(input.UV3), ddy(input.UV3));

    float4 albedo = float4(material.baseColor.rgb, 1.0f);

	#if OPAQUE_PASS == 1
		if (albedo.a < 1.0f)
			discard;
	#else
		if (albedo.a >= 1.0f)
			discard;
	#endif

	float3 lightDir = normalize(float3(0.2f, 1.0f, 0.3f));
	float3 lightColor = float3(1.0f, 1.0f, 1.0f);
	float3 ambientLightColor = float3(0.1f, 0.1f, 0.1f);

	float3 color = albedo * (max(dot(input.normal, lightDir), 0.0f) * lightColor + ambientLightColor);

    float preExposure = pow(2.0f, /*$(Variable:PreExposureFStops)*/);
    color *= preExposure;

	ret.colorTarget = float4(color, albedo.a);

	#if OPAQUE_PASS == 1
        ret.motionVectors = (input.positionLastFrame.xy / input.positionLastFrame.w) - (input.positionThisFrame.xy / input.positionThisFrame.w);
        ret.motionVectors *= float2(0.5f, -0.5f);
	#endif

	return ret;
}
