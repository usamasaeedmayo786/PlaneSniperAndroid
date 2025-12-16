using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Knife.Effects.SimpleController
{
    /// <summary>
    /// RPG Weapon component.
    /// </summary>
    public class RPG : Weapon
    {
        /// <summary>
        /// Projectile spawn point.
        /// </summary>
        [SerializeField] [Tooltip("Projectile spawn point")] private Transform projectileSpawnPoint;
        //[SerializeField] [Tooltip("Projectile spawn point")] private Transform projectileSpawnPoint2;

        /// <summary>
        /// Projectile prefab.
        /// </summary>
        [SerializeField] [Tooltip("Projectile prefab")] private GameObject projectilePrefab;
        //[SerializeField] [Tooltip("Projectile prefab")] private GameObject projectilePrefab2;

        /// <summary>
        /// Player root transform.
        /// </summary>
        [SerializeField] [Tooltip("Player root transform")] private GameObject playerRoot;

        private Collider[] playerColliders;
        public GameObject missile;
        public bool containsMissile = false;
        protected override void OnEnableHook()
        {
            playerColliders = playerRoot.GetComponents<Collider>();
        }

        protected override void Shot()
        {
            if (containsMissile == true)
            {
                missile.gameObject.SetActive(false);
            }
            gunLight.SetActive(true);
            AnalyticsManager.LockedGunInteractions(gameObject.name + "_" + GetComponent<GunID>().gunId.ToString());

            PlayFX();
            playSFX();

            handsAnimator.Play("Shot", 0, 0);
            var instance = Instantiate(projectilePrefab, projectileSpawnPoint.position, projectileSpawnPoint.rotation);
            //var instance2 = Instantiate(projectilePrefab2, projectileSpawnPoint2.position, projectileSpawnPoint2.rotation);

            var ignoreCollision = instance.GetComponent<ICollisionIgnore>();
            if (ignoreCollision != null)
            {
                foreach (var c in playerColliders)
                {
                    ignoreCollision.IgnoreCollision(c);
                }
            }
            Destroy(instance, 30);
            //Destroy(instance, 5);

            StartCoroutine(EnableTheMissile());
        }

        IEnumerator EnableTheMissile()
        {
            yield return new WaitForSeconds(1f);
            if (containsMissile ==true)
                missile.gameObject.SetActive(true);
        }
    }
}