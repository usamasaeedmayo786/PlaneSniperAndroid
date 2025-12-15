using UnityEngine;

public class RaycastDetection : MonoBehaviour
{
    public static RaycastDetection instance;

    public bool CanDetect = true;
    public float raycastDistance = 100f;

    public bool ObjectFound = false;
    public GameObject lastObject;

    private void Awake()
    {
        instance = this;
    }

    void Update()
    {
        if (GameManager.instance.levelManager.soldier.GetComponent<ReloadGun>().isLoadingBullets == false)
        {
            if (CanDetect)
            {
                Ray ray = Camera.main.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0));
                RaycastHit hit;

                if (Physics.Raycast(ray, out hit, raycastDistance))
                {
                    if (hit.collider != null && hit.collider.gameObject.tag == "helicopter")
                    {
                        ObjectFound = true;
                        lastObject = hit.collider.gameObject;
                    }
                    if (hit.collider != null && hit.collider.gameObject.GetComponent<TorpedoRocket>())
                    {
                        ObjectFound = true;
                        lastObject = hit.collider.gameObject;
                    }
                }
                else
                {
                    ObjectFound = false;
                    lastObject = null; // Reset lastObject to null when no object is hit by the raycast
                }
            }
            if (ObjectFound && LevelManager.Instance.soldier.GetComponent<WeaponBase>() && !LevelManager.Instance.soldier.GetComponent<WeaponBase>().AutoShootMachineGun && lastObject != null)
            {
                StartCoroutine(CallFunctionWithDelay());
            }
        }
    }




    private System.Collections.IEnumerator CallFunctionWithDelay()
    {
        if (lastObject != null && lastObject.GetComponent<EnemyHealth>() != null && !lastObject.GetComponent<EnemyHealth>().IsDestroyed)
        {
            if (GameManager.instance.isLevelCompleted || GameManager.instance.isLevelFailed)
            {
                // Stop fire animation if level is complete or failed
                WeaponBase wpb = LevelManager.Instance.soldier.GetComponent<WeaponBase>();
                if (wpb != null && wpb.gunAnimator != null)
                {
                    wpb.gunAnimator.GetComponent<Animator>().SetBool("Fire", false);
                }
                yield break; // Exit the coroutine
            }

            if (FindObjectOfType<ZoomSystem>() != null)
            {
                FindObjectOfType<ZoomSystem>().ThrowBrust();
            }

            WeaponBase weaponBase = LevelManager.Instance.soldier.GetComponent<WeaponBase>();
            if (weaponBase != null && weaponBase.gunAnimator != null)
            {
                weaponBase.gunAnimator.GetComponent<Animator>().SetBool("Fire", true);
            }

            yield return new WaitForSeconds(0.3f);
            ObjectFound = false; // Reset ObjectFound after performing the action
        }
    }
}