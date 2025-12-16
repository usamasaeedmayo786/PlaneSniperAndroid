#define USE_FACEBOOK_SDK
#define USE_BOOMBIT_SDK

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using System.Linq;
using ADC.Ads;
using CoreSdk = ADC.Core;
using ADCRemoteConfig;
using ADCAnalytics;

#if USE_FACEBOOK_SDK1
using Facebook.Unity;
#endif
#if USE_BOOMBIT_SDK1
using BoomBit.HyperCasual;
#endif
#if CORE_FIREBASE_SDK
//using Coredian.Firebase;
#endif


namespace ADC.Core
{
    /// <summary>
    /// Interface for SDK's
    /// </summary>
    public class SDKManager : MonoBehaviour
    {
        // Public
        public static SDKManager instance;
        public static bool isFirstPlay;
        public static bool reviewMode = false;

        [Header("ad settings")]
        public bool adsAvailableInEditor;
        public UICountdown adUITimer;

        // Properties
        static int timesPlayed
        {
            get { return PlayerPrefs.GetInt("TimesPlayed", 0); }
            set { PlayerPrefs.SetInt("TimesPlayed", value); }
        }

        public static int timeInGame
        {
            get { return PlayerPrefs.GetInt("_game_timeInGame", 0); }
            set { PlayerPrefs.SetInt("_game_timeInGame", value); }
        }

        // Unity
        private void Awake()
        {
            instance = this;


#if USE_BOOMBIT_SDK1
            HCSDK.StartHCSDK();
            AdManager.SetupPMEvents();
            StartGameTimer();
#endif
        }

        private void Start()
        {

            // FB
#if USE_FACEBOOK_SDK1
            FB.Init();
#endif

            RemoteConfigManager.Init();
            AdManager.Init();

            SetRemoteParameters();

#if USE_BOOMBIT_SDK1
            //banner
            if (HCSDK.InitializationComplete || Application.isEditor)
                StartCoroutine(AdManager.DelayedShowBanner(1.0f));
            else
                HCSDK.InitializationStartEvent += () => { StartCoroutine(AdManager.DelayedShowBanner(1.0f)); };
#endif


            if (timesPlayed == 0)
            {
                isFirstPlay = true;
                ADCAnalytics.AnalyticsManager.TrackEvent("First_Load");
                CInvoker.InvokeDelayed(() => isFirstPlay = false, 120);
            }

            timesPlayed++;

        }

        // Remote Parameters
        void SetRemoteParameters()
        {
            if (this == null) return;

            var data = RemoteConfigManager.GetParameter("REVIEW_MODE", "");

            if (!data.success)
            {
                CInvoker.InvokeDelayed(SetRemoteParameters, 1);
                return;
            }

            string reviewVersionString = data.config;
            if (reviewVersionString.Contains("."))
            {
                Version reviewVersion = new Version(reviewVersionString);
                reviewMode = new Version(Application.version) >= reviewVersion;
            }

            Debug.Log("Review mode: " + reviewVersionString);
        }

        // Game Timer
        private void StartGameTimer()
        {
            InvokeRepeating(nameof(CountGameTime), 1, 1);
        }

        private void CountGameTime()
        {
            timeInGame++;
            AdManager.timeFromLastInterstitial++;
        }

        // No Ads
        public static void BlockAdsAfterBuyingInapp()
        {
            AdManager.adsDisabled = true;
#if USE_BOOMBIT_SDK1
            AdManager.HideBanner();
#endif
        }
    }

}

namespace ADC.Ads
{
    /// <summary>
    /// a class that handles the fetching of RV's
    /// </summary>
    class RVFetch
    {
        public GameObject owner;
        public AdVariantReference adVariant;

        public void StartFetch(Action callback, Action onNullOwner)
        {
            // check that the owner still exists
            if (owner == null)
            {
                Debug.Log("owner is null");
                onNullOwner?.Invoke();
                return;
            }

            //Debug.Log("fetching RV");

            // if no rewarded is available try again each second until one is
            if (!AdManager.IsRewardedAvailable(adVariant))
                CInvoker.InvokeDelayed(() => StartFetch(callback, onNullOwner), 1);
            else
                callback?.Invoke();
        }
    }

    /// <summary>
    /// Interface for Ads
    /// </summary>
    public static class AdManager
    {
        private static Dictionary<string, bool> isPlacementShown = new Dictionary<string, bool>();

