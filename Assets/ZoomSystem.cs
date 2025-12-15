using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;
using UnityEngine.UI;
public class ZoomSystem : MonoBehaviour
{

    public GameObject SnipperUI;
    public GameObject inGamePointer;
    public Camera mainCamera;
    float soldierScale;
    [HideInInspector]
    public bool isZoomPressed = false;
    public bool isReadyToShootBullet = false;

    [HideInInspector]
    public bool isPointerDown = false;

    GameObject Soldier;

    Camera maincamera;
    GameInitialization gameInitialization;
    public void Start()
    {
        gameInitialization = FindObjectOfType<GameInitialization>();

        Soldier = GameManager.instance.levelManager.soldier.gameObject;
        soldierScale = Soldier.transform.localScale.x;
        maincamera = LevelManager.Instance.mainCamera;
    }

    public void MousDownCalled()
    {


        if (gameInitialization != null && gameInitialization.gameObject.activeInHierarchy)
        {
            gameInitialization.isDragActive = false;
        }
        if (Soldier.GetComponent<ReloadGun>().isLoadingBullets == false)
        {
            PointerDowned();

            if (Soldier.GetComponent<WeaponBase>() && !Soldier.GetComponent<ReloadGun>().isShoulderRocket)
            {
                LevelManager.Instance.mainCamera.GetComponent<Animator>().SetTrigger("zoom");
                var MachineGunImage = GameManager.instance.MachineGunIcon.GetComponent<Image>();
                MachineGunImage.DOColor(new Color(MachineGunImage.color.r, MachineGunImage.color.g, MachineGunImage.color.b, 0.3f), .2f);
            }

            else if (Soldier.GetComponent<WeaponBase>() && Soldier.GetComponent<ReloadGun>().isShoulderRocket)
            {
                if (Soldier.GetComponent<WeaponBase>().rocketMissile != null)
                {
                    if (!Soldier.GetComponent<WeaponBase>().rocketMissile.activeInHierarchy)
                    {
                        Soldier.GetComponent<WeaponBase>().rocketMissile.SetActive(true);
                    }
                }
                Soldier.GetComponent<Animator>().SetBool("aimUp", true);
                var MachineGunImage = GameManager.instance.MachineGunIcon.GetComponent<Image>();
                MachineGunImage.DOColor(new Color(MachineGunImage.color.r, MachineGunImage.color.g, MachineGunImage.color.b, 0.3f), .2f);
            }

            else
            {
                Soldier.transform.transform.GetComponent<Animator>().SetBool("aimUp", true);
                isZoomPressed = true;
                transform.GetComponent<Image>().enabled = false;
                RaycastDetection.instance.lastObject = null;
                RaycastDetection.instance.CanDetect = true;
                inGamePointer.SetActive(false);
                Invoke("CallZoomInWithDelay", .4f);
            }
        }
    }

    public void PointerUpped()
    {
        isPointerDown = false;
    }
    public void PointerDowned()
    {
        isPointerDown = true;
    }

