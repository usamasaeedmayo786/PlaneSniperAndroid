using System.Collections.Generic;
using UnityEngine;
using TMPro;
using NaughtyAttributes;

namespace ADC.Core
{

    /// <summary>
    /// Interface for making FX
    /// </summary>
    public abstract class BaseFXManager : SafeInstancedMonoBehaviour<BaseFXManager>
    {
        // Data

        public enum CreationMode
        {
            /// <summary>
            /// Instantiates the object
            /// </summary>
            INSTANTIATE,
            /// <summary>
            /// Instantiates the object using an ObjectPool
            /// </summary>
            INSTANTIATE_POOLED,
            /// <summary>
            /// Caches the effect and moves it around, calling Play()
            /// </summary>
            CACHE_AND_PLAY,
            /// <summary>
            /// Caches the effect and moves it around, calling Emit(). Emission amounts are determined by emission burst settings
            /// </summary>
            CACHE_AND_EMIT
        }

        /// <summary>
        /// Provides common base functionality for FX
        /// </summary>
        [System.Serializable]
        public abstract class BaseFX
        {
            public GameObject prefab;
            public CreationMode creationMode = CreationMode.INSTANTIATE;
            [AllowNesting]
            [ShowIf("creationMode", CreationMode.INSTANTIATE_POOLED)]
            public int poolSize = 32;

            // Internal

            protected bool isInitialized = false;
            protected ParticleSystem rootParticles;
            protected List<ParticleSystem> cachedParticles = new List<ParticleSystem>();
            protected List<int> cachedParticleEmissionAmounts = new List<int>();

            // Public Interface

            /// <summary>
            /// Initialize the FX
            /// </summary>
            public virtual void Initialize()
            {
                if (prefab == null)
                {
                    Debug.LogError($"WARNING: An FXManager effect was not initialized due to having no prefab set");
                    return;
                }

                // Always cache the prefab to ensure FX are preloaded and that we don't edit the original asset
                prefab = Instantiate(prefab, instance.transform);

                // Find particles
                rootParticles = prefab.GetComponent<ParticleSystem>();
                // Cache child particles
                cachedParticles.AddRange(prefab.GetComponentsInChildren<ParticleSystem>());

                // Inactive by default
                prefab.SetActive(false);

                // CACHED PARTICLES TYPES
                if (creationMode == CreationMode.CACHE_AND_PLAY || creationMode == CreationMode.CACHE_AND_EMIT)
                {
                    Debug.Assert(rootParticles != null, $"WARNING: No Particles were found on {prefab.name} when creationMode={creationMode} (which requires particles)");

                    // Ensure correct settings
                    cachedParticles.ForEach(cp => { 

                        var main = cp.main;
                        main.playOnAwake = false;
                        main.loop = false;
                        main.stopAction = ParticleSystemStopAction.None;
                        main.simulationSpace = ParticleSystemSimulationSpace.World;
                    });
                    // Try to find how many particles are bursted and cache them, for use with _EMIT
                    cachedParticles.ForEach(ps =>
                    {
                        var emission = ps.emission;
                        ParticleSystem.Burst[] bursts = new ParticleSystem.Burst[emission.burstCount];
                        emission.GetBursts(bursts);
                        cachedParticleEmissionAmounts.Add(bursts.Length > 0 ? bursts[0].maxCount : 0);
                    });

                    // Active by default
                    prefab.SetActive(true);

                }
                // INSTANTIATE type
                else
                {
                    // Check if its a particle effect and try to fix it if its stop action is bad
                    rootParticles = prefab.GetComponent<ParticleSystem>();
                    if (rootParticles != null)
                    {
                        // Ensure children play corectly
                        cachedParticles.ForEach(cp => {

                            var main = cp.main;
                            main.playOnAwake = false;
                            main.stopAction = ParticleSystemStopAction.None;
                        });

                        // Make sure the main module stops correctly
                        var main = rootParticles.main;
                        main.playOnAwake = true;
                        if (main.stopAction == ParticleSystemStopAction.None || main.stopAction == ParticleSystemStopAction.Disable)
                        {
                            //Debug.LogWarning($"WARNING: The effect {prefab.name}'s particles did not have a stop action and would have leaked into the scene - fixed at runtime");
                            main.stopAction = ParticleSystemStopAction.Destroy;
                        }
                    }

                    // Pooled objects
                    if (creationMode == CreationMode.INSTANTIATE_POOLED)
                    {
                        // If it is a pooled effect, check the stop action is a callback type - if not, try to fix it
                        if (rootParticles != null)
                        {
                            var main = rootParticles.main;
                            if (main.stopAction != ParticleSystemStopAction.Callback)
                            {
                                Debug.LogWarning($"WARNING: The effect {prefab.name}'s particles did not have a stop callback and would not have worked with ObjectPool - fixed at runtime");
                                main.stopAction = ParticleSystemStopAction.Callback;
                                ParticlePoolRelease ppr = prefab.GetComponent<ParticlePoolRelease>();
                                if (ppr == null) prefab.AddComponent<ParticlePoolRelease>();
                            }
                        }

                        //PoolManager.WarmPool(prefab, poolSize, instance.transform);
                    }
                }

                isInitialized = true;
            }