        public static int timeFromLastInterstitial
        {
            get { return PlayerPrefs.GetInt("ads.timeSinceLastInterstitial", 0); }
            set { PlayerPrefs.SetInt("ads.timeSinceLastInterstitial", value); }
        }

        public static int interstitialCount = 0;

        private static bool resetInterstitialInterval;
        private static bool resetInterstitialQueue;
        public static bool isWatchingAd = false;
        private static bool banerIsActive = false;

        private static Action videoStartedCallback;
        private static Action<bool> videoCallback;
        private static Action interstitialAdCallback;
        public static Action adStarted;
        public static Action adFinished;

        static List<RVFetch> activeRvFetches = new List<RVFetch>();

        // Properties
        public static bool adsDisabled
        {
            get { return PlayerPrefs.GetInt("adsDisabled", 0) == 1; }
            set { PlayerPrefs.SetInt("adsDisabled", value ? 1 : 0); }
        }

        public static void Init()
        {
            SetRemoteParameters();
        }

        static void SetRemoteParameters()
        {
            var resetIntIntervalData = RemoteConfigManager.GetParameter("RESET_INTERSTITIAL_INTERVAL", false);
            var resetIntQueueData = RemoteConfigManager.GetParameter("RV_RESET_INT_QUEUE", false);

            resetInterstitialInterval = resetIntIntervalData.config;
            resetInterstitialQueue = resetIntQueueData.config;

            // if either failed keep trying
            if (!resetIntIntervalData.success || !resetIntQueueData.success)
                CInvoker.InvokeDelayed(SetRemoteParameters, 1);
        }

        #region Rewarded
        /// <summary>
        /// show a Rewarded video with a AdvariantReference, callback returns true if the whole video was watched and false if the video was closed before finishing
        /// </summary>
        /// <param name="variant"></param>
        /// <param name="callback"></param>
        /// <param name="suffix"></param>
        /// <param name="videoStartCallback"></param>
        public static void ShowRewarded(AdVariantReference variant, Action<bool> callback, string suffix = "", Action videoStartCallback = null)
        {
            videoCallback = callback;
            videoStartedCallback = videoStartCallback;

            callback?.Invoke(false);
            videoStartCallback?.Invoke();
            return;


            if (!IsRewardedAvailable(variant))
            {
#if UNITY_EDITOR
                Debug.Log("Faked Rewarded Ad Watch: " + variant.type + suffix);
#endif
                callback?.Invoke(false);
                videoStartCallback?.Invoke();
                return;
            }
#if UNITY_EDITOR
            if (CoreSdk.SDKManager.instance.adsAvailableInEditor)
            {
                callback?.Invoke(true);
                return;
            }
#endif
#if USE_BOOMBIT_SDK1
            HCSDK.ShowRewarded(variant.type + suffix);
#endif
        }

        /// <summary>
        /// Check if a rewarded ad is ready to be displayed
        /// </summary>
        /// <param name="variant"></param>
        /// <param name="suffix"></param>
        /// <returns></returns>
        public static bool IsRewardedAvailable(AdVariantReference variant, string suffix = "")
        {
            if (CoreSdk.SDKManager.reviewMode)
                return false;
            if (!RemoteConfigManager.GetParameter("video_active", true).config)
                return false;
            if (RemoteConfigManager.GetParameter("rewarded_disabled_" + variant.type.ToLower(), false).config)
                return false;
            //if (SharedController.adsDisabled)
            //    return false;

#if UNITY_EDITOR
            return CoreSdk.SDKManager.instance.adsAvailableInEditor;
#endif

            bool isVideoAvailable = false;

#if USE_BOOMBIT_SDK1
            isVideoAvailable = HCSDK.IsRewardedReady(variant.type + suffix);
#endif
#if !UNITY_EDITOR
            if (RemoteConfigManager.GetParameter("check_no_fill", true).config)
            {
                if (RemoteConfigManager.GetParameter("check_no_fill_once_per_variant", false).config)
                {
                    if (isVideoAvailable && isPlacementShown.ContainsKey(variant.type) && isPlacementShown[variant.type])
                    {
                        isPlacementShown[variant.type] = false;
                    }
                    else if (!isVideoAvailable && (!isPlacementShown.ContainsKey(variant.type) || !isPlacementShown[variant.type]))
                    {
                        if (isPlacementShown.ContainsKey(variant.type))
                            isPlacementShown[variant.type] = true;
                        else
                            isPlacementShown.Add(variant.type, true);
#if USE_BOOMBIT_SDK1
                        HCSDK.TrackNoRewardedVideo(variant.type.ToLower());
#endif
                    }
                }
                else
                {
#if USE_BOOMBIT_SDK1
                    if (!isVideoAvailable)
                        HCSDK.TrackNoRewardedVideo(variant.type.ToLower());
#endif
                }
            }
#endif
#if USE_BOOMBIT_SDK1
            return isVideoAvailable;
#else
            return true;
#endif
        }

