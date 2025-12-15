using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TorpedoRocketThrower : MonoBehaviour
{
    public GameObject RocketPrefab;


    public ParticleSystem selfDestructionExplosion;

    public float minDelayToBlast = 4f;
    public float maxDelayToBlast = 8f;

    Vector3 RandomTargetPosition;
    public float sphereArea = 5f;
    public bool canThrowHighAltitudeBombs = false;
    public float minDelayToThrowRocket = 4f;
    public float maxDelayToThrowRocket = 8f;

    [SerializeField] bool playSideSmoke = false;
    public bool canGiveDamage = false;

    private void Start()
    {
        if (canThrowHighAltitudeBombs)
        {
            StartCoroutine(SpawnTheRocket());
        }
        if(playSideSmoke)
            StartCoroutine(SideExplosions());

    }

    IEnumerator SpawnTheRocket()
    {
        var delay = Random.Range(minDelayToThrowRocket, maxDelayToThrowRocket);
        yield return new WaitForSeconds(delay);

        var numbers = Random.Range(1, 5);
        for (int i = 0; i < numbers; i++)
        {
            var missile= Instantiate(RocketPrefab, transform.position, transform.rotation);

            if (canGiveDamage)
                missile.GetComponent<HighAltitudeBombs>().willGiveDamage = true;
            yield return new WaitForSeconds(.6f);
        }
        StartCoroutine(SpawnTheRocket());
    }


    IEnumerator SideExplosions()
    {
        var randomDelay = Random.Range(minDelayToBlast, maxDelayToBlast);
        yield return new WaitForSeconds(randomDelay);

        //Vector3 randomOffset = Random.insideUnitSphere * sphereArea;
        //Vector3 targetPosition = RandomTargetPosition + randomOffset;

        var Explosion = Instantiate(selfDestructionExplosion, transform.position, transform.rotation);
        
        Explosion.transform.parent = gameObject.transform;
        Explosion.transform.localPosition = Vector3.zero;

        Explosion.transform.localPosition = new Vector3(Random.Range(-10, 10), Random.Range(-10, 10), Random.Range(-2, 25));

        Explosion.transform.parent = null;

        StartCoroutine(SideExplosions());
    }

    //var Explosion = Instantiate(selfDestructionExplosion, transform.position, transform.rotation);

}
