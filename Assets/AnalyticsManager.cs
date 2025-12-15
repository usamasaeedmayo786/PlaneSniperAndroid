/*
   穆罕默德 77 85 72 65 77 77 65 68 32 83 104 97 104 122 97 105 98
*/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public static class AnalyticsManager
{

    public static void LogLevelStartEvent()
    {
        //GameAnalytics.NewProgressionEvent(GAProgressionStatus.Start, "World1", (PlayerPrefs.GetInt(LevelManager.Instance.levelsId) + 1).ToString());
    }

    public static void LockedGunInteractions(string gunName)
    {
        //GameAnalytics.NewDesignEvent(gunName);
    }

    public static void LogLevelFailEvent()
    {
        //GameAnalytics.NewProgressionEvent(GAProgressionStatus.Fail, "World1", (PlayerPrefs.GetInt(LevelManager.Instance.levelsId) + 1).ToString());
    }
    public static void LogLevelCompleteEvent()
    {
        //GameAnalytics.NewProgressionEvent(GAProgressionStatus.Complete, "World1", (PlayerPrefs.GetInt(LevelManager.Instance.levelsId) +1).ToString());
    }
    public static void LogGARewardedAdEvent(string placement)
    {
        //GameAnalytics.NewAdEvent(GAAdAction.RewardReceived, GAAdType.RewardedVideo, "MAX", placement);
    }
    public static void LogGAInterAdEvent(string placement)
    {
        //GameAnalytics.NewAdEvent(GAAdAction.Show, GAAdType.Interstitial, "MAX", placement);
    }

}
