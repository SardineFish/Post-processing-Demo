using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName ="PostProcess", menuName ="PostProcess/General")]
public class PostProcessShader : PostProcessor
{
    public Material material;
    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        cmd.Blit(src, dst, material);
    }
}
