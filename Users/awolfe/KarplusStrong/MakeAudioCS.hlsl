// Unnamed technique, shader MakeAudio
/*$(ShaderResources)*/

static const float c_pi = 3.14159265359f;
static const float c_twoPi = c_pi * 2.0f;

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:AudioOutSampleWindowCount)*/)
        return;

    float sample = 0.0f;

    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
		if (Voices[i].noteSamples == 0)
			continue;

        uint sampleIndex = Voices[i].sampleOffset + DTid.x;

        float voice = NotesBuffer[i * /*$(Variable:_MaxNotesSamples)*/ + (sampleIndex % Voices[i].noteSamples)];

        sample += voice * /*$(Variable:Volume)*/;
	}

    float volLeft = 1.0f;
    float volRight = 1.0f;
    if (/*$(Variable:SpinnerFrequency)*/ > 0.0f)
    {
        float time = float(/*$(Variable:SpinnerSampleClock)*/) / float(/*$(Variable:AudioOutSampleRate)*/);
        volLeft = sin(/*$(Variable:SpinnerFrequency)*/ * c_twoPi * time);
        volRight = cos(/*$(Variable:SpinnerFrequency)*/ * c_twoPi * time);
    }

    if (/*$(Variable:AudioOutStereo)*/)
    {
        Audio[DTid.x * 2 + 0] = sample * volLeft;
        Audio[DTid.x * 2 + 1] = sample * volRight;
    }
    else
    {
        Audio[DTid.x] = sample * volLeft;
	}
}

/*
Shader Resources:
    Buffer Audio (as UAV)
    Buffer Voices (as UAV)
    Buffer NotesBuffer (as SRV)
*/
