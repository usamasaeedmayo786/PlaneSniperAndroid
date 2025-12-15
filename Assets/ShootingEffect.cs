using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DG.Tweening;
public class ShootingEffect : MonoBehaviour
{

    //private Vector3 savedPosition;
    private Quaternion savedRotation;
    public GameObject gunBullets;
    public GameObject gunAnimator;
    public GameObject bulletPos;


    //=========================================================ROUGH FOR NOW


    public ParticleSystem bulletParticle;
    public float bulletsDelay = .2f;

    [Header("This will not exceed than bullets Delay")]
    public float muzzleDisableDelay = .2f;



    //=========================================================ROUGH FOR NOW
    Animator gunAnimatorObj;
    private void Start()
    {
        gunAnimatorObj = gunAnimator.GetComponent<Animator>();
        //savedPosition = LevelManager.Instance.mainCamera.gameObject.transform.localPosition;
        savedRotation = transform.parent.gameObject.transform.localRotation;
    }
    public List<GameObject> UiSprites;
    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit))
            {
                // This will work for any collider hit, whether it's on the parent or a child, as long as it has the correct tag.
                if (hit.collider.CompareTag("StoreGun"))
                {
                    StartShooting();
                }
            }
        }
        else if (Input.GetMouseButtonUp(0))
        {
            StopShooting();
        }
    }

    private void StartShooting()
    {
        //transform.localPosition = savedPosition;
        //transform.parent.gameObject.transform.localEulerAngles =VehicleSelection.Instance.Rotations;
        gunAnimatorObj.enabled = true;

        transform.parent.DOLocalRotate(VehicleSelection.Instance.Rotations, .3f);

        StartCoroutine(ShootBulletsRepeatedly());
    }

    private void StopShooting()
    {
        foreach (var item in UiSprites)
        {
            item.SetActive(false);
        }
        transform.parent.DOLocalRotate(savedRotation.eulerAngles, .4f);
        //LevelManager.Instance.mainCamera.gameObject.transform.localPosition = savedPosition;
        //LevelManager.Instance.mainCamera.gameObject.transform.localRotation = savedRotation;
        StopAllCoroutines();
    }

    IEnumerator ShootBulletsRepeatedly()
    {
        while (true)
        {
            PlayBulletsEffects();
            yield return new WaitForSeconds(bulletsDelay);
        }
    }

    public void PlayBulletsEffects()
    {
        StartCoroutine(ShootBullet());
    }

    IEnumerator ShootBullet()
    {
        foreach (var item in UiSprites)
        {
            item.SetActive(true);
        }
        if (gunBullets != null)
        {
            GameObject GunBullet = Instantiate(gunBullets, transform.position, transform.rotation);
            GunBullet.transform.SetParent(bulletPos.transform, false);
            GunBullet.transform.localPosition = Vector3.zero;
            GunBullet.transform.DOLocalRotate(Vector3.zero, .000001f);

            GunBullet.transform.DetachChildren(); // Make sure it does not remain a child of the camera.
            GunBullet.GetComponent<PlaneTransformer>().canTransform = true;
            StartCoroutine(DestroyTheBullets(GunBullet));
        }
        if (bulletParticle != null)
        {
            bulletParticle.Play();
        }

        yield return new WaitForSeconds(muzzleDisableDelay);
        foreach (var item in UiSprites)
        {
            item.SetActive(false);
        }
    }

    IEnumerator DestroyTheBullets(GameObject GunBullet)
    {
        yield return new WaitForSeconds(.2f);
        Destroy(GunBullet);
    }
}
