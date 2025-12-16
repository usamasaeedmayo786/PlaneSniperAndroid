using UnityEngine;
using NaughtyAttributes;

namespace ADC.Components
{
    public partial class CurrencyDatabase : ADC.Core.BaseScriptableTypeDatabase<Currency>
    {
        // You have to override this for the context menu to work
#if UNITY_EDITOR
        [Button("Auto Fill")]
        [ContextMenu("Auto Fill")]
        protected override void AutoFill() { base.AutoFill(); }
#endif
    }

}


// Currency Reference

/// <summary>
/// Reference to an item in the CurrencyDatabase
/// </summary>
[System.Serializable]
public class CurrencyReference : ADC.Core.BaseScriptableTypeReference<Currency>
{

    public CurrencyReference() { }
    public CurrencyReference(string type) { this.type = type; }

    /// <summary>
    /// Returns data from the database
    /// </summary>
    public override Currency data
    {
        get
        {
            if (string.IsNullOrEmpty(type)) type = "NONE";
            return ADC.Components.CurrencyDatabase.Get(type);
        }
    }

    public CurrencyQuantity OnEntity(EntityCurrencyInventory entityModule)
    {
        if (entityModule == null) return null;
        return entityModule.Get(type);
    }

    public string Format(double value)
    {
        return data.Format(value);
    }

    public string FormatName(double value)
    {
        return value <= 1 ? data.singularName : data.pluralName;
    }

}