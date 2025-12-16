using UnityEngine;
using System;
using SimpleJSON;

/// <summary>
/// Basic implementation of a key/value collection store using playerprefs. Supports C# value types & serializable classes (via JSON)
/// You should be able to override this class and write your own implementations using sqlite, mongo, etc
/// </summary>
public class Database : SafeInstancedManagerMonobehaviour<Database>
{

    // Static Interface

    static public T Read<T>(string store, string key, string defaultValue = "") { return instance._Read<T>(store, key, defaultValue); }
    static public void ReadAsync<T>(string store, string key, Action<bool, T> callback, string defaultValue = "") { instance._ReadAsync<T>(store, key, callback, defaultValue); }
    static public void Write<T>(string store, string key, T value) { instance._Write<T>(store, key, value); }
    static public void WriteAsync<T>(string store, string key, T value, Action<bool, string> callback = null) { instance._WriteAsync<T>(store, key, value, callback); }

    // Internal

    protected virtual void _ReadAsync<T>(string store, string key, Action<bool, T> callback, string defaultValue = "")
    {
        T val = _Read<T>(store, key, defaultValue);
        callback?.Invoke(true, val);
    }

    protected virtual T _Read<T>(string store, string key, string defaultValue = "")
    {
        string value = PlayerPrefs.GetString($"{store}.{key}", defaultValue);
        if (string.IsNullOrEmpty(value)) return default(T);

        if (typeof(T) == typeof(JSONNode) || typeof(T) == typeof(JSONObject) || typeof(T) == typeof(JSONArray))
        {
            return (T)(object)JSON.Parse(value);
        }
        else if (!typeof(T).IsValueType && typeof(T) != typeof(string))
        {
            return JsonUtility.FromJson<T>(value);
        }
        else
        {
            return (T)Convert.ChangeType(value, typeof(T));
        }
    }

    protected virtual void _WriteAsync<T>(string store, string key, T value, Action<bool, string> callback)
    {
        _Write<T>(store, key, value);
        callback?.Invoke(true, "success");
    }

    protected virtual void _Write<T>(string store, string key, T value)
    {
        if (typeof(T) == typeof(JSONNode) || typeof(T) == typeof(JSONObject) || typeof(T) == typeof(JSONArray))
        {
            PlayerPrefs.SetString($"{store}.{key}", value.ToString());
        }
        else if (!typeof(T).IsValueType && typeof(T) != typeof(string))
        {
            PlayerPrefs.SetString($"{store}.{key}", JsonUtility.ToJson(value));
        }
        else
        {
            PlayerPrefs.SetString($"{store}.{key}", Convert.ToString(value));
        }
    }

    // Unity

    [System.Serializable]
    class TestObject
    {
        public int test = 100;
    }

