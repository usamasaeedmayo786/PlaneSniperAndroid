using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class PlaneTransformer : MonoBehaviour
{
    public float planeMoverSpeed;
    public bool canTransform = false;
    public bool isPlayerBullet = false;
    public bool isDestroyable = false;

    public float rotationSpeed = 30.0f; 
    public float rotationDuration = 2.0f;

    public bool shouldRotate = false;
    private float rotateStartTime;
    private Quaternion startRotation;
    private Quaternion targetRotation;

    private float distance;
    private float time;
    private float GoingInBucketSpeed = 10;
    public GameObject fireEffect;

    public bool isFirstCollisionDetected = false;
    private void Start()
    {
        if (isPlayerBullet)
        {
            Destroy(gameObject, 3);
        }
        if (isDestroyable)
        {
            Destroy(gameObject, 1.2f);
        }
    }

    void Update()
    {
        if (canTransform)
            transform.Translate(Vector3.forward * Time.deltaTime * planeMoverSpeed);

        if (shouldRotate)
        {
            RotateHelicopter();
        }
        if (isPlayerBullet)
        {
            MoveToZeroPosition(); 
            distance = Vector3.Distance(transform.position, transform.parent.position);
            time = distance / GoingInBucketSpeed;
        }
    }

    public void MoveToZeroPosition()
    {
        if (isPlayerBullet)
        {
            transform.DOLocalMove(Vector3.zero, 5f);
        }
    }

    public void StartRotation()
    {
        shouldRotate = true;
        rotateStartTime = Time.time;
        startRotation = transform.localRotation;
        float randomYRotation = Random.Range(100f, 180f);
        targetRotation = Quaternion.Euler(0f,transform.localRotation.y+ randomYRotation, 0f) * startRotation;
    }

    private void RotateHelicopter()
    {
        float progress = (Time.time - rotateStartTime) / rotationDuration;
        if (progress >= 1.0f)
        {
            shouldRotate = false; 
            planeMoverSpeed = 45;
        }
        else
        {
            planeMoverSpeed = 25;
        }
    }
}

