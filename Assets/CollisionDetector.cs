using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollisionDetector : MonoBehaviour
{
    // Start is called before the first frame update

    public GameObject offScreenIndicator;
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.name =="EndBoundries")
        {
            offScreenIndicator.SetActive(false);
        }
    }
}
