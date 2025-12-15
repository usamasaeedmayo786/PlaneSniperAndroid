using UnityEngine;

public class BulletMovement : MonoBehaviour
{
    private Vector3 targetPosition;
    private float speed;
    private GameObject targetgGO;
    public bool Stopdamaging = false;
    public void SetTarget(Vector3 target, GameObject targetObject, float bulletSpeed)
    {
        targetgGO = targetObject;
        targetPosition = target;
        speed = bulletSpeed;
    }

    void Update()
    {
        transform.position = Vector3.Lerp(transform.position, targetPosition, speed * Time.deltaTime);
        if (Vector3.Distance(transform.position, targetPosition) < 0.1f)
        {
            if (!Stopdamaging)
            {
                if (targetgGO.gameObject != null)
                {
                    if (targetgGO.gameObject.transform.GetComponentInParent<BaseHealthManager>())
                        targetgGO.gameObject.transform.GetComponentInParent<BaseHealthManager>().UpdateTheHealth();
                }
                if (GameManager.instance.isLevelFailed == false && GameManager.instance.isLevelCompleted == false)
                {
                    FindObjectOfType<HealthManager>().UpdatePlayerHealth();
                }
            }
            Destroy(gameObject);
        }
    }
}
