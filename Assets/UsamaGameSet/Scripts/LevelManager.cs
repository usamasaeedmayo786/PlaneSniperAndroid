using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;
using UnityEngine.UI;
using System.Collections;
using UnityEngine.EventSystems;
using DG.Tweening;
using ADC.Core;
using ADC.Ads;

[Serializable]
public struct LevelInfo
{

    public Transform levelData;


    //public Transform cameraNeutralPos;
    //public Transform cameraZoomPos;

    public int totalTargets;

    //public GameObject soldier;
    //public Camera mainCamera;

    public Transform gunSetupPos;
    public Transform gunSetupPosSniper;

    [Space(10)]

    public List<GameObject> PlayerBaseList;
    public List<GameObject> EnemyAeroplanesList;
    
    public List<GameObject> levelDataToActive;

    public List<GameObject> levelEnviormentToActive;
    [Space(10)]

    public float PlayerHealthValue;

    [Space(10)]



    [Space(10)]
    public List<GameObject> extraDataToEnable;
    [Space(5)]
    [Header("Sniper Zoom Value, By default it will be 7")]
    public float ZoomFovValue;

    [Header("Editor Use Only=======================================")]
    public GameObject gunReferanceInStore;

    [Space(10)]
    public GameObject planesParent;
    public string planesPrefabName; // Name of the prefab file without the extension


    [Space(10)]
    public string PlayerBasePrefabsName;

    [Space(15)]
    [Header("Game Difficulty Level =======================================")]
    public int minGunLevel;
    public int maxGunLevel;

}

public class LevelManager : MonoBehaviour
{
    public static LevelManager Instance;

    public GameObject CurrentGun;
    public GameObject soldier;
    public Camera mainCamera;
    public Transform cameraNeutralPos;
    public Transform cameraZoomPos;
    [Space(20)]

    public float totalMilestone;

    [Space(10)]
    public float MilesStoneAchieved = 0;

    [Space(15)]
    [SerializeField] LevelInfo[] levels;
    
    [HideInInspector] public LevelInfo currentLevel;
    
    [Space(15)]
    public string levelsId = "LevelNumber";


    // variable to test the any given level
    public int TestLevel = -1;

    [Space(15)]
    public bool isMobileControll = false;
    public float MobileControllSpeed;
    public void Awake()
    {
        Instance = this;
        MilesStoneAchieved = PlayerPrefs.GetFloat("NumberOfRepetationCount");
        PrefabLoader.instance.LoadTheGunsEffectStore();
        if (TestLevel == -1)
        {
            ActiveLevel();
        }
        else
        {
            ActiveGivenLevel();
        }
        GameController.onLevelComplete += OnLevelComplete;
    }
    // impliment the code for adding new aeroplans Randomly

    void Start()
    {
        Application.targetFrameRate = 60;
    }

    void OnLevelComplete()
    {       
        var levelNo = PlayerPrefs.GetInt(levelsId, 0);
        levelNo++;
        PlayerPrefs.SetInt(levelsId, levelNo);
    }



    void ActiveLevel()
    {
        int levelNo = PlayerPrefs.GetInt(levelsId);
        if (levelNo > levels.Length - 1)
            levelNo %= levels.Length;
        currentLevel = levels[levelNo];
        //currentLevel.levelData.gameObject.SetActive(true);
        //foreach (var item in currentLevel.levelEnviormentToActive)
        //{
        //    item.SetActive(true);
        //}
    }
    float endValTofill=0;
    float startValTofill = 0;

    public void CallUnlockSystem()
    {
        StartCoroutine(UpdateTheUnlockSystem());
    }

    IEnumerator UpdateTheUnlockSystem()
    {
        // Final Calls
        //HomeScreen.instance.ShowInterstitial();
        //AdsManagers.ShowInterstitial("Level Complete");
        yield return new WaitForSeconds(.3f);
        currentLevel.gunReferanceInStore.SetActive(true);
        UIManager.instance.unlockPanel.SetActive(true);
        UIManager.instance.AllLockedGunsContainer.SetActive(true);
        endValTofill = MilesStoneAchieved / totalMilestone;
        UIManager.instance.fillImageSlider.fillAmount = endValTofill;
        UIManager.instance.fillImageSliderValue.text = "PROGRESS: " + UIManager.instance.fillImageSlider.fillAmount * 100 + "%";
        yield return new WaitForSeconds(.4f);
        
        MilesStoneAchieved++;

        endValTofill = MilesStoneAchieved / totalMilestone;
        UIManager.instance.fillImageSlider.DOFillAmount(endValTofill, 1).OnUpdate(delegate 
        {
            int progressPercentage = Mathf.RoundToInt(UIManager.instance.fillImageSlider.fillAmount * 100);
            UIManager.instance.fillImageSliderValue.text = "PROGRESS: " + progressPercentage + "%";
        });

        if (MilesStoneAchieved >= totalMilestone)
        {
            MilesStoneAchieved = 0;
            yield return new WaitForSeconds(1f);
            UIManager.instance.fillImageSliderValue.text = "GUN UNLOCKED";
            UIManager.instance.RewardedButton.SetActive(true);
            UIManager.instance.SkipButton.SetActive(true);
            GameManager.instance.gunStoreContainer.SetActive(true);
            print(currentLevel.gunReferanceInStore.GetComponent<GunID>().gunId + "gunID");


            VehicleSelection vehSel = GameManager.instance.vehicleSelection;
            vehSel.gameObject.SetActive(true);
            vehSel.gameObject.transform.localScale = Vector3.zero;
            VehicleSelection.Instance.UnlockVehicleInLevel(currentLevel.gunReferanceInStore.GetComponent<GunID>().gunId);
            vehSel.gameObject.SetActive(false);

        }
        else
        {
            UIManager.instance.ContinueButton.SetActive(true);
        }
        PlayerPrefs.SetFloat("NumberOfRepetationCount", MilesStoneAchieved);

    }

    void ActiveGivenLevel()
    {
        int levelNo = TestLevel;
        if (levelNo > levels.Length - 1)
            levelNo %= levels.Length;
        currentLevel = levels[levelNo];
        currentLevel.levelData.gameObject.SetActive(true);
        foreach (var item in currentLevel.levelEnviormentToActive)
        {
            item.SetActive(true);
        }
    }

}