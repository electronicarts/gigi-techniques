
/*
Input:
* timeSeconds - The time in seconds since the note started playing
* releaseTimeSeconds - The time in seconds since the note started releasing, or 0 if not yet released
* attack - float2(peakVolume, attackTimeSeconds)
* decay - float2(sustainVolume, decayTimeSeconds)
* release - releaseTimeSeconds

Output:
* finished - true if the envelope has finished (note can be considered done)
* volume - the current volume level (0.0 to 1.0)
*/
void ADSREnvelope(in float timeSeconds, in float releaseTimeSeconds, in float2 attack, in float2 decay, in float release, out bool finished, out float volume)
{
    if (releaseTimeSeconds > 0)
    {
        float releaseProgress = clamp((timeSeconds - releaseTimeSeconds) / release, 0.0f, 1.0f);
        finished = releaseProgress >= 1.0f;
        volume = lerp(decay.x, 0.0f, releaseProgress);
    }
    else
    {
        finished = false;

        if (timeSeconds < attack.y)
        {
            float attackProgress = timeSeconds / attack.y;
            volume = lerp(0.0f, attack.x, attackProgress);
        }
        else if (timeSeconds < (attack.y + decay.y))
        {
            float decayProgress = (timeSeconds - attack.y) / decay.y;
            volume = lerp(attack.x, decay.x, decayProgress);
        }
        else
        {
            volume = decay.x;
        }
    }
}
