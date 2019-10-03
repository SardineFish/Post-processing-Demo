using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName ="GaussianProvider", menuName ="PostProcess/GaussianBlur")]
public class GaussianProvider : ScriptableObject
{
    public Texture Gaussian;
    Material material;
    public void Blur(int radius, CommandBuffer cmd, RenderTargetIdentifier src, RenderTargetIdentifier dst, RenderTextureFormat format = RenderTextureFormat.Default)
    {
        if (!material)
        {
            material = new Material(Shader.Find("GaussianBlur/Blur"));
            material.SetTexture("_Gaussian", Gaussian);
        }
        cmd.SetGlobalTexture("_Gaussian", Gaussian);
        var blurTexture = Shader.PropertyToID("__GaussianTempTexture");
        cmd.SetGlobalInt("_BlurRadius", radius);
        cmd.GetTemporaryRT(blurTexture, -1, -1, 0, FilterMode.Bilinear, format);
        cmd.SetGlobalVector("_BlurDirection", new Vector2(1, 0));
        cmd.Blit(src, blurTexture, material, 0);
        cmd.SetGlobalVector("_BlurDirection", new Vector2(0, 1));
        cmd.Blit(blurTexture, dst, material, 0);
        cmd.ReleaseTemporaryRT(blurTexture);
    }

    public void MultiBlur(int iteration, bool overlay, int radius, CommandBuffer cmd, RenderTargetIdentifier src, RenderTargetIdentifier dst, RenderTextureFormat format = RenderTextureFormat.Default)
    {
        var rtManager = new TemplateRTManager(cmd, 3);

        int blurSrc = -1;

        for (int i = 0; i < iteration; i++)
        {
            if (overlay)
            {
                var blurTarget = rtManager.GetRT();
                if (i == 0)
                {
                    Blur(radius, cmd, src, blurTarget, format);
                    blurSrc = blurTarget;
                }
                else
                {
                    Blur(radius, cmd, blurSrc, blurTarget, format);
                    var blendTarget = rtManager.GetRT();
                    cmd.SetGlobalTexture("_Overlay", blurSrc);
                    cmd.Blit(blurTarget, blendTarget, material, 1);
                    rtManager.PutRT(blurTarget);
                    if (blurSrc != -1)
                        rtManager.PutRT(blurSrc);
                    blurSrc = blendTarget;
                }
            }
        }
        cmd.Blit(blurSrc, dst);
        rtManager.ReleaseRTs();
    }
}