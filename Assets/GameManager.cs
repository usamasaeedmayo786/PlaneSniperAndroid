using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;
using UnityEngine.UI;
public class GameManager : MonoBehaviour
{
    public static GameManager instance;

    public GameObject playerGunBullet;
    public GameObject zoomSystem;
    public LevelManager levelManager;
    public Transform playerGunBulletInstantiatePos;

    public bool isLevelFailed = false;
    public bool isLevelCompleted = false;

    public GameObject SniperIcon;
    public GameObject MachineGunIcon;
    public Image AimIcon;

    public GameObject playerMissileRocket;
    public GameObject playerMissileRocketHands;

    public GameObject gunStoreContainer;

    //public GameObject touchPad;
    public Transform spawnpoint;
    public Image aimSprite;

    public VehicleSelection vehicleSelection;
    //public const string isFirstPlayedGame = "isFirstPlayed";

    public GameObject BlastSound;
    private void Awake()
    {
        instance = this;
    }
    private void Start()
    {
        PrefabLoader.instance.loadResourcesGun(PlayerPrefs.GetInt(GameConstants.SelectedVehicles));
    }

    public void RestartButton()
    {
        SceneManager.LoadScene(0);
    }

    private void Update()
    {
        GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList = GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList.Where(item => item != null).ToList();
        GameManager.instance.levelManager.currentLevel.PlayerBaseList = GameManager.instance.levelManager.currentLevel.PlayerBaseList.Where(item => item != null).ToList();
    }



}
