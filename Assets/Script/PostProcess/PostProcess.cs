using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
//[ImageEffectAllowedInSceneView]
public class PostProcess : MonoBehaviour
{
    public ReflectionProbe ReflectionProbe;
    public GaussianProvider GaussianProvider;
    public Light MainLight;
    public PostProcessor[] PostProcessors = new PostProcessor[0];

    Camera camera;
    public float Near;
    public float Far;
    [Range(0, 1)]
    public float Density;

    CommandBuffer cmd;

    public GameObject ShadowCameraObject;
    public Camera shadowCamera;
    public RenderTexture shadowTexture;
    public Shader ScreenSpaceShadowShader;

    private void Reset()
    {
        Near = GetComponent<Camera>().nearClipPlane;
        Far = GetComponent<Camera>().farClipPlane;
    }
    [EditorButton("Reload")]
    void Start()
    {
        camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.Depth | DepthTextureMode.MotionVectors | DepthTextureMode.DepthNormals;
        cmd = new CommandBuffer();
        camera.RemoveAllCommandBuffers();
        camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
        InitShadowCamera();
        PostProcessors.ForEach(p => p.Init(camera));
    }

    void InitShadowCamera()
    {
        if (!ShadowCameraObject)
        {
            ShadowCameraObject = transform.Find("ShadowCameraObject")?.gameObject;
            if(!ShadowCameraObject)
            {
                ShadowCameraObject = new GameObject("ShadowCameraObject");
                ShadowCameraObject.transform.parent = transform;
            }
            ShadowCameraObject.transform.localPosition = Vector3.zero;
            ShadowCameraObject.transform.localRotation = Quaternion.identity;
            ShadowCameraObject.transform.localScale = Vector3.one;
        }

        camera = GetComponent<Camera>();
        shadowCamera = ShadowCameraObject.GetComponent<Camera>();
        if(!shadowCamera)
            shadowCamera = ShadowCameraObject.AddComponent<Camera>();
        shadowCamera.CopyFrom(camera);
        shadowCamera.cullingMask = ~0;
        shadowCamera.clearFlags = CameraClearFlags.SolidColor;
        shadowCamera.backgroundColor = Color.white;
        shadowCamera.enabled = false;
        shadowTexture = new RenderTexture(camera.pixelWidth, camera.pixelHeight, 512);
        shadowCamera.targetTexture = shadowTexture;
        shadowCamera.depthTextureMode = DepthTextureMode.Depth;
        ScreenSpaceShadowShader = Shader.Find("MyShader/ScreenSpaceShadow");
        
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
        if (!shadowCamera)
            InitShadowCamera();
        shadowCamera.RenderWithShader(ScreenSpaceShadowShader, "");

        if(cmd is null)
        {
            InitShadowCamera();
            camera.RemoveAllCommandBuffers();
            cmd = new CommandBuffer();
            camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, cmd);
        }
        cmd.Clear();
        cmd.BeginSample("Post Process");

        cmd.SetGlobalTexture("_ScreenSpaceShadow", shadowCamera.targetTexture);

        var screenImage = Shader.PropertyToID("_ScreenImage");
        cmd.GetTemporaryRT(screenImage, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);

        for (var i = 0; i < PostProcessors.Length; i++)
        {
            cmd.SetRenderTarget(screenImage);
            cmd.Blit(BuiltinRenderTextureType.CameraTarget, screenImage);

            cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
            PostProcessors[i].Manager = this;
            PostProcessors[i].Process(cmd, camera, screenImage, BuiltinRenderTextureType.CameraTarget);
        }

        cmd.ReleaseTemporaryRT(screenImage);
        cmd.EndSample("Post Process");

    }

    private void OnDrawGizmos()
    {
        PostProcessors.ForEach(p => p.OnDrawGizmos());
    }
}

public abstract class PostProcessor : ScriptableObject
{
    public PostProcess Manager;
    public abstract void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst);

    public virtual void Init(Camera camera) { }
    public virtual void OnDrawGizmos() { }
}