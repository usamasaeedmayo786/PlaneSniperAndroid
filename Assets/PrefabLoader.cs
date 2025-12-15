using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;
using UnityEngine.UI;

public class PrefabLoader : MonoBehaviour
{
    public static PrefabLoader instance;
    public List<string> gunSetup;

    public string gunsEffecStoreName;

    private void Awake()
    {
        instance = this;
    }

    public void LoadResourcesData()
    {
        // Load the prefab from the Resources folder
        GameObject prefabPlayer = Resources.Load(LevelManager.Instance.currentLevel.PlayerBasePrefabsName) as GameObject;

        GameObject prefabPlane = Resources.Load(LevelManager.Instance.currentLevel.planesPrefabName) as GameObject;


        if (prefabPlane != null)
        {
            /*var prefabPlayersData = */
            Instantiate(prefabPlayer, LevelManager.Instance.currentLevel.levelData.transform);

            /* var planesData = */
            Instantiate(prefabPlane, LevelManager.Instance.currentLevel.planesParent.transform);

        }
        else
        {
            Debug.LogError("Prefab not found in Resources folder: " + LevelManager.Instance.currentLevel.planesPrefabName);
        }
    }

    public void loadResourcesGun(int i)
    {
       
        GameObject prefabPlane = Resources.Load(gunSetup[i]) as GameObject;

        if (prefabPlane != null)
        {
            var newGun= Instantiate(prefabPlane, LevelManager.Instance.currentLevel.levelData.transform);
            newGun.GetComponent<GunReferances>().SetupGunData();

            if (LevelManager.Instance.currentLevel.gunSetupPosSniper == null || !LevelManager.Instance.CurrentGun.GetComponent<GunReferances>().isGun)
            {
                newGun.GetComponent<SwipeRotate>().minRotationX = LevelManager.Instance.currentLevel.gunSetupPos.GetComponent<swipeValuesContainer>().minRotationX;
                newGun.GetComponent<SwipeRotate>().maxRotationX = LevelManager.Instance.currentLevel.gunSetupPos.GetComponent<swipeValuesContainer>().maxRotationX;
                newGun.GetComponent<SwipeRotate>().minRotationY = LevelManager.Instance.currentLevel.gunSetupPos.GetComponent<swipeValuesContainer>().minRotationY;
                newGun.GetComponent<SwipeRotate>().maxRotationY = LevelManager.Instance.currentLevel.gunSetupPos.GetComponent<swipeValuesContainer>().maxRotationY;
                newGun.GetComponent<SwipeRotate>().rotationSpeed = LevelManager.Instance.MobileControllSpeed;
            }
            else if (LevelManager.Instance.currentLevel.gunSetupPosSniper != null && LevelManager.Instance.CurrentGun.GetComponent<GunReferances>().isGun)
            {
                newGun.GetComponent<SwipeRotate>().minRotationX = LevelManager.Instance.currentLevel.gunSetupPosSniper.GetComponent<swipeValuesContainer>().minRotationX;
                newGun.GetComponent<SwipeRotate>().maxRotationX = LevelManager.Instance.currentLevel.gunSetupPosSniper.GetComponent<swipeValuesContainer>().maxRotationX;
                newGun.GetComponent<SwipeRotate>().minRotationY = LevelManager.Instance.currentLevel.gunSetupPosSniper.GetComponent<swipeValuesContainer>().minRotationY;
                newGun.GetComponent<SwipeRotate>().maxRotationY = LevelManager.Instance.currentLevel.gunSetupPosSniper.GetComponent<swipeValuesContainer>().maxRotationY;
                newGun.GetComponent<SwipeRotate>().rotationSpeed = LevelManager.Instance.MobileControllSpeed;
            }
        }
        else
        {
            Debug.LogError("Prefab not found in Resources folder: " + LevelManager.Instance.currentLevel.planesPrefabName);
        }

    }


    public void LoadTheGunsEffectStore()
    {
        GameObject prefabPlane = Resources.Load(gunsEffecStoreName) as GameObject;


        if (prefabPlane != null)
        {
            Instantiate(prefabPlane);
        }
        else
        {
            Debug.LogError("Prefab not found in Resources folder: " + LevelManager.Instance.currentLevel.planesPrefabName);
        }
    }
}
