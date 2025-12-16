using UnityEngine;

/// <summary>
/// Provides a static 'instance' variable to a MonoBehaviour which is safe to call on Awake
/// </summary>
/// <typeparam name="T"></typeparam>
public class SafeInstancedMonoBehaviour<T> : MonoBehaviour where T: MonoBehaviour
{

    static protected T _instance;
    static public T instance
    {
        get
        {
            if (_instance == null) _instance = FindObjectOfType<T>(true);
            Debug.Assert(_instance != null, $"Could not find class of type '{typeof(T)}' - do you have one in the scene?");
            return _instance;
        }
    }

    protected virtual void Awake()
    {
        _instance = this as T;
    }

}
