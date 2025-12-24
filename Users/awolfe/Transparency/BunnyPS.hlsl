// Unnamed technique, shader BunnyPS
/*$(ShaderResources)*/

#include "PCG.hlsli"

struct PSInput // AKA VSOutput
{
    float4 position : SV_POSITION;
    float3 normal : TEXCOORD0;
    float2 uv : TEXCOORD1;
    uint instanceID : TEXCOORD2;
};

struct PSOutput
{
    float4 colorTarget : SV_Target0;
};

float IGN(float2 px)
{
    return frac(52.9829189f * frac(0.06711056f * px.x + 0.00583715f * px.y));
}

float SampleSpatioTemporalTexture(in Texture2DArray<float> t, uint2 px, int frameIndex)
{
    uint width, height, depth;
    t.GetDimensions(width, height, depth);
    return t[uint3(px % uint2(width, height), frameIndex % depth)];
}

PSOutput main(PSInput input)
{
	PSOutput ret = (PSOutput)0;

    uint frameIndex = /*$(Variable:AnimateNoise)*/ ? /*$(Variable:iFrame)*/ : 0;
	uint2 noisePx = uint2(input.position.xy);

    if (/*$(Variable:InstanceNoise)*/)
		noisePx += uint2(input.instanceID * 37, input.instanceID * 57);

	switch(/*$(Variable:ColorMode)*/)
    {
    	case ColorModes::Normal: ret.colorTarget = float4(input.normal * 0.5f + 0.5f, 1.0f); break;
        case ColorModes::UV: ret.colorTarget = float4(input.uv, 0.0f, 1.0f); break;
        case ColorModes::SolidColor: ret.colorTarget = float4(/*$(Variable:SolidColor)*/, 1.0f); break;
        case ColorModes::Texture: ret.colorTarget = BunnyTex.Sample(texSampler, input.uv); break; // TODO: this
	}

    switch (input.instanceID)
    {
    	case 0: ret.colorTarget.a = /*$(Variable:Alpha1)*/; break;
		case 1: ret.colorTarget.a = /*$(Variable:Alpha2)*/; break;
		case 2: ret.colorTarget.a = /*$(Variable:Alpha3)*/; break;
        case 3: ret.colorTarget.a = /*$(Variable:Alpha4)*/; break;
        case 4: ret.colorTarget.a = /*$(Variable:Alpha5)*/; break;
	}

    switch (/*$(Variable:TransparencyMode)*/)
    {
		case TransparencyModes::Transparency: break; // no-op. real transparency
		case TransparencyModes::White:
        {
            uint rng = HashInit(uint3(noisePx, frameIndex));
			float rnd = RandomFloat01(rng);
            if (rnd > ret.colorTarget.a)
                discard;
            ret.colorTarget.a = 1.0f;
			break;
        }
        case TransparencyModes::Blue:
        {
            float rnd = SampleSpatioTemporalTexture(/*$(Image2DArray:FAST/real_uniform_gauss1_0_exp0101_separate05_%i.png:R8_Unorm:float:false)*/, noisePx, frameIndex);
            if (rnd > ret.colorTarget.a)
                discard;
            ret.colorTarget.a = 1.0f;
            break;
		}
        case TransparencyModes::IGN:
        {
            float rnd = IGN(noisePx);
			if (rnd > ret.colorTarget.a)
				discard;
			ret.colorTarget.a = 1.0f;
			break;
		}
	}

	return ret;
}
