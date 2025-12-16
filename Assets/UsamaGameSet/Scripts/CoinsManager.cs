/*
	真主
     穆罕默德 真主啊，为我们的大师穆罕默德和他的家人祈祷与和平 77 85 72 65 77 77 65 68 32 
         83 104 97 104 122 97 105 98	
*/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System;
using UnityEngine.UI;
public class CoinsManager : MonoBehaviour
{

    public int coins, coinsRequired;
    public string coinsId = "Coin", coinsLevelId = "CoinLevel";
    //UIRefs uiRefs;
    public int increaseAmount = 10;
    public int coinsLevel;
    public static CoinsManager instance;
   // UIRefs.UpgradeInfo upgradeInfo;
    public int upgradeInfoIndex = 0;

    public Text coinsText;
    public int addCoinsCount;
    private void Awake()
    {
        instance = this;
    }

    /////////// this method checks if game is played first time then makes an entry in player pref else load the appropriate level ////////
    void Start()
    {
       // uiRefs = FindObjectOfType<UIRefs>();
        //upgradeInfo = uiRefs.upgradeInfos[upgradeInfoIndex];
        //upgradeInfo.upgradeButton.onClick.AddListener(BuyBonus);
        if (PlayerPrefs.HasKey(coinsId))
        {

            coins = PlayerPrefs.GetInt(coinsId);
        }

        else
        {
            SaveLevelProgress(coins);
        }

        string coinsText = ChangeCurrency((double)coinsRequired);
        //upgradeInfo.priceText.text = coinsText;
        LoadCoinsAmount(coins);
        CheckAvailability();
        LoadCoinsLevel();
    }


    void LoadCoinsLevel()
    {
        if (PlayerPrefs.HasKey(coinsLevelId))
        {
            coinsLevel = PlayerPrefs.GetInt(coinsLevelId);
        }
        else
        {
            coinsLevel = 1;
            SaveCoinsLevel();
        }

        //upgradeInfo.levelText.text = "Lvl: " + coinsLevel+ " / 3";
        //∞
    }

    void SaveCoinsLevel()
    {
        PlayerPrefs.SetInt(coinsLevelId, coinsLevel);
    }

    private void Update()
    {

        CheckAvailability();
    }


    ///////////////////////// this method checks if coins available to unlock a tank or not //////////////////////

    public void CheckAvailability()
    {
        //if (GetCoins() >= coinsRequired && coinsLevel<3)
        //{
        //    UIManager.instance.SetUIInteractability(upgradeInfo.upgradeButton,true);
        //   //upgradeInfo.upgradeButton.interactable = true;
        //}
        //else
        //{
        //    UIManager.instance.SetUIInteractability(upgradeInfo.upgradeButton, false);
        //    // upgradeInfo.upgradeButton.interactable = false;
        //    if (upgradeInfo.upgradeButton.GetComponent<iTween>())
        //    {
        //        upgradeInfo.upgradeButton.GetComponent<iTween>().enabled = false;
        //    }
        //}

    }




    public void BuyBonus()
    {
        int coinsAvailable = GetCoins();

        if (coinsAvailable >= coinsRequired && coinsLevel < 3)
        {
           // upgradeInfo.upgradeButton.GetComponentInChildren<ParticleSystem>().Play();
            coinsAvailable -= coinsRequired;
            if (coinsAvailable <= 0)
            {
                coinsAvailable = 0;
            }

            DecreaseCoins(coinsRequired);
            coinsLevel++;
            SaveCoinsLevel();
            LoadCoinsLevel();

        }

        
    }

    /////////// simply loads the given coins amount ////////////
    public void LoadCoinsAmount(int coins)
    {
        string suffix = " K ";
        int coinsHere = coins;
        //if (coins >= 1000)
        //{
        //    suffix = "M";
        //    coinsHere = (int)((float)coins / 1000);
        //}

        //if (coins>=100000)
        //{
        //    suffix = "B";
        //    coinsHere = (int)((float)coins / 100000);
        //}


        string coinsTexts = ChangeCurrency((double)coinsHere);
        coinsText.text = coinsTexts;
        UIManager.instance.UICoinsText.text = coinsTexts;
    }

    public int GetCoins()
    {
        int coinsHere = PlayerPrefs.GetInt(coinsId);
        return coinsHere;
    }

    ///////// increases coins and saves progress //////////
    public void IncreaseCoins(int amountToIncrease)
    {
        coins += (amountToIncrease * coinsLevel);
        SaveLevelProgress(coins);
        LoadCoinsAmount(coins);
    }

