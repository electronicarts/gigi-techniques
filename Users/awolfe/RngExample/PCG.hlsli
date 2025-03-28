
// Computed using nested PCG, with implementation based on https://jcgt.org/published/0009/03/02/supplementary.pdf
#define PRIME32_6 747796405u
#define PRIME32_7 2891336453u
#define PRIME32_8 277803737u

/*
uint wang_hash(inout uint seed)
{
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}
*/

uint HashPCG(inout uint val)
{
    uint state = val * PRIME32_6 + PRIME32_7;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * PRIME32_8;
    val = state;
    return (word >> 22u) ^ word;
}

uint HashInit(uint3 seed)
{
    return uint(seed.x * uint(1973) + seed.y * uint(9277) + seed.z * uint(26699)) | uint(1);
}

float RandomFloat01(inout uint state)
{
    return float(HashPCG(state)) / 4294967296.0;
}

static const float c_pi = 3.14159265359f;
static const float c_twopi = 2.0f * c_pi;

float3 RandomUnitVector(inout uint state)
{
    float z = RandomFloat01(state) * 2.0f - 1.0f;
    float a = RandomFloat01(state) * c_twopi;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return float3(x, y, z);
}