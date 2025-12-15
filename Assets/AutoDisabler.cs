using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoDisabler : MonoBehaviour
{
    // Start is called before the first frame update
    public float value = 3f;
    void Start()
    {
        Invoke("AutoDisable", value);
    }

    public void AutoDisable()
    {
        gameObject.SetActive(false);
    }

    private void OnEnable()
    {
        Invoke("AutoDisable", value);
    }
}
