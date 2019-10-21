using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName ="Bloom", menuName ="PostProcess/Bloom")]
public class Bloom : PostProcessor
{
    [Range(0, 1)]
    public float Threshold = 0.5f;
    [Range(0, 1)]
    public float SoftThreshold = 0.5f;
    [Range(1, 8)]
    public int Iteration;
    public float Intensity;
    Material material;
    public override void Init(Camera camera)
    {
        material = new Material(Shader.Find("MyShader/Postprocess/Bloom"));
    }
    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        var tmp = Shader.PropertyToID("_TempTex");
        float width = camera.pixelWidth;
        float height = camera.pixelHeight;
        cmd.GetTemporaryRT(tmp, (int)(width / 2), (int)(height / 2), 0, FilterMode.Bilinear);

        // Down sample
        for (int i = 0; i < Iteration; i++)
        {
            var scale = Mathf.Pow(2, -(i + 1));
            // Down sample & light prefilter
            if (i == 0)
            {
                cmd.SetGlobalFloat("_PreFilter_Thredshold", Threshold);
                cmd.SetGlobalFloat("_PreFilter_SoftThreshold", SoftThreshold);
                cmd.Blit(src, tmp, material, 0);
            }
            else
            {
                var downSampleSrc = tmp;
                tmp = Shader.PropertyToID($"_DownSample_TempTex{i}");
                cmd.GetTemporaryRT(tmp, (int)(width * scale), (int)(height * scale), 0, FilterMode.Bilinear);
                cmd.Blit(downSampleSrc, tmp, material, 1);
                cmd.ReleaseTemporaryRT(downSampleSrc);
            }
        }

        // Up sample
        for (int i = Iteration - 1; i >= 0; i--)
        {
            var scale = Mathf.Pow(2, -(i));
            var upSampleSrc = tmp;
            tmp = Shader.PropertyToID($"_UpSample_TempTex{i}");
            cmd.GetTemporaryRT(tmp, (int)(width * scale), (int)(height * scale), 0, FilterMode.Bilinear);
            cmd.Blit(upSampleSrc, tmp, material, 2);
            cmd.ReleaseTemporaryRT(upSampleSrc);
        }

        // Apply bloom
        cmd.SetGlobalTexture("_BlurTex", tmp);
        cmd.SetGlobalFloat("_Intensity", Intensity);
        cmd.Blit(src, dst, material, 3);
        cmd.ReleaseTemporaryRT(tmp);
    }
}