        /// <summary>
        /// Starts a fetch for an RV, The button is only available when an RV is
        /// </summary>
        /// <param name="button"></param>
        /// <param name="adVariant"></param>
        /// <param name="callback"></param>
        public static void FetchRV(GameObject owner, AdVariantReference adVariant, Action callback)
        {
            // Check if a fetch with this gameObject is already active
            if (activeRvFetches.Find((rvFetch) => rvFetch.owner == owner && rvFetch.adVariant == adVariant) != null) return;

            // Create a new fetch
            RVFetch fetch = new RVFetch
            {
                owner = owner,
                adVariant = adVariant,
            };

            // Add to the active fetches list
            activeRvFetches.Add(fetch);

            // Remove from the list when the rv has been fetched
            callback += () => CInvoker.InvokeDelayed(() => activeRvFetches.Remove(fetch));

            //Debug.Log("starting fetch");

            // Start the fetch loop
            fetch.StartFetch(callback, () => activeRvFetches.Remove(fetch));
        }

        #endregion

        #region Interstitials
        /// <summary>
        /// shows an intestitial with a AdvariantReference, callback is called when the ad is closed
        /// </summary>
        /// <param name="variant"></param>
        /// <param name="callback"></param>
        public static void ShowInterstitial(AdVariantReference variant, bool showCountdown = false, Action callback = null)
        {
            interstitialCount++;
            interstitialAdCallback = callback;

            if (!IsInterstitialAvailable(variant))
            {
#if UNITY_EDITOR
                ResetInterstitialTracking(true);
                Debug.Log("faked Interstitial ad");
#endif
                interstitialAdCallback?.Invoke();
                interstitialAdCallback = null;
                return;
            }


            if (showCountdown)
            {
                if (CoreSdk.SDKManager.instance.adUITimer == null)
                {
                    Debug.LogError("Tried to show UI Timer for ad but one has not been assigned to the SDKManager!");
                    return;
                }


                CoreSdk.SDKManager.instance.adUITimer.ShowCountdown(5, () =>
                {
                    Debug.Log("Interstitial Show");
#if USE_BOOMBIT_SDK1
                    HCSDK.ShowInterstitial(variant.type);
#endif
                });
            }
            else
            {
                Debug.Log("Interstitial Show");
#if USE_BOOMBIT_SDK1
                HCSDK.ShowInterstitial(variant.type);
#endif
            }

        }

        /// <summary>
        /// checks if an interstitial is ready to be displayed
        /// </summary>
        /// <param name="variant"></param>
        /// <param name="suffix"></param>
        /// <returns></returns>
        public static bool IsInterstitialAvailable(AdVariantReference variant, string suffix = "")
        {
            if (CoreSdk.SDKManager.reviewMode)
                return false;

            //// dont show ads for first 3 levels
            if (PlayerPrefs.GetInt("LevelNumber", 0) <= 0)
                return false;


            if (CoreSdk.SDKManager.instance.adUITimer != null
                && CoreSdk.SDKManager.instance.adUITimer.isShowing == false)
                return false;

            if (!RemoteConfigManager.GetParameter("INTERSTITIALS_ACTIVE", true).config)
                return false;

            if (RemoteConfigManager.GetParameter("interstitials_disabled_" + variant.type.ToLower(), false).config)
                return false;

            if (adsDisabled)
                return false;

            if (RemoteConfigManager.GetParameter("INTERSTITIAL_AD_INTERVAL_DEPENDENCY", 1).config == 1)
            {
                //AND - If either condition is not met, return false
                if ((timeFromLastInterstitial < RemoteConfigManager.GetParameter("INTERSTITIAL_AD_TIME_INTERVAL", 20).config) ||
                    (interstitialCount < RemoteConfigManager.GetParameter("INTERSTITIAL_AD_FREQUENCY_INTERVAL", 1).config))
                    return false;
            }
            else
            {
                //OR - return false if both conditions are unmet
                if ((timeFromLastInterstitial < RemoteConfigManager.GetParameter("INTERSTITIAL_AD_TIME_INTERVAL", 3600).config) &&
                    (interstitialCount < RemoteConfigManager.GetParameter("INTERSTITIAL_AD_FREQUENCY_INTERVAL", 2).config))
                    return false;
            }

#if UNITY_EDITOR
            return CoreSdk.SDKManager.instance.adsAvailableInEditor;
#endif
#if USE_BOOMBIT_SDK1
            return HCSDK.IsInterstitialReady(variant.type);
#else
            return true;
#endif
        }

