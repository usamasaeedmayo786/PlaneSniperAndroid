using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System.Linq;

public class PlayerMissileLauncher : MonoBehaviour
{
    public float minDelay;
    public float maxDelay;
    public ParticleSystem selfDestructionExplosion;
    public bool shouldLookBefroreShoot = false;


    public Transform targetTransform; 
    public float bulletSpeed = 5f; 
    public float sphereArea = 5f; 
    public float fireDelay = 0.05f;
    public float nextFireDelay = 3f;
    private void Start()
    {
        Invoke("StartGameplay", .2f);
    }

    public void StartGameplay()
    {
        StartCoroutine(FireBullets());
    }

    IEnumerator FireBullets()
    {
        //if(GameManager.instance.isLevelCompleted)
        //{
        //    minDelay = .2f;
        //    maxDelay = .6f;
        //}
        var RandomTimedelay = Random.Range(minDelay, maxDelay);
        InstantiateBullet();
        yield return new WaitForSeconds(RandomTimedelay);
        if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count != 0)
        {
            StartCoroutine(FireBullets());
            randomEnemy = Random.Range(0, GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count);
            RandomTargetPosition = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject.transform.position;
            targetObjects = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject;
        }
    }
    GameObject targetObjects;
    int randomEnemy;
    Vector3 RandomTargetPosition;
    public float num;


    public void BunchOfRockets()
    {

        for (int i = 4 - 1; i >= 0; i--)
        {
            InstantiateBullet();
            if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count != 0)
            {
                StartCoroutine(FireBullets());
                randomEnemy = Random.Range(0, GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count);
                RandomTargetPosition = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject.transform.position;
                targetObjects = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList[randomEnemy].gameObject;
            }
        }
    }
    bool isCalled = false;
    bool isAttacked = false;
    private void Update()
    {
        if(GameManager.instance.isLevelCompleted && isCalled == false)
        {
            isCalled = true;
            BunchOfRockets();
        }
    }
    void InstantiateBullet()
    {

        if (Vector3.Distance(transform.position, RandomTargetPosition) <= num)
        {
            return;
        }
        
        var validTargets = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList
            .Where(target => Vector3.Distance(transform.position, target.transform.position) > num)
            .ToList();

        if (validTargets.Count > 0)
        {

            Vector3 randomOffset = Random.insideUnitSphere * sphereArea;
            var targetObject = validTargets[Random.Range(0, validTargets.Count)].gameObject;

            Transform targetTransform = targetObject.transform;
            Vector3 targetPosition = targetTransform.position + randomOffset;
            //transform.LookAt(targetTransform.GetChild(0).transform);
            transform.DOLookAt(targetObject.transform.position, 1.5f).OnComplete(delegate
            {
                if (targetObject != null)
                {
                    GameObject bullet = Instantiate(Resources.Load("Missile1"), transform.position, Quaternion.identity) as GameObject;
                    RocketMovement rocketMovement = bullet.GetComponent<RocketMovement>();
                    if (rocketMovement != null)
                    {

                        rocketMovement.SetTarget(targetPosition, targetObject, bulletSpeed);
                    }
                }
            });

        }
    }
}
