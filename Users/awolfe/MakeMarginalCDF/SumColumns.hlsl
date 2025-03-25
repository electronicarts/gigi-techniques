// Unnamed technique, shader SumColumns
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 InputDims;
    Input.GetDimensions(InputDims.x, InputDims.y);

    float sum = 0.0f;
    for (uint iy = 0; iy < InputDims.y; ++iy)
    {
        float value = dot(Input[uint2(DTid.x, iy)], /*$(Variable:InputDotProduct)*/);
        if (/*$(Variable:InputMaxValue)*/ > 0.0f)
            value = min(value, /*$(Variable:InputMaxValue)*/);
        sum += value;
    }

    Output[DTid.x] = sum;
}

/*
Shader Resources:
	Texture Input (as SRV)
	Buffer Output (as UAV)
*/
