// Unnamed technique, shader MakeAudio
/*$(ShaderResources)*/

static const float c_pi = 3.14159265359f;

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:AudioOutSampleWindowCount)*/)
      return;

    uint audioSampleIndex = (/*$(Variable:AudioOutSampleWindowStart)*/ + DTid.x) % /*$(Variable:AudioOutSampleRate)*/;

    float audioSampleTime = float(audioSampleIndex) / float(/*$(Variable:AudioOutSampleRate)*/);

    float left = sin(frac(audioSampleTime * /*$(Variable:Frequency)*/) * c_pi * 2.0f) * /*$(Variable:Volume)*/;
    float right = cos(frac(audioSampleTime * /*$(Variable:Frequency)*/) * c_pi * 2.0f) * /*$(Variable:Volume)*/;

    if (/*$(Variable:AudioOutStereo)*/)
    {
        Audio[DTid.x * 2 + 0] = left;
        Audio[DTid.x * 2 + 1] = right;
    }
    else
    {
        Audio[DTid.x] = left;
    }
}

/*
Shader Resources:
	Buffer Audio (as UAV)
*/
