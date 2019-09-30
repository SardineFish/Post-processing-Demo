using UnityEngine;

[ExecuteInEditMode]
public class Mirror: MonoBehaviour
{
    public Camera SourceCamera;
    public Camera MirrorCamera;

    void Start()
    {
    }
    void Update()
    {
        var matrix = new Matrix4x4(
            new Vector4(1, 0, 0, 0),
            new Vector4(0, -1, 0, 0),
            new Vector4(0, 0, 1, 0),
            new Vector4(0, 0, 0, 1)
        );
        var localPos = transform.worldToLocalMatrix.MultiplyPoint(SourceCamera.transform.position);
        var mirrorPos = matrix.MultiplyPoint(localPos);
        MirrorCamera.transform.position = transform.localToWorldMatrix.MultiplyPoint(mirrorPos);
    }
}