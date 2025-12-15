using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class ReloadGun : MonoBehaviour
{
    public int reloadAfter;
    int reloadStartVal;

    public int bulletsAvailable;
    public int totalBullets;

    public bool isLoadingBullets = false;
    public bool isMachineGun = false;

    public bool isShoulderRocket = false;


    [Header("Values to Adjust The Gun, Editor Use Only")]
    public float GunYPos;
    public float GunXRot;


    public int brustToThrow = 12;

    private Vector3 savedPosition;
    private Quaternion savedRotation;

    private void Start()
    {
        reloadStartVal = reloadAfter;
        if (GetComponent<WeaponBase>()) 
        {
            savedPosition = LevelManager.Instance.mainCamera.gameObject.transform.localPosition;
            savedRotation = LevelManager.Instance.mainCamera.gameObject.transform.localRotation;
            //cameraInitialPos.position = LevelManager.Instance.mainCamera.gameObject.transform.localPosition;
            //cameraInitialRot.rotation = LevelManager.Instance.mainCamera.gameObject.transform.localRotation;

        }
    }

    public void ReloadGunBullets()
    {
        isLoadingBullets = true;
        GetComponent<Animator>().SetTrigger("ReloadGun");
    }

    public void AllowReloading()
    {
        GameManager.instance.zoomSystem.gameObject.transform.DOScale(0.87625f, .2f);

        isLoadingBullets = false;
        ResetCamera();
    }

    public void UpdateBulletsMagezine()
    {
        bulletsAvailable -= 1;
        reloadAfter -= 1;
        if(bulletsAvailable==0)
        {
            print("LevelFail");
        }
        if(reloadAfter==0)
        {
            GameManager.instance.zoomSystem.gameObject.transform.localScale = Vector3.zero;
            reloadAfter = reloadStartVal;
            if(isMachineGun)
            {
                GameManager.instance.zoomSystem.gameObject.transform.localScale = Vector3.zero;
                // load machineGunHere
                ReloadMachineGunBullets();
            }
            else if (isShoulderRocket)
            {
                GameManager.instance.zoomSystem.gameObject.transform.localScale = Vector3.zero;
                // load machineGunHere
                //ReloadMachineGunBullets();
                ReloadGunBullets();

            }
            else
            {
                GameManager.instance.zoomSystem.gameObject.transform.localScale = Vector3.zero;
                ReloadGunBullets();
            }
        }
    }

    public void ReloadMachineGunBullets()
    {
        isLoadingBullets = true;

        LevelManager.Instance.mainCamera.transform.DOMove(GetComponent<WeaponBase>().CameraReloadInitialPosition.transform.position, .2f).
        OnComplete(delegate 
        {
            print("tttr");
            GameManager.instance.MachineGunIcon.SetActive(false);
            GetComponent<WeaponBase>().playerHead.GetComponent<SkinnedMeshRenderer>().enabled = true;
            LevelManager.Instance.mainCamera.transform.DOMove(GetComponent<WeaponBase>().CameraReloadPosition.transform.position, .2f);
            LevelManager.Instance.mainCamera.transform.DORotate(GetComponent<WeaponBase>().CameraReloadPosition.transform.eulerAngles, .2f).
            OnComplete(delegate 
            {
                print("tttr2");

                GetComponent<WeaponBase>().gunAnimator.GetComponent<Animator>().SetTrigger("ReloadGun");
            });
        });


        // undoAll
        LevelManager.Instance.mainCamera.transform.DOMove(GetComponent<WeaponBase>().CameraReloadInitialPosition.transform.position, .2f).SetDelay(delay: 4f).
        OnComplete(delegate
        {
            GetComponent<WeaponBase>().playerHead.GetComponent<SkinnedMeshRenderer>().enabled = false;
            LevelManager.Instance.mainCamera.transform.DOMove(GetComponent<WeaponBase>().CameraShootPosition.transform.position, .2f);
            LevelManager.Instance.mainCamera.transform.DORotate(GetComponent<WeaponBase>().CameraShootPosition.transform.eulerAngles, .2f);
            GameManager.instance.MachineGunIcon.SetActive(true);
        });
    }

    public void ResetCamera()
    {
        //print("savedRotation initial" + savedRotation);

        //LevelManager.Instance.mainCamera.transform.DOLocalRotate(new Vector3(0, 180, 0), .02f);
        if (GetComponent<WeaponBase>())
        {

            LevelManager.Instance.mainCamera.gameObject.transform.localPosition = savedPosition;
            LevelManager.Instance.mainCamera.gameObject.transform.localRotation = savedRotation;
            //print("savedRotation final" + savedRotation);
        }
    }
}
