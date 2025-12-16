using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NaughtyAttributes;
public class SimpleVectorPath : MonoBehaviour
{

    public List<Transform> points = new List<Transform>();

    public bool autoUpdate;
    public bool reverse;
    // Public Interface

    float _pathLength = -1;
    public float totalLength
    {
        get
        {
            if (_pathLength == -1)
            {
                _pathLength = 0;
                for (int i = 0; i < points.Count - 1; i++)
                {
                    _pathLength += (points[i + 1].position - points[i].position).magnitude;
                }
            }
            return _pathLength;
        }
    }

    public Vector3 GetPosition(float distance)
    {
        var p = GetPositionAndDirection(distance);
        return p.position;
    }

    public (Vector3 position, Vector3 direction) GetPositionAndDirection(float distance)
    {
        distance = Mathf.Clamp(distance, 0, totalLength);
        float d = 0;
        for (int i = 0; i < points.Count - 1; i++)
        {
            float mag = (points[i + 1].position - points[i].position).magnitude;
            if (d + mag >= distance)
            {
                return (position: points[i].position + (points[i + 1].position - points[i].position).normalized * (distance - d), direction: (points[i + 1].position - points[i].position).normalized);
            }
            else
            {
                d += mag;
            }
        }
        return (position: points[points.Count - 1].position, direction: (points[points.Count - 1].position - points[points.Count - 2].position).normalized );
    }

    [Button("Force Update")]
    private void OnValidate()
    {
        if (autoUpdate)
        {
            points.Clear();

            for (int i = 0; i < transform.childCount; i++)
            {
                if (transform.GetChild(i).name.ToLower().Contains("point"))
                {
                    points.Add(transform.GetChild(i));
                }
            }

            if (reverse)
                points.Reverse();
        }
    }

}
