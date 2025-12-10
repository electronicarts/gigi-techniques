static const float c_pi = 3.14159265359f;
static const float c_twoPi = c_pi * 2.0f;

#define EDGE   0.005
#define SMOOTH 0.0025

// F(x,y) = F(x) - y
float F(in float2 coords, in float A, in float B, in float C, in float D)
{
    float T = coords.x;
    return
        (A * (1.0-T) * (1.0-T) * (1.0-T)) + 
        (B * 3.0 * (1.0-T) * (1.0-T) * T) +
        (C * 3.0 * (1.0-T) * T * T) +
        (D * T * T * T) -
        coords.y;
}

// gradiant function for finding G for a generic function when you can't
// get it analytically using partial derivatives.  We could do
// partial derivatives of F above, but I'm being lazy.
float2 Grad( in float2 coords,in float A, in float B, in float C, in float D )
{
    float2 h = float2( 0.01, 0.0 );
    return float2( F(coords+h.xy,A,B,C,D) - F(coords-h.xy,A,B,C,D),
                 F(coords+h.yx,A,B,C,D) - F(coords-h.yx,A,B,C,D) ) / (2.0*h.x);
}

// signed distance function for F(x,y)
float SDF( in float2 coords,in float A, in float B, in float C, in float D)
{
    float v = F(coords,A,B,C,D);
    float2  g = Grad(coords,A,B,C,D);
    return abs(v)/length(g);
}

// signed distance function for Circle, for control points
float SDFCircle( in float2 coords, in float2 offset )
{
    coords -= offset;
    float v = coords.x * coords.x + coords.y * coords.y - EDGE*EDGE;
    float2  g = float2(2.0 * coords.x, 2.0 * coords.y);
    return v/length(g); 
}

float makeSine(float revolutions)
{
    return sin(revolutions*c_twoPi);
}

float Integral(float x, float time, float A, float B, float C, float D, float2 FrequencyMultiplyAdd)
{
    // 1d quadtratic bezier indefinite integral:
    // A*(-x^4/4+x^3-(3 x^2)/2+x) +
    // B*((3 x^4)/4-2 x^3+(3 x^2)/2) +
    // C*(x^3-(3 x^4)/4) +
    // D*(x^4/4)
    return
        (A * FrequencyMultiplyAdd.x + FrequencyMultiplyAdd.y) * (pow(x,4.0)/-4.0 + pow(x,3.0) - (3.0 * pow(x,2.0)) / 2.0 + x) +
        (B * FrequencyMultiplyAdd.x + FrequencyMultiplyAdd.y) * (3.0 * pow(x,4.0)/4.0 - 2.0 * pow(x, 3.0) + 3.0 * pow(x,2.0) / 2.0) +
        (C * FrequencyMultiplyAdd.x + FrequencyMultiplyAdd.y) * (pow(x,3.0) - (3.0 * pow(x,4.0)/4.0)) +
        (D * FrequencyMultiplyAdd.x + FrequencyMultiplyAdd.y) * (pow(x,4.0) / 4.0);
    ;
    
}
