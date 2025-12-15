using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
public class DataAvailability : MonoBehaviour
{

    public GameObject notDataAvailablePanel;


    private void Start()
    {
        
    }
    private void Update()
    {
        //if (Application.internetReachability == NetworkReachability.NotReachable)
        //{
        //    if (Time.timeScale != 0)
        //    {
        //        Time.timeScale = 0f;
        //        notDataAvailablePanel.SetActive(true);
        //        Debug.Log(" NOT AVAILABLE DATA");
        //    }
        //}
    }

    public void CheckNetworkAvailibility()
    {
/*        if (Application.internetReachability == NetworkReachability.NotReachable)
        {
            notDataAvailablePanel.SetActive(true);
            Time.timeScale = 0f;
            Debug.Log(" NOT AVAILABLE DATA");
        }
        else if (Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork)
        {
            Debug.Log(" WIFI AVAILABLE DATA");
            notDataAvailablePanel.SetActive(false);
            Time.timeScale = 1f;
        }
        else if (Application.internetReachability == NetworkReachability.ReachableViaCarrierDataNetwork)
        {
            Debug.Log(" MOBILE AVAILABLE DATA");
            notDataAvailablePanel.SetActive(false);
            Time.timeScale = 1f;
        }*/
    }
}
