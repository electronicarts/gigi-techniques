// Unnamed technique, shader Delay
/*$(ShaderResources)*/

static const float c_pi = 3.14159265359f;
static const float c_twoPi = c_pi * 2.0f;

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (/*$(Variable:Delay)*/.x <= 0.0f)
		return;

    if (DTid.x >= /*$(Variable:AudioOutSampleWindowCount)*/)
		return;

    uint delaySampleIndex = (/*$(Variable:DelayClock)*/ + DTid.x) % /*$(Variable:_DelaySamplesU)*/;

    if (/*$(Variable:AudioOutStereo)*/)
    {
		float delayLeft = DelayBuffer[delaySampleIndex * 2 + 0] * /*$(Variable:Delay)*/.y;
		float delayRight = DelayBuffer[delaySampleIndex * 2 + 1] * /*$(Variable:Delay)*/.y;

        float left = Audio[DTid.x * 2 + 0] + delayLeft;
		float right = Audio[DTid.x * 2 + 1] + delayRight;

        Audio[DTid.x * 2 + 0] = left;
		Audio[DTid.x * 2 + 1] = right;

        DelayBuffer[delaySampleIndex * 2 + 0] = left;
		DelayBuffer[delaySampleIndex * 2 + 1] = right;
	}
	else
	{
		float mono = Audio[DTid.x] + DelayBuffer[delaySampleIndex] * /*$(Variable:Delay)*/.y;

		Audio[DTid.x] = mono;

		DelayBuffer[delaySampleIndex] = mono;
	}

}

/*
Shader Resources:
	Buffer DelayBuffer (as UAV)
	Buffer Audio (as UAV)
*/