            /// <summary>
            /// Plays the FX
            /// </summary>
            public virtual GameObject Play(Vector3 position)
            {
                if (!isInitialized)
                {
                    Debug.LogError($"The effect {(prefab == null ? "(NULL)" : prefab.name)} was not initialized! Remember to call Initialize() on your custom FX");
                    return null;
                }

                GameObject spawnedObject = null;

                if (creationMode == CreationMode.INSTANTIATE)
                {
                    spawnedObject = Instantiate(prefab);
                    spawnedObject.transform.position = position;
                    spawnedObject.SetActive(true);
                }
                else if (creationMode == CreationMode.INSTANTIATE_POOLED)
                {
                    //spawnedObject = PoolManager.SpawnObject(prefab, position, Quaternion.identity);
                }
                else if (creationMode == CreationMode.CACHE_AND_PLAY)
                {
                    prefab.transform.position = position;
                    rootParticles.Play(true);
                }
                else if (creationMode == CreationMode.CACHE_AND_EMIT)
                {
                    prefab.transform.position = position;
                    for (int i=0; i<cachedParticles.Count; i++)
                    {
                        cachedParticles[i].Emit(cachedParticleEmissionAmounts[i]);
                    }
                }

                return spawnedObject;
            }
        }

        /// <summary>
        /// Basic class for spawning particles at a position
        /// </summary>
        [System.Serializable]
        public class PositionEffect : BaseFX { }

        // Internal

        protected override void Awake()
        {
            base.Awake();

            // Initialzie your FX in Awake
            hitParticle.Initialize();
            collectStartEffect.Initialize();
            collectEndEffect.Initialize();
            floatingText.Initialize();
            weaponTracer.Initialize();
            meleeHitParticle.Initialize();
            bloodHitParticle.Initialize();
        }

        // Static Interface - FX GO HERE!

        // Make Hit Particle Effect

        public PositionEffect hitParticle;

        static public void MakeHitParticle(Vector3 pos)
        {
            instance.hitParticle.Play(pos);
        }

        // Make Collect Start Effect

        public PositionEffect collectStartEffect;

        static public void MakeCollectStartEffect(Vector3 pos)
        {
            instance.collectStartEffect.Play(pos);
        }

        // Make Collect End Effect

        public PositionEffect collectEndEffect;

        static public void MakeCollectEndEffect(Vector3 pos)
        {
            instance.collectEndEffect.Play(pos);
        }

        // Make Floating Text

        public PositionEffect floatingText;

        static public void MakeFloatingText(Vector3 pos, string text, Color color)
        {
            GameObject obj = instance.floatingText.Play(pos);

            TextMeshProUGUI tm = obj.GetComponentInChildren<TextMeshProUGUI>();
            tm.text = text;
            tm.color = color;
        }

        // Make Floating Money Text

        static public void MakeFloatingText(Vector3 pos, CurrencyReference currency, double amount)
        {
            MakeFloatingText(pos, currency.Format(amount), currency.data.textColor);
        }

        // Make Weapon Tracer

        public PositionEffect weaponTracer;

        static public void MakeWeaponTracer(Vector3 pos, Vector3 direction, Color color)
        {
            GameObject obj = instance.weaponTracer.Play(pos);

            LineRenderer line = obj.GetComponent<LineRenderer>();
            line.material.color = color;
            line.SetPosition(0, pos);
            line.SetPosition(1, pos + direction.normalized * 100);
        }

        // Make Melee Hit Particle

        public PositionEffect meleeHitParticle;

        static public void MakeMeleeHitParticle(Vector3 pos)
        {
            instance.meleeHitParticle.Play(pos);
        }

        // Make Blood Hit Particle

        public PositionEffect bloodHitParticle;

        static public void MakeBloodHitParticle(Vector3 pos)
        {
            instance.bloodHitParticle.Play(pos);
        }

        // Make Currency Transfer Effect

        /// <summary>
        /// Animates a currency transfer
        /// </summary>
        static public void MakeCurrencyTransfer(CurrencyReference currency, double amount, Transform fromPos, Transform toPos, bool playHaptics = true, System.Action callback = null, System.Action perItemCallback = null, TransferAnimation.PerItemCallbackTiming perItemCallbackTiming = TransferAnimation.PerItemCallbackTiming.ON_FINISH, bool render = true)
        {
            Mesh mesh = currency.data.worldModel.GetComponentInChildren<MeshFilter>().sharedMesh; // TODO: would be nice to cache this
            Material[] materials = currency.data.worldModel.GetComponentInChildren<Renderer>().sharedMaterials;
            Vector3 localScale = TransferAnimation.FindMeshScale(mesh, 0.5f) * currency.data.worldModelScale;

            TransferAnimation.CreateAnimation(mesh, materials, new TransferAnimation.PositionRotationScale(currency.data.worldModelPosition, Quaternion.Euler(currency.data.worldModelRotation), localScale), amount, fromPos, toPos, playHaptics, callback, perItemCallback, perItemCallbackTiming, render);
        }

        // Make Resource Transfer Effect

        /// <summary>
        /// Animates a Resource Transfer
        /// </summary>
        //static public void MakeResourceTransfer(ResourceReference resource, double amount, Transform fromPos, Transform toPos, bool playHaptics, System.Action callback = null, System.Action perItemCallback = null, TransferAnimation.PerItemCallbackTiming perItemCallbackTiming = TransferAnimation.PerItemCallbackTiming.ON_FINISH, bool render = true)
        //{
        //    Mesh mesh = resource.data.backpackModel.GetComponentInChildren<MeshFilter>().sharedMesh; // TODO: would be nice to cache this
        //    Material[] materials = resource.data.backpackModel.GetComponentInChildren<Renderer>().sharedMaterials;
        //    Vector3 localScale = TransferAnimation.FindMeshScale(mesh, 0.35f) * resource.data.backpackModelScale;

        //    TransferAnimation.CreateAnimation(mesh, materials, new TransferAnimation.PositionRotationScale(resource.data.backpackModelOffset, Quaternion.Euler(resource.data.backpackModelRotation), localScale), amount, fromPos, toPos, playHaptics, callback, perItemCallback, perItemCallbackTiming, render);
        //}

    }

}