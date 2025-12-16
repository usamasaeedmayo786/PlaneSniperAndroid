
using UnityEngine;
using UnityEngine.EventSystems;

#if UNITY_EDITOR

using UnityEditor;
#endif

static public class GameUtil
{

    public static void SafeDestroy(Object o)
    {
        if (Application.isPlaying)
            Object.Destroy(o);
        else
            Object.DestroyImmediate(o);
    }

    public static bool IsPointerOverGameObject()
    {
        //check mouse
        if (EventSystem.current != null && EventSystem.current.IsPointerOverGameObject())
            return true;

        //check touch
        if (EventSystem.current != null && Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
        {
            if (EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId))
                return true;
        }

        return false;
    }

    public static bool IsPrefabMode()
    {
#if UNITY_EDITOR
        UnityEditor.SceneManagement.PrefabStage prefabStage = UnityEditor.SceneManagement.PrefabStageUtility.GetCurrentPrefabStage();

        if (prefabStage == null) return false;
        if (!prefabStage.stageHandle.IsValid()) return false;

        return true;
#else
        return false;
#endif
    }

    public static bool IsEditingPrefabInAssetFolder(GameObject o)
    {
#if UNITY_EDITOR
        return o.transform.root == o.transform;
#else
        return false;
#endif
    }

    /// <summary>
    /// Are we currently editing a particular object as a prefab?
    /// Note this is not safe to call from OnValidate, so use it with EditorApplication.delayCall
    /// </summary>
    /// <param name="o"></param>
    /// <returns></returns>
    public static bool IsEditingPrefab(GameObject o)
    {
#if UNITY_EDITOR
        UnityEditor.SceneManagement.PrefabStage prefabStage = UnityEditor.SceneManagement.PrefabStageUtility.GetCurrentPrefabStage();

        if (prefabStage == null) return false;
        if (!prefabStage.stageHandle.IsValid()) return false;
        if (!prefabStage.stageHandle.Contains(o)) return false;
        if (prefabStage.prefabContentsRoot != o) return false;

        //PrefabUtility.is
        // note: the below line prevents prefab mode from being recognised in the in-context edit mode
        //if (PrefabUtility.GetPrefabInstanceStatus(o) != PrefabInstanceStatus.Connected) return false;
        return true;
#else
        return false;
#endif
    }



    public static void GizmoString(string text, Vector3 worldPos, int fontSize = 50, Color? colour = null)
    {
#if UNITY_EDITOR
        UnityEditor.Handles.BeginGUI();
        if (colour.HasValue) GUI.color = colour.Value;
        var view = UnityEditor.SceneView.currentDrawingSceneView;
        Vector3 screenPos = view.camera.WorldToScreenPoint(worldPos);
        Vector2 size = GUI.skin.label.CalcSize(new GUIContent(text));
        GUIStyle style = new GUIStyle();
        style.fontSize = fontSize;
        style.fontStyle = FontStyle.Bold;
        style.alignment = TextAnchor.MiddleCenter;

        style.normal.textColor = Color.black;
        GUI.Label(new Rect(screenPos.x - (size.x / 2) + 1, -screenPos.y + view.position.height + 5, size.x, size.y), text, style);

        if (colour.HasValue) style.normal.textColor = colour.Value;
        GUI.Label(new Rect(screenPos.x - (size.x / 2), -screenPos.y + view.position.height + 4, size.x, size.y), text, style);
        UnityEditor.Handles.EndGUI();
#endif
    }

    static public Vector3 GetObjectBoundingBoxSize(GameObject obj)
    {
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);
        return b.size;
    }

    public static void PositionObjectOnFloor(GameObject obj, Vector3 floorPos)
    {
        obj.transform.position = floorPos;
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);
        
        Vector3 offset = b.center - obj.transform.position;
        obj.transform.position = floorPos - offset + Vector3.up * b.extents.y;
    }

    public static void SizeObjectToFixedWorldSize(GameObject obj, float maxWorldSize)
    {
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);
        
        float aspect = 0;

        if (b.size.x > b.size.y && b.size.x > b.size.z)         // largest side is x
            aspect = maxWorldSize / b.size.x;
        else if (b.size.y > b.size.x && b.size.y > b.size.z)    // largest side is y
            aspect = maxWorldSize / b.size.y;
        else                                                    // largest side is z
            aspect = maxWorldSize / b.size.z;
        
        obj.transform.localScale = obj.transform.localScale * aspect;
    }

    public static void SizeObjectToFixedWorldSize(GameObject obj, Vector3 maxWorldSize)
    {
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);

        float aspect = 0;

        if (b.size.x > b.size.y && b.size.x > b.size.z)         // largest side is x
            aspect = maxWorldSize.x / b.size.x;
        else if (b.size.y > b.size.x && b.size.y > b.size.z)    // largest side is y
            aspect = maxWorldSize.y / b.size.y;
        else                                                    // largest side is z
            aspect = maxWorldSize.z / b.size.z;

        obj.transform.localScale = obj.transform.localScale * aspect;
    }

    public static void SizeObjectToFixedWorldSizeXZ(GameObject obj, float maxWorldSize)
    {
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);

        float aspect = 0;

        if (b.size.x > b.size.z)               // largest side is x
            aspect = maxWorldSize / b.size.x;
        else                                    // largest side is z
            aspect = maxWorldSize / b.size.z;

        obj.transform.localScale = obj.transform.localScale * aspect;
    }

    public static void SizeObjectToFixedWorldSizeX(GameObject obj, float maxWorldSize)
    {
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);

        float aspect = 0;
        aspect = maxWorldSize / b.size.x;
        obj.transform.localScale = obj.transform.localScale * aspect;
    }
    public static void SizeObjectToFixedWorldSizeY(GameObject obj, float maxWorldSize)
    {
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);

        float aspect = 0;
        aspect = maxWorldSize / b.size.y;
        obj.transform.localScale = obj.transform.localScale * aspect;
    }
    public static void SizeObjectToFixedWorldSizeZ(GameObject obj, float maxWorldSize)
    {
        Bounds b = obj.GetComponentInChildren<Renderer>().bounds;
        foreach (Renderer r in obj.GetComponentsInChildren<Renderer>()) b.Encapsulate(r.bounds);

        float aspect = 0;
        aspect = maxWorldSize / b.size.y;
        obj.transform.localScale = obj.transform.localScale * aspect;
    }

    static public string CapitlizeFirstLetter(string text)
    {
        if (text.Length < 2) return text;
        return text.Substring(0, 1).ToUpper() + text.Substring(1).ToLower();
    }

    static public string PluralString(string text, int number)
    {
        if (number == 1) return text;
        if (text.Substring(text.Length - 1, 1) == "s") return text + "'s";
        return text + "s";
    }

}