    ///////// decreases coins and saves progress //////////
    public void DecreaseCoins(int decreaseAmount)
    {
        coins -= decreaseAmount;

        if (coins < 0)
        {
            coins = 0;
        }

        SaveLevelProgress(coins);

        LoadCoinsAmount(coins);
    }

    /////////   saves coins//////////
    public void SaveLevelProgress(int coinsHere)
    {
        PlayerPrefs.SetInt(coinsId, coinsHere);
    }

    /// <summary>
    /// Resets everything and reloads the game.
    /// </summary>
    public void Reset()
    {
        coins = 0;
        SaveLevelProgress(coins);
    }

    #region CurrencyChanger
    private string outputText;
    double Novendecillion = 1e+60;
    double octodecillion = 1e+57;
    double septendecillion = 1e+54;
    double sexdecillion = 1e+51;
    double quinquadecillion = 1e+48;
    double quattuordecillion = 1e+45;
    double tredecillion = 1e+42;
    double duodecillion = 1e+39;
    double undecillion = 1e+36;
    double decillion = 1e+33;
    double nonillion = 1e+30;
    double octillion = 1e+27;
    double septillion = 1e+24;
    double sextillion = 1e+21;
    ulong quintillion = 1000000000000000000;
    ulong quadrillion = 1000000000000000;
    ulong trillion = 1000000000000;
    ulong billion = 1000000000;
    uint million = 1000000;
    public string ChangeCurrency(double amount)
    {
        //ulong ogCurrency = UInt64.Parse(currencyInput.text);
        double ogCurrency = amount;
        double truncatedCurrency = 0;
        //Debug.Log(ogCurrency);
        if (ogCurrency >= Novendecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / Novendecillion, 2);
            outputText = truncatedCurrency.ToString() + "N";
        }
        else
       if (ogCurrency >= octodecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / octodecillion, 2);
            outputText = truncatedCurrency.ToString() + "O";
        }
        else
       if (ogCurrency >= septendecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / septendecillion, 2);
            outputText = truncatedCurrency.ToString() + "St";
        }
        else
       if (ogCurrency >= sexdecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / sexdecillion, 2);
            outputText = truncatedCurrency.ToString() + "Sd";
        }
        else
        if (ogCurrency >= quinquadecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / quinquadecillion, 2);
            outputText = truncatedCurrency.ToString() + "Qd";
        }
        else
        if (ogCurrency >= quattuordecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / quattuordecillion, 2);
            outputText = truncatedCurrency.ToString() + "Qt";
        }
        else
       if (ogCurrency >= tredecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / tredecillion, 2);
            outputText = truncatedCurrency.ToString() + "T";
        }
        else
        if (ogCurrency >= duodecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / duodecillion, 2);
            outputText = truncatedCurrency.ToString() + "D";
        }
        else
       if (ogCurrency >= undecillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / undecillion, 2);
            outputText = truncatedCurrency.ToString() + "U";
        }
        else
        if (ogCurrency >= decillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / decillion, 2);
            outputText = truncatedCurrency.ToString() + "d";
        }
        else
       if (ogCurrency >= nonillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / nonillion, 2);
            outputText = truncatedCurrency.ToString() + "n";
        }
        else
        if (ogCurrency >= octillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / octillion, 2);
            outputText = truncatedCurrency.ToString() + "o";
        }
        else
       if (ogCurrency >= septillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / septillion, 2);
            outputText = truncatedCurrency.ToString() + "S";
        }
        else
       if (ogCurrency >= sextillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / sextillion, 2);
            outputText = truncatedCurrency.ToString() + "s";
        }
        else
        if (ogCurrency >= quintillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / quintillion, 2);
            outputText = truncatedCurrency.ToString() + "Q";
        }
        else
        if (ogCurrency >= quadrillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / quadrillion, 2);
            outputText = truncatedCurrency.ToString() + "q";
        }
        else
        if (ogCurrency >= trillion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / trillion, 2);
            outputText = truncatedCurrency.ToString() + "t";
        }
        else if (ogCurrency >= billion)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / billion, 2);
            outputText = truncatedCurrency.ToString() + "B";
        }
        else if (ogCurrency >= million)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / million, 2);
            outputText = truncatedCurrency.ToString() + "M";
        }
        else if (ogCurrency >= 1000)
        {
            truncatedCurrency = Math.Round((double)ogCurrency / 1000, 2);
            outputText = truncatedCurrency.ToString() + "K";
        }
        else if (ogCurrency >= 0)
        {
            truncatedCurrency = Math.Round((double)ogCurrency, 2);

            outputText = truncatedCurrency.ToString()+"$";
        }


        return outputText;
    }
    #endregion

}