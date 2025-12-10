// Unnamed technique, shader AdvanceVoices
/*$(ShaderResources)*/

#include "ADSR.hlsli"

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
        if (Voices[i].note == 0)
            continue;

		// Advance time
        Voices[i].sampleOffset += /*$(Variable:AudioOutSampleWindowCount)*/;

		float sampleTime = float(Voices[i].sampleOffset) / float(/*$(Variable:AudioOutSampleRate)*/);

		// If the voice is not yet in release mode
		// And the attack and decay phases are done
		// And there should be no sustain, or the key been released
		// Then enter release mode.
        if (Voices[i].releaseSample == 0 &&
			(sampleTime >= /*$(Variable:Attack)*/.y + /*$(Variable:Decay)*/.y ) &&
            (/*$(Variable:Sustain)*/ == false || KeyStates[Voices[i].key] == 0))
        {
            Voices[i].releaseSample = Voices[i].sampleOffset;
		}

		// When a note is finished playing, clear it out
        bool noteFinished = false;
        float ADSRVolume = 1.0f;
        ADSREnvelope(sampleTime, float(Voices[i].releaseSample) / float(/*$(Variable:AudioOutSampleRate)*/),
                     /*$(Variable:Attack)*/,
                     /*$(Variable:Decay)*/,
                     /*$(Variable:Release)*/, noteFinished, ADSRVolume);

        if (noteFinished)
			Voices[i].note = 0;
    }	
}

/*
Shader Resources:
	Buffer Voices (as UAV)
	Buffer KeyStates (as SRV)
*/
