using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.Rendering;
using System.Linq;

[CreateAssetMenu(fileName ="VolumericFog", menuName ="PostProcess/Volumeric")]
public class VolumericShadow : PostProcessor
{
    public float MaxVolumeRenderDistance = 10;
    public float VolumeStretchDistance = 100;
    public float Near = 50;
    public float Far = 1000;
    public Color AtmosphereColor;
    [Range(-1, 1)]
    public float ScatterFactor = 0.3f;
    public float Intensity = 0.5f;
    [Range(0, 1)]
    public float Density = 0.5f;
    public float FogScale = 1f;
    public bool EnableVolume;
    Collider[] shadowTargets;
    Mesh boxMeshBase;
    Mesh boxMesh;
    Dictionary<Transform, Mesh> volumeMeshs = new Dictionary<Transform, Mesh>();

    [EditorButton("Rebuild")]
    public void Rebuild()
    {
        Init(GameObject.FindGameObjectWithTag("MainCamera").GetComponent<Camera>());
    }
    public override void Init(Camera camera)
    {
        shadowTargets = new Collider[256];
        boxMeshBase = CreateBox();
        boxMesh = new Mesh();
        boxMesh.vertices = new Vector3[boxMeshBase.vertices.Length];
        boxMesh.triangles = new int[boxMeshBase.triangles.Length];
        Array.Copy(boxMeshBase.triangles, boxMesh.triangles, boxMeshBase.triangles.Length);

        var count = Physics.OverlapSphereNonAlloc(camera.transform.position, 1000, shadowTargets);
        for (int i = 0; i < count; i++)
        {
            var mesh = GenerateVolumnMesh(shadowTargets[i]);
            if (mesh)
                volumeMeshs[shadowTargets[i].transform] = mesh;
        }
    }

