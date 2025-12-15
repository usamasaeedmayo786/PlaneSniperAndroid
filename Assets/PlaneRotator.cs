using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaneRotator : MonoBehaviour
{

    public List<GameObject> allColliders;

    public bool isFirstCollision = false;
    public bool DestroyAble = false;

    private bool notActivatedYet = false;
    //private void OnTriggerEnter(Collider other)
    //{
    //    if (other.gameObject.tag == "helicopter")
    //    {
    //        print("isAeroplane");

    //        if(isFirstCollision)
    //        {
    //            other.gameObject.GetComponent<PlaneTransformer>().isFirstCollisionDetected = true;
    //        }

    //        if (other.gameObject.GetComponent<PlaneTransformer>().shouldRotate == false && other.gameObject.GetComponent<PlaneTransformer>().isFirstCollisionDetected)
    //        {
    //            other.gameObject.GetComponent<PlaneTransformer>().StartRotation();
    //        }
    //        if (!notActivatedYet)
    //        {
    //            notActivatedYet = true;
    //            foreach (var item in allColliders)
    //            {
    //                item.SetActive(true);
    //            }
    //        }
    //    }
    //}

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "helicopter" && collision.gameObject.GetComponent<PlaneTransformer>())
        {
            //Destroy(collision.gameObject);
            //collision.gameObject.transform.localPosition = collision.gameObject.transform.GetComponent<ShootingFromAeroplane>().startPos;
            //collision.gameObject.transform.localEulerAngles = collision.gameObject.transform.GetComponent<ShootingFromAeroplane>().startRot;
            collision.gameObject.transform.GetComponent<ShootingFromAeroplane>().MoveFromStart();

        }
    }
}
