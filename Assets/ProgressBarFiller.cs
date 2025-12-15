using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class ProgressBarFiller : MonoBehaviour
{

    public static ProgressBarFiller instance;
    public GameObject slider;
    public Vector3 firstMove;
    public Vector3 secondMove;
    public Vector3 thirdMove;

    private void Awake()
    {
        instance = this;
    }

    public void moveSliderToFirst()
    {

        slider.transform.DOMove(firstMove, 3f).SetDelay(delay: 1f).SetEase(ease: Ease.Linear);
    }

    public void moveSliderToSecond()
    {
        slider.transform.position = firstMove;
        slider.SetActive(true);
        slider.transform.DOMove(secondMove, 3f).SetDelay(delay: 1f).SetEase(ease: Ease.Linear);
    }
    public void moveSliderToThird()
    {
        slider.transform.position = secondMove;
        slider.transform.DOMove(thirdMove, 3f).SetDelay(delay: 1f).SetEase(ease: Ease.Linear);
    }
}
