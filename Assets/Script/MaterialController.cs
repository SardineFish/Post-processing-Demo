using UnityEngine;
using System.Collections;
using TMPro;

public class MaterialController : MonoBehaviour
{
    public float Sensity = 1;

    // Use this for initialization
    void Start()
    {
    }

    Coroutine scrollCoroutine;

    // Update is called once per frame
    void Update()
    {
        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if(!Mathf.Approximately(scroll, 0))
        {
            RaycastHit hit;
            if(Physics.Raycast(new Ray(transform.position, transform.forward), out hit, 500))
            {
                var renderer = hit.transform.GetComponent<Renderer>();
                if (renderer && renderer.material)
                {
                    if (scrollCoroutine!=null)
                        StopCoroutine(scrollCoroutine);
                    if (Input.GetKey(KeyCode.LeftShift))
                    {
                        scrollCoroutine = StartCoroutine(AdjustMateiral(scroll * Sensity * 0.2f, renderer.material, renderer.gameObject));
                    }
                    else
                        scrollCoroutine = StartCoroutine(AdjustMateiral(scroll * Sensity, renderer.material, renderer.gameObject));
                }
            }
        }
    }

    IEnumerator AdjustMateiral(float inc, Material material, GameObject obj)
    {
        if (!material.HasProperty("_Roughness"))
            yield break;
        var roughness = material.GetFloat("_Roughness");
        foreach (var t in Utility.TimerNormalized(0.2f))
        {
            var v = roughness + inc * t;
            v = Mathf.Clamp01(v);
            material.SetFloat("_Roughness", v);
            if (obj.transform.Find("Roughness"))
                obj.transform.Find("Roughness").GetComponent<TextMeshPro>().text = v.ToString();
            yield return null;
        }
    }
}
