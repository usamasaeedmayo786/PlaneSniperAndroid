using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NaughtyAttributes;

public class AdVariantDatabase : ADC.Core.BaseScriptableTypeDatabase<AdVariant>
{
    // You have to override this for the context menu to work
#if UNITY_EDITOR
    [Button("Auto Fill")]
    [ContextMenu("Auto Fill")]
    protected override void AutoFill() { base.AutoFill(); }
#endif

}

/// <summary>
/// Reference to an item in the AdVariantDatabase
/// </summary>
[System.Serializable]
public class AdVariantReference : ADC.Core.BaseScriptableTypeReference<AdVariant>
{

    public AdVariantReference() { }
    public AdVariantReference(string type) { this.type = type; }

    /// <summary>
    /// Returns AdVariant data from the AdVariantDatabase
    /// </summary>
    public override AdVariant data
    {
        get
        {
            if (string.IsNullOrEmpty(type)) type = "NONE";
            return AdVariantDatabase.Get(type);
        }
    }

}