using UnityEngine;
using System.Collections;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName ="InfiniteGround", menuName ="PostProcess/InfiniteGround")]
public class InfiniteGround : PostProcessor
{
    public Material material;

    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        cmd.SetGlobalMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);
        cmd.SetGlobalVector("_CameraPos", camera.transform.position);
        cmd.SetGlobalVector("_CameraClipPlane", new Vector3(camera.nearClipPlane, camera.farClipPlane, camera.farClipPlane - camera.nearClipPlane));
        cmd.Blit(src, dst, material);
    }
}
