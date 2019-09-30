using UnityEngine;

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
class PostProcess : MonoBehaviour
{
    public Material PostProcessMat;
    Camera camera;
    public float Near;
    public float Far;
    [Range(0, 1)]
    public float Density;

    private void Reset()
    {
        Near = GetComponent<Camera>().nearClipPlane;
        Far = GetComponent<Camera>().farClipPlane;
    }
    void Start()
    {
        camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void Update()
    {
        var m = (camera.projectionMatrix * camera.worldToCameraMatrix).inverse;
        Vector4 p = new Vector4(-1, -1, -1, 1);
        p = Vector4.Scale(p, new Vector4(camera.nearClipPlane, camera.nearClipPlane, camera.nearClipPlane, camera.nearClipPlane));
        p = m * p;
        Debug.DrawLine(camera.transform.position, p, Color.red);
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!PostProcessMat)
            return;

        PostProcessMat.SetMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);
        PostProcessMat.SetVector("_CameraPos", camera.transform.position);
        PostProcessMat.SetVector("_ViewRange", new Vector3(Near, Far, Far - Near));
        PostProcessMat.SetVector("_CameraClipPlane", new Vector3(camera.nearClipPlane, camera.farClipPlane, camera.farClipPlane - camera.nearClipPlane));
        PostProcessMat.SetFloat("_Density", 1 / (1 - Mathf.Pow(Density, .5f) + 0.000001f));
        Graphics.Blit(source, destination, PostProcessMat);
    }
}