// Unnamed technique, shader BunnyVS
/*$(ShaderResources)*/

struct VSInput
{
    float3 position : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    uint instanceID : SV_InstanceID;
};

struct VSOutput // AKA PSInput
{
    float4 position : SV_POSITION;
    float3 normal : TEXCOORD0;
    float2 uv : TEXCOORD1;
    uint instanceID : TEXCOORD2;
};

VSOutput main(VSInput input)
{
    VSOutput ret = (VSOutput)0;

    float3 offset = float3(2.0f * float(input.instanceID), 0.0f, 0.0f);

    ret.position = mul(float4(input.position + offset, 1.0f), /*$(Variable:ViewProjMtx)*/);

    ret.normal = input.normal;
    ret.uv = input.uv;
	ret.instanceID = input.instanceID;

    return ret;
}