        // Tracking
        public static void ResetInterstitialTracking(bool resetTime)
        {
            Debug.Log("Resetting Interstitial, time too? " + resetTime);
            if (resetTime) timeFromLastInterstitial = 0;
            interstitialCount = 0;
        }

        #endregion

        #region Banners

        public static void ShowBanner()
        {
            if (CoreSdk.SDKManager.reviewMode)
                return;

            if (banerIsActive)
                return;

            if (!RemoteConfigManager.GetParameter("BANNERS_ACTIVE", true).config)
                return;

            if (adsDisabled)
                return;

            banerIsActive = true;

#if UNITY_EDITOR
            Debug.Log("faked show banner");
#endif

#if USE_BOOMBIT_SDK1
            HCSDK.ShowBanner();
#endif
        }

        public static void HideBanner()
        {
            if (!banerIsActive)
                return;

#if UNITY_EDITOR
            Debug.Log("faked hide banner");
#endif
#if USE_BOOMBIT_SDK1
            HCSDK.HideBanner();
#endif
        }

        #endregion

        //PM Events
        static public void SetupPMEvents()
        {
/*#if USE_BOOMBIT_SDK
            HCSDK.VideoSuccessEvent += () =>
            {
                if (resetInterstitialInterval)
                    ResetInterstitialTracking(resetInterstitialQueue);

                if (videoCallback != null)
                {
                    videoCallback(true);
                    videoCallback = null;
                }

                adFinished?.Invoke();
                isWatchingAd = false;
            };

            HCSDK.VideoCancelEvent += () =>
            {
                if (videoCallback != null)
                {
                    videoCallback(false);
                    videoCallback = null;
                }

                adFinished?.Invoke();
                isWatchingAd = false;
            };

            HCSDK.VideoFailEvent += () =>
            {
                if (videoCallback != null)
                {
                    videoCallback(false);
                    videoCallback = null;
                }

                adFinished?.Invoke();
                isWatchingAd = false;
            };

            HCSDK.VideoDisplayEvent += () =>
            {
                if (videoStartedCallback != null)
                {
                    videoStartedCallback();
                    videoStartedCallback = null;
                }

                adStarted?.Invoke();
                isWatchingAd = true;
            };

            HCSDK.InterstitialDisplayEvent += () =>
            {
                adStarted?.Invoke();
                isWatchingAd = true;
            };

            HCSDK.InterstitialCloseEvent += () =>
            {
                adFinished?.Invoke();
                isWatchingAd = false;
                ResetInterstitialTracking(true);
                interstitialAdCallback?.Invoke();
                interstitialAdCallback = null;
            };

            HCSDK.InterstitialFailEvent += () =>
            {
                adFinished?.Invoke();
                isWatchingAd = false;
                interstitialAdCallback?.Invoke();
                interstitialAdCallback = null;
            };
#endif*/
        }

        // Banner Delay
        public static IEnumerator DelayedShowBanner(float waitTime)
        {
            yield return new WaitForSeconds(waitTime);
            if (RemoteConfigManager.IsRemoteConfigReady())
                ShowBanner();
            else
                RemoteConfigManager.onRemoteConfigFetched += ShowBanner;
        }
    }
}

