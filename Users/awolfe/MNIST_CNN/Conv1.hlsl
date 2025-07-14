// mnist technique, shader Conv1
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    int weightsBegin = DTid.z * 25;

    // Convolution of input and weights
    float result = 0.0f;
    uint2 readPx = uint2(0, 0);
    for (uint iy = 0; iy < 5; ++iy)
    {
        readPx.y = DTid.y + iy;
        for (uint ix = 0; ix < 5; ++ix)
        {
            readPx.x = DTid.x + ix;
            result += Input[readPx] * Weights[weightsBegin + iy * 5 + ix];
        }
    }

    // Bias
    result += Bias[DTid.z];

    // Relu
    result = max(result, 0);

    // Store the maximum value seen
    // https://www.jeremyong.com/graphics/2023/09/05/f32-interlocked-min-max-hlsl/
    {
        uint uvalue = asuint(result);

        if ((uvalue >> 31) == 0)
        {
            // The sign bit wasn't set, so set it temporarily.
            uvalue = uvalue | (1 << 31);
        }
        else
        {
            // In the case where we started with a negative value, take
            // the ones complement.
            uvalue = ~uvalue;
        }

        InterlockedMin(MaxValues[0].x, uvalue);
        InterlockedMax(MaxValues[0].y, uvalue);
    }

    // write result
    Output[DTid.xyz] = result;
}

/*
Shader Resources:
	Buffer Weights (as SRV)
	Buffer Bias (as SRV)
	Texture Output (as UAV)
	Texture Input (as SRV)
*/
