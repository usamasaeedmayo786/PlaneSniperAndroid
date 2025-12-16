using UnityEngine;

/// <summary>
/// Provides a singleton pattern for ScriptableObjects - Loads them from a resources folder
/// Note that the file name of the scriptable MUST match its type
/// </summary>
/// <typeparam name="T"></typeparam>
public class SafeInstancedScriptableObject<T> : ScriptableObject where T : ScriptableObject
{
    static private T _instance;
    static public T instance
    {
        get
        {
            if (_instance == null) _instance = Resources.Load(typeof(T).Name, typeof(T)) as T;
            if (_instance == null)
            {
                Debug.LogError($"Cannot find any ScriptableObject named '{typeof(T)}' of type '{typeof(T)}' in a Resources folder");
            }
            return _instance;
        }
    }

}
