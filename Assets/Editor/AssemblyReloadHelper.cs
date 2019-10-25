using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEditor;
using UnityEditor.Compilation;

namespace Assets.Editor
{
    [InitializeOnLoad]
    public class AssemblyReloadHelper
    {
        static AssemblyReloadHelper()
        {
            AssemblyReloadEvents.afterAssemblyReload += AfterAssemblyReload;
        }

        private static void AfterAssemblyReload()
        {
            GameObject.FindObjectOfType<Camera>().RemoveAllCommandBuffers();
            GameObject.FindObjectsOfType<MonoBehaviour>()
                .Where(obj => obj is INotifyOnReload)
                .Select(obj => obj as INotifyOnReload)
                .ForEach(obj => obj.OnReload());
                
        }
    }
}
