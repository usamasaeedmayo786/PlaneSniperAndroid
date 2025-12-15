using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyHealth : MonoBehaviour
{
    public int playerRemainingHealth;

    public bool CanBeDestroyed = false;

    public bool IsDestroyed;

    public void DamagePlayerHealth()
    {
        playerRemainingHealth -= 1;
        if(playerRemainingHealth<0)
        {
            CanBeDestroyed = true;
        }
    }
}
