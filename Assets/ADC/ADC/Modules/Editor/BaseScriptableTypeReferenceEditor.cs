using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace ADC.Editor
{
    public class BaseScriptableTypeReferenceEditor<DatabaseType, DataType> : PropertyDrawer where DatabaseType : ADC.Core.BaseScriptableDatabase<DataType> where DataType : ADC.Core.BaseScriptableType
    {
        DatabaseType database;

        public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
        {
            return (EditorGUIUtility.singleLineHeight + 2) * 1;
        }

        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            if (database == null)
            {
                database = GameObject.FindObjectOfType<DatabaseType>();
                Debug.Assert(database != null, $"Can't find a {typeof(DatabaseType)}<{typeof(DataType)}> database!");
            }

            EditorGUI.BeginChangeCheck();
            EditorGUI.BeginProperty(position, label, property);

            List<string> types = new List<string>();
            types.Add("NONE");
            database.list.ForEach(data =>
            {
                types.Add(data.type);
            });

            int selected = types.FindIndex(0, t => property.FindPropertyRelative("type").stringValue == t);
            if (selected < 0) selected = 0;
            int idx = EditorGUI.Popup(position, property.displayName, selected, types.ToArray());
            

            EditorGUI.EndProperty();
            if (EditorGUI.EndChangeCheck())
            {
                property.FindPropertyRelative("type").stringValue = types[idx];
            }
        }

    }
}