using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName ="SSAO", menuName ="PostProcess/SSAO")]
public class SSAO : PostProcessor
{
    public Material material;
    public int Radius = 8;
    public int ResScale = 4;
    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        var ssao = Shader.PropertyToID("_SSAO_MAP");
        var tmp = Shader.PropertyToID("__TEMP_TEXTURE__");
        var tmpCombine = Shader.PropertyToID("__TEMP_TEXTURE__");
        var width = camera.pixelWidth / ResScale;
        var height = camera.pixelHeight / ResScale;
        cmd.GetTemporaryRT(ssao, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.GetTemporaryRT(tmp, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);
        cmd.GetTemporaryRT(tmpCombine, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);

        cmd.Blit(src, ssao, material, 0);
        //this.Manager.GaussianProvider.Blur(Radius, cmd, ssao, tmp, RenderTextureFormat.ARGBFloat);
        this.Manager.GaussianProvider.MultiBlur(2, false, 16, cmd, ssao, tmp, width, height);

        cmd.SetGlobalTexture("_ScreenImage", src);
        cmd.SetGlobalTexture("_SSAO_Texture", tmp);
        cmd.Blit(src, dst, material, 1);

        cmd.ReleaseTemporaryRT(ssao);
        cmd.ReleaseTemporaryRT(tmp);
        cmd.ReleaseTemporaryRT(tmpCombine);
    }
}
