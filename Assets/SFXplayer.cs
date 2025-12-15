using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SFXplayer : MonoBehaviour
{
    //public abstract
    public AudioSource shootSound; // Drag and drop your shoot sound in the inspector

    public int val;

    public void PlayReload()
    {
        StartCoroutine(PlayMultipleSounds(val));
        print("played");
    }

    private IEnumerator PlayMultipleSounds(int numSounds)
    {
        for (int i = 0; i < numSounds; i++)
        {
            shootSound.PlayOneShot(shootSound.clip);
            // Wait until the current sound finishes playing before playing the next one
            yield return new WaitForSeconds(.1f);
        }
    }
}

