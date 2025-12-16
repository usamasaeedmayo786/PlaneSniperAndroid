using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using ADC.Ads;
using UnityEngine.UI;
public class SceneLoad : MonoBehaviour
{

    [SerializeField] string sceneName;
    bool isButtonPressed = false;
    public bool isRvButton = false;
    //public bool willShowAds = false;
    private void Start()
    {
        //if(isRvButton)
        //GetComponent<Button>().interactable = AdManager.IsRewardedAvailable(new AdVariantReference("Gun Unlocked"));

        //Invoke(nameof(LoadNextLevel3xBonus),2f);
    }

    public void LoadScene()
    {
        if (string.IsNullOrEmpty(sceneName))
        {
            return;
        }

        SceneManager.LoadSceneAsync(sceneName);
    }

    public void ReloadSceneSimply()
    {
        if (isButtonPressed == false)
        {
            isButtonPressed = true;
            //AdManager.ShowInterstitial(new AdVariantReference("Level Complete"));

            if (string.IsNullOrEmpty(sceneName))
            {
                sceneName = SceneManager.GetActiveScene().name;
                //GetComponent<Button>().interactable = false;
            }

            SceneManager.LoadSceneAsync(sceneName);
        }
    }

    public void LoadNextLevel3xBonus()
    {
        if (isButtonPressed == false)
        {
            isButtonPressed = true;

            StartCoroutine(Play3XAnimEffect());
        }
    }


    IEnumerator Play3XAnimEffect()
    {
        Vector3 startPos = UIManager.instance.Cash3XButton.transform.GetComponent<RectTransform>().position;
        StartCoroutine(FXManager.instance.TransferCoinsFromUIToUI(startPos));


        yield return new WaitForSeconds(2f);


        AdManager.ShowRewarded(new AdVariantReference("Gun Unlocked"), (watched) =>
        {
            if (watched)
            {
                UIManager.instance.NoBonusButton.SetActive(false);

                VehicleSelection vehSel = GameManager.instance.vehicleSelection;

                var gunId = LevelManager.Instance.currentLevel.gunReferanceInStore.GetComponent<GunID>().gunId;

                vehSel.gameObject.SetActive(true);
                vehSel.gameObject.transform.localScale = Vector3.zero;
                if (vehSel.bikes[gunId].bike.GetComponent<GunID>().isGunUnlocked == true)
                {

                    vehSel.gameObject.SetActive(false);

                    CoinsManager.instance.IncreaseCoins(CoinsManager.instance.addCoinsCount * 1);

                    LevelManager.Instance.MilesStoneAchieved = 0;
                    PlayerPrefs.SetFloat("NumberOfRepetationCount", LevelManager.Instance.MilesStoneAchieved);
                    StartCoroutine(LoadSceneWithoutPanel());

                }
                else
                {
                    vehSel.gameObject.SetActive(false);


                        // play next level if the gun is unlocked
                        //currentLevel.gunReferanceInStore
                        StartCoroutine(showTheGunPanels3X(3));
                }

            }
            else
            {
                GetRV();
            }
        });


    }
    IEnumerator showTheGunPanels3X(int vari)
    {
        //yield return new WaitForSeconds(2f);

        CoinsManager.instance.IncreaseCoins(CoinsManager.instance.addCoinsCount * vari);
        LevelManager.Instance.CallUnlockSystem();
        yield return new WaitForSeconds(.1f);
        //AdManager.ShowInterstitial(new AdVariantReference("Level Complete"));


    }

    IEnumerator showTheGunPanels(int vari)
    {
        //yield return new WaitForSeconds(2f);

        CoinsManager.instance.IncreaseCoins(CoinsManager.instance.addCoinsCount * vari);
        LevelManager.Instance.CallUnlockSystem();
        yield return new WaitForSeconds(.1f);
        AdManager.ShowInterstitial(new AdVariantReference("Level Complete"));


    }

    public void ShowGunPanel() // show interstitial here and then disable the rv button here
    {
        if (isButtonPressed == false)
        {
            isButtonPressed = true;

            StartCoroutine(Play1XAnim());
        }
    }

    IEnumerator Play1XAnim()
    {
        UIManager.instance.Cash3XButton.SetActive(false);
        Vector3 startPos = UIManager.instance.NoBonusButton.transform.GetComponent<RectTransform>().position;

        StartCoroutine(FXManager.instance.TransferCoinsFromUIToUI(startPos));

        yield return new WaitForSeconds(1.8f);



        var gunId = LevelManager.Instance.currentLevel.gunReferanceInStore.GetComponent<GunID>().gunId;
        VehicleSelection vehSel = GameManager.instance.vehicleSelection;

        vehSel.gameObject.SetActive(true);
        vehSel.gameObject.transform.localScale = Vector3.zero;
        if (vehSel.bikes[gunId].bike.GetComponent<GunID>().isGunUnlocked == true)
        {

            vehSel.gameObject.SetActive(false);

            //AdManager.ShowInterstitial(new AdVariantReference("Level Complete"));
            //StartCoroutine(FXManager.instance.TransferCoinsFromUIToUI(startPos));
            CoinsManager.instance.IncreaseCoins(CoinsManager.instance.addCoinsCount * 1);

            LevelManager.Instance.MilesStoneAchieved = 0;
            PlayerPrefs.SetFloat("NumberOfRepetationCount", LevelManager.Instance.MilesStoneAchieved);
            //ReloadSceneSimply();
            StartCoroutine(LoadSceneWithoutPanel());

        }
        else
        {
            vehSel.gameObject.SetActive(false);


            // play next level if the gun is unlocked
            //currentLevel.gunReferanceInStore
            StartCoroutine(showTheGunPanels(1));
        }

    }

    IEnumerator LoadSceneWithoutPanel()
    {
        yield return new WaitForSeconds(1f);
        sceneName = SceneManager.GetActiveScene().name;
        SceneManager.LoadSceneAsync(sceneName);
    }
    public void ReloadScene()
    {
        if (isButtonPressed == false)
        {
            isButtonPressed = true;
            AdManager.ShowInterstitial(new AdVariantReference("Level Complete"));

            if (string.IsNullOrEmpty(sceneName))
            {
                sceneName = SceneManager.GetActiveScene().name;
            }

            SceneManager.LoadSceneAsync(sceneName);
        }
    }



    void GetRV()
    {
        if (this == null) return;

        //GetComponent<Button>().interactable = AdManager.IsRewardedAvailable(new AdVariantReference("Gun Unlocked"));

        if (!GetComponent<Button>().interactable)
            CInvoker.InvokeDelayed(GetRV, 1);
    }


	public void ReloadSceneWithRV()
	{
        if (isButtonPressed == false)
        {




            isButtonPressed = true;



            //AdManager.ShowRewarded(new AdVariantReference("Gun Unlocked"), (watched) =>
            {
                if (true)
                {
                    UIManager.instance.SkipButton.SetActive(false);
                    UIManager.instance.UiLoading.SetActive(true);
                    if (string.IsNullOrEmpty(sceneName))
                    {
                        sceneName = SceneManager.GetActiveScene().name;
                    }
                    SceneManager.LoadSceneAsync(sceneName);

                    Time.timeScale = 1;
                }
                else
                {
                    GetRV();
                }
            }
            //);
        }
	}

}