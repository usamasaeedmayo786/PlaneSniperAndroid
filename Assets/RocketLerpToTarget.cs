using System.Collections;
using UnityEngine;

public class RocketLerpToTarget : MonoBehaviour
{
    public Transform targetTransform;
    public float bulletSpeed = 5f;
    public float sphereArea = 5f;
    public float fireDelay = 0.05f;
    public float nextFireDelay = 3f;

    void Start()
    {
        StartCoroutine(FireBullets());
    }

    IEnumerator FireBullets()
    {
        yield return new WaitForSeconds(nextFireDelay); 
        InstantiateBullet();
        StartCoroutine(FireBullets()); // Start firing sequence again
        randomEnemy = Random.Range(0, GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count);
        RandomTargetPosition = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject.transform.position;
    }

    int randomEnemy;
    Vector3 RandomTargetPosition;
    void InstantiateBullet()
    {
        GameObject bullet = Instantiate(Resources.Load("Missile1"), transform.position, Quaternion.identity) as GameObject;

        if (bullet != null)
        {
            Vector3 randomOffset = Random.insideUnitSphere * sphereArea;
            Vector3 targetPosition = RandomTargetPosition + randomOffset;
            RocketMovement rocketetMovement = bullet.GetComponent<RocketMovement>();
            if (rocketetMovement != null)
            {
                rocketetMovement.SetTarget(targetPosition, GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject, bulletSpeed);
            }
        }
    }
}