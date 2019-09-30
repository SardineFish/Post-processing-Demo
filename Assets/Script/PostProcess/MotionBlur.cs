using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName = "MotionBlur", menuName = "PostProcess/MotionBlur")]
public class MotionBlur : PostProcessor
{
    public Material mat;
    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        cmd.Blit(src, dst, mat);
    }
}
