using UnityEngine;

/// <summary>
/// Holds a CurrencyReference and amount owned
/// </summary>
public class CurrencyQuantity : ADC.Core.BaseScriptableTypeQuantity<CurrencyReference, Currency>
{

    public CurrencyQuantity(CurrencyReference currencyDefinition) : base(currencyDefinition) { }
    public CurrencyQuantity(CurrencyReference currencyDefinition, double amount) : base(currencyDefinition, amount) { }

}

