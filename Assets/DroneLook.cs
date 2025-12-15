using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class DroneLook : MonoBehaviour
{
    private void Update()
    {
        transform.LookAt(LevelManager.Instance.soldier.gameObject.transform);
    }
}
