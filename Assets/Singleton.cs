using UnityEngine;
using System.Linq;
using System;
public class Singleton<T> : MonoBehaviour where T : Singleton<T>
{

    private static T _instance;

    public static T Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = (T)FindObjectOfType(typeof(T));
                //DontDestroyOnLoad(_instance.gameObject);
            }

            //if (_instance == null)
            //{
            //    GameObject singleton = new GameObject();
            //    _instance = singleton.AddComponent<T>();
            //    singleton.name = "(Singleton) " + typeof(T).ToString();
            //    //DontDestroyOnLoad(singleton);
            //}

            return _instance;
        }
    }

    void Awake()
    {
        if (_instance != null&&_instance!=this)
        {
            Destroy(gameObject);
            return;
        }

        //DontDestroyOnLoad(gameObject);
        _instance = (T)this;
    }

}

 
    public static class MyExtensions
    {
        ///<summary>
        /// get a random array with no duplicates
        ///</summary>
        public static int[] uniqRandAry(int max, int length)
        {
            return Enumerable.Range(0, max).OrderBy(n => Guid.NewGuid()).Take(length).ToArray();
        }
   
}
