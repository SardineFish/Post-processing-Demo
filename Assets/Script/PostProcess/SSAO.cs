using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName ="SSAO", menuName ="PostProcess/SSAO")]
public class SSAO : PostProcessor
{
    public Material material;
    public int Radius = 8;
    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        var ssao = Shader.PropertyToID("_SSAO_MAP");
        var tmp = Shader.PropertyToID("__TEMP_TEXTURE__");
        var tmpCombine = Shader.PropertyToID("__TEMP_TEXTURE__");

        cmd.GetTemporaryRT(ssao, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.GetTemporaryRT(tmp, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.GetTemporaryRT(tmpCombine, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);

        cmd.Blit(src, ssao, material, 0);
        //this.Manager.GaussianProvider.Blur(Radius, cmd, ssao, tmp, RenderTextureFormat.ARGBFloat);
        //this.Manager.GaussianProvider.MultiBlur(2, true, Radius, cmd, ssao, tmp);

        cmd.SetGlobalTexture("_ScreenImage", src);
        cmd.SetGlobalTexture("_SSAO_Texture", ssao);
        cmd.Blit(src, dst, material, 1);

        cmd.ReleaseTemporaryRT(ssao);
        cmd.ReleaseTemporaryRT(tmp);
        cmd.ReleaseTemporaryRT(tmpCombine);
    }
}
