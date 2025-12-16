using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DG.Tweening;
using ADC.Ads;

public class VehicleSelection : Singleton<VehicleSelection>
{
    public enum VehicleStatus { Locked, Unlocked }
    public enum PurchaseType { Free, CashUnlock, VideoUnlock, LevelUnlock }
    public Color disabledColor;
    public Sprite buttonBgGreen;
    public Sprite buttonBgYellow;
    public Sprite buttonBgOrignal;

    public Vector3 Rotations;

    private const string hasPlayedKey = "isHandUsed";
    public GameObject handForDirection;


    [System.Serializable]
    public class Bikes
    {
        public int bikeID;

        public VehicleStatus status;
        public PurchaseType type;
        public int price;
        public float topSpeed, handling, accelration;
        //public GameObject button;
        public GameObject bike;
        //public GameObject selectedOption;
        public TextMeshProUGUI vehicleStausShow;
        //public GameObject lockImage;
        public int unlockAtLevel;

        [Space(15)]
        [Header(" UI Bullets Data")]
        public int RvToUnlock = 0;
        public int CoinsToUnlock = 0;

    }
    public int selectedBike;
    public Bikes[] bikes;
    public GameObject[] guns; // Array to hold all the guns

    private int currentIndex = 0; // Index to keep track of the current gun being displayed
    //public GameObject[] alLGuns;

    // Start is called before the first frame update
    void Awake()
    {
        GarageUIManager.Instance.guns3Dmodels = gameObject;
        for (int i = 0; i < bikes.Length; i++)
        {
            LoadRvToUnlock(i);
            if (PlayerPrefs.HasKey(GameConstants.VehileStatusId + bikes[i].bikeID))
            {
                bikes[i].status = (VehicleStatus)System.Enum.Parse(typeof(VehicleStatus), PlayerPrefs.GetString(GameConstants.VehileStatusId + bikes[i].bikeID));
            }
            else
            {
                PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[i].bikeID, bikes[i].status.ToString());
            }

        }
        if (!PlayerPrefs.HasKey(GameConstants.SelectedVehicles))
        {
            selectedBike = 0;
            PlayerPrefs.SetInt(GameConstants.SelectedVehicles, 0);
        }
        else
        {
            selectedBike = PlayerPrefs.GetInt(GameConstants.SelectedVehicles);
        }
        //for (int i = 0; i < bikes.Length; i++)
        //{
        //    int copy = i;
        //    bikes[copy].button.GetComponent<Button>().onClick.AddListener(() => { OnBikeButtonClick(bikes[copy].bikeID); });

