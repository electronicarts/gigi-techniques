// Unnamed technique, shader InitNotes
/*$(ShaderResources)*/

#include "PCG.hlsli"

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:_MaxNotesSamples)*/)
        return;

	uint noteSampleIndex = DTid.x;

    uint rng = HashInit(uint3(noteSampleIndex, 0x1337, 0xbeef));

    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
        if (Voices[i].noteSamples == 0 || !Voices[i].needsInitialization)
            continue;

        float sample = (noteSampleIndex >= Voices[i].noteSamples) ? 0.0f : RandomFloat01(rng) * 2.0f - 1.0f;
        NotesBuffer[i * /*$(Variable:_MaxNotesSamples)*/ + noteSampleIndex] = sample;
    }
}

/*
Shader Resources:
	Buffer Voices (as UAV)
	Buffer NotesBuffer (as UAV)
*/
