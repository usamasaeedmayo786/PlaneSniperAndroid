using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class DroneTransformer : MonoBehaviour
{
    // this script will move the aeroplanes
    public ParticleSystem selfDestructionExplosion;
    public Transform Target;

    [SerializeField] float minTime = 15;
    [SerializeField] float maxTime = 30f;


    Vector3 initialPosition;
    private void Start()
    {

        initialPosition = transform.localPosition;
        FindNewTarget();
    }

    public void FindNewTarget()
    {
        transform.localPosition = initialPosition;
        int targetNumber = Random.Range(0, LevelManager.Instance.currentLevel.PlayerBaseList.Count);
        Target = LevelManager.Instance.currentLevel.PlayerBaseList[targetNumber].transform;
        DestroyTheBlast(Target.gameObject);
    }

    public void DestroyTheBlast(GameObject gameObj)
    {
        var randomDuration = Random.Range(minTime, maxTime);
        transform.DOMove(gameObj.transform.position, randomDuration).SetEase(ease:Ease.Linear).OnComplete(delegate
         {
             var Explosion = Instantiate(selfDestructionExplosion, transform.position, transform.rotation);
             Explosion.transform.localScale = Explosion.transform.localScale / 5;
             Explosion.transform.parent = null;
             FindObjectOfType<HealthManager>().UpdatePlayerHealth();
             UIManager.instance.totalTargetsRemaining.text = GameManager.instance.levelManager.currentLevel.totalTargets.ToString();
             FindNewTarget();
         });
    }

}
