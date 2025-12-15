using UnityEngine;
using System.Collections.Generic;
using DG.Tweening;

public class RandomWaypoints : MonoBehaviour
{
    public Transform[] waypoints; // Array of waypoints to define the path
    public float moveDuration = 3f; // Duration to move between waypoints

    void Start()
    {
        // Create a list to store the waypoints excluding the last one
        List<Transform> intermediateWaypoints = new List<Transform>(waypoints.Length - 1);
        intermediateWaypoints.AddRange(waypoints);
        intermediateWaypoints.RemoveAt(waypoints.Length - 1); // Remove the last waypoint

        // Shuffle the intermediate waypoints to have a different starting point each time
        ShuffleList(intermediateWaypoints);

        // Create a new list to hold the final waypoints with a different start and the same end
        List<Transform> finalWaypoints = new List<Transform>();
        finalWaypoints.Add(waypoints[waypoints.Length - 1]); // Add the last waypoint (same as the first)
        finalWaypoints.AddRange(intermediateWaypoints); // Add the shuffled intermediate waypoints

        // Move the object through the waypoints using DoTween
        transform.DOPath(finalWaypoints.ConvertAll(wp => wp.position).ToArray(), moveDuration, PathType.CubicBezier, PathMode.Full3D)
            .SetOptions(true)
            .SetLookAt(lookAtPosition:Vector3.forward)
            .SetEase(Ease.Linear)
            .SetLoops(-1, LoopType.Restart); // Loop indefinitely
    }

    // Shuffle the list of waypoints
    private void ShuffleList<T>(List<T> list)
    {
        for (int i = 0; i < list.Count; i++)
        {
            int randomIndex = Random.Range(i, list.Count);
            T temp = list[randomIndex];
            list[randomIndex] = list[i];
            list[i] = temp;
        }
    }
}
