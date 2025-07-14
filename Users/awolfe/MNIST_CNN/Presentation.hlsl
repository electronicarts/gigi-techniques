/*$(ShaderResources)*/

#define USE_MAX_VALUES 1
// 0 = use sigmoid to map +/- inf to [0,1]
// 1 = use min/max values to map actual range to [0,1]

float sigmoid(float x)
{
    return 1.0f / (1.0f + exp(-x));
}

float DecodeAtomicInt(uint i)
{
    // https://www.jeremyong.com/graphics/2023/09/05/f32-interlocked-min-max-hlsl/
    if ((i >> 31) == 0)
    {
        // The MSB is unset, so take the complement, then bitcast,
        // turning this back into a negative floating point value.

        return asfloat(~i);
    }
    else
    {
        // The MSB is set, so we started with a positive float.
        // Unset the MSB and bitcast.

        return asfloat(i & ~(1u << 31));
    }
}

/*$(_compute:Presentation)*/(uint3 DTid : SV_DispatchThreadID)
{
    const int c_borderSize = 3;

    const int2 c_drawPanelPos = int2(30, 30);
    const int2 c_drawPanelSize = int2/*$(Variable:c_drawingCanvasSize)*/;

    const int2 c_inputPanelPos = int2(c_drawPanelPos.x + c_drawPanelSize.x + c_borderSize * 2 + 10, 30);
    const int2 c_inputPanelSize = int2/*$(Variable:c_NNInputImageSize)*/;

    const int2 c_instructionsPos = int2(30, c_drawPanelPos.y + c_drawPanelSize.y + c_borderSize * 2 + 30);
    const int2 c_instructionsSize = int2(300, 292);

    const int2 c_conv1OutputPos = int2(c_inputPanelPos.x + c_inputPanelSize.x + c_borderSize * 2 + 10, 30);
    const int c_conv1OutputScale = /*$(Variable:Conv1OutputScale)*/;
    const int2 c_conv1OutputSize = int2(24 * c_conv1OutputScale, 2 * (24 * c_conv1OutputScale + c_borderSize) - c_borderSize);

    const int2 c_maxPool1OutputPos = int2(c_conv1OutputPos.x + c_conv1OutputSize.x + c_borderSize * 2 + 10, 30);
    const int c_maxPool1OutputScale = /*$(Variable:MaxPool1OutputScale)*/;
    const int2 c_maxPool1OutputSize = int2(12 * c_maxPool1OutputScale, 2 * (12 * c_maxPool1OutputScale + c_borderSize) - c_borderSize);

    const int2 c_conv2OutputPos = int2(c_maxPool1OutputPos.x + c_maxPool1OutputSize.x + c_borderSize * 2 + 10, 30);
    const int c_conv2OutputScale = /*$(Variable:Conv2OutputScale)*/;
    const int2 c_conv2OutputSize = int2(10 * c_conv2OutputScale, 4 * (10 * c_conv2OutputScale + c_borderSize) - c_borderSize);

    const int2 c_maxPool2OutputPos = int2(c_conv2OutputPos.x + c_conv2OutputSize.x + c_borderSize * 2 + 10, 30);
    const int c_maxPool2OutputScale = /*$(Variable:MaxPool2OutputScale)*/;
    const int2 c_maxPool2OutputSize = int2(5 * c_maxPool2OutputScale, 4 * (5 * c_maxPool2OutputScale + c_borderSize) - c_borderSize);

    const int2 c_linearOutputPos = int2(c_maxPool2OutputPos.x + c_maxPool2OutputSize.x + c_borderSize * 2 + 10, 30);
    const int2 c_linearOutputSize = int2(28, 280 + c_borderSize * 9);

    const int2 c_linearOutputLabelsPos = int2(c_linearOutputPos.x + c_linearOutputSize.x + c_borderSize * 2, 30);
    const int2 c_linearOutputLabelsSize = int2(28, 280 + c_borderSize * 9);

    const int2 c_winnerLabelPos = int2(c_linearOutputLabelsPos.x + c_linearOutputLabelsSize.x + c_borderSize * 2, 30);
    const int2 c_winnerLabelSize = int2(28, 280 + c_borderSize * 9);

    const float4 c_borderColor = float4(0.8f, 0.8f, 0.0f, 1.0f);
    const float4 c_backgroundColor = float4(0.2f, 0.2f, 0.2f, 1.0f);

    const float4 c_mouseCursorColor = float4(1.0f, 1.0f, 1.0f, 0.15f);

    // Draw the draw panel
    {
        int2 relPos = int2(DTid.xy) - c_drawPanelPos;
        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_drawPanelSize.x && relPos.y < c_drawPanelSize.y)
        {
            float4 mouse = /*$(Variable:MouseState)*/;
            float3 color;

            if (!/*$(Variable:UseImportedImage)*/)
            {
                color = float3(0.0f, DrawCanvas[relPos], 0.0f);
            }
            else
            {
                const uint2 c_drawingCanvasSize = uint2/*$(Variable:c_drawingCanvasSize)*/;
                const uint2 c_NNInputImageSize = uint2/*$(Variable:c_NNInputImageSize)*/;
                int2 srcPos = float2(relPos) * float2(c_NNInputImageSize) / float2(c_drawingCanvasSize);
                float value = NNInput[srcPos];

                color = float3(value, value, 0.0f);
            }

            if (length(mouse.xy - float2(DTid.xy)) < /*$(Variable:PenSize)*/)
                color = lerp(color, c_mouseCursorColor.rgb, c_mouseCursorColor.aaa);

            PresentationCanvas[DTid.xy] = float4(color, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_drawPanelSize.x + c_borderSize && relPos.y < c_drawPanelSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // Draw the input layer activations (the NN input)
    {
        int2 relPos = int2(DTid.xy) - c_inputPanelPos;
        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_inputPanelSize.x && relPos.y < c_inputPanelSize.y)
        {
            float value = NNInput[relPos];
            PresentationCanvas[DTid.xy] = float4(value.xxx, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_inputPanelSize.x + c_borderSize && relPos.y < c_inputPanelSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // Draw Conv1Output
    {
        int2 relPos = int2(DTid.xy) - c_conv1OutputPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_conv1OutputSize.x && relPos.y < c_conv1OutputSize.y)
        {
            if ((relPos.y % (c_conv1OutputSize.x + c_borderSize)) >= c_conv1OutputSize.x)
            {
                PresentationCanvas[DTid.xy] = c_borderColor;
                return;
            }

            uint3 readPx = uint3(relPos.xy, 0);

            int zValue = relPos.y / (c_conv1OutputSize.x + c_borderSize);
            readPx.z = zValue;
            readPx.y -= (c_conv1OutputSize.x + c_borderSize) * zValue;

            readPx.xy /= c_conv1OutputScale;

            // Normalize for display
            #if USE_MAX_VALUES
            float minValue = DecodeAtomicInt(MaxValues[0 * 2 + 0]);
            float maxValue = DecodeAtomicInt(MaxValues[0 * 2 + 1]);
            float value = (Conv1Output[readPx] - minValue) / (maxValue - minValue);
            #else
            float value = sigmoid(Conv1Output[readPx]);
            #endif

            PresentationCanvas[DTid.xy] = float4(value.xxx, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_conv1OutputSize.x + c_borderSize && relPos.y < c_conv1OutputSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // Draw MaxPool1Output
    {
        int2 relPos = int2(DTid.xy) - c_maxPool1OutputPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_maxPool1OutputSize.x && relPos.y < c_maxPool1OutputSize.y)
        {
            if ((relPos.y % (c_maxPool1OutputSize.x + c_borderSize)) >= c_maxPool1OutputSize.x)
            {
                PresentationCanvas[DTid.xy] = c_borderColor;
                return;
            }

            uint3 readPx = uint3(relPos.xy, 0);

            int zValue = relPos.y / (c_maxPool1OutputSize.x + c_borderSize);
            readPx.z = zValue;
            readPx.y -= (c_maxPool1OutputSize.x + c_borderSize) * zValue;

            readPx.xy /= c_maxPool1OutputScale;

            // Normalize for display
            #if USE_MAX_VALUES
            float minValue = DecodeAtomicInt(MaxValues[1 * 2 + 0]);
            float maxValue = DecodeAtomicInt(MaxValues[1 * 2 + 1]);
            float value = (MaxPool1Output[readPx] - minValue) / (maxValue - minValue);
            #else
            float value = sigmoid(MaxPool1Output[readPx]);
            #endif

            PresentationCanvas[DTid.xy] = float4(value.xxx, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_maxPool1OutputSize.x + c_borderSize && relPos.y < c_maxPool1OutputSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // Draw Conv2Output
    {
        int2 relPos = int2(DTid.xy) - c_conv2OutputPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_conv2OutputSize.x && relPos.y < c_conv2OutputSize.y)
        {
            if ((relPos.y % (c_conv2OutputSize.x + c_borderSize)) >= c_conv2OutputSize.x)
            {
                PresentationCanvas[DTid.xy] = c_borderColor;
                return;
            }

            uint3 readPx = uint3(relPos.xy, 0);

            int zValue = relPos.y / (c_conv2OutputSize.x + c_borderSize);
            readPx.z = zValue;
            readPx.y -= (c_conv2OutputSize.x + c_borderSize) * zValue;

            readPx.xy /= c_conv2OutputScale;

            // Normalize for display
            #if USE_MAX_VALUES
            float minValue = DecodeAtomicInt(MaxValues[2 * 2 + 0]);
            float maxValue = DecodeAtomicInt(MaxValues[2 * 2 + 1]);
            float value = (Conv2Output[readPx] - minValue) / (maxValue - minValue);
            #else
            float value = sigmoid(Conv2Output[readPx]);
            #endif

            PresentationCanvas[DTid.xy] = float4(value.xxx, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_conv2OutputSize.x + c_borderSize && relPos.y < c_conv2OutputSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // Draw MaxPool2Output
    {
        int2 relPos = int2(DTid.xy) - c_maxPool2OutputPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_maxPool2OutputSize.x && relPos.y < c_maxPool2OutputSize.y)
        {
            if ((relPos.y % (c_maxPool2OutputSize.x + c_borderSize)) >= c_maxPool2OutputSize.x)
            {
                PresentationCanvas[DTid.xy] = c_borderColor;
                return;
            }

            uint3 readPx = uint3(relPos.xy, 0);

            int zValue = relPos.y / (c_maxPool2OutputSize.x + c_borderSize);
            readPx.z = zValue;
            readPx.y -= (c_maxPool2OutputSize.x + c_borderSize) * zValue;

            readPx.xy /= c_maxPool2OutputScale;

            // Normalize for display
            #if USE_MAX_VALUES
            float minValue = DecodeAtomicInt(MaxValues[3 * 2 + 0]);
            float maxValue = DecodeAtomicInt(MaxValues[3 * 2 + 1]);
            float value = (MaxPool2Output[readPx] - minValue) / (maxValue - minValue);
            #else
            float value = sigmoid(MaxPool2Output[readPx]);
            #endif

            PresentationCanvas[DTid.xy] = float4(value.xxx, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_maxPool2OutputSize.x + c_borderSize && relPos.y < c_maxPool2OutputSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // Draw LinearOutput
    {
        int2 relPos = int2(DTid.xy) - c_linearOutputPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_linearOutputSize.x && relPos.y < c_linearOutputSize.y)
        {
            if ((relPos.y % 31) >= 28)
            {
                PresentationCanvas[DTid.xy] = c_borderColor;
                return;
            }

            relPos.y /= 31;

            // Normalize for display
            #if USE_MAX_VALUES
            float minValue = DecodeAtomicInt(MaxValues[4 * 2 + 0]);
            float maxValue = DecodeAtomicInt(MaxValues[4 * 2 + 1]);
            float value = (LinearOutput[relPos.y] - minValue) / (maxValue - minValue);
            #else
            float value = sigmoid(LinearOutput[relPos.y]);
            #endif

            PresentationCanvas[DTid.xy] = float4(value.xxx, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_linearOutputSize.x + c_borderSize && relPos.y < c_linearOutputSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // Draw the output layer labels
    {
        int2 relPos = int2(DTid.xy) - c_linearOutputLabelsPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_linearOutputLabelsSize.x && relPos.y < c_linearOutputLabelsSize.y)
        {
            if ((relPos.y % 31) < 28)
            {
                int index = relPos.y / 31;
                relPos.y = relPos.y % 31;

                float alpha = 0.0f;
                switch (index)
                {
                    case 0: alpha = /*$(Image:0.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 1: alpha = /*$(Image:1.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 2: alpha = /*$(Image:2.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 3: alpha = /*$(Image:3.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 4: alpha = /*$(Image:4.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 5: alpha = /*$(Image:5.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 6: alpha = /*$(Image:6.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 7: alpha = /*$(Image:7.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 8: alpha = /*$(Image:8.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                    case 9: alpha = /*$(Image:9.png:RGBA8_Unorm_sRGB:float:true)*/[relPos].r; break;
                }

                if (alpha > 0.0f)
                {
                    // Normalize for display
                    #if USE_MAX_VALUES
                    float minValue = DecodeAtomicInt(MaxValues[4 * 2 + 0]);
                    float maxValue = DecodeAtomicInt(MaxValues[4 * 2 + 1]);
                    float value = (LinearOutput[index] - minValue) / (maxValue - minValue);
                    #else
                    float value = sigmoid(LinearOutput[index]);
                    #endif

                    float3 pixelColor = lerp(float3(0.4f, 0.0f, 0.0f), float3(1.0f, 1.0f, 0.0f), value);
                    pixelColor = lerp(c_backgroundColor.rgb, pixelColor, alpha);
                    PresentationCanvas[DTid.xy] = float4(pixelColor, 1.0f);
                    return;
                }
            }
        }
    }

    // Draw the winner
    {
        // c_winnerLabelPos
        // c_winnerLabelSize

        int2 relPos = int2(DTid.xy) - c_winnerLabelPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_winnerLabelSize.x && relPos.y < c_winnerLabelSize.y)
        {
            if ((relPos.y % 31) < 28)
            {
                float maxValue = 0.0f;

                for (int i = 0; i < 10; ++i)
                {
                    float iValue = LinearOutput[i];
                    if (iValue > maxValue)
                        maxValue = iValue;
                }

                int index = relPos.y / 31;
                bool isWinner = LinearOutput[index] >= maxValue;

                if (isWinner)
                {
                    PresentationCanvas[DTid.xy] = float4(0.0f, 1.0f, 0.0f, 1.0f);
                    return;
                }
            }
        }
    }

    // Draw the instructions - not on webgpu though because it puts us over budget for sampled textures
    {
        int2 relPos = int2(DTid.xy) - c_instructionsPos;

        if (relPos.x >= 0 && relPos.y >= 0 && relPos.x < c_instructionsSize.x && relPos.y < c_instructionsSize.y)
        {
            PresentationCanvas[DTid.xy] = float4(/*$(Image:instructions.png:RGBA8_Unorm_sRGB:float4:true)*/[relPos.xy].rgb, 1.0f);
            return;
        }

        if (relPos.x >= -c_borderSize && relPos.y >= -c_borderSize && relPos.x < c_instructionsSize.x + c_borderSize && relPos.y < c_instructionsSize.y + c_borderSize)
        {
            PresentationCanvas[DTid.xy] = c_borderColor;
            return;
        }
    }

    // background color
    PresentationCanvas[DTid.xy] = c_backgroundColor;
}
