using UnityEngine;

/// <summary>
/// Provides an guarenteed 'instance' member which will create a copy of the class if it does not exist
/// </summary>
/// <typeparam name="T"></typeparam>
public class SafeInstancedManagerMonobehaviour<T> : MonoBehaviour where T : SafeInstancedManagerMonobehaviour<T>
{
	public static T instance
	{
		get
		{
			if (_instance == null)
			{
				T[] managers = Object.FindObjectsOfType(typeof(T)) as T[];
				if (managers.Length != 0)
				{
					if (managers.Length == 1)
					{
						_instance = managers[0];
						_instance.gameObject.name = typeof(T).Name;
						return _instance;
					}
					else
					{
						Debug.LogError("Class " + typeof(T).Name + " exists multiple times in violation of singleton pattern. Destroying all copies");
						foreach (T manager in managers)
						{
							Destroy(manager.gameObject);
						}
					}
				}
				var go = new GameObject(typeof(T).Name, typeof(T));
				_instance = go.GetComponent<T>();
				DontDestroyOnLoad(go);
			}
			return _instance;
		}
		set
		{
			_instance = value as T;
		}
	}
	private static T _instance;
}