    public override void Process(CommandBuffer cmd, Camera camera, RenderTargetIdentifier src, RenderTargetIdentifier dst)
    {
        bool inVolume = Physics.Raycast(new Ray(camera.transform.position, -Manager.MainLight.transform.forward), VolumeStretchDistance);

        var mat = new Material(Shader.Find("MyShader/Postprocess/Volumeric"));
        var volumMap = Shader.PropertyToID("_VolumericLightMap");
        var volumBackMap = Shader.PropertyToID("_VolumericBackMap");
        var volumDepth = Shader.PropertyToID("_VolumericDepthMap");
        cmd.GetTemporaryRT(volumMap, -1, -1, 32);
        cmd.GetTemporaryRT(volumDepth, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.RFloat);
        cmd.GetTemporaryRT(volumBackMap, -1, -1, 32, FilterMode.Bilinear, RenderTextureFormat.ARGBFloat);

        // Copy depth buffer into volumMap
        cmd.SetRenderTarget(volumDepth, volumMap);
        cmd.ClearRenderTarget(true, true, Color.black);
        cmd.SetGlobalTexture("_DepthTex", BuiltinRenderTextureType.Depth);
        cmd.Blit(BuiltinRenderTextureType.Depth, volumMap, mat, 2);

        // Copy depth buffer into depthMap
        cmd.SetRenderTarget(volumDepth, BuiltinRenderTextureType.Depth);
        cmd.Blit(BuiltinRenderTextureType.Depth, volumDepth);

        cmd.SetRenderTarget(volumMap, volumMap);
        cmd.ClearRenderTarget(true, true, Color.blue);
        //cmd.SetRenderTarget(volumBackMap, volumBackMap);
        //cmd.ClearRenderTarget(true, true, Color.black);
        cmd.SetRenderTarget(new RenderTargetIdentifier[] { volumMap, volumDepth }, volumMap);

        if (EnableVolume)
        {
            // Render Volumes
            volumeMeshs
            .Where(pair => (pair.Key.position - camera.transform.position).magnitude < MaxVolumeRenderDistance)
            .ForEach(pair =>
            {
                if (inVolume)
                {
                    // cmd.SetRenderTarget(volumBackMap, volumBackMap);
                    cmd.DrawMesh(pair.Value, Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one), mat, 0, 1);
                }
                else
                {
                    // cmd.SetRenderTarget(new RenderTargetIdentifier[] { volumMap, volumDepth }, volumMap);
                    cmd.DrawMesh(pair.Value, Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one), mat, 0, 0);
                }


            });
        }
            

        /*
        var count = Physics.OverlapSphereNonAlloc(camera.transform.position, ShadowDistance, shadowTargets);
        for (int i = 0; i < count; i++)
        {
            var mesh = GenerateVolumnMesh(shadowTargets[i]);
            if (mesh)
                cmd.DrawMesh(mesh, Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one), mat, 0, 0);
        }*/

        cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget, BuiltinRenderTextureType.CameraTarget);

        // Render Atmospheric scattering with volumeric shadows.
        cmd.SetGlobalTexture("_VolumericDepthMap", volumDepth);
        cmd.SetGlobalMatrix("_ViewProjectionInverseMatrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse * Matrix4x4.Scale(new Vector3(1, -1, 1)));
        cmd.SetGlobalVector("_CameraPos", camera.transform.position);
        cmd.SetGlobalVector("_ViewRange", new Vector3(Near, Far, Far - Near));
        cmd.SetGlobalVector("_CameraClipPlane", new Vector3(camera.nearClipPlane, camera.farClipPlane, camera.farClipPlane - camera.nearClipPlane));
        cmd.SetGlobalColor("_FogColor", AtmosphereColor);
        cmd.SetGlobalFloat("_Density", Density);
        cmd.SetGlobalFloat("_FogScale", FogScale);
        cmd.SetGlobalFloat("_ScatterFactor", ScatterFactor);
        cmd.SetGlobalFloat("_ScatterIntensity", Intensity);
        cmd.Blit(src, dst, mat, 3);

        cmd.ReleaseTemporaryRT(volumMap);
        cmd.ReleaseTemporaryRT(volumBackMap);
        cmd.ReleaseTemporaryRT(volumDepth);
    
        cmd.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        
    }

    public Mesh GenerateVolumnMesh(Collider collider)
    {
        var lightDir = Manager.MainLight.transform.forward;
        if(collider is BoxCollider)
        {
            var mat = collider.transform.localToWorldMatrix;
            var box = collider as BoxCollider;
            var verts = boxMesh.vertices;
            Array.Copy(boxMeshBase.vertices, verts, boxMeshBase.vertices.Length);
            boxMesh.triangles = boxMeshBase.triangles;
            MeshBuilder mb = new MeshBuilder(128);

            // Transform from local to world pos;
            for (int i = 0; i < verts.Length; i++)
            {
                verts[i] = mat.MultiplyPoint(Vector3.Scale(verts[i] / 2, box.size) + box.center);
            }

            // Build volume mesh
            MeshAnalyser meshAnalyser = new MeshAnalyser(12);
            for (int i = 0; i < boxMesh.triangles.Length / 3; i++)
            {
                var idx = i * 3;
                var triangle = new Triangle(verts[boxMesh.triangles[idx + 0]], verts[boxMesh.triangles[idx + 1]], verts[boxMesh.triangles[idx + 2]]);
                if (Vector3.Dot(lightDir, triangle.normal) < 0)
                    meshAnalyser.AddTriangle(triangle);
                /*
                if (Vector3.Dot(lightDir, triangle.normal) < 0)
                    BuildPrism(-triangle, lightDir * VolumeStretchDistance, mb);*/
            }
            BuildPrism(meshAnalyser, lightDir * VolumeStretchDistance, mb);
            return mb.ToMesh();
        }
        return null;
    }

    void BuildPrism(MeshAnalyser meshAnalyser, Vector3 extend, MeshBuilder mb)
    {
        foreach(var triangle in meshAnalyser.Triangles)
        {
            mb.AddTriangle(-triangle, new Color(1, 0, 0, 1));
            mb.AddTriangle(triangle + extend, new Color(0, 0, 1, 1));
        }
        foreach(var edge in meshAnalyser.FindBorders())
        {
            var extentEdge = edge + extend;
            mb.AddTriangle(new Triangle(edge.a, edge.b, extentEdge.b), new Color(0, 1, 0, 1));
            mb.AddTriangle(new Triangle(edge.a, extentEdge.b, extentEdge.a), new Color(0, 1, 0, 1));
        }
    }

    void BuildPrism(Triangle surface, Vector3 extend, MeshBuilder mb)
    {
        var extentSurface = new Triangle(surface.a + extend, surface.b + extend, surface.c + extend);
        mb.AddTriangle(surface);
        mb.AddTriangle(surface.a, extentSurface.b, surface.b);
        mb.AddTriangle(surface.a, extentSurface.a, extentSurface.b);
        mb.AddTriangle(surface.b, extentSurface.c, surface.c);
        mb.AddTriangle(surface.b, extentSurface.b, extentSurface.c);
        mb.AddTriangle(surface.c, extentSurface.a, surface.a);
        mb.AddTriangle(surface.c, extentSurface.c, extentSurface.a);
        mb.AddTriangle(extentSurface.c, extentSurface.b, extentSurface.a);
    }

    Mesh CreateBox()
    {
        Mesh mesh = new Mesh();
        mesh.Clear();
        mesh.vertices = new Vector3[]
        {
            new Vector3(-1, -1, -1),
            new Vector3(1, -1, -1),
            new Vector3(1, -1, 1),
            new Vector3(-1, -1, 1),
            new Vector3(-1, 1, -1),
            new Vector3(1, 1, -1),
            new Vector3(1, 1, 1),
            new Vector3(-1, 1, 1),
        };
        mesh.triangles = new int[]
        {
            0, 2, 1,
            0, 3, 2,
            1, 4, 0,
            1, 5, 4,
            1, 2, 5,
            2, 6, 5,
            2, 3, 6,
            3, 7, 6,
            0, 4, 7,
            3, 0, 7,
            7, 4, 5,
            7, 5, 6
        };
        return mesh;
    }

    public override void OnDrawGizmos()
    {
        return;
        volumeMeshs.ForEach(pair =>
        {
            var mesh = pair.Value;
            Gizmos.DrawWireMesh(mesh);
        });
    }
}
