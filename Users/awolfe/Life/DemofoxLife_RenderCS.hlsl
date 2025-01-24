// Unnamed technique, shader Render
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
	const int simReadIndex = (/*$(Variable:FrameIndex)*/ + 1) % 2;

	int2 px = DTid.xy;

	float2 uv = float2(px) / float2(/*$(Variable:RenderSize)*/);
	float2 cellIndexF = uv * float2(/*$(Variable:GridSize)*/);
	int2 cellIndex = int2(cellIndexF);

	int2 pixelsPerCell = /*$(Variable:RenderSize)*/ / /*$(Variable:GridSize)*/;
	if (/*$(Variable:Grid)*/ && pixelsPerCell.x >= 4 && pixelsPerCell.y >= 4)
	{
		float2 cellIndexFrac = frac(cellIndexF);
		cellIndexFrac = min(cellIndexFrac, 1.0f - cellIndexFrac);
		float cellEdgeDist = min(cellIndexFrac.x, cellIndexFrac.y);
		if (cellEdgeDist < 0.01f)
		{
			Color[px] = float4(0.2f, 0.2f, 0.2f, 1.0f);
			return;
		}
	}

	uint GridValue = GridState[uint3(cellIndex, simReadIndex)];

	if (GridValue == 0)
		Color[px] = float4(0.0f, 0.0f, 0.0f, 1.0f);
	else
		Color[px] = float4(uv, 1.0f - uv.x, 1.0f);
}

/*
Shader Resources:
	Texture GridState (as SRV)
	Texture Color (as UAV)
*/
