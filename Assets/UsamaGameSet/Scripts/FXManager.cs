/*
	真主
     穆罕默德 真主啊，为我们的大师穆罕默德和他的家人祈祷与和平 77 85 72 65 77 77 65 68 32 
         83 104 97 104 122 97 105 98	
*/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
/*
	This script holds all working of FX related things i.e plays particles /effects
     穆罕默德 77 85 72 65 77 77 65 68 32 83 104 97 104 122 97 105 98
*/


public class FXManager : MonoBehaviour

{
    public int i, numberOfCoins;
    public GameObject coinsTarget, uicoin;
    public GameObject[] coinImages;
    public ParticleSystem playerHit,enemyHit, confetti, confettiOnLevelEnd,
        blastParticles,upgradeParticles,decal,splashParticles,sandHitParticles,
        fireParticles,shootParticles,smokeParticles;
    public static FXManager instance;

    private void Awake()
    {
        instance = this;
    }

    //////////// this method plays the particles when player gets hit and particles are played at the position of player /////
    public void PlayParticles(ParticleSystem hitParticles,Vector3 hitPosition,bool destroyParticles)
    {
        
        var newParticles = Instantiate(hitParticles,hitPosition,hitParticles.transform.rotation);
        newParticles.transform.SetParent(transform);
        newParticles.Play();
        if (destroyParticles)
        {
            Destroy(newParticles.gameObject, 2f);
        }
        else Destroy(newParticles.gameObject,8f);
    }

    //////////// this method plays the particles when player gets hit and particles are played at the position of player /////
    public void PlayParticlesWithParent(Transform parentToSet,ParticleSystem hitParticles, Vector3 hitPosition, bool destroyParticles)
    {

        var newParticles = Instantiate(hitParticles, hitPosition, hitParticles.transform.rotation);
        newParticles.transform.SetParent(parentToSet);
        newParticles.Play();
        if (destroyParticles)
        {
            Destroy(newParticles.gameObject, 2f);
        }
        else Destroy(newParticles.gameObject, 8f);
    }




    ////////// this method plays confetti at the position of an object ////////////
    public void PlayConfettiParticles(GameObject playerPosition)
    {
        Vector3 tempPos = playerPosition.transform.position;
        tempPos.y += 1f;
        confetti.transform.position = tempPos;
        confetti.Play();
    }

    ////////// this method plays upgrade particles at the position of an object ////////////
    public void PlayUpgradeParticles(GameObject playerPosition)
    {
        Vector3 tempPos = playerPosition.transform.position;
        tempPos.y -= 1f;
        upgradeParticles.transform.position = tempPos;
        upgradeParticles.Play();
    }

    //////////// this method simply plays confetti (Here this confetti is present in camera)///////////
    public IEnumerator PlayConfettiOnLevelEnd(float waitTime)
    {
        yield return new WaitForSeconds(waitTime);
            confettiOnLevelEnd.Play();
        
    }


    /////////////////////////// this method is called from outside with reference of the world position in parameter //////
    public IEnumerator TransferCoinFromWorldToCanvas(Vector3 coinsPositionReference)
    {
        yield return new WaitForSeconds(.1f);
        StartCoroutine(WaitThenTransfer(coinsPositionReference,false));
    }

    /// <summary>
    /// ////
    /// </summary>
    /// <param name="refPos"></param>
    /// <returns></returns>
    /// 
    public IEnumerator TransferCoinsFromUIToUI(Vector3 coinsPositionReference)
    {
        yield return new WaitForSeconds(.1f);
        StartCoroutine(WaitThenTransfer(coinsPositionReference, true));
    }

    //////////// wait for sometime before pushing up the specified number of coins from given reference position in parameter ///
    IEnumerator WaitThenTransfer(Vector3 refPos,bool uiTransfer)
    {
        for (int j = 0; j < numberOfCoins; j++)
        {
            yield return new WaitForSeconds(.1f);
            TransferCoins(refPos,uiTransfer);
        }
    }

    //////// this method transfers the coins from world position to the target on camvas //////////
    public void TransferCoins(Vector3 pos,bool isUITransfer)
    {
        if (i < coinImages.Length - 1)
        {
            i++;
        }
        else
        {
            i = 0;
        }

        var wantedPos = FindObjectOfType<Camera>().WorldToScreenPoint(pos);
        //var wantedPos = Camera.main.WorldToScreenPoint(pos);
        GameObject coinImage = coinImages[i];
        coinImage.gameObject.SetActive(true);
        if (!isUITransfer)
            coinImage.transform.position = wantedPos;
        //   coinImage.transform.GetComponent<RectTransform>().position = wantedPos;
        //else 

        coinImage.GetComponent<RectTransform>().DOAnchorPos(coinsTarget.transform.GetComponent<RectTransform>().anchoredPosition, .7f).OnComplete(()=>CallFunction(coinImage)).SetEase(Ease.InOutQuad).SetUpdate(true);		
    }

    //////////////////////  after coins reaches the destination coin imag disables and itween is played for collection effect ////
    void CallFunction(GameObject coinImage)
    {
        coinImage.gameObject.SetActive(false);
        PlayTween();
    }

    //////////////////////  playing the tween //////////////
    void PlayTween()
    {
        //iTween.PunchScale(uicoin, iTween.Hash("x", 0.2f, "y", 0.2f, "z", 0.2f, "easeType",
        //"spring", "loopType", "none", "delay", 0f, "time", 1.0f));
    }




}