using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;



public class UICountdown : MonoBehaviour
{

    public TextMeshProUGUI timer;

    public bool isShowing { get; private set; }

    protected void Awake()
    {
        gameObject.SetActive(false);
    }

    /// <summary>
    /// Show the countdown timer UI, callback is invoked when the timer is complete
    /// </summary>
    /// <param name="time"></param>
    /// <param name="callback"></param>
    public virtual void ShowCountdown(float time, Action callback)
    {      
        // show the UI
        gameObject.SetActive(true);

        // animate the countdown
        SimpleAnimation.AnimateLinear(time, (dt) =>
        {
            if (this == null) return;
            timer.text = (time < 10 ? ":0" : ":") + (time * (1 - dt)).ToString("F0");
        }, () => {

            // hide the ui and invoke the callback
            callback?.Invoke();
            if (this == null) return;
            gameObject.SetActive(false);
           
        });

    }


}
