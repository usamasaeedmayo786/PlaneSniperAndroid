using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WeaponBase : MonoBehaviour
{

    public bool AutoShootMachineGun = false;

    public bool isHandGranade = false;

    public GameObject playerHead;
    public GameObject playerHands;
    public GameObject gunAnimator;
    public GameObject bulletPrefab;


    public Transform CameraReloadInitialPosition;
    public Transform CameraReloadPosition;
    public Transform CameraShootPosition;
    public Transform bulletInitialPos;




    public Image aimSprite;
    //public Sprite aimSpriteReplacement;

    public ParticleSystem bulletParticle1;
    public ParticleSystem bulletParticle2;

    public GameObject rocketMissile;

    private void Start()
    {
        aimSprite = GameManager.instance.aimSprite;
    }
}