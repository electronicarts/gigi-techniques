// Unnamed technique, shader DecayNotes
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:AudioOutSampleWindowCount)*/)
        return;

    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
        // Don't process inactive voices
        if (Voices[i].noteSamples == 0)
            continue;

        uint voiceSampleIndex = Voices[i].sampleOffset + DTid.x;

        uint bufferSampleIndex = i * /*$(Variable:_MaxNotesSamples)*/ + (voiceSampleIndex % Voices[i].noteSamples);
        uint bufferSampleIndexNext = i * /*$(Variable:_MaxNotesSamples)*/ + ((voiceSampleIndex + 1) % Voices[i].noteSamples);

		Out[bufferSampleIndex] = (NotesBuffer[bufferSampleIndex] + NotesBuffer[bufferSampleIndexNext]) * 0.5f * /*$(Variable:Feedback)*/;
    }
}

/*
Shader Resources:
    Buffer Out (as UAV)
    Buffer Voices (as UAV)
	Buffer NotesBuffer (as SRV)
*/
