// Unnamed technique, shader MakeAudio
/*$(ShaderResources)*/

static const float c_pi = 3.14159265359f;
static const float c_twoPi = c_pi * 2.0f;

float makeSound(float time)
{
    return sin(/*$(Variable:Frequency)*/ *c_twoPi * time);
}

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:AudioOutSampleWindowCount)*/)
      return;

    float SOUND_ORBIT_RATE = /*$(Variable:OrbitRate)*/;

    uint audioSampleIndex = (/*$(Variable:AudioOutSampleWindowStart)*/ +DTid.x) % /*$(Variable:_MaxAudioSample)*/;

    float time = float(audioSampleIndex) / float(/*$(Variable:AudioOutSampleRate)*/);

    // generate a mono channel sound
    float monoSound = makeSound(time);

    // Make a little envelope to hide the fact that we restart the audio clock every ~10 seconds to avoid floating point problems which show up as audio artifacts.
    float envelope = 1.0f;
    {
        uint envelopeSize = uint(0.05f * float(/*$(Variable:AudioOutSampleRate)*/));
        if (audioSampleIndex < envelopeSize)
        {
            envelope *= float(audioSampleIndex) / float(envelopeSize);
        }
        else if (audioSampleIndex > (/*$(Variable:_MaxAudioSample)*/ - envelopeSize))
        {
            envelope *= float(/*$(Variable:_MaxAudioSample)*/ - audioSampleIndex) / float(envelopeSize);
        }
    }

    // calculate the volume for the left and right channel
    float volumeLeft = cos(SOUND_ORBIT_RATE * c_twoPi * time) * envelope * /*$(Variable:Volume)*/ * monoSound;
    float volumeRight = sin(SOUND_ORBIT_RATE * c_twoPi * time) * envelope * /*$(Variable:Volume)*/ * monoSound;

    if (/*$(Variable:AudioOutStereo)*/)
    {
        Audio[DTid.x * 2 + 0] = volumeLeft;
        Audio[DTid.x * 2 + 1] = volumeRight;
    }
    else
    {
        Audio[DTid.x] = volumeLeft;
    }
}

/*
Shader Resources:
	Buffer Audio (as UAV)
*/
