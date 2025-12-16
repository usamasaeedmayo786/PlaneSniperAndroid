
using CnControls;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class MovementController : MonoBehaviour
{
    public float rotationFactor, rotationSpeed, movementSpeed, upDownFactor, SmokeTrailDelayFactor;
    public Vector3 tiltRotation;
    public GameObject exPlosion;
    public GameObject smokeTrails;

    public Transform HitTarget;

    private bool isBlasted = false;
    private float timeElapsed = 0f;
    public float lateralFrequency = 1f; // Adjust this for lateral movement frequency
    public float verticalFrequency = 1f; // Adjust this for vertical movement frequency
    public float lateralAmplitude = 1f; // Adjust this for lateral movement amplitude
    public float verticalAmplitude = 1f; // Adjust this for vertical movement amplitude


    private Vector3 randomPosition;
    private float lerpStartTime;
    public float lerpDuration = 5f; // Adjust this for the duration 


    [SerializeField] bool PlayCurveEffect = false;
    void Start()
    {
        transform.SetParent(null);
        transform.position = LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.position;
        transform.rotation = LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.rotation;

        if (HitTarget != null && PlayCurveEffect)
        {
            float distance = Vector3.Distance(transform.position, HitTarget.transform.position);

            if (distance > 550f)
            {
                randomPosition = new Vector3(
                    HitTarget.transform.position.x + Random.Range(-150f, 150f),
                    HitTarget.transform.position.y + Random.Range(-150, 150),
                    HitTarget.transform.position.z + Random.Range(-3, 3)
                );
                lerpStartTime = Time.time;
            }
        }
        Invoke("EnableSmokeTrail", SmokeTrailDelayFactor);
    }

    public void EnableSmokeTrail()
    {
        if(smokeTrails!=null)
            smokeTrails.SetActive(true);
    }

    private void Update()
    {
        if (HitTarget == null)
        {
            MoveWithoutTarget();
        }
        else
        {
            MoveTowardsTarget();
        }
    }

    private void MoveWithoutTarget()
    {
        timeElapsed += Time.deltaTime;

        // Calculate lateral and vertical offsets using sine and cosine functions
        float lateralOffset = Mathf.Sin(timeElapsed * lateralFrequency) * lateralAmplitude;
        float verticalOffset = Mathf.Cos(timeElapsed * verticalFrequency) * verticalAmplitude;

        // Apply the offsets to the position
        Vector3 offset = new Vector3(lateralOffset, verticalOffset, 1f);
        transform.Translate(offset * movementSpeed * Time.deltaTime);
    }

    private void MoveTowardsTarget()
    {
        if (PlayCurveEffect)
        {
            float elapsedTime = Time.time - lerpStartTime;
            float t = elapsedTime / lerpDuration;

            Vector3 currentPosition = Vector3.Lerp(randomPosition, HitTarget.position, t);
            transform.LookAt(currentPosition);

        }
        else
        {
            transform.LookAt(HitTarget.transform);
        }
        transform.Translate(Vector3.forward * movementSpeed * Time.deltaTime);
        float distance = (transform.position - HitTarget.transform.position).magnitude;
        if (distance < 5 && !isBlasted)
        {
            isBlasted = true;
            var particle = Instantiate(exPlosion, transform.position, transform.rotation);
            particle.transform.localScale = particle.transform.localScale / 3;
            particle.transform.SetParent(null);
            Destroy(gameObject);

            if (HitTarget.GetComponent<DOTweenPath>())
            {
                DOTween.Kill(HitTarget.gameObject);
                Destroy(HitTarget.GetComponent<DOTweenPath>());
            }

            if (HitTarget.GetComponent<TorpedoRocket>())
            {
                //
                HitTarget.GetComponent<TorpedoRocket>().DestryTheRocket();
            }
            else
            {
                HitTarget.GetComponent<ShootingFromAeroplane>().DestoyThePlane();
                print("testtt");

            }
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Opponent")
        {
            //GameManager.instance.touchPad.SetActive(false);
            //print("Dest");
            var particle = Instantiate(exPlosion, transform.position, transform.rotation);
            particle.transform.SetParent(null);
            Destroy(gameObject);
        }
    }
}

