using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlansAssigner : MonoBehaviour
{
    [SerializeField] List<GameObject> planes;


    public bool isPlayerBase = false;
    private void Start()
    {
        if (isPlayerBase)
        {
            foreach (var item in planes)
            {
                LevelManager.Instance.currentLevel.PlayerBaseList.Add(item);
            }
        }
        else
        {
            // Shuffle the planes list
            Shuffle(planes);

            // Take first 4 planes from the shuffled list and add them to EnemyAeroplanesList
            for (int i = 0; i < LevelManager.Instance.currentLevel.totalTargets && i < planes.Count; i++)
            {
                
                LevelManager.Instance.currentLevel.EnemyAeroplanesList.Add(planes[i]);
                planes[i].SetActive(true);
            }
        }
    }

    // Function to shuffle a list
    private void Shuffle<T>(List<T> list)
    {
        for (int i = 0; i < list.Count; i++)
        {
            int randomIndex = Random.Range(i, list.Count);
            T temp = list[randomIndex];
            list[randomIndex] = list[i];
            list[i] = temp;
        }
    }
}
