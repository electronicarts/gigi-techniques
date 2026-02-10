// Unnamed technique, shader VS
/*$(ShaderResources)*/

struct VSInput
{
	float3 position   : POSITION;
	float3 normal     : NORMAL;
	float2 UV0        : TEXCOORD0;
	float2 UV1        : TEXCOORD1;
	float2 UV2        : TEXCOORD2;
	float2 UV3        : TEXCOORD3;
	int    materialID : TEXCOORD4;
};

struct VSOutput // AKA PSInput
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

VSOutput vsmain(VSInput input)
{
    float3 meshPos = input.position * /*$(Variable:MeshScale)*/;

    VSOutput ret = (VSOutput)0;
    ret.position = mul(float4(meshPos, 1.0f), /*$(Variable:JitteredViewProjMtx)*/);
    ret.UV0 = input.UV0;
    ret.UV1 = input.UV1;
    ret.UV2 = input.UV2;
    ret.UV3 = input.UV3;
	ret.normal = input.normal;
	ret.materialID = input.materialID;

    float4 cameraPos = mul(float4(meshPos, 1.0f), /*$(Variable:ViewMtx)*/);
	ret.depth = cameraPos.z / cameraPos.w;

	#if OPAQUE_PASS == 1
		ret.positionThisFrame = mul(float4(meshPos, 1.0f), /*$(Variable:ViewProjMtx)*/);
		ret.positionLastFrame = mul(float4(meshPos, 1.0f), /*$(Variable:ViewProjMtxLastFrame)*/);
	#endif

	return ret;
}
