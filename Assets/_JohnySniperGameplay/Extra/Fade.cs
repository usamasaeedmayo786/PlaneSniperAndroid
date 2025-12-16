/*
	
	穆罕默德 77 85 72 65 77 77 65 68 32 83 104 97 104 122 97 105 98
    This script manages fading in or out of image
*/

using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class Fade : MonoBehaviour
{
    public Image img;
    [SerializeField] private float waitTime = 0f, startAlpha = .7f, 
        fadeAmount = .1f,endAlpha=1f,startDelay=1f;
    public static Fade instance;

    void Awake()
    {
        instance = this;
    }
    void Start()
    {
        if (img==null)
        {
            img = GetComponent<Image>();
        }
        // StartCoroutine(FadeInImage());
    }
    IEnumerator FadeInImage()
    {
        // fade from opaque to transparent
        yield return new WaitForSeconds(startDelay);
        //////////////// first starts making up the color assigned in image inspector//////////
        for (float i = startAlpha; i <= endAlpha; i += fadeAmount)
        {
            // set color with i as alpha
            // img.color = new Color(1, 0.5f, 0.5f, i);
            img = GetComponent<Image>();
            var tempColor = img.color;
            tempColor.a = i;
            img.color = tempColor;
            yield return new WaitForSeconds(waitTime);
        }

        StartCoroutine(FadeOutImage());
    }

    IEnumerator FadeOutImage()
    {

        ///////////////// fading out the color //////////////////////////////////
        for (float i = 1; i >= 0; i -= fadeAmount)
        {
            // set color with i as alpha
            // img.color = new Color(1, 0.5f, 0.5f, i);
            img = GetComponent<Image>();
            var tempColor = img.color;
            tempColor.a = i;
            img.color = tempColor;
            yield return new WaitForSeconds(waitTime);
        }
    }


    public void ShowEffect()
    {
        StartCoroutine(FadeInImage());
    }

}