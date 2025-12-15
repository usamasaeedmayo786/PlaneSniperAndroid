using UnityEngine;
using DG.Tweening;

public class RocketMovement : MonoBehaviour
{
    private GameObject targetgGO;
    private float speed;
    public ParticleSystem explosionParticle;

    public GameObject ParticlePrefab; 
    public GameObject rocketMesh; 

    float boostedSpeed;

    private void Start()
    {
        boostedSpeed = speed * 2f;
    }

    bool shouldLookAt = false;
    public void SetTarget(Vector3 target, GameObject targetObject, float bulletSpeed)
    {
        targetgGO = targetObject;
        speed = bulletSpeed;
        targetgGO.transform.GetChild(0).transform.localPosition = new Vector3(Random.Range(-35f, 35f), Random.Range(-25f, 25f), Random.Range(-15f, 0f));

        //print(targetgGO.transform.GetChild(0).parent.gameObject.name + " name of planes");

        shouldLookAt = true;
        targetgGO.transform.GetChild(0).transform.DOLocalMove(Vector3.zero, 3f).OnComplete(() =>
        {
            if (targetgGO.gameObject.GetComponentInParent<BaseHealthManager>())
            {
                targetgGO.gameObject.GetComponentInParent<BaseHealthManager>().UpdateTheHealth();
            }
            rocketMesh.GetComponent<MeshRenderer>().enabled = false;
            DestroyParticles(gameObject);

        });
    }

    void Update()
    {
        if (targetgGO != null)
        {
            if(shouldLookAt)
                transform.LookAt(targetgGO.transform.GetChild(0).transform.position);

            transform.Translate(Vector3.forward * speed * Time.deltaTime);
            if (Vector3.Distance(transform.position, targetgGO.transform.GetChild(0).transform.position) < 0.1f)
            {
                if (targetgGO.gameObject.transform.GetComponentInParent<BaseHealthManager>())
                {
                    targetgGO.gameObject.GetComponentInParent<BaseHealthManager>().UpdateTheHealth();
                }
                rocketMesh.GetComponent<MeshRenderer>().enabled = false;
                DestroyParticles(gameObject);
            }

            if (Vector3.Distance(transform.position, targetgGO.transform.GetChild(0).transform.position) < 10f)
            {
                shouldLookAt = false;
                speed = boostedSpeed;
                rocketMesh.GetComponent<MeshRenderer>().enabled = false;
            }
        }
        else
        {
            DestroyParticles(gameObject);
        }
    }


    private void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.tag =="Helicopter")
        {
            DestroyParticles(collision.gameObject);
        }
    }

    public void DestroyParticles(GameObject g)
    {
        //if(GameManager.instance.isLevelCompleted)
        //{
        //    //FindObjectOfType<HealthManager>().PerformRocketDestoyer(g);
        //}
        rocketMesh.GetComponent<MeshRenderer>().enabled = false;
        var newExplosion = Instantiate(explosionParticle, g.transform.position, Quaternion.identity);
        ParticlePrefab.transform.parent = null;
        newExplosion.transform.parent = null;
        Destroy(gameObject);
    }
}