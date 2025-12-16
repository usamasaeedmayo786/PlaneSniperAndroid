using System.Collections.Generic;
using UnityEngine;
using NaughtyAttributes;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace ADC.Core
{

    /// <summary>
    /// Stores a list of ScriptableObjects
    /// </summary>
    /// <typeparam name="Scriptable"></typeparam>
    public abstract class BaseScriptableDatabase<Scriptable> : SafeInstancedMonoBehaviour<BaseScriptableDatabase<Scriptable>> where Scriptable : ScriptableObject
    {

        // Public fields

        [Header("Auto Fill Paths")]

        public List<string> autoFillPaths = new List<string>() { "Assets/" };

        [Header("Database")]
        [Expandable]
        public List<Scriptable> list = new List<Scriptable>();

        // Editor

#if UNITY_EDITOR

        protected virtual void AutoFill()
        {
            list.Clear();
            autoFillPaths.ForEach(RecursiveAddAssets);
        }

        protected void RecursiveAddAssets(string path)
        {
            Debug.Log($"Searching {path} for {typeof(Scriptable)}");

            string[] assets = AssetDatabase.FindAssets($"t:{typeof(Scriptable)}", new string[] { path });
            foreach (string asset in assets)
            {
                Scriptable obj = AssetDatabase.LoadMainAssetAtPath(AssetDatabase.GUIDToAssetPath(asset)) as Scriptable;

                if (obj != null)
                {
                    Debug.Log("Found " + obj.name);
                    list.Add(obj);
                }
            }

            EditorUtility.SetDirty(this);
        }
#endif

    }

}