using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName = "Fog", menuName = "PostProcess/Fog")]
public class Fog : PostProcessor
{
    public Material mat;
    public float Near = 50;
    public float Far = 1000;
    [Range(0, 1)]
    public float Density = .5f;
    [Range(0, 1)]
    public float Scale = 1f;
    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        cmd.SetGlobalMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse * Matrix4x4.Scale(new Vector3 (1, -1, 1)));
        cmd.SetGlobalVector("_CameraPos", camera.transform.position);
        cmd.SetGlobalVector("_CameraClipPlane", new Vector3(camera.nearClipPlane, camera.farClipPlane, camera.farClipPlane - camera.nearClipPlane));

        cmd.SetGlobalVector("_ViewRange", new Vector3(Near, Far, Far - Near));
        cmd.SetGlobalFloat("_Density", 1 / (1 - Mathf.Pow(Density, .5f) + 0.000001f));
        cmd.SetGlobalFloat("_Scale", Scale);

        cmd.Blit(src, dst, mat);
    }
}
