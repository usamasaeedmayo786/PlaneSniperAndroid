using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

public class BaseHealthManager : MonoBehaviour
{
    public GameObject healthPanel;

    public Image healthImage;

    public float totalHealthValue;
    public float currentHealthValue;

    public float damageDeductionValue;

    public ParticleSystem smokeParticle;
    public ParticleSystem explosionParticle;


    bool enableTheSmoke = false;
    bool isActivated = false;


    //public bool isthecheckingbool = false;
    private void Start()
    {
        //currentHealthValue = totalHealthValue;
        //healthImage.fillAmount = currentHealthValue;
    }
    //private void Update()
    //{
    //    healthPanel.transform.LookAt(GameManager.instance.levelManager.currentLevel.mainCamera.transform);
    //    if(currentHealthValue<.5f && .01f > currentHealthValue && enableTheSmoke == false)
    //    {
    //        enableTheSmoke = true;
    //    }
    //    if(enableTheSmoke && isActivated == false)
    //    {
    //        isActivated = true;
    //        smokeParticle.gameObject.SetActive(true);
    //    }
    //}

    public void UpdateTheHealth()
    {
        StartCoroutine(UpdateDamage());   
    }

    IEnumerator UpdateDamage()
    {
        yield return new WaitForSeconds(.5f);
        currentHealthValue = currentHealthValue-damageDeductionValue;
        healthImage.fillAmount = currentHealthValue;
        if (currentHealthValue <= 0)
        {
            explosionParticle.gameObject.transform.parent = null;
            explosionParticle.Play();
            Destroy(gameObject);
        }
    }
}
