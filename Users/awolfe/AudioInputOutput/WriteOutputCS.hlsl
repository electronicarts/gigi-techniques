// Unnamed technique, shader WriteOutputCS
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:SamplesActuallyRead)*/)
        return;

    // the read position is (writePos - count), but we need to handle wrap around.
    uint2 circularBufferReadPos = (/*$(Variable:CircularBufferWritePos)*/ + /*$(Variable:CircularBufferSizeSamples)*/ - /*$(Variable:CircularBufferCount)*/ + DTid.x);

    if (/*$(Variable:AudioStereo)*/)
    {
        uint readIndex1 = (circularBufferReadPos * 2 + 0) % /*$(Variable:CircularBufferSizeFloats)*/;
        uint readIndex2 = (circularBufferReadPos * 2 + 1) % /*$(Variable:CircularBufferSizeFloats)*/;
        uint writeIndex1 = DTid.x * 2 + 0;
        uint writeIndex2 = DTid.x * 2 + 1;
        AudioOutput[writeIndex1] = CircularBuffer[readIndex1];
        AudioOutput[writeIndex2] = CircularBuffer[readIndex2];
    }
    else
    {
        uint readIndex = (circularBufferReadPos) % /*$(Variable:CircularBufferSizeFloats)*/;
        uint writeIndex = DTid.x;
        AudioOutput[writeIndex] = CircularBuffer[readIndex];
    }	
}

/*
Shader Resources:
    Buffer CircularBuffer (as SRV)
    Buffer AudioOutput (as UAV)
*/
