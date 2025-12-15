using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class ShootingFromAeroplane : MonoBehaviour
{
    public GameObject bulletPrefab;
    public Transform firePoint;
    public Transform player; 

    public float bulletSpeed = 10f;


    public float minDelay;
    public float maxDelay;

    public ParticleSystem selfDestructionbullet;
    public ParticleSystem selfDestructionExplosion;
    public ParticleSystem bulletFiredParticles;
    [HideInInspector]
    public Vector3 startPos;
    [HideInInspector]
    public Vector3 startRot;
    Vector3 localScale;
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.L))
        {
            Shoot();
        }
    }
    private void Start()
    {
        startPos = transform.localPosition;
        startRot = transform.localEulerAngles;
        localScale = transform.localScale;       
    }

    IEnumerator CallShootFunction()
    {
        var RandomTimedelay = Random.Range(minDelay, maxDelay);
        yield return new WaitForSeconds(RandomTimedelay);
        Shoot();
    }

    public void MoveFromStart()
    {
        transform.localPosition = transform.GetComponent<ShootingFromAeroplane>().startPos;
        gameObject.transform.localEulerAngles = gameObject.transform.GetComponent<ShootingFromAeroplane>().startRot;
        transform.localScale = Vector3.zero;
        transform.DOScale(localScale, 2f);
    }

    public void DestoyThePlane()
    {
        if (gameObject.activeInHierarchy)
        {
            StartCoroutine(PerformDestroyEffect());
        }
        else
        {
            gameObject.SetActive(true);
            StartCoroutine(PerformDestroyEffect());
        }
    }
    IEnumerator PerformDestroyEffect()
    {
        if (gameObject.transform.GetComponent<DroneTransformer>())
        {

            yield return new WaitForSeconds(0.1f);
            transform.GetComponent<PlaneTransformer>().fireEffect.SetActive(true);
            //GetComponent<Rigidbody>().velocity = new Vector3(0, -70f, 0);
            transform.DOBlendableRotateBy(new Vector3(Random.Range(-360f, 360f), Random.Range(-360f, 360f), Random.Range(-360f, 360f)), 2f).SetLoops(-1, LoopType.Incremental).SetEase(Ease.Linear);
            GetComponent<Rigidbody>().isKinematic = false;
            GetComponent<PlaneTransformer>().enabled = false;
            yield return new WaitForSeconds(0.2f);
            var Explosion = Instantiate(selfDestructionExplosion, transform.position, transform.rotation);
            Explosion.transform.localScale = Explosion.transform.localScale / 10;

            GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Remove(gameObject);
            if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count == 1)
            {
                foreach (var item in GameManager.instance.levelManager.currentLevel.PlayerBaseList)
                {
                    if (item.GetComponentInChildren<AutoMachineGuns>())
                        item.GetComponentInChildren<AutoMachineGuns>().enabled = false;
                }
            }
            FindObjectOfType<HealthManager>().UpdateOpponentHealth();
            UIManager.instance.totalTargetsRemaining.text = GameManager.instance.levelManager.currentLevel.totalTargets.ToString();
            if (GameManager.instance.levelManager.currentLevel.totalTargets == 0)
            {
                GameController.changeGameState.Invoke(GameState.Complete);
            }
            Destroy(gameObject);
        }
        else
        {
            GameInitialization gameInitialization = FindObjectOfType<GameInitialization>();

            if (gameInitialization != null && gameInitialization.gameObject.activeInHierarchy)
            {
                GameManager.instance.levelManager.currentLevel.totalTargets -= 1;
                if (GameManager.instance.levelManager.currentLevel.totalTargets == 0)
                {
                    gameInitialization.tutorialEnded = true;
                }
            }
            yield return new WaitForSeconds(0.1f);
            transform.GetComponent<PlaneTransformer>().fireEffect.SetActive(true);
            GetComponent<Rigidbody>().velocity = new Vector3(0, -70f, 0);
            transform.DOBlendableRotateBy(new Vector3(Random.Range(-360f, 360f), Random.Range(-360f, 360f), Random.Range(-360f, 360f)), 2f).SetLoops(-1, LoopType.Incremental).SetEase(Ease.Linear);
            GetComponent<Rigidbody>().isKinematic = false;
            GetComponent<PlaneTransformer>().enabled = false;

            yield return new WaitForSeconds(1.4f);
            var Explosion = Instantiate(selfDestructionExplosion, transform.position, transform.rotation);
            GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Remove(gameObject);
            if (GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Count == 1)
            {
                foreach (var item in GameManager.instance.levelManager.currentLevel.PlayerBaseList)
                {
                    if (item.GetComponentInChildren<AutoMachineGuns>())
                        item.GetComponentInChildren<AutoMachineGuns>().enabled = false;
                }
            }
            FindObjectOfType<HealthManager>().UpdateOpponentHealth();
            UIManager.instance.totalTargetsRemaining.text = GameManager.instance.levelManager.currentLevel.totalTargets.ToString();
            //if (GameManager.instance.levelManager.currentLevel.totalTargets == 0)
            //{
            //    GameController.changeGameState.Invoke(GameState.Complete);
            //}

            if (gameInitialization != null && gameInitialization.gameObject.activeInHierarchy)
            {
                //GameManager.instance.levelManager.currentLevel.totalTargets -= 1;
                //if(GameManager.instance.levelManager.currentLevel.totalTargets==0)
                //{
                //    gameInitialization.tutorialEnded = true;
                //}
                gameInitialization.ActivePlane();
            }

            Destroy(gameObject);
        }
    }
    Vector3 targetPosition;
    void Shoot()
    {
        if (GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count != 0)
        {
            var randomEnemy = Random.Range(0, GameManager.instance.levelManager.currentLevel.PlayerBaseList.Count);
            targetPosition = GameManager.instance.levelManager.currentLevel.PlayerBaseList[randomEnemy].gameObject.transform.position;
            GameObject bullet = Instantiate(bulletPrefab, firePoint.position, firePoint.rotation);
            if(GameManager.instance.levelManager.currentLevel.PlayerBaseList[randomEnemy].gameObject.transform.GetComponentInParent<BaseHealthManager>())
                GameManager.instance.levelManager.currentLevel.PlayerBaseList[randomEnemy].gameObject.transform.GetComponentInParent<BaseHealthManager>().UpdateTheHealth();
            bullet.transform.localScale = new Vector3(1f, 1f, 1f);
            bullet.transform.LookAt(targetPosition);
            bullet.GetComponent<PlaneTransformer>().canTransform = true;

            FindObjectOfType<HealthManager>().UpdatePlayerHealth();

            StartCoroutine(CallShootFunction());
        }
    }
}