    public void CallZoomInWithDelay()
    {
        if (isPointerDown)
        {
            Camera.main.transform.parent = GameManager.instance.levelManager.cameraZoomPos.transform;
            var floatVal = LevelManager.Instance.soldier.GetComponent<ReloadGun>().GunYPos;
            var floatVal2 = LevelManager.Instance.soldier.GetComponent<ReloadGun>().GunXRot;

            GameManager.instance.levelManager.mainCamera.transform.DOLocalMove(new Vector3(0f, floatVal, 0f), .5f).OnComplete(delegate
            {
                SnipperUI.SetActive(true);
                isReadyToShootBullet = true;

                if (gameInitialization != null && gameInitialization.gameObject.activeInHierarchy)
                {
                    gameInitialization.ReleaseTheZoomButton();
                }
            });
            GameManager.instance.levelManager.mainCamera.transform.DOLocalRotate(new Vector3(floatVal2, 0f, 0f), .2f).OnComplete(delegate
            {
                GameManager.instance.levelManager.mainCamera.transform.DOLocalMoveZ(3f, .2f).SetRelative().OnComplete(delegate
                {

                });
            });
            DOTween.To(() => Camera.main.fieldOfView, x => Camera.main.fieldOfView = x, LevelManager.Instance.currentLevel.ZoomFovValue, .4f);
        }
    }
    public void MouseUpCalled()
    {

        //HapticTouch.FailVibration();

        PointerUpped();
        if (LevelManager.Instance.soldier.GetComponent<WeaponBase>())
        {
            if (Soldier.GetComponent<WeaponBase>().rocketMissile != null)
            {
                Soldier.GetComponent<WeaponBase>().rocketMissile.SetActive(false);
            }

            if (LevelManager.Instance.soldier.GetComponent<WeaponBase>().AutoShootMachineGun && LevelManager.Instance.soldier.GetComponent<ReloadGun>().isMachineGun)
            {
                StartBrustAttacks();
                LevelManager.Instance.CurrentGun.GetComponent<SFXplayer>().PlayReload();
                //StartCoroutine(DestroyThePlaneSounds(1.05f));

                var MachineGunImage = GameManager.instance.MachineGunIcon.GetComponent<Image>();
                MachineGunImage.DOColor(new Color(MachineGunImage.color.r, MachineGunImage.color.g, MachineGunImage.color.b, 0f), .2f);
            }

            else if (LevelManager.Instance.soldier.GetComponent<ReloadGun>().isShoulderRocket)
            {
                LaunchRocket();
                LevelManager.Instance.CurrentGun.GetComponent<SFXplayer>().PlayReload();
                //StartCoroutine(DestroyThePlaneSounds(1.05f));
                LevelManager.Instance.soldier.GetComponent<Animator>().SetBool("aimUp", false);
                var MachineGunImage = GameManager.instance.MachineGunIcon.GetComponent<Image>();
                MachineGunImage.DOColor(new Color(MachineGunImage.color.r, MachineGunImage.color.g, MachineGunImage.color.b, 0f), .2f);
            }
        }

        else if (!LevelManager.Instance.soldier.GetComponent<WeaponBase>())
        {

            if (Soldier.GetComponent<ReloadGun>().isLoadingBullets == false && isReadyToShootBullet == true)
            {
                LevelManager.Instance.CurrentGun.GetComponent<SFXplayer>().PlayReload();

                HapticTouch.FailVibration();
                print("ppp");
                if (gameInitialization != null && gameInitialization.gameObject.activeInHierarchy)
                {
                    gameInitialization.EnableTheDragPanel();
                }
                GameManager.instance.levelManager.mainCamera.transform.parent = GameManager.instance.levelManager.cameraNeutralPos.transform;

                isZoomPressed = false;
                transform.GetComponent<Image>().enabled = true;
                if (RaycastDetection.instance.lastObject != null)
                {
                    StartCoroutine(ShootBullet(RaycastDetection.instance.lastObject.gameObject));
                }
                else
                {

                    StartCoroutine(ShootBulletWithoutTarget());
                }
                Soldier.transform.DOScale(soldierScale, .1f);

            }
            else if (!isReadyToShootBullet)
            {

                //HapticTouch.FailVibration();

                Soldier.transform.transform.GetComponent<Animator>().SetBool("aimUp", false);
                isZoomPressed = false;
                transform.GetComponent<Image>().enabled = true;
                RaycastDetection.instance.CanDetect = false;
                inGamePointer.SetActive(true);
                GameManager.instance.levelManager.mainCamera.transform.parent = GameManager.instance.levelManager.cameraNeutralPos.transform;
                DOTween.Kill(GameManager.instance.levelManager.mainCamera.transform);
                DisableTheScope();

            }
        }
    }
    public void LaunchRocket()
    {
        HapticTouch.FailVibration();
        GameObject Rocket;
        if (LevelManager.Instance.soldier.GetComponent<WeaponBase>().isHandGranade)
        {
            Rocket = Instantiate(GameManager.instance.playerMissileRocketHands, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos);
        }
        else
        {
            Rocket = Instantiate(GameManager.instance.playerMissileRocket, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos);
        }
        if (FindObjectOfType<RaycastDetection>().lastObject != null)
        {
            StartCoroutine(DestroyThePlaneSounds(1.05f));
            Rocket.GetComponent<MovementController>().HitTarget = FindObjectOfType<RaycastDetection>().lastObject.gameObject.transform;
        }

        Rocket.GetComponent<MovementController>().enabled = true;

        Soldier.GetComponent<ReloadGun>().UpdateBulletsMagezine();
        Invoke("ReactivateTheMissile", 1.5f);
    }

    public void ReactivateTheMissile()
    {
        if (Soldier.GetComponent<WeaponBase>().rocketMissile != null)
        {
            if (!Soldier.GetComponent<WeaponBase>().rocketMissile.activeInHierarchy)
            {
                Soldier.GetComponent<WeaponBase>().rocketMissile.SetActive(true);
            }
        }
    }


