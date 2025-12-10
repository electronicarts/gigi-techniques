// Unnamed technique, shader MakeAudio
/*$(ShaderResources)*/

static const float c_pi = 3.14159265359f;
static const float c_twoPi = c_pi * 2.0f;

#include "ADSR.hlsli"

float CalculateVoice(float phase)
{
    switch (/*$(Variable:WaveForm)*/)
    {
		case WaveForms::Sine:
        {
            return sin(phase * c_twoPi);
		}
		case WaveForms::Triangle:
		{
            if (/*$(Variable:Harmonics)*/ == 0)
            {
                float ret = 0.0f;
                if (phase <= 0.5f)
                    ret = phase * 2.0f;
                else
                    ret = (1.0f - phase) * 2.0f;

                return (ret * 2.0f) - 1.0f;
            }
            else
            {
                float ret = 0.0f;
                for (int harmonicIndex = 1; harmonicIndex <= /*$(Variable:Harmonics)*/; ++harmonicIndex)
                {
                    float value = sin(phase * c_twoPi * (float)(harmonicIndex * 2 - 1)) / ((float)(harmonicIndex * 2 - 1) * (float)(harmonicIndex * 2 - 1));
                    bool bIsOdd = (harmonicIndex % 2) == 1;
					ret += value * (bIsOdd ? -1.0f : 1.0f);
                }
                return ret;
			}
        }
        case WaveForms::Square:
        {
            if (/*$(Variable:Harmonics)*/ == 0)
            {
                if (phase <= 0.5f)
                    return 1.0f;
                else
                    return -1.0f;
            }
            else
            {
                float ret = 0.0f;
                for (int harmonicIndex = 1; harmonicIndex <= /*$(Variable:Harmonics)*/; ++harmonicIndex)
                    ret += sin(phase * c_twoPi * (float)(harmonicIndex * 2 - 1)) / (float)(harmonicIndex * 2 - 1);
                return ret;
			}
        }
        case WaveForms::Saw:
        {
            if (/*$(Variable:Harmonics)*/ == 0)
            {
                return ((phase * 2.0f) - 1.0f) * -1.0f;
            }
            else
            {
                float ret = 0.0f;
                for (int harmonicIndex = 1; harmonicIndex <= /*$(Variable:Harmonics)*/; ++harmonicIndex)
                    ret += sin(phase * c_twoPi * (float)harmonicIndex) / (float)harmonicIndex;
                return ret;
            }
		}
	}

    return 0.0f;
}

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:AudioOutSampleWindowCount)*/)
        return;

    float sample = 0.0f;

    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
		if (Voices[i].note == 0)
			continue;

        float frequency = 440.0f * pow(2.0f, float(Voices[i].note - 1) / 12.0f);
		
		uint sampleIndex = Voices[i].sampleOffset + DTid.x;
		float sampleSeconds = float(sampleIndex) / float(/*$(Variable:AudioOutSampleRate)*/);

        float phase = (frequency * sampleSeconds) % 1.0f;

        float voice = CalculateVoice(phase);

        bool noteFinished = false;
        float ADSRVolume = 1.0f;
        ADSREnvelope(sampleSeconds, float(Voices[i].releaseSample) / float(/*$(Variable:AudioOutSampleRate)*/),
                     /*$(Variable:Attack)*/,
                     /*$(Variable:Decay)*/,
                     /*$(Variable:Release)*/, noteFinished, ADSRVolume);

        sample += voice * ADSRVolume * /*$(Variable:Volume)*/;
	}

    if (/*$(Variable:AudioOutStereo)*/)
    {
        Audio[DTid.x * 2 + 0] = sample;
        Audio[DTid.x * 2 + 1] = sample;
    }
    else
    {
        Audio[DTid.x] = sample;
	}
}

/*
Shader Resources:
	Buffer Audio (as UAV)
	Buffer Voices (as SRV)
*/
