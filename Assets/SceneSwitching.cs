using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System;

public class SceneSwitching : MonoBehaviour
{
    private int NextSceneIndex = 1;
    private int currentSceneIndex;

    public Image LoadingBar;

    private bool WaitForAC_API = true;
    private bool WaitForRoblox_API = true;
    private bool KeepWaiting = true;

    private float MaxFillLimit_ACSDK = 0.4f, MaxFillLimit_RBSDK = 0.75f,
        LoadingFinishTime = 5;

    private AsyncOperation async;



    private void Start()
    {
        StartSceneLoading();
    }

    private void StartSceneLoading()
    {
        KeepWaiting = false;
        WaitForAC_API = false;
        StartCoroutine(loadingSceneAsync());
    }

    private void AppCentralApiInitializationCompleted()
    {
        WaitForAC_API = false;

        //KeepWaiting = false;
    }

    private void RBApiInitializationCompleted()
    {
        WaitForRoblox_API = false;
        //KeepWaiting = false;
    }

    IEnumerator loadingSceneAsync()
    {

        currentSceneIndex = SceneManager.GetActiveScene().buildIndex;


        float T = 0;
        LoadingBar.fillAmount = T;

        yield return new WaitForSeconds(0.25f);

        async = SceneManager.LoadSceneAsync(NextSceneIndex);
        async.allowSceneActivation = false;
        KeepWaiting = true;

        while (WaitForAC_API)
        {
            if (T <= MaxFillLimit_ACSDK / 2)
            {
                T += Time.deltaTime / LoadingFinishTime;
                LoadingBar.fillAmount = T;
            }

            yield return null;
        }

        //KeepWaiting = false;

        while (KeepWaiting)
        {
            if (T <= MaxFillLimit_ACSDK)
            {
                T += Time.deltaTime / LoadingFinishTime;
                LoadingBar.fillAmount = T;
            }
            else
            {
                KeepWaiting = false;
            }

            yield return null;
        }







        LoadingBar.fillAmount = 0.95f;

        yield return new WaitForSeconds(0.5f);

        ActivateNextScene();
    }

    bool oneTime = true;

    public void ActivateNextScene()
    {

        if (oneTime)
        {
            oneTime = false;
            async.allowSceneActivation = true;
        }
    }


}

