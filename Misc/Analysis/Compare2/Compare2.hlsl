// Compare2 technique, shader Compare2
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
	// Calculate where the separator is
	uint2 dims;
	Out.GetDimensions(dims.x, dims.y);
	uint separatorX = clamp(uint(float(dims.x) * /*$(Variable:LeftSizePercent)*/), 0, dims.x-1);

	int distance = abs((int)DTid.x - (int)separatorX);

	if (distance <= 1)
	{
		float color = float(distance);
		Out[DTid.xy] = float4(color.xxx, 1.0f);
		return;
	}
	else if (DTid.x < separatorX)
		Out[DTid.xy] = A[DTid.xy];
	else
	{
		if (/*$(Variable:ShowSameHalf)*/)
			Out[DTid.xy] = B[DTid.xy - uint2(separatorX, 0)];
		else
			Out[DTid.xy] = B[DTid.xy];
	}
}

/*
Shader Resources:
	Texture A (as SRV)
	Texture B (as SRV)
	Texture Out (as UAV)
*/
