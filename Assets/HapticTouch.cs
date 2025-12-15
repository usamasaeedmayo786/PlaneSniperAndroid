/*
	Download niceVibrations
	 穆罕默德 77 85 72 65 77 77 65 68 32 83 104 97 104 122 97 105 98
*/

using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using MoreMountains.NiceVibrations;

public class HapticTouch : MonoBehaviour
{

    public static HapticTouch instance;

    private void Awake()
    {
        instance = this;
    }

    public static void SimpleVibrate()
    {
        //	Handheld.Vibrate();
        MMVibrationManager.Vibrate();

    }

    //////// this method plays haptic sound of rigid (we are using this for hitting obstacles)////

    public static void RigidVibration()
    {
        MMVibrationManager.Haptic(HapticTypes.MediumImpact);
    }

    //////// this method plays haptic sound of light (we are using this for boost)////

    public static void LightVibration()
    {
        MMVibrationManager.Haptic(HapticTypes.LightImpact);
    }

    //////// this method plays haptic sound of success (we are using this for win i.e level up)////

    public static void WinVibration()
    {
        MMVibrationManager.Haptic(HapticTypes.Success);
    }

    //////// this method plays haptic sound of failure (we are using this for loss i.e level restart)////

    public static void FailVibration()
    {
        MMVibrationManager.Haptic(HapticTypes.Failure);
    }

    //////// this method plays continuous haptic (we are using this when holding and kept on holding something)////
    public void ContinuousVibration()
    {
     //   MMVibrationManager.ContinuousHaptic(0.3f, 0.8f, Mathf.Infinity, HapticTypes.LightImpact, this,true);
    }

    //////// this method stops continuous haptic ////
    public static void StopContinuousVibration()
    {
 //       MMVibrationManager.S
//        MMVibrationManager.StopContinuousHaptic();
       // MMVibrationManager.StopAllHaptics();
    }

}