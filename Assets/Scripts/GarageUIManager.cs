using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using TMPro;
public class GarageUIManager : Singleton<GarageUIManager>
{

    // Final Calls// Final Calls// Final Calls// Final Calls
    public GameObject[] buttons;
    public GameObject panel;
    public RectTransform buttonsTransform;
    public GameObject bikePlane;
    public RectTransform backButton;
    public RectTransform specificationPanel;
    public Slider topSpeedSli, HandlingSli, AccSli;
    public GameObject Popup;
    public GameObject playButton;

    public TextMeshProUGUI popupText;
    public GameObject guns3Dmodels;
    // Start is called before the first frame update
    void Start()
    {
        // Initialize the store with the first gun
        //ShowGun(currentIndex);

        // Add listeners to the buttons
        //    leftButton.onClick.AddListener(ShowNextGun);
        //    rightButton.onClick.AddListener(ShowPreviousGun);
    }
    public void ShowPopup(string popText)
    {
        Popup.SetActive(true);
        Popup.transform.DOScale(Vector2.one, 0.3f).OnComplete(()=> {
            Popup.GetComponent<Button>().interactable = true;
        });
        popupText.text = popText;
    }
    public void ClosePopup()
    {

        Popup.GetComponent<Button>().interactable = false;
        Popup.transform.DOScale(Vector2.zero, 0.3f);
        DOVirtual.DelayedCall(0.4f, () => {
        Popup.SetActive(false);
        });
    }
    public void OpenGarage()
    {
        guns3Dmodels.SetActive(true);
        panel.SetActive(true);
        specificationPanel.DOAnchorPosX(0, 0.3f).SetEase(Ease.OutBack,1f);
        bikePlane.transform.DOScale(Vector3.one, 0.2f).SetEase(Ease.OutBack, 1f);
        backButton.DOAnchorPosX(80, 0.5f).SetEase(Ease.OutBack, 1f);
        buttonsTransform.DOAnchorPosY(-1520, 0.4f).SetEase(Ease.OutBack, 1f);
       // UISliderController.Instance.DisableLevelsProgress();
       // FindObjectOfType<UIRefs>().coinsPanel.SetActive(true);
       // coin
        //GameManager.instance.gameState = GameManager.GameState.start;
    }
    public void CloseGarage()
    {
        //if (UIManager.instance.GunsEffectsContainer.gameObject != null)
        //{
        //    UIManager.instance.GunsEffectsContainer.gameObject.SetActive(false);
        //}
        guns3Dmodels.SetActive(false);

        //specificationPanel.DOAnchorPosX(2000, 0.3f).SetEase(Ease.InBack, 1f);
        //bikePlane.transform.DOScale(new Vector3(0.3f,0.3f,0.3f), 0.5f).SetEase(Ease.InBack, 1f);
        //backButton.DOAnchorPosX(-80, 0.3f).SetEase(Ease.InBack, 1f);
        //buttonsTransform.DOAnchorPosY(-3000, 0.2f).SetEase(Ease.InBack, 1f);
        //DOVirtual.DelayedCall(0.5f, () => {
        //    //FindObjectOfType<UIRefs>().coinsPanel.SetActive(false);

        //    panel.SetActive(false);
        //    //UISliderController.Instance.EnableLevelsProgress();
        //});

        // Final Calls
        //HomeScreen.instance.ShowInterstitial();
        if(LevelManager.Instance.CurrentGun!=null)
        {
            LevelManager.Instance.CurrentGun.SetActive(false);
        }
        var tempGun = LevelManager.Instance.CurrentGun;
        //print(PlayerPrefs.GetInt(GameConstants.SelectedVehicles)+" selected Gun is");
        PrefabLoader.instance.loadResourcesGun(PlayerPrefs.GetInt(GameConstants.SelectedVehicles));
        UIManager.instance.TapToPlay();
        Destroy(tempGun.gameObject);

        //GameObject.FindObjectOfType<LevelSpecificManager>().UpdatePlayer();
    }
    // Update is called once per frame
    void Update()
    {
        //if (Input.GetKeyDown(KeyCode.A))
        //{
        //    OpenGarage();
        //}
        //if (Input.GetKeyDown(KeyCode.S))
        //{
        //    CloseGarage();
        //}
    }
    public void MoreBikes()
    {
        buttonsTransform.DOAnchorPosX(-1200, 0.4f).SetEase(Ease.OutBack, 1f);
    }
    public void LessBikes()
    {
        buttonsTransform.DOAnchorPosX(0, 0.4f).SetEase(Ease.OutBack, 1f);
    }

    public void ShowPrevious()
    {
        VehicleSelection.Instance.ShowPreviousGun();
    }

    public void ShowNext()
    {
        VehicleSelection.Instance.ShowNextGun();
    }
   

    public Button leftButton; // Button to show the next gun
    public Button rightButton; // Button to show the previous gun



    public void DeductRV()
    {
        //VehicleSelection.Instance.bike[GameConstants.SelectedVehicles].bike.GetComponent<RvDataManager>().SaveRvToUnlock();
        VehicleSelection.Instance.DeductTheCount();
    }


    public void UnlockOnCoins()
    {
        //VehicleSelection.Instance.CoinsUnlockSystem();
        VehicleSelection.Instance.DeductTheCountCoins();
    }
}
