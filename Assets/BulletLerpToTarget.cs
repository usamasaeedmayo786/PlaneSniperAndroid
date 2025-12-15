using System.Collections;
using UnityEngine;

public class BulletLerpToTarget : MonoBehaviour
{
    public Transform shootingPos;
    public float bulletSpeed = 5f; 
    public float sphereArea = 5f; 
    public float fireDelay = 0.05f;
    public float minNextFireDelay = 3f;
    public float maxNextFireDelay = 3f;

    public int maxBulletPerBrust;
    public int minBulletPerBrust;

    public bool inPlayerHand = false;
    public bool isDummyBullets = false;
    public bool isDrone = false;

    void Start()
    {
        StartCoroutine(FireBullets());
    }

    IEnumerator FireBullets()
    {
        yield return new WaitUntil(() => Vector3.Distance(GameManager.instance.levelManager.mainCamera.transform.position, transform.position) < 2100f);

        var RandomDelay = Random.Range(minNextFireDelay, maxNextFireDelay);
        yield return new WaitForSeconds(RandomDelay);
        if (inPlayerHand)
        {
            if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count != 0)
            {
                if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count > 0)
                {
                    randomEnemy = Random.Range(0, GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count);
                    // Rest of the code for EnemyAeroplanesList access
                }
                RandomTargetPosition = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject.transform.position;
                for (int i = 0; i < Random.Range(minBulletPerBrust, maxBulletPerBrust); i++)
                {
                    InstantiateBullet();
                    yield return new WaitForSeconds(fireDelay);
                }
                yield return new WaitForSeconds(RandomDelay);
                StartCoroutine(FireBullets());
            }
        }
        else
        {
            //print("tettt");

            if (GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count != 0)
            {
                if (GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count > 0)
                {
                    randomEnemy = Random.Range(0, GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count);
                    // Rest of the code for EnemyAeroplanesList access
                }
                //print("tettt");
                
                if(!isDrone)
                    RandomTargetPosition = GameManager.instance.levelManager.currentLevel.PlayerBaseList[randomEnemy].gameObject.transform.position;
                else
                    RandomTargetPosition = GameManager.instance.levelManager.mainCamera.transform.position;

                for (int i = 0; i < Random.Range(minBulletPerBrust, maxBulletPerBrust); i++)
                {
                    InstantiateBullet();
                    yield return new WaitForSeconds(fireDelay);
                }
                yield return new WaitForSeconds(RandomDelay);
                StartCoroutine(FireBullets());
            }
        }
    }
    GameObject targetObject;

    int randomEnemy;
    Vector3 RandomTargetPosition;
    void InstantiateBullet()
    {
        GameObject bullet = Instantiate(Resources.Load("BulletPrefab"), shootingPos.transform.position, Quaternion.identity) as GameObject;
        if (isDummyBullets)
        {
            bullet.GetComponent<BulletMovement>().Stopdamaging = true;
        }

        if (bullet != null)
        {
            Vector3 randomOffset = Random.insideUnitSphere * sphereArea;
            Vector3 targetPosition = RandomTargetPosition + randomOffset;
            BulletMovement bulletMovement = bullet.GetComponent<BulletMovement>();

            if (bulletMovement != null)
            {
                int enemyCount = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count;
                int playerCount = GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count;

                if (inPlayerHand && enemyCount > 0)
                {
                    randomEnemy = Random.Range(0, enemyCount);
                    targetObject = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject;
                }
                else if (!inPlayerHand && playerCount > 0)
                {
                    randomEnemy = Random.Range(0, playerCount);
                    targetObject = GameManager.instance.levelManager.currentLevel.PlayerBaseList[randomEnemy].gameObject;
                }

                if (!GameManager.instance.isLevelFailed && !GameManager.instance.isLevelCompleted && targetObject != null)
                {
                    bulletMovement.SetTarget(targetPosition, targetObject, bulletSpeed);
                }
                else
                {
                    Destroy(bulletMovement.gameObject);
                }
            }
        }
    }
}
