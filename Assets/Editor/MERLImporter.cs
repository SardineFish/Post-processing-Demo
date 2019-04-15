using UnityEngine;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
using System.IO;
using System;

namespace Assets.Editor
{
    [ScriptedImporter(9, "binary")]
    class MERLImporter: ScriptedImporter
    {
        const int BRDFSamplingResThetaH = 90;
        const int BRDFSamplingResThetaD = 90;
        const int BRDFSamplingResPhiD = 360;

        const double RedScale = 1.0 / 1500.0;
        const double GreenScale = 1.15 / 1500.0;
        const double BlueScale = 1.66 / 1500;

        public override void OnImportAsset(AssetImportContext ctx)
        {
            var brdf = ReadBRDF(ctx.assetPath);
            Debug.Log($"Loading MERL from '{ctx.assetPath}'");
            var texture = new Texture3D(BRDFSamplingResThetaH, BRDFSamplingResThetaD, BRDFSamplingResPhiD / 2, TextureFormat.ARGB32, false);

            for (var x = 0; x < 90;x++)
            {
                for (var y = 0; y < 90;y++)
                {
                    for (var z = 0; z < 180;z++)
                    {
                        var (r, g, b) = LookupBRDF(brdf, x, y, z);
                        texture.SetPixel(x, y, z, new Color((float)r, (float)g, (float)b));
                    }
                }
            }
            texture.filterMode = FilterMode.Trilinear;
            texture.wrapMode = TextureWrapMode.Clamp;
            ctx.AddObjectToAsset("Texture3D", texture);
            ctx.SetMainObject(texture);
            Debug.Log($"MERL loaded.");
        }

        static double[] ReadBRDF(string filename)
        {
            using (var fs = new FileStream(filename, FileMode.Open))
            using (var br = new BinaryReader(fs))
            {
                int dimensionThetaHalf = br.ReadInt32();
                int dimensionThetaDiff = br.ReadInt32();
                int dimensionPhiDiff = br.ReadInt32();
                int n = dimensionPhiDiff * dimensionThetaDiff * dimensionThetaHalf;
                if (n != BRDFSamplingResPhiD * BRDFSamplingResThetaD * BRDFSamplingResThetaH / 2)
                    throw new Exception("Dimensions don't match");
                double[] buffer = new double[n * 3];
                for (var i = 0; i < n * 3; i++)
                    buffer[i] = br.ReadDouble();
                br.Close();
                fs.Close();
                return buffer;
            }
        }
        static (double red, double green, double blue) LookupBRDF(double[] brdf, int thetaHalf, int thetaDiff, int phiDiff)
        {
            int idx = phiDiff +
                thetaDiff * BRDFSamplingResPhiD / 2 +
                thetaHalf * BRDFSamplingResPhiD / 2 * BRDFSamplingResThetaD;

            return (
                brdf[idx] * RedScale,
                brdf[idx + BRDFSamplingResThetaH * BRDFSamplingResThetaD * BRDFSamplingResPhiD / 2] * GreenScale,
                brdf[idx + BRDFSamplingResThetaH * BRDFSamplingResThetaD * BRDFSamplingResPhiD] * BlueScale
            );
        }
    }
}