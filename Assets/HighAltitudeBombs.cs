using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HighAltitudeBombs : MonoBehaviour
{
    public ParticleSystem explosion;


    public float fallSpeed = 5f; // Adjust the speed as needed

    private Rigidbody rb;

    public bool willGiveDamage = false;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        // Start moving the bomb downward when it spawns
        rb.velocity = Vector3.down * fallSpeed;
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.name=="Water")
        {
            StartCoroutine(DestroyObject());
        }

        if (other.gameObject.tag == "ground")
        {
            explosion.gameObject.transform.localScale = explosion.gameObject.transform.localScale / 2;
            explosion.Play();
            explosion.transform.parent = null;
            transform.GetChild(0).gameObject.SetActive(false);
            //explosion.transform.parent = gameObject.transform;
            Destroy(gameObject);
        }

    }

    IEnumerator DestroyObject()
    {
        yield return new WaitForSeconds(.5f);
        explosion.Play();
        explosion.transform.parent = null;
        transform.GetChild(0).gameObject.SetActive(false);
        yield return new WaitForSeconds(1.5f);
        explosion.transform.parent = gameObject.transform;
        if(willGiveDamage)
            FindObjectOfType<HealthManager>().UpdatePlayerHealth();
        Destroy(gameObject);
    }
}
