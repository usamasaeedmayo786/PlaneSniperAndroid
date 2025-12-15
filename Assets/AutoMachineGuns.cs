using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System.Linq;

public class AutoMachineGuns : MonoBehaviour
{
    public GameObject bulletPrefab;
    public Transform firePoint;

    public float minDelay;
    public float maxDelay;


    public bool shootClosest = false;
    private void Start()
    {
        StartCoroutine(CallShootFunction());
    }

    IEnumerator CallShootFunction()
    {
        var randomTimeDelay = Random.Range(minDelay, maxDelay);
        yield return new WaitForSeconds(randomTimeDelay);
        if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count!=0)
            Shoot();
    }

    Vector3 targetPosition;
    GameObject closestEnemy;
    void Shoot()
    {

        if (shootClosest)
        {
            if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count != 0)
            {
                closestEnemy = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList
                    .OrderBy(enemy => Vector3.Distance(transform.position, enemy.transform.position))
                    .FirstOrDefault();
            }
        }
        else
        {
            if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count != 0)
            {
                var randomTarget = Random.Range(0, GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count);
                closestEnemy = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomTarget].gameObject;
            }
        }


        StartCoroutine(RotateAndShoot());
    }
    IEnumerator RotateAndShoot()
    {
        yield return new WaitForSeconds(.18f);

        if (closestEnemy != null)
        {
            targetPosition = closestEnemy.transform.position;
            firePoint.transform.DOLookAt(targetPosition, .16f);
        }
        GameObject bullet = Instantiate(bulletPrefab, firePoint.position, firePoint.rotation);
        bullet.transform.localScale = new Vector3(1f, 1f, 1f);

        bullet.GetComponent<PlaneTransformer>().canTransform = true;
        bullet.transform.LookAt(targetPosition);
        StartCoroutine(CallShootFunction());

    }
}
