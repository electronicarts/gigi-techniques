// Unnamed technique, shader DetectSilentVoices
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:_MaxNotesSamples)*/)
        return;

    uint noteSampleIndex = DTid.x;

    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
        Voices[i].needsInitialization = false;

		// Only check valid samples for the voice
        if (noteSampleIndex >= Voices[i].noteSamples)
            continue;

        float sample = NotesBuffer[i * /*$(Variable:_MaxNotesSamples)*/ + noteSampleIndex];

        InterlockedMax(Voices[i].audible, abs(sample) > /*$(Variable:AudibleThreshold)*/ ? 1 : 0);

        uint volumeU = uint(abs(sample) * 1000.0f);
        InterlockedMax(Voices[i].maxVolume, volumeU);
    }	
}

/*
Shader Resources:
    Buffer Voices (as UAV)
    Buffer NotesBuffer (as SRV)
*/