        //}

    }
    public void Start()
    {
        UIManager.instance.RV_CountButton.GetComponent<Button>().interactable = AdManager.IsRewardedAvailable(new AdVariantReference("RV Store Unlocked"));

        //ShowGun(currentIndex);
        GameManager.instance.vehicleSelection = GetComponent<VehicleSelection>();

        RefreshGarage();
        currentIndex = selectedBike;

        CheckHandStatus();

    }

    public void CheckHandStatus()
    {
        // Check if the player has already played the game
        if (!PlayerPrefs.HasKey(hasPlayedKey))
        {
            handForDirection.SetActive(true);

            // Play the game object
            //PlayGameObject();
        }
        else
        {
            handForDirection.SetActive(false);
            // If the player has already played, do not play the game object
            Debug.Log("Player has already played. Skipping game object.");
        }
    }

    public void SavePlayerHandsStatus()
    {
        if (!PlayerPrefs.HasKey(hasPlayedKey))
        {
            // If not, set the PlayerPrefs value to indicate that the player has played
            PlayerPrefs.SetInt(hasPlayedKey, 1);
            PlayerPrefs.Save();
            handForDirection.SetActive(false);

            // Play the game object
            //PlayGameObject();
        }
    }


    bool OneTimeRefreshGarage = true;
    public void RefreshGarage()
    {

        if (!OneTimeRefreshGarage)
            return;



            //OneTimeRefreshGarage = false;
        

        Debug.Log("RefreshGarage A");

        for (int i = 0; i < bikes.Length; i++)
        {
            Debug.Log("RefreshGarage B");

            if (bikes[i].status == VehicleStatus.Locked)
            {
                Debug.Log("RefreshGarage C");

                switch (bikes[i].type)
                {
                    case PurchaseType.Free:
                        //if (bikes[i].status == VehicleStatus.Locked)
                        //bikes[i].vehicleStausShow.text = "Free";
                        break;

                    case PurchaseType.CashUnlock:
                        if (bikes[i].status == VehicleStatus.Locked)
                        {
                            //bikes[i].vehicleStausShow.text = bikes[i].price.ToString() + "$";
                            //if (bikes[i].price > CoinsManager.instance.coins)
                            //{
                            //bikes[i].button.GetComponent<Button>().image.color = disabledColor;
                            //bikes[i].lockImage.SetActive(true);
                            //}
                            //else
                            //{
                            //    bikes[i].button.GetComponent<Button>().image.color = Color.white;
                            //    bikes[i].lockImage.SetActive(false);
                            //}
                        }
                        break;
                    case PurchaseType.VideoUnlock:
                        if (bikes[i].status == VehicleStatus.Locked)
                        {
                            //bikes[i].vehicleStausShow.text = "WatchVideo";
                            //bikes[i].button.GetComponent<Button>().image.color = disabledColor;
                            //bikes[i].lockImage.SetActive(true);

                        }
                        break;
                    case PurchaseType.LevelUnlock:
                        if (bikes[i].status == VehicleStatus.Locked)
                        {
                            //bikes[i].vehicleStausShow.text = "Find In Levels";
                            //bikes[i].button.GetComponent<Button>().image.color = disabledColor;
                            //bikes[i].lockImage.SetActive(true);
                        }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                Debug.Log("RefreshGarage D");

                //bikes[i].vehicleStausShow.text = "Unlocked";
                if (i == selectedBike)
                {
                    //bikes[i].selectedOption.SetActive(true);
                    bikes[i].bike.SetActive(true);
                    GarageUIManager.Instance.HandlingSli.value = bikes[i].handling;
                    GarageUIManager.Instance.topSpeedSli.value = bikes[i].topSpeed;
                    GarageUIManager.Instance.AccSli.value = bikes[i].accelration;
                    //UIManager.instance.RV_CountButton.SetActive(false);
                    //UIManager.instance.Coins_RequiredButton.SetActive(false);
                    //GarageUIManager.Instance.Popup.gameObject.SetActive(false);
                    //GarageUIManager.Instance.playButton.gameObject.SetActive(true);


                    //bikes[i].vehicleStausShow.text = "Selected";
                    //bikes[i].button.GetComponent<Image>().sprite = buttonBgGreen;
                }
                else
                {
                    //bikes[i].selectedOption.SetActive(false);
                    bikes[i].bike.SetActive(false);
                    UIManager.instance.RV_CountButton.SetActive(true);
                    UIManager.instance.Coins_RequiredButton.SetActive(true);
                    GarageUIManager.Instance.Popup.gameObject.SetActive(true);
                    GarageUIManager.Instance.playButton.gameObject.SetActive(false);
                    //bikes[i].button.GetComponent<Image>().sprite = buttonBgOrignal;

                }
                bikes[i].RvToUnlock = 2;
                bikes[i].bike.GetComponent<GunID>().isGunUnlocked = true;
                UIManager.instance.RV_CountButton.SetActive(false);
                UIManager.instance.Coins_RequiredButton.SetActive(false);
                GarageUIManager.Instance.Popup.gameObject.SetActive(false);
                GarageUIManager.Instance.playButton.gameObject.SetActive(true);
            }
        }

    }
    int tempVal;
    public void OnBikeButtonClick(int id)
    {
        return;
        Debug.Log("ShowNextGun F");

        tempVal = id;


        if (bikes[id].status == VehicleStatus.Unlocked)
        {

            Debug.Log("ShowNextGun G");

            selectedBike = bikes[id].bikeID;
            PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
            //RefreshGarage();
            //bikes[id].vehicleStausShow.text = "Selected";
            //bikes[id].button.GetComponent<Image>().sprite = buttonBgGreen;

            //bikes[id].selectedOption.SetActive(true);


            //UIManager.instance.RV_CountButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[id].RvToUnlock.ToString();
            //UIManager.instance.Coins_RequiredButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[id].CoinsToUnlock.ToString();

            GarageUIManager.Instance.playButton.SetActive(true);
            GarageUIManager.Instance.Popup.SetActive(false);
            GarageUIManager.Instance.Popup.SetActive(false);
            UIManager.instance.RV_CountButton.SetActive(false);
            UIManager.instance.Coins_RequiredButton.SetActive(false);

        }
        //else 
        //if (bikes[id].status == VehicleStatus.Locked)
        //{

        //    Debug.Log("ShowNextGun H");

        //    switch (bikes[id].type)
        //    {

        //        case PurchaseType.Free:

        //            Debug.Log("ShowNextGun I");

        //            selectedBike = bikes[id].bikeID;
        //            PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
        //            bikes[id].status = VehicleStatus.Unlocked;
        //            PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[id].bikeID, bikes[id].status.ToString());
        //            //RefreshGarage();
        //            //bikes[id].selectedOption.SetActive(true);
        //            //bikes[id].button.GetComponent<Image>().sprite = buttonBgGreen;
        //            //bikes[id].vehicleStausShow.text = "Selected";
        //            break;
        //        case PurchaseType.CashUnlock:
        //            Debug.Log("ShowNextGun J");

        //            if (bikes[id].price <= CoinsManager.instance.coins)
        //            {

        //                Debug.Log("ShowNextGun J");

        //                //bikes[id].button.GetComponentInChildren<ParticleSystem>().Play();
        //                CoinsManager.instance.DecreaseCoins(bikes[id].price);
        //                selectedBike = bikes[id].bikeID;
        //                PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
        //                bikes[id].status = VehicleStatus.Unlocked;
        //                PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[id].bikeID, bikes[id].status.ToString());
        //                //bikes[id].selectedOption.SetActive(true);
        //                //bikes[id].button.GetComponent<Image>().sprite = buttonBgGreen;
        //                //bikes[id].vehicleStausShow.text = "Selected";
        //                //bikes[id].lockImage.SetActive(false);

        //                //RefreshGarage();
        //            }
        //            else
        //            {
        //                Debug.Log("ShowNextGun L");

        //                GarageUIManager.Instance.ShowPopup("Not Enough Cash");
        //                //bikes[id].button.GetComponent<Image>().sprite = buttonBgYellow;
        //            }
        //            break;
        //        case PurchaseType.VideoUnlock:
        //            Debug.Log("ShowNextGun M");

        //            break;
        //        case PurchaseType.LevelUnlock:
        //            Debug.Log("ShowNextGun N");

        //            GarageUIManager.Instance.ShowPopup("Unlocks At Level " + bikes[id].unlockAtLevel.ToString());
        //            UIManager.instance.RV_CountButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[id].RvToUnlock.ToString();
        //            UIManager.instance.Coins_RequiredButton.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "$" + bikes[id].CoinsToUnlock.ToString();
        //            GarageUIManager.Instance.playButton.SetActive(false);
        //            GarageUIManager.Instance.Popup.SetActive(true);
        //            UIManager.instance.RV_CountButton.SetActive(true);
        //            UIManager.instance.Coins_RequiredButton.SetActive(true);
        //            // here i will be adding new values by assigning that and saving that


        //            //bikes[id].button.GetComponent<Image>().sprite = buttonBgYellow;
        //            break;
        //        default:
        //            break;
        //    }

        //}


        Debug.Log("ShowNextGun O");

        for (int i = 0; i < bikes.Length; i++)
        {
            if (bikes[i].bikeID == id)
            {
                Debug.Log("ShowNextGun P");

                bikes[i].bike.SetActive(true);
                GarageUIManager.Instance.HandlingSli.value = bikes[i].handling;
                GarageUIManager.Instance.topSpeedSli.value = bikes[i].topSpeed;
                GarageUIManager.Instance.AccSli.value = bikes[i].accelration;


            }
            else
            {
                Debug.Log("ShowNextGun Q");

                bikes[i].bike.SetActive(false);
                //if(i!=selectedBike)
                //bikes[i].button.GetComponent<Image>().sprite = buttonBgOrignal;
            }
        }

        //RefreshGarage();

        Debug.Log("ShowNextGun R");


    }

    public void OnBikeButtonClickNew(int id)
    {
        Debug.Log("ShowNextGun F");

        tempVal = id;


        if (bikes[id].status == VehicleStatus.Unlocked)
        {

            Debug.Log("ShowNextGun G");

            selectedBike = bikes[id].bikeID;
            PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
            //RefreshGarage();
            //bikes[id].vehicleStausShow.text = "Selected";
            //bikes[id].button.GetComponent<Image>().sprite = buttonBgGreen;

            //bikes[id].selectedOption.SetActive(true);


            //UIManager.instance.RV_CountButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[id].RvToUnlock.ToString();
            //UIManager.instance.Coins_RequiredButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[id].CoinsToUnlock.ToString();

            GarageUIManager.Instance.playButton.SetActive(true);
            GarageUIManager.Instance.Popup.SetActive(false);
            GarageUIManager.Instance.Popup.SetActive(false);
            UIManager.instance.RV_CountButton.SetActive(false);
            UIManager.instance.Coins_RequiredButton.SetActive(false);

        }
        else
        if (bikes[id].status == VehicleStatus.Locked)
        {

            Debug.Log("ShowNextGun H");

            switch (bikes[id].type)
            {

                case PurchaseType.Free:

                    Debug.Log("ShowNextGun I");

                    selectedBike = bikes[id].bikeID;
                    PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
                    bikes[id].status = VehicleStatus.Unlocked;
                    PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[id].bikeID, bikes[id].status.ToString());

                    break;
                case PurchaseType.CashUnlock:
                    Debug.Log("ShowNextGun J");

                    if (bikes[id].price <= CoinsManager.instance.coins)
                    {

                        Debug.Log("ShowNextGun J");

                        CoinsManager.instance.DecreaseCoins(bikes[id].price);
                        selectedBike = bikes[id].bikeID;
                        PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
                        bikes[id].status = VehicleStatus.Unlocked;
                        PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[id].bikeID, bikes[id].status.ToString());

                    }
                    else
                    {
                        Debug.Log("ShowNextGun L");

                        GarageUIManager.Instance.ShowPopup("Not Enough Cash");
                        //bikes[id].button.GetComponent<Image>().sprite = buttonBgYellow;
                    }
                    break;
                case PurchaseType.VideoUnlock:
                    Debug.Log("ShowNextGun M");

                    break;
                case PurchaseType.LevelUnlock:
                    Debug.Log("ShowNextGun N");

                    UIManager.instance.RV_CountButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[id].RvToUnlock.ToString();
                    UIManager.instance.Coins_RequiredButton.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "$" + bikes[id].CoinsToUnlock.ToString();

                    UIManager.instance.RV_CountButton.SetActive(true);
                    UIManager.instance.Coins_RequiredButton.SetActive(true);

                    //GarageUIManager.Instance.ShowPopup("Unlocks At Level " + bikes[id].unlockAtLevel.ToString());

                    GarageUIManager.Instance.playButton.SetActive(false);
                    GarageUIManager.Instance.Popup.SetActive(true);

                    break;
                default:
                    break;
            }

        }


        Debug.Log("ShowNextGun O");

        for (int i = 0; i < bikes.Length; i++)
        {
            if (bikes[i].bikeID == id)
            {
                Debug.Log("ShowNextGun P");

                bikes[i].bike.SetActive(true);
                GarageUIManager.Instance.HandlingSli.value = bikes[i].handling;
                GarageUIManager.Instance.topSpeedSli.value = bikes[i].topSpeed;
                GarageUIManager.Instance.AccSli.value = bikes[i].accelration;


            }
            else
            {
                Debug.Log("ShowNextGun Q");

                bikes[i].bike.SetActive(false);
                //if(i!=selectedBike)
                //bikes[i].button.GetComponent<Image>().sprite = buttonBgOrignal;
            }
        }

        //RefreshGarage();

        Debug.Log("ShowNextGun R");


    }
    public void UnlockVehicleInLevel(int vehicleId)
    {
        if (bikes[vehicleId].status == VehicleStatus.Locked)
        {
            switch (bikes[vehicleId].type)
            {
                case PurchaseType.Free:
                    selectedBike = bikes[vehicleId].bikeID;
                    PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
                    bikes[vehicleId].status = VehicleStatus.Unlocked;
                    PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[vehicleId].bikeID, bikes[vehicleId].status.ToString());
                    //RefreshGarage();
                    //bikes[vehicleId].selectedOption.SetActive(true);
                    //bikes[vehicleId].button.GetComponent<Image>().sprite = buttonBgGreen;
                    //bikes[vehicleId].vehicleStausShow.text = "Selected";
                    break;
                case PurchaseType.CashUnlock:
                    if (bikes[vehicleId].price <= CoinsManager.instance.coins)
                    {
                        CoinsManager.instance.DecreaseCoins(bikes[vehicleId].price);
                        selectedBike = bikes[vehicleId].bikeID;
                        PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
                        bikes[vehicleId].status = VehicleStatus.Unlocked;
                        PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[vehicleId].bikeID, bikes[vehicleId].status.ToString());
                        //bikes[vehicleId].selectedOption.SetActive(true);
                        //bikes[vehicleId].vehicleStausShow.text = "Selected";

                        //bikes[vehicleId].button.GetComponent<Image>().sprite = buttonBgGreen;

                        //RefreshGarage();
                    }
                    break;
                case PurchaseType.VideoUnlock:
                    break;
                case PurchaseType.LevelUnlock:
                    selectedBike = bikes[vehicleId].bikeID;
                    PlayerPrefs.SetInt(GameConstants.SelectedVehicles, selectedBike);
                    bikes[vehicleId].status = VehicleStatus.Unlocked;
                    PlayerPrefs.SetString(GameConstants.VehileStatusId + bikes[vehicleId].bikeID, bikes[vehicleId].status.ToString());
                    //bikes[vehicleId].selectedOption.SetActive(true);
                    //bikes[vehicleId].vehicleStausShow.text = "Selected";
                    //bikes[vehicleId].button.GetComponent<Image>().sprite = buttonBgGreen;


                    //RefreshGarage();
                    break;
                default:
                    break;
            }

        }

        RefreshGarage();

    }


    private void ShowGun(int index)
    {
        Debug.Log("ShowNextGun C");

        // Disable all guns
        foreach (GameObject gun in guns)
        {
            Debug.Log("ShowNextGun D");

            gun.SetActive(false);
        }

        Debug.Log("ShowNextGun E");

        // Enable the gun at the specified index
        guns[index].SetActive(true);
        OnBikeButtonClickNew(guns[index].gameObject.transform.GetComponent<GunID>().gunId);

    }

    public void ShowNextGun()
    {

        Debug.Log("ShowNextGun A");
        // Increment the index
        currentIndex++;

        // If we reach the end of the array, loop back to the beginning
        if (currentIndex >= guns.Length)
        {
            currentIndex = 0;
        }
        Debug.Log("ShowNextGun B");

        // Show the gun at the new index
        ShowGun(currentIndex);
        Debug.Log("ShowNextGun S");
        // onButtonClick
    }

    public void ShowPreviousGun()
    {
        // Decrement the index
        currentIndex--;

        // If we reach the beginning of the array, loop back to the end
        if (currentIndex < 0)
        {
            currentIndex = guns.Length - 1;
        }

        // Show the gun at the new index
        ShowGun(currentIndex);
    }


    //=====================================================LOCK UNLOCK GUNS AND STATS FOR RV COUNTS===========================================================



    public void DeductTheCount()
    {
        //SaveRvToUnlock(tempVal, 1);

        if (bikes[tempVal].RvToUnlock < 2)
        {
            ReloadSceneWithRV(1);
        }
    }

    public void DeductTheCountCoins()
    {
        //SaveRvToUnlock(tempVal, 1);

        if (bikes[tempVal].RvToUnlock < 2)
        {
            ReloadSceneWithRV(2);
        }
    }



    public int RvToUnlock(int i)
    {
        string key = "RvToUnlock__" + i; // Use i to create unique PlayerPrefs key for each gun

        // Check if the key exists in PlayerPrefs
        if (!PlayerPrefs.HasKey(key))
        {
            // If the key doesn't exist, set the default value to the RvToUnlock value of the bike with index i
            PlayerPrefs.SetInt(key, bikes[i].RvToUnlock);
        }

        bikes[i].RvToUnlock = PlayerPrefs.GetInt("RvToUnlock__" + i);

        UIManager.instance.RV_CountButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[i].RvToUnlock.ToString();
        UIManager.instance.Coins_RequiredButton.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "$" + bikes[i].CoinsToUnlock.ToString();
        if (bikes[i].RvToUnlock >= 2)
        {
            bikes[i].bike.GetComponent<GunID>().isGunUnlocked = true;
        }
        // Return the value stored in PlayerPrefs
        return PlayerPrefs.GetInt(key);

    }

    public void SaveRvToUnlock(int i, int rvCount, int btn)
    {
        if (btn == 1)
        {
            rvCount = bikes[i].RvToUnlock + 1;
            print("tatta2" + rvCount);

            string key = "RvToUnlock__" + i; // Use i to create unique PlayerPrefs key for each gun
            bikes[i].RvToUnlock = rvCount;
            PlayerPrefs.SetInt(key, rvCount);
            UIManager.instance.RV_CountButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = bikes[i].RvToUnlock.ToString();
            UIManager.instance.Coins_RequiredButton.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "$" + bikes[i].CoinsToUnlock.ToString();
            if (bikes[i].RvToUnlock >= 2)
            {
                bikes[i].bike.GetComponent<GunID>().isGunUnlocked = true;
                UnlockVehicleInLevel(bikes[i].bikeID);
                GarageUIManager.Instance.playButton.SetActive(true);
                GarageUIManager.Instance.Popup.SetActive(false);
                UIManager.instance.RV_CountButton.SetActive(false);
                UIManager.instance.Coins_RequiredButton.SetActive(false);
            }
        }
        else if (btn == 2)
        {

            if (bikes[tempVal].CoinsToUnlock <= CoinsManager.instance.coins)
            {
                rvCount = 2;
                string key = "RvToUnlock__" + i; // Use i to create unique PlayerPrefs key for each gun
                bikes[i].RvToUnlock = rvCount;
                PlayerPrefs.SetInt(key, rvCount);
                if (bikes[i].RvToUnlock >= 2)
                {
                    bikes[i].bike.GetComponent<GunID>().isGunUnlocked = true;
                    UnlockVehicleInLevel(bikes[i].bikeID);
                    GarageUIManager.Instance.playButton.SetActive(true);
                    GarageUIManager.Instance.Popup.SetActive(false);
                    UIManager.instance.RV_CountButton.SetActive(false);
                    UIManager.instance.Coins_RequiredButton.SetActive(false);
                    CoinsManager.instance.DecreaseCoins(bikes[tempVal].CoinsToUnlock);
                }
            }
            else
            {
                // no enough coins

                UIManager.instance.NotCashText.SetActive(true);
                UIManager.instance.NotCashText.GetComponent<DOTweenAnimation>().DORestart();
                UIManager.instance.Coins_RequiredButton.GetComponent<Button>().transform.DOScale(1f, .1f).SetEase(Ease.Linear)
            .OnComplete(() => ResetButtonScale());
            }


        }
    }

    public int LoadRvToUnlock(int i)
    {
        string key = "RvToUnlock__" + i; // Use i to create unique PlayerPrefs key for each gun
        return RvToUnlock(i);
    }

    //public void CoinsUnlockSystem()
    //{
    //    print(bikes[tempVal].CoinsToUnlock + " bike cash value");
    //    print(CoinsManager.instance.coins + " coin cash value");

    //    if (bikes[tempVal].CoinsToUnlock <= CoinsManager.instance.coins)
    //    {
    //        // unlock here
    //        bikes[tempVal].bike.GetComponent<GunID>().isGunUnlocked = true;
    //        UnlockVehicleInLevel(bikes[tempVal].bikeID);
    //        GarageUIManager.Instance.playButton.SetActive(true);
    //        GarageUIManager.Instance.Popup.SetActive(false);
    //        UIManager.instance.RV_CountButton.SetActive(false);
    //        UIManager.instance.Coins_RequiredButton.SetActive(false);
    //        CoinsManager.instance.DecreaseCoins(bikes[tempVal].CoinsToUnlock);
    //    }
    //    else
    //    {
    //        // no enough coins
    //        UIManager.instance.Coins_RequiredButton.GetComponent<Button>().transform.DOScale(1f, .1f).SetEase(Ease.Linear)
    //    .OnComplete(() => ResetButtonScale());
    //    }
    //}
    void ResetButtonScale()
    {
        // Reset button scale after pinching
        UIManager.instance.Coins_RequiredButton.GetComponent<Button>().transform.DOScale(.8f, .1f).SetEase(Ease.Linear);
    }


    //=====================================================REWARDED VIDEO PLAY PORTION===========================================================

    void GetRV()
    {
        if (this == null) return;

        UIManager.instance.RV_CountButton.GetComponent<Button>().interactable = AdManager.IsRewardedAvailable(new AdVariantReference("RV Store Unlocked"));

        if (!UIManager.instance.RV_CountButton.GetComponent<Button>().interactable)
            CInvoker.InvokeDelayed(GetRV, 1);
    }

    public void ReloadSceneWithRV(int btn)
    {
        //if (isButtonPressed == false)
        //{
        //isButtonPressed = true;
        if (btn == 1)
        {
            AdManager.ShowRewarded(new AdVariantReference("RV Store Unlocked"), (watched) =>
            {
                if (watched)
                {
                    SaveRvToUnlock(tempVal, 1, btn);
                }
                else
                {
                    GetRV();
                }
            });
        }
        else if (btn == 2)
        {
            SaveRvToUnlock(tempVal, 1, btn);
        }
        //}
    }
}