    public void ThrowBrust()
    {
        StartCoroutine(BrustAttack(/*RaycastDetection.instance.lastObject.gameObject*/));
    }

    void StartBrustAttacks()
    {
        StartCoroutine(PerformMultipleBrustAttacks());
    }

    IEnumerator PerformMultipleBrustAttacks()
    {

        int attackCount = LevelManager.Instance.soldier.GetComponent<ReloadGun>().brustToThrow; // Number of times to run the BrustAttack function
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().gunAnimator.GetComponent<Animator>().SetBool("Fire", true);

        for (int i = 0; i < attackCount; i++)
        {
            GameObject GunBullet = Instantiate(LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletPrefab, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.transform.position, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.transform.rotation);
            GunBullet.transform.parent = LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.transform;
            GunBullet.transform.localPosition = Vector3.zero;
            GunBullet.transform.localEulerAngles = Vector3.zero;
            GunBullet.transform.parent = null;
            GunBullet.transform.GetComponent<PlaneTransformer>().canTransform = true;
            HapticTouch.LightVibration();
            yield return new WaitForSeconds(.01f);
            Soldier.GetComponent<ReloadGun>().UpdateBulletsMagezine();
            Destroy(GunBullet, .4f);

        }
        yield return new WaitForSeconds(.2f);
        if (RaycastDetection.instance.ObjectFound)
        {
            if (RaycastDetection.instance.lastObject != null)
            {

                if (RaycastDetection.instance.lastObject.GetComponent<DOTweenPath>())
                {
                    DOTween.Kill(RaycastDetection.instance.lastObject.gameObject);
                    Destroy(RaycastDetection.instance.lastObject.GetComponent<DOTweenPath>());
                    RaycastDetection.instance.lastObject.GetComponent<EnemyHealth>().IsDestroyed = true;
                    LevelManager.Instance.soldier.GetComponent<WeaponBase>().gunAnimator.GetComponent<Animator>().SetBool("Fire", false);

                }
                if (RaycastDetection.instance.lastObject.GetComponent<TorpedoRocket>())
                {
                    //

                    RaycastDetection.instance.lastObject.GetComponent<TorpedoRocket>().DestryTheRocket();
                }
                else
                {
                    RaycastDetection.instance.lastObject.GetComponent<ShootingFromAeroplane>().DestoyThePlane();
                    StartCoroutine(DestroyThePlaneSounds(1.05f));

                }

            }
        }
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().aimSprite.color = Color.white;
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().gunAnimator.GetComponent<Animator>().SetBool("Fire", false);
        if (LevelManager.Instance.mainCamera.GetComponent<Animator>())
        {
            LevelManager.Instance.mainCamera.GetComponent<Animator>().SetTrigger("zoom");
        }

    }

    IEnumerator BrustAttack()
    {
        GameObject GunBullet = Instantiate(LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletPrefab, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.transform.position, LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.transform.rotation);
        GunBullet.transform.parent = LevelManager.Instance.soldier.GetComponent<WeaponBase>().bulletInitialPos.transform;
        GunBullet.transform.localPosition = Vector3.zero;
        GunBullet.transform.localEulerAngles = Vector3.zero;
        GunBullet.transform.parent = null;
        GunBullet.transform.GetComponent<PlaneTransformer>().canTransform = true;

        yield return new WaitForSeconds(.2f);
        if (RaycastDetection.instance.ObjectFound)
        {
            if (RaycastDetection.instance.lastObject != null)
            {
                RaycastDetection.instance.lastObject.GetComponent<EnemyHealth>().DamagePlayerHealth();
                if (RaycastDetection.instance.lastObject.GetComponent<EnemyHealth>().CanBeDestroyed)
                {
                    if (RaycastDetection.instance.lastObject.GetComponent<DOTweenPath>())
                    {
                        DOTween.Kill(RaycastDetection.instance.lastObject.gameObject);
                        Destroy(RaycastDetection.instance.lastObject.GetComponent<DOTweenPath>());
                        RaycastDetection.instance.lastObject.GetComponent<EnemyHealth>().IsDestroyed = true;
                        LevelManager.Instance.soldier.GetComponent<WeaponBase>().gunAnimator.GetComponent<Animator>().SetBool("Fire", false);

                    }
                    if (RaycastDetection.instance.lastObject.GetComponent<TorpedoRocket>())
                    {
                        //
                        RaycastDetection.instance.lastObject.GetComponent<TorpedoRocket>().DestryTheRocket();
                    }
                    else
                    {
                        RaycastDetection.instance.lastObject.GetComponent<ShootingFromAeroplane>().DestoyThePlane();
                    }
                }
            }
        }
        Destroy(GunBullet, .4f);
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().aimSprite.color = Color.white;
        Soldier.GetComponent<ReloadGun>().UpdateBulletsMagezine();
        LevelManager.Instance.soldier.GetComponent<WeaponBase>().gunAnimator.GetComponent<Animator>().SetBool("Fire", false);
    }

