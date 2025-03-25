// Unnamed technique, shader CombineCDFs
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    if (DTid.y == 0)
    {
        Output[DTid.xy] = XICDF[uint2(DTid.x, 0)];
        return;
	}

    Output[DTid.xy] = YICDFs[uint2(DTid.x, DTid.y - 1)];
}

/*
Shader Resources:
	Texture XICDF (as SRV)
	Texture YICDFs (as SRV)
	Texture Output (as UAV)
*/
