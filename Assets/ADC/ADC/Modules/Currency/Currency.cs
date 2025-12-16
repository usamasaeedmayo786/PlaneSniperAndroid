using UnityEngine;
using NaughtyAttributes;

[CreateAssetMenu(menuName = "ADC/Currency")]
public partial class Currency : ADC.Core.BaseScriptableType
{

    [Header("Data")]

    public string symbol = "$";
    public int decimalPlaces = 2;
    public string singularName = "Dollar";
    public string pluralName = "Dollars";
    public Color textColor = Color.white;
    public Sprite icon;

    public GameObject worldModel;
    public Vector3 worldModelPosition;
    public Vector3 worldModelRotation;
    public float worldModelScale = 1;

    // Examples

    [ShowNativeProperty]
    string example => $"{Format(123456)} {pluralName}";

    // Interface

    public string Format(double value)
    {
        return CurrencyUtil.Format(value, decimalPlaces, symbol);
    }

}

