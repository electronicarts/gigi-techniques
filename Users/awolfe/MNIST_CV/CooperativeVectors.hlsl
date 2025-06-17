// mnist technique, shader CooperativeVectors
/*$(ShaderResources)*/

#include "linalg.h"

using namespace dx::linalg;

#define c_numInputNeurons /*$(Variable:c_numInputNeurons)*/
#define c_numHiddenNeurons /*$(Variable:c_numHiddenNeurons)*/
#define c_numOutputNeurons /*$(Variable:c_numOutputNeurons)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    // Load the input
    vector<float16_t, c_numInputNeurons> Input = NNInput.Load<vector<float16_t, c_numInputNeurons> >(/*StartOffset*/ 0);

    // Make references to the weights and biases
    MatrixRef<DATA_TYPE_FLOAT16, c_numHiddenNeurons, c_numInputNeurons, MATRIX_LAYOUT_MUL_OPTIMAL> HiddenWeights = { NNHiddenWeights, /*StartOffset*/ 0, /*Stride*/ 0 };
    VectorRef<DATA_TYPE_FLOAT16> HiddenBias = { NNHiddenBias, 0 };
    MatrixRef<DATA_TYPE_FLOAT16, c_numOutputNeurons, c_numHiddenNeurons, MATRIX_LAYOUT_MUL_OPTIMAL> OutputWeights = { NNOutputWeights, /*StartOffset*/ 0, /*Stride*/ 0 };
    VectorRef<DATA_TYPE_FLOAT16> OutputBias = { NNOutputBias, 0 };

    // Hidden layer
    vector<float16_t, c_numHiddenNeurons> HiddenLayer = MulAdd<float16_t>(HiddenWeights, MakeInterpretedVector<DATA_TYPE_FLOAT16>(Input), HiddenBias);

    // Activation function
    HiddenLayer = 1.0f / (1.0f + exp(-HiddenLayer));

    // Store the hidden layer activations
    HiddenLayerActivations.Store(0, HiddenLayer);

    // Output layer
    vector<float16_t, c_numOutputNeurons> OutputLayer = MulAdd<float16_t>(OutputWeights, MakeInterpretedVector<DATA_TYPE_FLOAT16>(HiddenLayer), OutputBias);

    // Activation function
    OutputLayer = 1.0f / (1.0f + exp(-OutputLayer));

    // Store the Output layer activations
    OutputLayerActivations.Store(0, OutputLayer);
}

/*
Shader Resources:
    Buffer NNHiddenWeights (as SRV)
    Buffer NNHiddenBias (as SRV)
    Buffer NNOutputWeights (as SRV)
    Buffer NNOutputBias (as SRV)
    Buffer NNInput (as SRV)
    Buffer OutputLayerActivations (as UAV)
*/
