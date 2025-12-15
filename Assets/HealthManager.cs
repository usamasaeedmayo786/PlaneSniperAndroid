using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using ADC.Ads;
using TMPro;

public class HealthManager : MonoBehaviour
{
    public Image playerHealth;
    public Image opponentHealth;

    public GameObject RevivePanel;
    public GameObject ReviveButton;

    public TextMeshProUGUI CounterText;

    public float playerHeathDecrease;
    public float opponentHeathDecrease;

    float playerCurrentHealth;
    float opponentCurrentHealth;
    private float countdownTimer = 5f;

    // pub
    // assign the value here in correct format so that it can be utilized in a way

    private void Start()
    {
        playerCurrentHealth = 1f;
        opponentCurrentHealth = 1f;

        float newVal = (float)(1 / (float)GameManager.instance.levelManager.currentLevel.totalTargets);
        opponentHeathDecrease = newVal;
        playerHeathDecrease = 0.0008f * LevelManager.Instance.currentLevel.PlayerHealthValue;
        //print(opponentHeathDecrease);
    }

    public void UpdatePlayerHealth()
    {
        playerCurrentHealth -= playerHeathDecrease;
        playerHealth.fillAmount = playerCurrentHealth;

        if(playerCurrentHealth <=0 && hasDecissionMade== false)
        {

            //ShowRevivePanel();

            //====================COMMENT IS FOR THE DIRECT DEAD====================
            hasDecissionMade = true;
            GameManager.instance.isLevelFailed = true;
            /*StartCoroutine(*/
            PerformLevelFailEffectWithDelay();
            FindObjectOfType<SwipeRotate>().enabled = false;
            GameController.changeGameState.Invoke(GameState.Fail);
        }
    }
    public void ShowRevivePanel()
    {
        CounterText.transform.parent.transform.gameObject.SetActive(true);
        CounterText.text = countdownTimer.ToString() /*+ " s"*/;
        ReviveButton.SetActive(true);
        StartCoroutine(Timer());
        isRevivePanelContinue = true;

        //RevivePanel.SetActive(true);
        Time.timeScale = 0f;
    }


    public void GiveHealth()
    {
        AdManager.ShowRewarded(new AdVariantReference("REVIVE PLAYER HEALTH"), (watched) =>
        {
            if (watched)
            {
                isRevivePanelContinue = false;
                playerCurrentHealth = .5f;
                playerHealth.fillAmount = playerCurrentHealth;
                Time.timeScale = 1f;
                ReviveButton.SetActive(false);

                RevivePanel.SetActive(false);
                CounterText.transform.parent.transform.gameObject.SetActive(false);
                countdownTimer = 5;

            }
            else
            {
                GetRV();
            }
        });


        //isRevivePanelContinue = false;
        //        playerCurrentHealth = .5f;
        //        playerHealth.fillAmount = playerCurrentHealth;
        //        Time.timeScale = 1f;
        //        RevivePanel.SetActive(false);
        //ReviveButton.SetActive(false);
        //        CounterText.transform.parent.transform.gameObject.SetActive(false);
        //        countdownTimer = 5;

    }

    public void FailLevel()
    {
        Time.timeScale = 1f;
        CounterText.transform.parent.transform.gameObject.SetActive(false);
        ReviveButton.SetActive(false);

        //RevivePanel.SetActive(false);
        hasDecissionMade = true;
        GameManager.instance.isLevelFailed = true;
        /*StartCoroutine(*/
        PerformLevelFailEffectWithDelay();
        FindObjectOfType<SwipeRotate>().enabled = false;
        GameController.changeGameState.Invoke(GameState.Fail);
    }
    void GetRV()
    {
        if (this == null) return;

        ReviveButton.GetComponent<Button>().interactable = AdManager.IsRewardedAvailable(new AdVariantReference("REVIVE PLAYER HEALTH"));

        if (!ReviveButton.GetComponent<Button>().interactable)
            CInvoker.InvokeDelayed(GetRV, 1);
    }

    void FixedUpdate()
    {
        //if (isAskingRevive)
        //{
        //    // Update the countdown timer
        //    countdownTimer -= Time.fixedDeltaTime;

           
        //}
    }