    IEnumerator ShootBulletWithoutTarget()
    {
        GameObject GunBullet = Instantiate(GameManager.instance.playerGunBullet, GameManager.instance.playerGunBulletInstantiatePos.position, GameManager.instance.playerGunBulletInstantiatePos.rotation);
        GunBullet.transform.parent = GameManager.instance.levelManager.mainCamera.transform;
        GunBullet.transform.localPosition = Vector3.zero;
        GunBullet.transform.localEulerAngles = Vector3.zero;
        GunBullet.transform.parent = null;
        GunBullet.transform.GetComponent<PlaneTransformer>().canTransform = true;
        yield return new WaitForSeconds(.2f);
        if (RaycastDetection.instance.ObjectFound)
        {
            if (RaycastDetection.instance.lastObject != null)
            {
                RaycastDetection.instance.lastObject.GetComponent<ShootingFromAeroplane>().DestoyThePlane();
            }
        }
        Destroy(GunBullet, .4f);
        yield return new WaitForSeconds(.4f);
        Soldier.GetComponent<ReloadGun>().UpdateBulletsMagezine();
        DisableTheScope();

    }

    IEnumerator ShootBullet(GameObject target)
    {
        GameObject GunBullet = Instantiate(GameManager.instance.playerGunBullet, GameManager.instance.playerGunBulletInstantiatePos.position, GameManager.instance.playerGunBulletInstantiatePos.rotation);
        GunBullet.transform.parent = GameManager.instance.levelManager.mainCamera.transform;
        GunBullet.transform.localPosition = Vector3.zero;
        GunBullet.transform.localEulerAngles = Vector3.zero;
        GunBullet.transform.parent = null;
        GunBullet.transform.GetComponent<PlaneTransformer>().canTransform = true;

        yield return new WaitForSeconds(.2f);

        if (RaycastDetection.instance.ObjectFound)
        {
            if (RaycastDetection.instance.lastObject != null)
            {
                if (RaycastDetection.instance.lastObject.GetComponent<DOTweenPath>())
                {
                    DOTween.Kill(RaycastDetection.instance.lastObject.gameObject);
                    Destroy(RaycastDetection.instance.lastObject.GetComponent<DOTweenPath>());
                }

                if (RaycastDetection.instance.lastObject.GetComponent<TorpedoRocket>())
                {
                    //
                    RaycastDetection.instance.lastObject.GetComponent<TorpedoRocket>().DestryTheRocket();
                }
                else
                {
                    RaycastDetection.instance.lastObject.GetComponent<ShootingFromAeroplane>().DestoyThePlane();
                    StartCoroutine(DestroyThePlaneSounds(1.1f));
                }
            }
        }
        Destroy(GunBullet, .4f);
        yield return new WaitForSeconds(.4f);
        Soldier.GetComponent<ReloadGun>().UpdateBulletsMagezine();

        DisableTheScope();
    }

    IEnumerator DestroyThePlaneSounds(float val)
    {
        yield return new WaitForSeconds(val);
        GameManager.instance.BlastSound.GetComponent<EnemiesBlastSoundManager>().PlayReload();

    }

    public void DisableTheScope()
    {
        isReadyToShootBullet = false;


        if (!isZoomPressed)
        {
            GameManager.instance.levelManager.mainCamera.transform.DOLocalRotate(Vector3.zero, .2f);
            DOTween.To(() => Camera.main.fieldOfView, x => Camera.main.fieldOfView = x, 60, .4f);
            GameManager.instance.levelManager.mainCamera.transform.DOLocalMove(Vector3.zero, .5f).OnComplete(delegate
            {
                if (!isZoomPressed)
                {

                    if (gameInitialization != null && gameInitialization.gameObject.activeInHierarchy)
                    {
                        gameInitialization.EnableTheDragPanel();
                    }

                    inGamePointer.SetActive(true);
                    SnipperUI.SetActive(false);
                    Soldier.transform.transform.GetComponent<Animator>().SetBool("aimUp", false);
                }
            });
        }
    }
}