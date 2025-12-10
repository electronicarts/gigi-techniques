// Unnamed technique, shader ReadInputCS
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:SamplesActuallyWritten)*/)
        return;

    uint2 circularBufferReadPos = (/*$(Variable:CircularBufferWritePos)*/ + /*$(Variable:CircularBufferSizeSamples)*/ - /*$(Variable:CircularBufferCount)*/ + DTid.x);

    if (/*$(Variable:AudioStereo)*/)
    {
        uint readIndex1 = DTid.x * 2 + 0;
        uint readIndex2 = DTid.x * 2 + 1;
        uint writeIndex1 = ((/*$(Variable:CircularBufferWritePos)*/ + DTid.x) * 2 + 0) % /*$(Variable:CircularBufferSizeFloats)*/;
        uint writeIndex2 = ((/*$(Variable:CircularBufferWritePos)*/ + DTid.x) * 2 + 1) % /*$(Variable:CircularBufferSizeFloats)*/;
        CircularBuffer[writeIndex1] = AudioInput[readIndex1];
        CircularBuffer[writeIndex2] = AudioInput[readIndex2];
    }
    else
    {
        uint readIndex = DTid.x;
        uint writeIndex = (/*$(Variable:CircularBufferWritePos)*/ + DTid.x) % /*$(Variable:CircularBufferSizeFloats)*/;
        CircularBuffer[writeIndex] = AudioInput[readIndex];
    }
}

/*
Shader Resources:
    Buffer AudioInput (as SRV)
    Buffer CircularBuffer (as UAV)
*/
