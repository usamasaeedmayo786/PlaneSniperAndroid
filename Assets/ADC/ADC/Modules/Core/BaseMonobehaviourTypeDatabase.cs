using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ADC.Core
{
    /// <summary>
    /// Base database for typed MonoBehaviours, contains a Get routine
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class BaseMonoBehaviourTypeDatabase<T> : BaseMonoBehaviourDatabase<T> where T : BaseMonoBehaviourType
    {

        /* Not nececerily needed?
        new static public BaseMonoBehaviourTypeDatabase<T> instance
        {
            get
            {
                if (_instance == null) _instance = FindObjectOfType<BaseMonoBehaviourTypeDatabase<T>>(true);
                Debug.Assert(_instance != null, $"Could not find class of type '{typeof(T)}' - do you have one in the scene?");
                return _instance as BaseMonoBehaviourTypeDatabase<T>;
            }
        }
        */

        /// <summary>
        /// Fetches an original Monobehaviour from the database
        /// </summary>
        /// <returns>The MonoBehaviour</returns>
        static public T Get(string id)
        {
            return instance.list.Find(item => item.type == id);
        }

    }

}