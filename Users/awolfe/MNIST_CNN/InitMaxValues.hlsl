// mnist technique, shader InitMaxValues
/*$(ShaderResources)*/

/*$(_compute:main)*/(uint3 DTid : SV_DispatchThreadID)
{
    //MaxValues[DTid.x] = uint2(-1, 0);
    MaxValues[DTid.x * 2 + 0] = -1;
    MaxValues[DTid.x * 2 + 1] = 0;
}

/*
Shader Resources:
	Buffer MaxValues (as UAV)
*/
