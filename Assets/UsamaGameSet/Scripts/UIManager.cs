using System;
using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using TMPro;
using DG.Tweening;
public class UIManager : MonoBehaviour
{

    public static UIManager instance;

    [SerializeField] GameObject homePanel;
    [SerializeField] GameObject gamplayPanel;
    [SerializeField] GameObject competePanel;
    [SerializeField] GameObject levelFailPanel;
    public GameObject UiLoading;




    [Header("Text Fields"), SerializeField] TextMeshProUGUI MissionNumber;
    /*[Header("Text Fields"), SerializeField]*/public TextMeshProUGUI totalTargetsRemaining;

    [Space(10)]
    [Header("_________________UNLOCK PANEL____________________")]
    public GameObject unlockPanel;
    public GameObject AllLockedGunsContainer;
    public Image fillImageSlider;
    public TextMeshProUGUI fillImageSliderValue;
    public GameObject RV_CountButton;
    public GameObject Coins_RequiredButton;
    public Text UICoinsText;
    public GameObject NotCashText;

    //public TextMeshProUGUI CollectButtonText;


    [Space(15)]
    [Header("_____________________________________")]
    public GameObject RewardedButton;
    public GameObject SkipButton;
    public GameObject ContinueButton;
    public GameObject NoBonusButton;
    public GameObject Cash3XButton;


    public GameObject GunsEffectsContainer;

    void Awake()
    {
        instance = this;

        GameController.onLevelComplete += OnLevelComplete;
        GameController.onGameplay += Gameplay;
        GameController.onLevelFail += LevelFail;
        GameController.onHome += Home;
    }
    private void Start()
    {
        //TapToPlay();
        HomeScreen.instance.ShowBanner();
        CoinsManager.instance.LoadCoinsAmount(CoinsManager.instance.coins);
    }
    //Events Definations
    void Home()
    {
        ActivePanel(home: true);
    }

    public void LevelFail()
    {
        GameManager.instance.zoomSystem.SetActive(false);
        AnalyticsManager.LogLevelFailEvent();
        HomeScreen.instance.ShowInterstitial();
        StartCoroutine(DelayInFail());
    }

    void Gameplay()
    {
        int levelNo = PlayerPrefs.GetInt("LevelNumber");
        levelNo += 1;
        MissionNumber.text = $"Mission {levelNo.ToString("0")}";
        ActivePanel(gameplay: true);
        foreach (var item in GameManager.instance.levelManager.currentLevel.levelDataToActive)
        {
            item.SetActive(true);
        }
        AnalyticsManager.LogLevelStartEvent();

    }

    public void OnLevelComplete()
    {
        GameManager.instance.zoomSystem.SetActive(false);

        AnalyticsManager.LogLevelCompleteEvent();
        HomeScreen.instance.ShowInterstitial();
        //GameManager.instance.SaveGameFirstPlay();
        StartCoroutine(DelayInComplete());
    }


    //Active Panels
    void ActivePanel(bool gameplay = false, bool home = false, bool complete = false, bool fail = false)
    {
        gamplayPanel.SetActive(gameplay);
        homePanel.SetActive(home);
        competePanel.SetActive(complete);
        levelFailPanel.SetActive(fail);
    }

    IEnumerator DelayInFail()
    {
        yield return new WaitForSeconds(1.5f);
        ActivePanel(fail: true);
    }
    IEnumerator DelayInComplete()
    {
        yield return new WaitForSeconds(3f);
        ActivePanel(complete: true);
    }
    // Buttons 



    public void TapToPlay()
    {
        // load the gun here

        LevelManager.Instance.currentLevel.levelData.gameObject.SetActive(true);
        foreach (var item in LevelManager.Instance.currentLevel.levelEnviormentToActive)
        {
            item.SetActive(true);
        }

        PrefabLoader.instance.LoadResourcesData();
        GameManager.instance.playerGunBulletInstantiatePos = GameManager.instance.levelManager.soldier.transform;
        FindObjectOfType<OffScreenIndicator>().mainCamera = LevelManager.Instance.mainCamera;
        if (GameManager.instance.levelManager.isMobileControll)
        {
            GameManager.instance.levelManager.mainCamera.GetComponentInParent<SwipeRotate>().rotationSpeed = GameManager.instance.levelManager.MobileControllSpeed;
        }

        foreach (var item in LevelManager.Instance.currentLevel.extraDataToEnable)
        {
            item.SetActive(true);
        }

        //=========================================NEW DATA

        GameController.changeGameState.Invoke(GameState.Gameplay);
        if (LevelManager.Instance.soldier.GetComponent<WeaponBase>())
        {
            GameManager.instance.MachineGunIcon.gameObject.SetActive(true);
            GameManager.instance.AimIcon = GameManager.instance.MachineGunIcon.GetComponent<Image>();
            if(!LevelManager.Instance.soldier.GetComponent<WeaponBase>().AutoShootMachineGun)
                GameManager.instance.zoomSystem.transform.DOScale(Vector3.zero,.001f);
        }
        else
        {
            GameManager.instance.SniperIcon.gameObject.SetActive(true);
            GameManager.instance.AimIcon = GameManager.instance.SniperIcon.GetComponent<Image>();
        }


        //===============================================================FOR SETTING THE HEALTH FOR THE LEVEL DIFFICULTY=================================================================

        //if (LevelManager.Instance.CurrentGun.GetComponent<GunReferances>().gunId != 0)
        //    FindObjectOfType<HealthManager>().playerHeathDecrease = 0.0008f * LevelManager.Instance.currentLevel.PlayerHealthValue / (LevelManager.Instance.CurrentGun.GetComponent<GunReferances>().gunId *2);
        //else
        //    FindObjectOfType<HealthManager>().playerHeathDecrease = 0.0008f * LevelManager.Instance.currentLevel.PlayerHealthValue;

        if(LevelManager.Instance.currentLevel.minGunLevel> LevelManager.Instance.CurrentGun.GetComponent<GunReferances>().gunId  && LevelManager.Instance.CurrentGun.GetComponent<GunReferances>().gunId < LevelManager.Instance.currentLevel.maxGunLevel)
        {
            FindObjectOfType<HealthManager>().playerHeathDecrease = 0.0008f * LevelManager.Instance.currentLevel.PlayerHealthValue * 3.6f;
            print("MG");
        }
        else
        {
            FindObjectOfType<HealthManager>().playerHeathDecrease = 0.0008f * LevelManager.Instance.currentLevel.PlayerHealthValue *1.2f;
            print("MG2");

        }

    }

}