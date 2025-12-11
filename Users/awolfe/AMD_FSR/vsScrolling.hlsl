// Unnamed technique, shader VSScrollingText
/*$(ShaderResources)*/

struct VSInput
{
	uint   vertexID   : SV_VertexID;
	uint   instanceId : SV_InstanceID;
};

struct VSOutput // AKA PSInput
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

VSOutput vsmain(VSInput input)
{
    float3 a = float3(0.0f, 1.0f, 3.0f - float(input.instanceId) * 8.0f);
    float3 b = float3(0.0f, 2.0f, 3.0f - float(input.instanceId) * 8.0f);
    float3 c = float3(0.0f, 2.0f, 4.0f - float(input.instanceId) * 8.0f);
    float3 d = float3(0.0f, 1.0f, 4.0f - float(input.instanceId) * 8.0f);

    float2 uva = float2(0.0f, 1.0f);
    float2 uvb = float2(0.0f, 0.0f);
    float2 uvc = float2(1.0f, 0.0f);
    float2 uvd = float2(1.0f, 1.0f);

    float2 uv;
    float3 meshPos;
    switch (input.vertexID % 6)
    {
        case 0: meshPos = a; uv = uva; break;
        case 1: meshPos = b; uv = uvb; break;
        case 2: meshPos = c; uv = uvc; break;
        case 3: meshPos = a; uv = uva; break;
        case 4: meshPos = c; uv = uvc; break;
        case 5: meshPos = d; uv = uvd; break;
    }

    VSOutput ret = (VSOutput)0;
    ret.position = mul(float4(meshPos, 1.0f), /*$(Variable:JitteredViewProjMtx)*/);
    ret.UV = uv;

    float4 cameraPos = mul(float4(meshPos, 1.0f), /*$(Variable:ViewMtx)*/);
    ret.depth = cameraPos.z / cameraPos.w;

	ret.instanceId = input.instanceId;

	#if OPAQUE_PASS == 1
		ret.positionThisFrame = mul(float4(meshPos, 1.0f), /*$(Variable:ViewProjMtx)*/);
		ret.positionLastFrame = mul(float4(meshPos, 1.0f), /*$(Variable:ViewProjMtxLastFrame)*/);
	#endif

	return ret;
}
