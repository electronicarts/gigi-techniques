// Unnamed technique, shader TemporalCS
/*$(ShaderResources)*/

#include "SRGB.hlsli"

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 px = DTid.xy;
    float4 inputColor = Color[px];
	inputColor.rgb = SRGBToLinear(inputColor.rgb);

    bool resetTemporal = /*$(Variable:CameraChanged)*/ || /*$(Variable:Reset Temporal)*/ || /*$(Variable:ParamChanged)*/;

	float4 outputColor = float4(0.0f, 0.0f, 0.0f, 0.0f);
	float4 outputTemporal = float4(0.0f, 0.0f, 0.0f, 0.0f);
    switch (/*$(Variable:TemporalMode)*/)
    {
		case TemporalModes::None:
        {
            outputColor = inputColor;
			break;
        }
        case TemporalModes::EMA:
        {
            float alpha = resetTemporal ? 1.0f : /*$(Variable:EMAAlpha)*/;
            outputColor.rgb = lerp(Temporal[px].rgb, inputColor.rgb, alpha);
            outputColor.a = 1.0f;

			outputTemporal = outputColor;
            break;
        }
        case TemporalModes::Integrate:
        {
            uint sampleCount = resetTemporal ? 0 : uint(Temporal[px].a);
			float alpha = 1.0f / float(sampleCount + 1);

            outputColor.rgb = lerp(Temporal[px].rgb, inputColor.rgb, alpha);
            outputColor.a = 1.0f;

            outputTemporal = float4(outputColor.rgb, sampleCount + 1);
            break;
		}
	}

    outputColor.rgb = LinearToSRGB(outputColor.rgb);
    Color[px] = outputColor;

	Temporal[px] = outputTemporal;
}

/*
Shader Resources:
    Texture Color (as UAV)
	Texture Temporal (as UAV)
*/
