// Unnamed technique, shader ClearReconstruction
/*$(ShaderResources)*/

/*$(_compute:csmain)*/(uint3 DTid : SV_DispatchThreadID)
{
    Reconstruction[DTid.xy] = 0;
}

/*
Shader Resources:
	Texture Reconstruction (as UAV)
*/
