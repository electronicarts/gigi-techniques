// Unnamed technique, shader SpawnVoices
/*$(ShaderResources)*/

// keys
static const float KEY_Q = 81;
static const float KEY_W = 87;
static const float KEY_E = 69;
static const float KEY_R = 82;
static const float KEY_T = 84;
static const float KEY_Y = 89;
static const float KEY_U = 85;
static const float KEY_I = 73;
static const float KEY_O = 79;
static const float KEY_P = 80;

static const float KEY_A = 65;
static const float KEY_S = 83;
static const float KEY_D = 68;
static const float KEY_F = 70;
static const float KEY_G = 71;
static const float KEY_H = 72;
static const float KEY_J = 74;
static const float KEY_K = 75;
static const float KEY_L = 76;

static const float KEY_Z = 90;
static const float KEY_X = 88;
static const float KEY_C = 67;
static const float KEY_V = 86;
static const float KEY_B = 66;
static const float KEY_N = 78;
static const float KEY_M = 77;

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.x > 0)
		return;

    // Force all voices to silent if we should
    if (/*$(Variable:Silence)*/)
    {
        for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
        {
            Voices[i].noteSamples = 0;
			Voices[i].sampleOffset = 0;
        }
    }

	// All voices are inaudible until proven otherwise
    for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
        Voices[i].audible = 0;
        Voices[i].maxVolume = 0;
    }
	
	// Find what note wants to be played, if any
    uint note = 0;
    uint key = 0;
	#define HANDLE_KEY(KEY, NOTE) \
		else if (KeyStates[uint(KEY)] != 0 && KeyStates[uint(KEY) + 256] == 0) \
		{ \
            note = NOTE; \
            key = KEY; \
		}

    if (false) {}

    HANDLE_KEY(KEY_Q, 1)
	HANDLE_KEY(KEY_W, 2)
	HANDLE_KEY(KEY_E, 3)
	HANDLE_KEY(KEY_R, 4)
	HANDLE_KEY(KEY_T, 5)
	HANDLE_KEY(KEY_Y, 6)
	HANDLE_KEY(KEY_U, 7)
	HANDLE_KEY(KEY_I, 8)
	HANDLE_KEY(KEY_O, 9)
	HANDLE_KEY(KEY_P, 10)

	HANDLE_KEY(KEY_A, 11)
	HANDLE_KEY(KEY_S, 12)
	HANDLE_KEY(KEY_D, 13)
	HANDLE_KEY(KEY_F, 14)
	HANDLE_KEY(KEY_G, 15)
	HANDLE_KEY(KEY_H, 16)
	HANDLE_KEY(KEY_J, 17)
	HANDLE_KEY(KEY_K, 18)
	HANDLE_KEY(KEY_L, 19)

	HANDLE_KEY(KEY_Z, 20)
	HANDLE_KEY(KEY_X, 21)
	HANDLE_KEY(KEY_C, 22)
	HANDLE_KEY(KEY_V, 23)
	HANDLE_KEY(KEY_B, 24)
	HANDLE_KEY(KEY_N, 25)
	HANDLE_KEY(KEY_M, 26)

	// If no notes want to be played, we are done
    if (note == 0)
        return;

	// If a note wants to be played, find a free voice slot and claim it
	for (uint i = 0; i < /*$(Variable:Polyphony)*/; i++)
    {
		if (Voices[i].noteSamples == 0)
        {
            float frequency = 440.0f * pow(2.0f, (float(note) + /*$(Variable:Tuning)*/) / 12.0f);
			uint sampleCount = uint(float(/*$(Variable:AudioOutSampleRate)*/) / frequency);

            Voices[i].noteSamples = sampleCount;
            Voices[i].sampleOffset = 0;
			Voices[i].needsInitialization = true;
			break;
		}
	}
}

/*
Shader Resources:
	Buffer Voices (as UAV)
	Buffer KeyStates (as SRV)
*/
