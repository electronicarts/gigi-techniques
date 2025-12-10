// Unnamed technique, shader OutputEffectCS
/*$(ShaderResources)*/

static const float c_pi = 3.14159265359f;
static const float c_twoPi = 2.0f * c_pi;

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:SamplesActuallyRead)*/)
        return;
	
	uint timeSamples = (/*$(Variable:AudioClockMod1Sec_Out)*/ + DTid.x) % (/*$(Variable:AudioSampleRate)*/);
	float timeSeconds = float(timeSamples) / float(/*$(Variable:AudioSampleRate)*/);

    if (/*$(Variable:AudioStereo)*/)
    {
		float sample1 = AudioOutput[DTid.x * 2 + 0];
		float sample2 = AudioOutput[DTid.x * 2 + 1];

        sample1 *= sin(/*$(Variable:OrbitHz)*/ * c_twoPi * timeSeconds) * 0.5f + 0.5f;
        sample2 *= cos(/*$(Variable:OrbitHz)*/ * c_twoPi * timeSeconds) * 0.5f + 0.5f;

        AudioOutput[DTid.x * 2 + 0] = sample1;
		AudioOutput[DTid.x * 2 + 1] = sample2;
	}
    else
    {
        float sample = AudioOutput[DTid.x];
        sample *= sin(/*$(Variable:OrbitHz)*/ * c_twoPi * timeSeconds) * 0.5f + 0.5f;
        AudioOutput[DTid.x] = sample;
	}
}

/*
Shader Resources:
	Buffer AudioOutput (as UAV)
*/
