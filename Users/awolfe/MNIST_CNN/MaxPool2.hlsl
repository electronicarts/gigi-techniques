// mnist technique, shader MaxPool1
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    float _00 = Input[uint3(DTid.xy * 2 + uint2(0, 0), DTid.z)];
	float _01 = Input[uint3(DTid.xy * 2 + uint2(0, 1), DTid.z)];
	float _10 = Input[uint3(DTid.xy * 2 + uint2(1, 0), DTid.z)];
	float _11 = Input[uint3(DTid.xy * 2 + uint2(1, 1), DTid.z)];

	float maxA = max(_00, _01);
    float maxB = max(_10, _11);
    float result = max(maxA, maxB);

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

        InterlockedMin(MaxValues[3].x, uvalue);
        InterlockedMax(MaxValues[3].y, uvalue);
    }

    Output[DTid] = result;
}

/*
Shader Resources:
	Texture Input (as SRV)
	Texture Output (as UAV)
*/
