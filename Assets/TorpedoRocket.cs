using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class TorpedoRocket : MonoBehaviour
{
    public GameObject fireEffect;
    public ParticleSystem selfDestructionExplosion;

    public GameObject trail1;
    public GameObject trail2;

    bool canTransform = false;
    public void DestryTheRocket()
    {
        StartCoroutine(PerformDestroyEffect());
    }

    public void Update()
    {
        if(canTransform)
            transform.Translate(Vector3.forward * 135f * Time.deltaTime);
    }

    public void OnCollisionEnter(Collision collision)
    {
        //if (collision.gameObject.name == "Water")
        //{
        //    GetComponent<Rigidbody>().isKinematic = true;
        //    transform.LookAt(LevelManager.Instance.currentLevel.soldier.gameObject.transform);
        //    transform.position = new Vector3(transform.position.x, -6.281754f, transform.position.z);
        //    canTransform = true;
        //}

    }
    private void OnTriggerEnter(Collider other)
    {

        if (other.gameObject.name == "PlayerBoat")
        {
            //LevelManager.Instance.currentLevel.mainCamera.transform.parent.gameObject.GetComponent<DOTweenAnimation>().DORewind();
            if (FindObjectOfType<SwipeRotate>().GetComponent<DOTweenAnimation>())
            {
                FindObjectOfType<SwipeRotate>().GetComponent<DOTweenAnimation>().DORewind();
                //LevelManager.Instance.currentLevel.mainCamera.transform.parent.gameObject.GetComponent<DOTweenAnimation>().DORestart();
                FindObjectOfType<SwipeRotate>().GetComponent<DOTweenAnimation>().DORestart();
            }
            DamageThePlayer();
        }
    }

    public void DamageThePlayer()
    {
        FindObjectOfType<HealthManager>().UpdatePlayerHealth();
        Vector3 pos = new Vector3(0, 20, 0);

        var Explosion = Instantiate(selfDestructionExplosion, transform.position + pos, transform.rotation);
        Explosion.gameObject.transform.localScale = Explosion.gameObject.transform.localScale / 1.5f;

    }

    IEnumerator PerformDestroyEffect()
    {
        trail1.transform.parent = null;
        trail2.transform.parent = null;

        yield return new WaitForSeconds(0.01f);
        fireEffect.SetActive(true);
        //transform.DOBlendableRotateBy(new Vector3(Random.Range(-360f, 360f), Random.Range(-360f, 360f), Random.Range(-360f, 360f)), 2f).SetLoops(-1, LoopType.Incremental).SetEase(Ease.Linear);
        yield return new WaitForSeconds(.001f);
        Vector3 pos = new Vector3(0, 20, 0);
        var Explosion = Instantiate(selfDestructionExplosion, transform.position +pos, transform.rotation);
        Explosion.gameObject.transform.localScale = Explosion.gameObject.transform.localScale / 2.3f;
        GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Remove(gameObject);
        GameManager.instance.BlastSound.GetComponent<EnemiesBlastSoundManager>().PlayReload();
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
        if (GameManager.instance.levelManager.currentLevel.totalTargets < 1)
        {
            GameController.changeGameState.Invoke(GameState.Complete);
        }
        Destroy(trail1.gameObject);
        Destroy(trail2.gameObject);
        
        Destroy(gameObject);
    }
}
