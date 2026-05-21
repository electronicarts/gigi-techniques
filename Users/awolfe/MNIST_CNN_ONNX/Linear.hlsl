// mnist technique, shader Linear
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    int weightIndex = DTid.x * 100;

    // Evaluate this neuron by doing a dot product of the input with the weights, and adding the bias.
    float result = Bias[DTid.x];
    for (uint iz = 0; iz < 4; ++iz)
    {
        for (uint iy = 0; iy < 5; ++iy)
        {
            for (uint ix = 0; ix < 5; ++ix)
            {
                float pixelValue = Input[uint3(ix, iy, iz)];
                result += pixelValue * Weights[weightIndex];
                weightIndex++;
			}
		}
    }
    Output[DTid.x] = result;

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
        InterlockedMin(MaxValues[4 * 2 + 0], uvalue, dummy);
        InterlockedMax(MaxValues[4 * 2 + 1], uvalue, dummy);
    }
}

/*
Shader Resources:
	Buffer Weights (as SRV)
	Buffer Bias (as SRV)
	Texture Input (as SRV)
	Buffer Output (as UAV)
*/

/*
TODO:
* track max value (also min? for all of the previous layers too?)
* add this to the display!

*/