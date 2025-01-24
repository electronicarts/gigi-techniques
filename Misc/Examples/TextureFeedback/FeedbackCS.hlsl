// Unnamed technique, shader FeedbackCS
/*$(ShaderResources)*/

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

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
	// We need a last frame texture to read from and a next frame texture to write to, because each compute shader
	// can be thought of as an individual thread running.  When one thread wants to read the old texture at a
	// specific location, a previous thread may have over-written it by then.
	// Having a separate last frame to read from and a next frame to write to means that this operation is thread safe.

	uint2 px = DTid.xy;

	// If this is the first frame, or the user wants to reset, pass the input color through
	if (/*$(Variable:iFrame)*/ == 0 || /*$(Variable:Reset)*/)
	{
		NextFrame[px] = float4(LinearToSRGB(Input[px].rgb), 1.0f);
		return;
	}

	// Otherwise, blur last frame to make the next frame
	uint2 inputDims;
	Input.GetDimensions(inputDims.x, inputDims.y);
	static const int c_radius = 2;
	static const int c_numPixels = (c_radius*2+1)*(c_radius*2+1);
	float3 color = float3(0.0f, 0.0f, 0.0f);
	for (int iy = -c_radius; iy <= c_radius; ++iy)
	{
		for (int ix = -c_radius; ix <= c_radius; ++ix)
		{
			uint2 readPx = uint2(int2(px) + int2(ix, iy) + int2(inputDims)) % inputDims;
			color += LastFrame[readPx].rgb;
		}
	}
	color = color / float(c_numPixels);

	color = LinearToSRGB(color);

	NextFrame[px] = float4(color, 1.0f);
}

/*
Shader Resources:
	Texture Input (as SRV)
	Texture LastFrame (as SRV)
	Texture NextFrame (as UAV)
*/
