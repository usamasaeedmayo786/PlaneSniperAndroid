using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class FireAnimationEvent : MonoBehaviour
{
    [SerializeField] bool inactive;
    WeaponBase WeaponBase;

    void Start()
    {
        if(!inactive)
        WeaponBase = GetComponentInParent<WeaponBase>();
    }

    // we no longer use animations for timing, but this script remains to catch the events that do exist in the animations

    public void Fire()
    {
        //if(WeaponBase)
        //WeaponBase.Fire();
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletParticle1.Play();
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletParticle2.Play();
    }

    public void StopFire()
    {
        //if(WeaponBase)
       // WeaponBase.StopFire();
    }

    public void StartFire()
    {
        //if(WeaponBase)
        //WeaponBase.StopFire();
    }

    public void RemoveBullet()
    {
        //if(WeaponBase)
        //WeaponBase.BulletRemoveAnimation();
    }

    public void ReloadStart()
    {
        //if(WeaponBase)
        //WeaponBase.ReloadStart();
    }

    public void Reload()
    {

    }

    public void AllowReloadingGun()
    {
        GetComponentInParent<ReloadGun>().AllowReloading();
    }

    public void ActivateBullet()
    {
        //if(WeaponBase)
        //WeaponBase.ActivateBullet();
    }

    public void PlayParticles()
    {
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletParticle1.Play();
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletParticle2.Play();
    }

    public void DisableZoom()
    {
        GameManager.instance.zoomSystem.gameObject.transform.DOScale(0.0001f, .01f);
    }

    public void ResetCamera()
    {
        GetComponentInParent<ReloadGun>().ResetCamera();
    }
}
