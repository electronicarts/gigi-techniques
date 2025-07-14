// mnist technique, shader Conv1
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    int weightsBegin = DTid.z * 18;

    // Convolution of input and weights
    float result = 0.0f;
    uint3 readPx = uint3(0, 0, 0);
    for (uint iz = 0; iz < 2; ++iz)
    {
        readPx.z = iz;
        for (uint iy = 0; iy < 3; ++iy)
        {
            readPx.y = DTid.y + iy;
            for (uint ix = 0; ix < 3; ++ix)
            {
                readPx.x = DTid.x + ix;
                result += Input[readPx] * Weights[weightsBegin + iz * 9 + iy * 3 + ix];
            }
        }
    }

    // Bias
    result += Bias[DTid.z];

    // Sigmoid
    result = 1.0f / (1.0f + exp(-result));

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

        uint dummy = 0;
        InterlockedMin(MaxValues[2 * 2 + 0], uvalue, dummy);
        InterlockedMax(MaxValues[2 * 2 + 1], uvalue, dummy);
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
