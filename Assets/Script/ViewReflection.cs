using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ViewReflection : MonoBehaviour
{
    public Transform target;
    public float Height;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        var pos = target.position;
        pos.y = Height - (target.position.y - Height);
        transform.position = pos;
    }
}
