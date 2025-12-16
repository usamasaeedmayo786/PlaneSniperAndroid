using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RVRPG : MonoBehaviour
{
    [SerializeField] WeaponBase weapon;

    private void Start()
    {
        //EventController.OnRPGRVActivate += OnDronActivate;
        //gameObject.SetInactive();
    }

    private void OnDestroy()
    {
        //EventController.OnRPGRVActivate -= OnDronActivate;

    }

    private void OnDronActivate()
    {
        //gameObject.SetActive();
    }

    private void OnEnable()
    {
        //weapon.StartFire();
    }

    private void OnDisable()
    {
        //weapon.StopFire();
    }
}