// cant use .RemoteConfig due to the HCSDK Core class conflicting with Core namespace
namespace ADCRemoteConfig
{
    /// <summary>
    /// Interface for Firebase Remote Config
    /// </summary>
    public static class RemoteConfigManager
    {
        private static bool isFirebaseRemoteConfigReady = false;
        public static event Action onRemoteConfigFetched;

        static public void Init()
        {

//#if USE_BOOMBIT_SDK && CORE_FIREBASE_SDK

//            if (Core.GetService<IFirebaseRemoteConfigService>().IsRemoteConfigInitialized)
//                RemoteConfigFetched();
//            else
//                Core.GetService<IFirebaseRemoteConfigService>().FirebaseRemoteConfigInitializedSuccessful += RemoteConfigFetched;
//#endif

//#if !USE_BOOMBIT_SDK
//            RemoteConfigFetched();
//#endif
        }

        private static void RemoteConfigFetched()
        {
            isFirebaseRemoteConfigReady = true;

            if (onRemoteConfigFetched != null)
                onRemoteConfigFetched?.Invoke();
        }

        public static bool IsRemoteConfigReady()
        {
#if USE_BOOMBIT_SDK && CORE_FIREBASE_SDK && !UNITY_EDITOR
            if (!isFirebaseRemoteConfigReady || !Core.GetService<IFirebaseRemoteConfigService>().IsRemoteConfigInitialized)
                return false;
#endif
            return true;
        }

        // Parameters
        public static (bool success, string config) GetParameter(string key, string defaultValue)
        {
            string _value = defaultValue;
            var data = GetRemoteParameter(key);
            _value = data.config;
            if (string.IsNullOrEmpty(_value)) _value = defaultValue;
            bool success = data.success;
            return (success, _value);
        }

        public static (bool success, float config) GetParameter(string key, float defaultValue)
        {
            float _value = defaultValue;
            var data = GetRemoteParameter(key);
            if (!float.TryParse(data.config, out _value)) _value = defaultValue;
            bool success = data.success;
            return (success, _value);
        }

        public static (bool success, int config) GetParameter(string key, int defaultValue)
        {
            int _value = defaultValue;
            var data = GetRemoteParameter(key);
            if (!int.TryParse(data.config, out _value)) _value = defaultValue;
            bool success = data.success;
            return (success, _value);
        }

        public static (bool success, bool config) GetParameter(string key, bool defaultValue)
        {
            bool _value = defaultValue;
            var data = GetRemoteParameter(key);
            if (!bool.TryParse(data.config, out _value)) _value = defaultValue;
            bool success = data.success;
            return (success, _value);
        }

        private static (bool success, string config) GetRemoteParameter(string key)
        {

            var value = "";

//#if CORE_FIREBASE_SDK && USE_BOOMBIT_SDK
//            if (!isFirebaseRemoteConfigReady || !Core.GetService<IFirebaseRemoteConfigService>().IsRemoteConfigInitialized)
//                return (false, "");

//            if (!Core.GetService<IFirebaseRemoteConfigService>().RemoteConfig.TryGetValue(key, out value))
//                return (false, value);

//#endif
            return (true, value);
        }

//#if USE_BOOMBIT_SDK && CORE_FIREBASE_SDK
//        public static void RemoveFetchedCallback()
//        {
//            Core.GetService<IFirebaseRemoteConfigService>().FirebaseRemoteConfigInitializedSuccessful -= RemoteConfigFetched;
//        }
//#endif
    }
}

// cant use .Analytics due to the HCSDK Core class conflicting with Core namespace
namespace ADCAnalytics
{
    /// <summary>
    /// Interface for Firebase event logging
    /// </summary>
    public static class AnalyticsManager
    {
        static public void TrackEvent(string evt, Dictionary<string, object> data = null)
        {

            // Firebase Log
#if USE_BOOMBIT_SDK1
#if CORE_FIREBASE_SDK
            if (data == null)
                Core.GetService<IFirebaseService>().LogEvent(evt);
            else
                Core.GetService<IFirebaseService>().LogEvent(evt, data);
#else

            Debug.LogError("Firebase modules not installed, please see core documentation required modules");
#endif
#endif

            // Facebook Log
#if USE_FACEBOOK_SDK1

            if (data == null)
                if (FB.IsInitialized) FB.LogAppEvent(evt);
                else
                if (FB.IsInitialized) FB.LogAppEvent(evt, parameters: data);
#endif
        }
    }
}
