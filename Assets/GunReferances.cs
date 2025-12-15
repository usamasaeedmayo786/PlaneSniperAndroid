using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GunReferances : MonoBehaviour
{
    public int gunId;

    public Transform cameraStartPos;
    public Transform cameraZoomPos;

    public GameObject soldier;
    public Camera gunCamera;

    public bool isGun = false;

    public void SetupGunData()
    {
        LevelManager.Instance.CurrentGun = gameObject;
        if (LevelManager.Instance.currentLevel.gunSetupPosSniper==null || !isGun)
        {
            transform.parent = LevelManager.Instance.currentLevel.gunSetupPos.transform.parent;
            transform.localPosition = LevelManager.Instance.currentLevel.gunSetupPos.transform.localPosition;
            transform.localRotation = LevelManager.Instance.currentLevel.gunSetupPos.transform.localRotation;
            transform.localScale = LevelManager.Instance.currentLevel.gunSetupPos.transform.localScale;

        }
        else if (LevelManager.Instance.currentLevel.gunSetupPosSniper != null && isGun)
        {
            transform.parent = LevelManager.Instance.currentLevel.gunSetupPosSniper.transform.parent;
            transform.localPosition = LevelManager.Instance.currentLevel.gunSetupPosSniper.transform.localPosition;
            transform.localRotation = LevelManager.Instance.currentLevel.gunSetupPosSniper.transform.localRotation;
            transform.localScale = LevelManager.Instance.currentLevel.gunSetupPosSniper.transform.localScale;
        }
        //print(LevelManager.Instance.l);

        LevelManager.Instance.cameraNeutralPos = cameraStartPos;
        LevelManager.Instance.cameraZoomPos = cameraZoomPos;
        LevelManager.Instance.soldier = soldier;
        LevelManager.Instance.mainCamera = gunCamera;
        print("degubb2");

    }
}
