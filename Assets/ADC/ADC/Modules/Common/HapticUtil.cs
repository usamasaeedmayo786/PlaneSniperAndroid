using UnityEngine;
using MoreMountains.NiceVibrations;

public static class HapticUtil
{

    /// <summary>
    /// Simple haptic fire
    /// </summary>
    /// <param name="haptic"></param>
    static public void Haptic(HapticTypes haptic = HapticTypes.Selection)
    {
        MMVibrationManager.Haptic(haptic);
    }

    static float lastLimitedHaptic = 0;

    /// <summary>
    /// Fires a haptic at a maximum frequency
    /// </summary>
    /// <param name="frequency"></param>
    /// <param name="haptic"></param>
    static public void LimitedHaptic(float frequency = 0.2f, HapticTypes haptic = HapticTypes.Selection)
    {
        if (Time.time - lastLimitedHaptic >= frequency)
        {
            lastLimitedHaptic = Time.time;
            MMVibrationManager.Haptic(haptic);
        }
    }

    /// <summary>
    /// Fires 6 haptics in quick succession over 1.5 seconds
    /// </summary>
    /// <param name="haptic"></param>
    static public void SuccessHaptic(HapticTypes haptic = HapticTypes.Success)
    {
        for (int i = 0; i < 6; i++)
        {
            CInvoker.InvokeDelayed(() => {
                MMVibrationManager.Haptic(haptic);
            }, i / 4f);
        }
    }


}
