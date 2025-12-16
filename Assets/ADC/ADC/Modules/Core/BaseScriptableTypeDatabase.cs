using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ADC.Core
{
    public class BaseScriptableTypeDatabase<T> : BaseScriptableDatabase<T> where T : BaseScriptableType
    {

        /* Not nececerily needed?
        new static public BaseScriptableTypeDatabase<T> instance
        {
            get
            {
                if (_instance == null) _instance = FindObjectOfType<BaseScriptableTypeDatabase<T>>(true);
                Debug.Assert(_instance != null, $"Could not find class of type '{typeof(T)}' - do you have one in the scene?");
                return _instance as BaseScriptableTypeDatabase<T>;
            }
        }
        */

        /// <summary>
        /// Fetches an original scriptable object from the database
        /// </summary>
        /// <returns>The scriptable object - be careful not to modify it, use CreateInstance for that</returns>
        static public T Get(string id)
        {
            return instance.list.Find(item => item.type == id);
        }

        /// <summary>
        /// Fetches and instantiates a scriptable, calls OnInstanceInitialized() on the instanced object
        /// </summary>
        /// <returns>An instance of the scriptable</returns>
        static public T CreateInstance(string id)
        {
            T o = Get(id);
            Debug.Assert(o != null, $"Could not instance scriptable '{id}' (not present in database)");
            o.OnInstanceInitialized();
            return o;
        }

        /// <summary>
        /// Fetches an original scriptable object from the database
        /// </summary>
        /// <returns>The scriptable object - be careful not to modify it, use CreateInstance for that</returns>
        public T _Get(string id)
        {
            return instance.list.Find(item => item.type == id);
        }

        /// <summary>
        /// Fetches and instantiates a scriptable
        /// </summary>
        /// <returns>An instance of the scriptable</returns>
        public T _CreateInstance(string id)
        {
            return Instantiate(instance.list.Find(item => item.type == id)) as T;
        }

    }

}