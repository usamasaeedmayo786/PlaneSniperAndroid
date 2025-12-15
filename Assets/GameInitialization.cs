using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using TMPro;
using DG.Tweening;

public class GameInitialization : MonoBehaviour
{
    public static GameInitialization instance;
    public const string isFirstTimeKey = "IsFirstTime";

    public List<GameObject> firstTimeData;
    public GameObject firstPlane;
    public GameObject secondPlane;
    public GameObject thirdPlane;
    public GameObject releaseText;
    public GameObject PressZoomText;
    public GameObject ZoomButton;
    public GameObject handIcon;
    public GameObject DragPanel;
    public List<GameObject> secondTimeData;

    public bool tutorialEnded = false;
    public ZoomSystem zoomSystem;
    private void Awake()
    {
        instance = this;
    }
    void Start()
    {

        if (!PlayerPrefs.HasKey(isFirstTimeKey))
        {
            ZoomButton.transform.DOScale(Vector3.zero, .0001f);

            ZoomButton.gameObject.SetActive(false);
            DragPanel.SetActive(true);
            ActivePlane();
        }
        else
        {
            SecondFunction();

        }

    }

    public void ActivePlane()
    {
        if (!PlayerPrefs.HasKey(isFirstTimeKey))
        {
            if (GameManager.instance.levelManager.currentLevel.totalTargets == 3)
                firstPlane.SetActive(true);
            else if (GameManager.instance.levelManager.currentLevel.totalTargets == 2)
                secondPlane.SetActive(true);
            else if (GameManager.instance.levelManager.currentLevel.totalTargets == 1)
                thirdPlane.SetActive(true);

            else
            {
                DragPanel.SetActive(false);
                print("done");
                SaveGameStats();
            }
            //GameManager.instance.levelManager.currentLevel.totalTargets -= 1;

        }
    }

    void SecondFunction()
    {
        foreach (var item in secondTimeData)
        {
            item.SetActive(true);
        }
        gameObject.SetActive(false);
    }

    public void EnableTheSniper()
    {     
        DOTween.Kill(ZoomButton.gameObject);
        ZoomButton.SetActive(true);
        ZoomButton.transform.DOScale(0.87625f, .1f);
        if(zoomSystem!=null)
        {
            if(zoomSystem.isZoomPressed == false)
            {
                PressZoomText.SetActive(true);
            }
        }
        isDragActive = false;

    }

    public void ReleaseTheZoomButton()
    {
        releaseText.SetActive(true);
    }


    public void DisableTheZoomButton()
    {
        releaseText.SetActive(false);
        PressZoomText.SetActive(false);
        ZoomButton.transform.DOScale(0f, .1f);
    }

    public void EnableTheDragPanel()
    {
        Invoke("CallDragPanelWithDelay", 1);
    }
    [HideInInspector]
    public bool isDragActive = false;
    public void CallDragPanelWithDelay()
    {
        if (!isDragActive)
        {
            isDragActive = true;
            if(!tutorialEnded)
                DragPanel.SetActive(true);
            releaseText.SetActive(false);
            PressZoomText.SetActive(false);
            ZoomButton.transform.DOScale(0f, .1f);
        }
    }


    public void enableSniperWithTouch()
    {
        Invoke("EnableTheSniper", 1f);
    }


    public void SaveGameStats()
    {
        if (!PlayerPrefs.HasKey(isFirstTimeKey) || PlayerPrefs.GetInt(isFirstTimeKey) != 1)
        {

            PlayerPrefs.SetInt(isFirstTimeKey, 1);
            PlayerPrefs.Save();
        }
    }

}