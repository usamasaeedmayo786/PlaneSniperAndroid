using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace ADC.Core
{

    /// <summary>
    /// Stores a list of MonoBehaviour
    /// </summary>
    /// <typeparam name="Scriptable"></typeparam>
    public abstract class BaseMonoBehaviourDatabase<Scriptable> : SafeInstancedMonoBehaviour<BaseMonoBehaviourDatabase<Scriptable>> where Scriptable : MonoBehaviour
    {

        // Public fields

        [Header("Database")]
        public List<Scriptable> list = new List<Scriptable>();

        // Editor

#if UNITY_EDITOR

        protected virtual void AutoFill()
        {
            list.Clear();
            list.AddRange(GetComponentsInChildren<Scriptable>());
        }

        protected virtual void AddNew()
        {
            GameObject obj = new GameObject("New Item");
            obj.transform.SetParent(transform, false);
            obj.AddComponent<Scriptable>();

            AutoFill();
        }

#endif

    }

}