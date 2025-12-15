using UnityEngine;
using UnityEngine.EventSystems;
using System.Collections;

namespace EpicToonFX
{
    public class MissileMovement : MonoBehaviour
    {
        public bool shoulDestroy = false;
        public ParticleSystem gasExplosion;



        private void Start()
        {
            if(shoulDestroy)
            {
                Destroy(gameObject, 4);
            }
        }
        private void OnCollisionEnter(Collision collision)
        {

            GameObject projectile = Instantiate(gasExplosion.gameObject, transform.position, Quaternion.identity); //Spawns the selected projectile

            Destroy(gameObject);
        }
    }
}