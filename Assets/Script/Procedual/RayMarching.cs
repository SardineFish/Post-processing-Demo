using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class RayMarching : MonoBehaviour, INotifyOnReload
{
    public Texture TerrainTexture;
    public Material RayMarchingMaterial;
    public Material TerrainProcessMaterial;
    new Camera camera;
    [SerializeField]
    CommandBuffer cmd;
    
    private void Start()
    {
    }

    public void OnReload()
    {
        Init();
    }

    [EditorButton("Reload")]
    public void Init()
    {
        camera = GetComponent<Camera>();
        cmd = new CommandBuffer();
        cmd.name = "Ray-marching";
        camera.AddCommandBuffer(CameraEvent.AfterForwardOpaque, cmd);
    }
    private void OnPreRender()
    {
        if (cmd == null)
            Init();
        if (!RayMarchingMaterial)
            return;
        cmd.Clear();

        var halfFOV = camera.fieldOfView / 2 * Mathf.Deg2Rad;
        var screenPlaneHeight = camera.nearClipPlane * Mathf.Tan(halfFOV) * 2;
        var screenPlaneWidth = screenPlaneHeight * camera.aspect;
        var pixelHeight = screenPlaneHeight / camera.pixelHeight;
        cmd.SetGlobalVector("_ScreenPlaneSize", new Vector2(screenPlaneWidth, screenPlaneHeight));
        cmd.SetGlobalVector("_PixelAngle", new Vector2(pixelHeight / camera.nearClipPlane, camera.nearClipPlane / pixelHeight));

        cmd.SetGlobalMatrix("_WorldProjection", GL.GetGPUProjectionMatrix(camera.projectionMatrix, false) * camera.worldToCameraMatrix);
        cmd.SetGlobalMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse * Matrix4x4.Scale(new Vector3(1, -1, 1)));
        cmd.SetGlobalVector("_CameraPos", camera.transform.position);
        cmd.SetGlobalVector("_CameraClipPlane", new Vector3(camera.nearClipPlane, camera.farClipPlane, camera.farClipPlane - camera.nearClipPlane));

        var processedTex = Shader.PropertyToID("_TerrainTex");
        cmd.GetTemporaryRT(processedTex, TerrainTexture.width, TerrainTexture.height, 0, TerrainTexture.filterMode, TerrainTexture.graphicsFormat);
        cmd.Blit(TerrainTexture, processedTex, TerrainProcessMaterial);

        cmd.SetGlobalTexture("_TerrainTex", processedTex);
        cmd.Blit(BuiltinRenderTextureType.None, BuiltinRenderTextureType.CameraTarget, RayMarchingMaterial, 0);

        var depthTex = Shader.PropertyToID("_CameraDepthTexture");
        cmd.GetTemporaryRT(depthTex, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.RFloat);
        
        cmd.Blit(BuiltinRenderTextureType.None, depthTex, RayMarchingMaterial, 1);
        cmd.SetGlobalTexture("_CameraDepthTexture", depthTex);

        cmd.ReleaseTemporaryRT(processedTex);
        cmd.ReleaseTemporaryRT(depthTex);
    }
}
