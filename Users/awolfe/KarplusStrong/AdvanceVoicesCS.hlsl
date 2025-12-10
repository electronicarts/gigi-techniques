// Unnamed technique, shader AdvanceVoices
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x > 0)
        return;

    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
        if (Voices[i].noteSamples == 0)
            continue;

        // When a note is inaudible, clear it out
        if (Voices[i].audible == 0)
        {
            Voices[i].noteSamples = 0;
            Voices[i].sampleOffset = 0;
            continue;
        }

		// Advance time
        Voices[i].sampleOffset += /*$(Variable:AudioOutSampleWindowCount)*/;
    }	
}

/*
Shader Resources:
	Buffer Voices (as UAV)
*/
