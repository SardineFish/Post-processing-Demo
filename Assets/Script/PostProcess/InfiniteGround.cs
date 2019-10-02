using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName ="InfiniteGround", menuName ="PostProcess/InfiniteGround")]
public class InfiniteGround : PostProcessor
{
    public Material material;
    public ReflectionProbe ReflectionProbe;
    public float Height;

    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        /*var pos = Manager.transform.position;
        pos.y = Height - (Manager.transform.position.y - Height);
        Manager.ReflectionProbe.transform.position = pos;*/
        Manager.ReflectionProbe.RenderProbe();
        material.SetTexture("_ReflectTex", Manager.ReflectionProbe.realtimeTexture);
        cmd.SetGlobalFloat("_Height", Height);
        cmd.SetGlobalMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse * Matrix4x4.Scale(new Vector3(1, -1, 1)));
        cmd.SetGlobalVector("_CameraPos", camera.transform.position);
        cmd.SetGlobalVector("_CameraClipPlane", new Vector3(camera.nearClipPlane, camera.farClipPlane, camera.farClipPlane - camera.nearClipPlane));
        cmd.Blit(src, dst, material);
    }
}
