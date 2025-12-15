using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class ThrowRocket : MonoBehaviour
{
    public GameObject bulletPrefab;
    public List<Transform> firePoint;

    public float minDelay;
    public float maxDelay;

    public ParticleSystem selfDestructionExplosion;
    public float speed = 500;

    public bool shouldLookBeforeShoot = false;

    private void Start()
    {
        StartCoroutine(CallShootFunction());
    }

    private void Update()
    {
        //print(Vector3.Distance(LevelManager.Instance.currentLevel.mainCamera.transform.position, transform.position)+" distance from Camera");
    }
    IEnumerator CallShootFunction()
    {
        yield return new WaitUntil(() => Vector3.Distance(GameManager.instance.levelManager.mainCamera.transform.position, transform.position) < 2100f);
        if (GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count != 0)
        {
            var randomTimeDelay = Random.Range(minDelay, maxDelay);
            int randomEnemy = Random.Range(0, GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count);

            Vector3 targetPosition = GameManager.instance.levelManager.currentLevel.PlayerBaseList[randomEnemy].transform.position;

            if (shouldLookBeforeShoot && targetPosition != Vector3.zero)
            {
                transform.DOLookAt(targetPosition, randomTimeDelay);
            }

            yield return new WaitForSeconds(randomTimeDelay);
            Shoot(targetPosition);
        }
    }

    void Shoot(Vector3 targetPosition)
    {
        if (GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count != 0)
        {
            int firePointNumber = Random.Range(0, firePoint.Count);
            GameObject projectile = Instantiate(bulletPrefab, firePoint[firePointNumber].position, firePoint[firePointNumber].rotation);

            projectile.transform.LookAt(targetPosition);
            projectile.GetComponent<Rigidbody>().AddForce(projectile.transform.forward * speed);

            if (GameManager.instance.levelManager.currentLevel.PlayerBaseList[0].gameObject.transform.GetComponentInParent<BaseHealthManager>())
            {
                GameManager.instance.levelManager.currentLevel.PlayerBaseList[0].gameObject.transform.GetComponentInParent<BaseHealthManager>().UpdateTheHealth();
            }

            StartCoroutine(CallShootFunction());
        }
    }
}

