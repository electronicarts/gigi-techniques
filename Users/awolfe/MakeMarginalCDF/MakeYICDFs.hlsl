// Unnamed technique, shader MakeColumnsICDFs
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 InputDims;
    Input.GetDimensions(InputDims.x, InputDims.y);

    float scale = ColumnSums[DTid.x];

    float sum = 0.0f;
    for (uint iy = 0; iy < InputDims.y; ++iy)
    {
        float value = dot(Input[uint2(DTid.x, iy)], /*$(Variable:InputDotProduct)*/);
        if (/*$(Variable:InputMaxValue)*/ > 0.0f)
            value = min(value, /*$(Variable:InputMaxValue)*/);
        sum += value;
        Output[uint2(DTid.x, iy)] = (scale > 0.0f) ? sum / scale : 0.0f;
    }
}

/*
Shader Resources:
    Texture Input (as SRV)
    Buffer ColumnSums (as SRV)
	Texture Output (as UAV)
*/
