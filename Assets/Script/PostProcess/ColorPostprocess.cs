using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName = "Color", menuName = "PostProcess/Color")]
public class ColorPostprocess : PostProcessor
{
    [Range(-1, 1)]
    public float Brightness = 0;
    [Range(-1, 1)]
    public float Contrast = 0;
    [Range(-1, 1)]
    public float Hue = 0;
    [Range(-1, 1)]
    public float Saturation = 0;
    Material material;
    public override void Init(Camera camera)
    {
        material = new Material(Shader.Find("MyShader/Postprocess/ColorAdjustment"));
    }
    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        cmd.SetGlobalFloat("_Brightness", Brightness);
        cmd.SetGlobalFloat("_Contrast", Contrast);
        cmd.SetGlobalFloat("_Hue", Hue);
        cmd.SetGlobalFloat("_Saturation", Saturation);
        cmd.Blit(src, dst, material, 0);
    }
}
