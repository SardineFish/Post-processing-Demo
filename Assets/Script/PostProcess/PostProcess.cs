using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
class PostProcess : MonoBehaviour
{
    public PostProcessor[] PostProcessors = new PostProcessor[0];
    Camera camera;
    public float Near;
    public float Far;
    [Range(0, 1)]
    public float Density;

    CommandBuffer cmd;

    private void Reset()
    {
        Near = GetComponent<Camera>().nearClipPlane;
        Far = GetComponent<Camera>().farClipPlane;
    }
    void Start()
    {
        camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.Depth | DepthTextureMode.MotionVectors | DepthTextureMode.DepthNormals;
        cmd = new CommandBuffer();
        camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
    }

    private void Update()
    {
        var m = (camera.projectionMatrix * camera.worldToCameraMatrix).inverse;
        Vector4 p = new Vector4(-1, -1, -1, 1);
        p = Vector4.Scale(p, new Vector4(camera.nearClipPlane, camera.nearClipPlane, camera.nearClipPlane, camera.nearClipPlane));
        p = m * p;
        Debug.DrawLine(camera.transform.position, p, Color.red);
    }

    private void OnPreRender()
    {
        if(cmd is null)
        {
            cmd = new CommandBuffer();
            camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
        }
        cmd.Clear();

        var screenImage = Shader.PropertyToID("_ScreenImage");
        cmd.GetTemporaryRT(screenImage, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);

        for (var i = 0; i < PostProcessors.Length; i++)
        {
            cmd.SetRenderTarget(screenImage);
            cmd.Blit(BuiltinRenderTextureType.CameraTarget, screenImage);

            cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
            PostProcessors[i].Process(cmd, camera, screenImage, BuiltinRenderTextureType.CameraTarget);
        }

        cmd.ReleaseTemporaryRT(screenImage);

    }
}

public abstract class PostProcessor : ScriptableObject
{
    public abstract void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst);
}