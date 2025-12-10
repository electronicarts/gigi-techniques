// Unnamed technique, shader MakeAudio
/*$(ShaderResources)*/

#include "Shared.hlsli"

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x >= /*$(Variable:AudioOutSampleWindowCount)*/)
      return;

    uint audioSampleIndex = (/*$(Variable:AudioOutSampleWindowStart)*/ + DTid.x) % /*$(Variable:_MaxAudioSample)*/;

    float time = float(audioSampleIndex) / float(/*$(Variable:AudioOutSampleRate)*/);

    float TIME_SCALE = /*$(Variable:TimeScale)*/;
    float ENVELOPE_TIME = 0.1 / TIME_SCALE;
    float2 FrequencyMultiplyAdd = /*$(Variable:FrequencyMultiplyAdd)*/;

    float A = /*$(Variable:ControlPoint1)*/;
    float B = /*$(Variable:ControlPoint2)*/;
    float C = /*$(Variable:ControlPoint3)*/;
    float D = /*$(Variable:ControlPoint4)*/;

    float rawTime = time;

    // make time repeat
    time /= TIME_SCALE;
    time = frac(max(time, 0.0));

    // put a short envelope at the front and back to prevent popping
    float envelope = 1.0;
    if (time < ENVELOPE_TIME)
        envelope = time / ENVELOPE_TIME;
    else if (time > 1.0 - ENVELOPE_TIME)
        envelope = ((1.0 - time) / ENVELOPE_TIME);

    float revolutions = (Integral(time, rawTime, A, B, C, D, FrequencyMultiplyAdd) - Integral(0.0, rawTime, A, B, C, D, FrequencyMultiplyAdd)) * TIME_SCALE;

    float left = sin(revolutions) * envelope;
    float right = cos(revolutions) * envelope;

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
