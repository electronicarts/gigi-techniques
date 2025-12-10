// Unnamed technique, shader MakeVideo
/*$(ShaderResources)*/

static const float c_pi = 3.14159265359f;
static const float c_twoPi = c_pi * 2.0f;

float makeSound(float time)
{
    return sin(/*$(Variable:Frequency)*/ * c_twoPi * time);
}

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    uint2 dims;
	Output.GetDimensions(dims.x, dims.y);

	uint2 px = DTid.xy;

    float iTime = /*$(Variable:iTime)*/;
    float SOUND_ORBIT_RATE = /*$(Variable:OrbitRate)*/;

    float aspectRatio = float(dims.y) / float(dims.x);
    float2 rawPercent = float2(px) / float2(dims);

    rawPercent.x -= 0.5;

    float2 percent = rawPercent;
    percent.x /= 256.0;
    percent.y = (percent.y) * 2.2 - 1.1;

    float timeOffset = iTime / 200.0;
    float value = makeSound(percent.x + timeOffset);

    float volumeLeft = cos(SOUND_ORBIT_RATE * c_twoPi * iTime);
    float volumeRight = sin(SOUND_ORBIT_RATE * c_twoPi * iTime);

    rawPercent.x /= aspectRatio;
    rawPercent.x += aspectRatio;
    rawPercent.x -= 0.5 / aspectRatio;
    float2 orbitLocationPercent = float2(
        cos(SOUND_ORBIT_RATE * c_twoPi * iTime * 2.0 + 3.14) * 0.45 + 0.5,
        sin(SOUND_ORBIT_RATE * c_twoPi * iTime * 2.0 + 3.14) * 0.45 + 0.5
    );

    // left channel
    float4 fragColor;
    if (abs(percent.y - (value * volumeLeft)) < 0.01)
        fragColor = float4(1.0, 0.0, 0.0, 1.0);
    // right channel
    else if (abs(percent.y - (value * volumeRight)) < 0.01)
        fragColor = float4(0.0, 0.0, 1.0, 1.0);
    // orbit ball
    else if (distance(rawPercent, orbitLocationPercent) < 0.05)
        fragColor = float4(0.0, 1.0, 0.0, 1.0);
    // background
    else
        fragColor = float4(0.0, 0.0, 0.0, 1.0);

	Output[px] = fragColor;
}

/*
Shader Resources:
	Texture Output (as UAV)
*/
