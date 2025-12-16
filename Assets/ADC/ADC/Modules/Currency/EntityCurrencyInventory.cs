using UnityEngine;
using System.Collections.Generic;
using SimpleJSON;
using System;

/// <summary>
/// Provides access to currencies owned by an entity
/// </summary>
public class EntityCurrencyInventory : ADC.Core.BaseScriptableTypeInventoryEntityModule<Currency, CurrencyReference, CurrencyQuantity>
{

    // Helpers for common currencies

    public CurrencyQuantity money;

    public CurrencyQuantity gems;

    public CurrencyQuantity energy;

    // Overrides

    // Currencies changes the default inventory behaviour in that we always want all of the base currencies to exist, and we allow individual editing of the values
    public override void Initialize(Entity character)
    {
        base.Initialize(character);

        // Create a currency for each one in the database and set up the save event
        ADC.Components.CurrencyDatabase.instance.list.ForEach(currencyDefinition => {

            CurrencyQuantity currency = new CurrencyQuantity(new CurrencyReference(currencyDefinition.type));
            currency.onChanged += CurrencyChanged;
            contents.Add(currency);
        });

        // Load any existing values
        Load();

        // Create helpers
        money = Get("money");
        gems = Get("gems");
        energy = Get("energy");
    }

    public double AddAmountWithFloatingText(CurrencyReference type, double amount, Transform animateFromPosition, bool playHaptics = false, Action callback = null, int? animationAmount = null, bool allowOverflow = false)
    {
        return base.AddAmount(type, amount, animateFromPosition, playHaptics, () => {
            callback?.Invoke();
            //FXManager.MakeFloatingText(owner.transferAnimationTransform.position + Vector3.up * 0.5f, type, amount);
        }, animationAmount, allowOverflow);
    }

    // We allow individual values to change, so hook the event & save manually
    void CurrencyChanged()
    {
        onContentsChanged?.Invoke();
        Save();
    }
     
    /// Deserialization works a bit differently because we don't want to add new CurrencyQuantity values but modify the existing ones
    public override void DeserializeJSON(JSONNode data)
    {
        foreach (string key in data.Keys)
        {
            CurrencyQuantity currency = Get(key);
            if (currency != null)
            {
                currency.Set(data[key].AsDouble);
            }
        }
    }

    // Save as currencies
    public override string saveKey => "currencies";

    // FX override
    public override void MakeTransferAnimation(CurrencyQuantity quantity, Transform fromPosition, Transform toPosition, bool playHaptics = false, Action callback = null, System.Action perItemCallback = null, TransferAnimation.PerItemCallbackTiming perItemCallbackTiming = TransferAnimation.PerItemCallbackTiming.ON_FINISH, bool render = true)
    {
        //FXManager.MakeCurrencyTransfer(quantity.reference, quantity.amount, fromPosition, toPosition, playHaptics, callback, perItemCallback, perItemCallbackTiming, render);
    }

    // Public Interface

    public CurrencyQuantity Get(string type)
    {
        return contents.Find(currency => currency.reference.type == type);
    }

}