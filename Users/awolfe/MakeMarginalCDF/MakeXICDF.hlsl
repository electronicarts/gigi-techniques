// Unnamed technique, shader MakeXICDF
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint count = 0;
    uint stride = 0;
    ColumnSums.GetDimensions(count, stride);

    float scale = 0.0f;
    for (int i = 0; i < count; ++i)
        scale += ColumnSums[i];

	float sum = 0.0f;
    for (int i = 0; i < count; ++i)
    {
        sum += ColumnSums[i];
        Output[uint2(i, 0)] = (scale > 0.0f) ? sum / scale : 0.0f;
    }
    InputSum[0] = scale;
}

/*
Shader Resources:
	Buffer ColumnSums (as SRV)
	Buffer Output (as UAV)
    Buffer InputSum (as UAV)
*/
