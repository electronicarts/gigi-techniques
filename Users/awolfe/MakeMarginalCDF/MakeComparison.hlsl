// Unnamed technique, shader MakeComparison
/*$(ShaderResources)*/

#include "gnuplot.hlsl"

float3 LinearToSRGB(float3 linearCol)
{
    float3 sRGBLo = linearCol * 12.92;
    float3 sRGBHi = (pow(abs(linearCol), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
    float3 sRGB;
    sRGB.r = linearCol.r <= 0.0031308 ? sRGBLo.r : sRGBHi.r;
    sRGB.g = linearCol.g <= 0.0031308 ? sRGBLo.g : sRGBHi.g;
    sRGB.b = linearCol.b <= 0.0031308 ? sRGBLo.b : sRGBHi.b;
    return sRGB;
}

float3 SRGBToLinear(in float3 sRGBCol)
{
    float3 linearRGBLo = sRGBCol / 12.92;
    float3 linearRGBHi = pow((sRGBCol + 0.055) / 1.055, float3(2.4, 2.4, 2.4));
    float3 linearRGB;
    linearRGB.r = sRGBCol.r <= 0.04045 ? linearRGBLo.r : linearRGBHi.r;
    linearRGB.g = sRGBCol.g <= 0.04045 ? linearRGBLo.g : linearRGBHi.g;
    linearRGB.b = sRGBCol.b <= 0.04045 ? linearRGBLo.b : linearRGBHi.b;
    return linearRGB;
}

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 InputDims;
    Input.GetDimensions(InputDims.x, InputDims.y);

    uint2 px = DTid.xy;
    if (px.x < InputDims.x)
    {
        uint2 pxIn = px;
        float shade = dot(Input[pxIn], /*$(Variable:InputDotProduct)*/);
        if (/*$(Variable:InputMaxValue)*/ > 0.0f)
            shade = min(shade, /*$(Variable:InputMaxValue)*/);		
        Comparison[px] = float4(LinearToSRGB(shade.xxx), 1.0f);
    }
    else if (px.x < InputDims.x * 2)
    {
        uint2 pxIn = px;
        pxIn.x -= InputDims.x;
        float numSamplesTaken = float(/*$(Variable:SampleIndex)*/) * 64.0f * 64.0f; // SampleIndex times the dispatch size of "PaintSample"
        float shade = float(Reconstruction[pxIn]) * InputSum[0] / numSamplesTaken;
        Comparison[px] = float4(LinearToSRGB(shade.xxx), 1.0f);
	}
    else
    {
        uint2 pxIn = px;
        pxIn.x -= InputDims.x * 2;

        float shadeLeft = dot(Input[pxIn], /*$(Variable:InputDotProduct)*/);
        if (/*$(Variable:InputMaxValue)*/ > 0.0f)
            shadeLeft = min(shadeLeft, /*$(Variable:InputMaxValue)*/);

        float numSamplesTaken = float(/*$(Variable:SampleIndex)*/) * 64.0f * 64.0f; // SampleIndex times the dispatch size of "PaintSample"
        float shadeRight = float(Reconstruction[pxIn]) * InputSum[0] / numSamplesTaken;

		// Calculate diff
        float diff = abs(shadeLeft - shadeRight);
        if (/*$(Variable:RelativeError)*/)
        {
            if (shadeLeft > 0.0f)
            	diff /= shadeLeft;
            else
                diff = 0.0f;
        }
        diff = clamp(diff, 0.0f, 1.0f);

        // Calculate the color to show
        float3 color = /*$(Variable:ColorMap)*/ ? colormap(diff, 7, 5, 15).xyz : LinearToSRGB(diff.xxx);

        Comparison[px] = float4(color, 1.0f);

        if (/*$(Variable:ColorMap)*/ && /*$(Variable:ShowColorMapLegend)*/ && pxIn.y < 20)
        {
            float percent = float(pxIn.x) / float(InputDims.x);
            Comparison[px] = float4(colormap(percent, 7, 5, 15).xyz, 1.0f);
        }
    }
}

/*
Shader Resources:
	Texture Input (as SRV)
	Texture Reconstruction (as SRV)
	Texture Comparison (as UAV)
	Buffer InputSum (as SRV)
*/