    bool isRevivePanelContinue = false;
    IEnumerator Timer()
    {
        yield return new WaitForSecondsRealtime(1f);
        countdownTimer--;
        // Check if the timer has reached zero
        if (countdownTimer <= 0f)
        {
            // Print something when timer reaches zero
            Debug.Log("Timer reached zero!");

            // Stop updating the timer
            //enabled = false;
        }
        CounterText.text = countdownTimer.ToString()/*+" s"*/;
        if(countdownTimer>0 && isRevivePanelContinue==true)
        StartCoroutine(Timer());
        //else if(countdownTimer < 0 && isRevivePanelContinue == true)
        //{
        //    print("empty");
        //}
        else if(countdownTimer > 0 && isRevivePanelContinue == true)
        {
            FailLevel();
            print("2");
        }

    }




    bool hasDecissionMade = false;
    public void UpdateOpponentHealth()
    {
        HapticTouch.FailVibration();
        opponentCurrentHealth -= opponentHeathDecrease;
        if (opponentCurrentHealth < 0)
        {
            opponentCurrentHealth = 0;
        }
        opponentHealth.fillAmount = opponentCurrentHealth;
        if (opponentHealth.fillAmount < 0.005f)
        {
            opponentHealth.fillAmount = 0;
        }
        //print(opponentHealth.fillAmount + " opponentHealth.fillAmount");
        if (/*opponentCurrentHealth <= 0 && */hasDecissionMade == false)
        {
            if (opponentHealth.fillAmount <= 0 || opponentHealth.fillAmount > 1.001f)
            {
                hasDecissionMade = true;


                GameManager.instance.isLevelCompleted = true;
                Invoke("PerformLevelWinEffectWithDelay", 1.6f);

                FindObjectOfType<SwipeRotate>().enabled = false;
                GameController.changeGameState.Invoke(GameState.Complete);

                if (LevelManager.Instance.soldier.GetComponent<WeaponBase>())
                    LevelManager.Instance.soldier.GetComponent<WeaponBase>().gunAnimator.GetComponent<Animator>().SetBool("Fire", false);
            }
        }
    }




    public void PerformLevelFailEffectWithDelay(/*float delayBetweenIterations*/)
    {
        foreach (var opponentAeroplanes in GameManager.instance.levelManager.currentLevel.PlayerBaseList)
        {

            if (opponentAeroplanes.GetComponent<BaseHealthManager>())
            {
                if (opponentAeroplanes.GetComponent<BaseHealthManager>().explosionParticle != null)
                {
                    opponentAeroplanes.GetComponent<BaseHealthManager>().explosionParticle.gameObject.transform.parent = null;
                    opponentAeroplanes.GetComponent<BaseHealthManager>().explosionParticle.Play();
                    Destroy(opponentAeroplanes);
                }
            }
            else if (opponentAeroplanes.GetComponentInChildren<BaseHealthManager>())
            {
                if (opponentAeroplanes.GetComponentInChildren<BaseHealthManager>().explosionParticle != null)
                {
                    opponentAeroplanes.GetComponentInChildren<BaseHealthManager>().explosionParticle.gameObject.transform.parent = null;
                    opponentAeroplanes.GetComponentInChildren<BaseHealthManager>().explosionParticle.Play();
                    Destroy(opponentAeroplanes);
                }
            }
        }
    }


    public void PerformLevelWinEffectWithDelay(/*float delayBetweenIterations*/)
    {
        foreach (var opponentAeroplanes in GameManager.instance.levelManager.currentLevel.EnemyAeroplanesList)
        {
            if (opponentAeroplanes.gameObject)
            {
                if (opponentAeroplanes.GetComponent<DOTweenPath>())
                {
                    DOTween.Kill(opponentAeroplanes);
                    Destroy(opponentAeroplanes.GetComponent<DOTweenPath>());
                }

                if (opponentAeroplanes.GetComponent<ShootingFromAeroplane>())
                {
                    opponentAeroplanes.GetComponent<ShootingFromAeroplane>().DestoyThePlane();
                }
                else /*if(opponentAeroplanes.GetComponent<TorpedoRocket>())*/
                {
                    if(opponentAeroplanes.GetComponent<TorpedoRocket>() != null)
                        opponentAeroplanes.GetComponent<TorpedoRocket>().DestryTheRocket();
                }
            }
        }
    }
}
