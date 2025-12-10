// Unnamed technique, shader MakeVideo
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
	uint2 px = DTid.xy;

    uint2 dimsInstructions;
    /*$(Image2D:Instructions.png:RGBA8_UNorm_SRGB:float4:true:false)*/.GetDimensions(dimsInstructions.x, dimsInstructions.y);

    uint2 dimsOutput;
	Output.GetDimensions(dimsOutput.x, dimsOutput.y);

    uint2 margins = (dimsOutput - dimsInstructions) / 2;

    float2 uv = float2(px) / float2(dimsOutput);
    float time = /*$(Variable:iTime)*/;

    // Create a colorful low-frequency animated pattern
    float3 color;
    color.r = 0.5 + 0.5 * sin(uv.x * 3.0 + time * 0.5 + sin(uv.y * 2.0 + time * 0.3) * 2.0);
    color.g = 0.5 + 0.5 * sin(uv.y * 3.0 + time * 0.7 + cos(uv.x * 2.5 - time * 0.4) * 2.0);
    color.b = 0.5 + 0.5 * sin((uv.x + uv.y) * 2.5 - time * 0.6 + sin(time * 0.2) * 3.0);

	if (px.x >= margins.x && px.x < (margins.x + dimsInstructions.x) &&
		px.y >= margins.y && px.y < (margins.y + dimsInstructions.y))
	{
        float3 instructionPixel = /*$(Image2D:Instructions.png:RGBA8_UNorm_SRGB:float4:true:false)*/[px - margins].rgb;
		color = lerp(color, instructionPixel, 2.0f / 3.0f);
	}
	
	Output[px] = float4(color, 1.0);
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
