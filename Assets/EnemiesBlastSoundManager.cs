using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemiesBlastSoundManager : MonoBehaviour
{
    public List<AudioClip> sounds;

    public AudioSource shootSound; // Drag and drop your shoot sound in the inspector

    public void PlayReload()
    {
        if (sounds.Count > 0)
        {
            // Get a random index within the range of the list
            int randomIndex = Random.Range(0, sounds.Count);
            AudioClip randomSound = sounds[randomIndex];

            // Assign the random sound to the shootSound AudioSource
            shootSound.clip = randomSound;

            // Play the sound
            shootSound.Play();
        }
        else
        {
            Debug.LogWarning("No sounds assigned to the list.");
        }
    }
}
