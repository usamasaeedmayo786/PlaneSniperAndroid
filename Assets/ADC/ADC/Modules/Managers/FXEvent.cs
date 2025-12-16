using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Serves as a relay to the FXManager for easy addition of events via UnityEvents 
/// </summary>
public class FXEvent : MonoBehaviour
{

    public void MakeHitParticle(Vector3 position)
    {
        //FXManager.MakeHitParticle(position);
    }

    public void MakeCollectStartEffect(Vector3 position)
    {
        //FXManager.MakeCollectStartEffect(position);
    }

    public void MakeCollectEndEffect(Vector3 position)
    {
        //FXManager.MakeCollectEndEffect(position);
    }

}