    [ContextMenu("Test")]
    protected virtual void Test()
    {
        // Non-async patterns are no longer supported to encourage proper database useage
        /*
        Database.Write("test", "stringValue", "100");
        Database.Write("test", "intValue", 100);
        Database.Write("test", "floatValue", 100f);
        Database.Write("test", "doubleValue", 100d);
        Database.Write("test", "typeValue", new TestObject());

        Debug.Log($"stringValue as string = {Database.Read<string>("test", "stringValue")}");
        Debug.Log($"stringValue as int = {Database.Read<int>("test", "stringValue")}");
        Debug.Log($"stringValue as float = {Database.Read<float>("test", "stringValue")}");
        Debug.Log($"stringValue as double = {Database.Read<double>("test", "stringValue")}");

        Debug.Log($"intValue as string = {Database.Read<string>("test", "intValue")}");
        Debug.Log($"intValue as int = {Database.Read<int>("test", "intValue")}");
        Debug.Log($"intValue as float = {Database.Read<float>("test", "intValue")}");
        Debug.Log($"intValue as double = {Database.Read<double>("test", "intValue")}");

        Debug.Log($"floatValue as string = {Database.Read<string>("test", "floatValue")}");
        Debug.Log($"floatValue as int = {Database.Read<int>("test", "floatValue")}");
        Debug.Log($"floatValue as float = {Database.Read<float>("test", "floatValue")}");
        Debug.Log($"floatValue as double = {Database.Read<double>("test", "floatValue")}");

        Debug.Log($"doubleValue as string = {Database.Read<string>("test", "doubleValue")}");
        Debug.Log($"doubleValue as int = {Database.Read<int>("test", "doubleValue")}");
        Debug.Log($"doubleValue as float = {Database.Read<float>("test", "doubleValue")}");
        Debug.Log($"doubleValue as double = {Database.Read<double>("test", "doubleValue")}");

        Debug.Log($"typeValue = {Database.Read<TestObject>("test", "typeValue").test}");

        Debug.Log($"missing value as string = {Database.Read<string>("test", "missing value")}");
        Debug.Log($"missing value as int = {Database.Read<int>("test", "missing value")}");
        Debug.Log($"missing value as float = {Database.Read<float>("test", "missing value")}");
        Debug.Log($"missing value as double = {Database.Read<double>("test", "missing value")}");
        */

        Database.WriteAsync("atest", "stringValue", "100",
        (success, error) =>
        {
            Database.ReadAsync<string>("atest", "stringValue", (success, value) => Debug.Log($"ASYNC stringValue as string = {value}"));
            Database.ReadAsync<int>("atest", "stringValue", (success, value) => Debug.Log($"ASYNC stringValue as int = {value}"));
            Database.ReadAsync<float>("atest", "stringValue", (success, value) => Debug.Log($"ASYNC stringValue as float = {value}"));
            Database.ReadAsync<double>("atest", "stringValue", (success, value) => Debug.Log($"ASYNC stringValue as double = {value}"));
        });
        Database.WriteAsync("atest", "intValue", 100,
        (success, error) =>
        {
            Database.ReadAsync<string>("atest", "intValue", (success, value) => Debug.Log($"ASYNC intValue as string = {value}"));
            Database.ReadAsync<int>("atest", "intValue", (success, value) => Debug.Log($"ASYNC intValue as int = {value}"));
            Database.ReadAsync<float>("atest", "intValue", (success, value) => Debug.Log($"ASYNC intValue as float = {value}"));
            Database.ReadAsync<double>("atest", "intValue", (success, value) => Debug.Log($"ASYNC intValue as double = {value}"));
        });
        Database.WriteAsync("atest", "floatValue", 100f,
        (success, error) =>
        {
            Database.ReadAsync<string>("atest", "floatValue", (success, value) => Debug.Log($"ASYNC floatValue as string = {value}"));
            Database.ReadAsync<int>("atest", "floatValue", (success, value) => Debug.Log($"ASYNC floatValue as int = {value}"));
            Database.ReadAsync<float>("atest", "floatValue", (success, value) => Debug.Log($"ASYNC floatValue as float = {value}"));
            Database.ReadAsync<double>("atest", "floatValue", (success, value) => Debug.Log($"ASYNC floatValue as double = {value}"));
        });
        Database.WriteAsync("atest", "doubleValue", 100d,
        (success, error) =>
        {
            Database.ReadAsync<string>("atest", "doubleValue", (success, value) => Debug.Log($"ASYNC doubleValue as string = {value}"));
            Database.ReadAsync<int>("atest", "doubleValue", (success, value) => Debug.Log($"ASYNC doubleValue as int = {value}"));
            Database.ReadAsync<float>("atest", "doubleValue", (success, value) => Debug.Log($"ASYNC doubleValue as float = {value}"));
            Database.ReadAsync<double>("atest", "doubleValue", (success, value) => Debug.Log($"ASYNC doubleValue as double = {value}"));
        });
        Database.WriteAsync("atest", "typeValue", new TestObject(),
        (success, error) =>
        {
            Database.ReadAsync<TestObject>("atest", "typeValue", (success, value) => Debug.Log($"ASYNC typeValue as string = {value.test}"));
        });

        JSONObject jsonNode = new JSONObject();
        jsonNode.Add("hello", "world");
        Database.WriteAsync("atest", "jsonValue", jsonNode,
        (success, error) =>
        {
            Database.ReadAsync<JSONNode>("atest", "jsonValue", (success, value) => Debug.Log($"ASYNC jsonValue as string = {value["hello"].Value}"));
        });

        Database.ReadAsync<string>("atest", "missing value", (success, value) => Debug.Log($"ASYNC missing value as string = {value}"));
        Database.ReadAsync<int>("atest", "missing value", (success, value) => Debug.Log($"ASYNC missing value as int = {value}"));
        Database.ReadAsync<float>("atest", "missing value", (success, value) => Debug.Log($"ASYNC missing value as float = {value}"));
        Database.ReadAsync<double>("atest", "missing value", (success, value) => Debug.Log($"ASYNC missing value as double = {value}"));



    }

}

