///////////////////////////////////////////////////////////////////////////////
//     Filter-Adapted Spatio-Temporal Sampling With General Distributions    //
//        Copyright (c) 2024 Electronic Arts Inc. All rights reserved.       //
///////////////////////////////////////////////////////////////////////////////

// Low discrepancy invertible stateless shuffler is from https://blog.demofox.org/2024/10/04/a-two-dimensional-low-discrepancy-shuffle-iterator-random-access-inversion/

// Example calculations
// 128x128 is 16384 pixels to shuffle, so numItems = 16384
// Coprime is 10127, calculated by code at that repo to be the coprime value closest to the golden ratio.
// StepsToUnity is 5999, calculated by code at that repo, using the chinese remainder theorem.
// Seed is the random seed of the shuffle, such as the constant "435".

// Return shuffle[index]
uint LDSShuffle1D_GetValueAtIndex(uint index, uint numItems, uint coprime, uint seed)
{
    return ((index % numItems) * coprime + seed) % numItems;
}

// return the index where shuffle[index] == value
uint LDSShuffle1D_GetIndexOfValue(uint value, uint numItems, uint stepsToUnity, uint seed)
{
    uint stepsToValue = (stepsToUnity * value) % numItems;
    uint stepsToSeed = (stepsToUnity * seed) % numItems;
    return (stepsToValue + numItems - stepsToSeed) % numItems;
}

void RotateAndFlip(in uint n, inout int x, inout int y, in int indexx, in int indexy)
{
    if (indexy != 0)
        return;

    if (indexx == 1)
    {
        x = n - x - 1;
        y = n - y - 1;
    }

    int temp = x;
    x = y;
    y = temp;
}

uint2 Convert1DTo2D_Hilbert(in uint shuffleIndex, in uint itemCount)
{
    int x = 0;
    int y = 0;

    for (int layerCount = 1; layerCount < itemCount; layerCount = layerCount * 2)
    {
        int indexx = (shuffleIndex / 2) % 2;
        int indexy = (shuffleIndex ^ indexx) % 2;
        RotateAndFlip(layerCount, x, y, indexx, indexy);
        x += layerCount * indexx;
        y += layerCount * indexy;
        shuffleIndex /= 4;
    }

    return uint2(x, y);
}
