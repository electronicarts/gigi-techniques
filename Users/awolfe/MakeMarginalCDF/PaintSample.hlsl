// Unnamed technique, shader PaintSample
/*$(ShaderResources)*/

// Branchless binary search based on code from https://blog.demofox.org/2017/06/20/simd-gpu-friendly-branchless-binary-search/

#include "PCG.hlsli"

uint2 SampleICDF(float2 rng, in Texture2D<float> MarginalCDF)
{
    // Get the dimensions of the MarginalCDF
    uint2 MarginalCDFDims;
    MarginalCDF.GetDimensions(MarginalCDFDims.x, MarginalCDFDims.y);

    // Find the column of pixels we want to sample from by doing a branchless binary search.  This is our x axis.
    uint2 samplePos = uint2(0, 0);
    {
        uint numColumns = MarginalCDFDims.x;
        uint pow2Size = (uint)1 << uint(ceil(log2(numColumns)));

        // Do first step manually to handle the possibility of non power of 2
        uint searchSize = pow2Size / 2;
        uint ret = 0;
        ret = (MarginalCDF[uint2(ret + searchSize, 0)] <= rng.x) * (numColumns - searchSize);
        searchSize /= 2;

        // Do the rest of the steps
        while (searchSize > 0)
        {
            ret += (MarginalCDF[uint2(ret + searchSize, 0)] <= rng.x) * searchSize;
            searchSize /= 2;
        }
        samplePos.x = ret;
    }

    // Find the row we want to sample, in that column, by doing a branchless binary search. This is our y axis.
    {
        uint numRows = MarginalCDFDims.y - 1;
        uint pow2Size = (uint)1 << uint(ceil(log2(numRows)));

        // Do first step manually to handle the possibility of non power of 2
        uint searchSize = pow2Size / 2;
        uint ret = 0;
        ret = (MarginalCDF[uint2(samplePos.x, ret + searchSize + 1)] <= rng.y) * (numRows - searchSize);
        searchSize /= 2;

        // Do the rest of the steps
        while (searchSize > 0)
        {
            ret += (MarginalCDF[uint2(samplePos.x, ret + searchSize + 1)] <= rng.y) * searchSize;
            searchSize /= 2;
        }
        samplePos.y = ret;
    }

    return samplePos;
}

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    // Get our random values
    uint RNG = HashInit(uint3(DTid.xy, /*$(Variable:SampleIndex)*/));
    float2 rng = float2(RandomFloat01(RNG), RandomFloat01(RNG));

    // Get an importance sampled position
    uint2 samplePos = SampleICDF(rng, MarginalCDF);

    // Add one to that pixel
    uint oldValue;
    InterlockedAdd(Output[samplePos], 1, oldValue);
}

/*
Shader Resources:
	Texture MarginalCDF (as SRV)
	Texture Output (as UAV)
*/
