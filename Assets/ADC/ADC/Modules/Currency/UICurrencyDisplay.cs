using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using NaughtyAttributes;

/// <summary>
/// Displays networked currency values on UI using UI TextMesh
/// </summary>
public class UICurrencyDisplay : MonoBehaviour
{
    public enum NumberBehaviour
    {
        INSTANT,
        COUNT_WHEN_ADDING,
        COUNT_WHEN_SPENDING,
        COUNT_BOTH
    }

    // Public 

    [Header("Setup")]

    public CurrencyReference currency;

    public bool useLocalPlayer = true;

    [HideIf("useLocalPlayer")]
    public EntityCurrencyInventory owner;


    [Header("Settings")]

    public NumberBehaviour numberBehaviour = NumberBehaviour.INSTANT;

    public float countSpeed = 5f;

    public int decimalPlaces = 2;

    public bool useSymbol = false;

    // Internal

    protected List<TextMeshProUGUI> text;

    protected double displayMoney = 0;
    protected double lastDisplayMoney = -1;

    // Internal Interface

    CurrencyQuantity localCurrency;

    protected virtual void RefreshInstant()
    {
        displayMoney = localCurrency.amount;
        Refresh();
    }

    protected virtual void Refresh()
    {
        foreach (TextMeshProUGUI txt in text)
            txt.text = currency.Format(displayMoney);
    }

    protected virtual void Setup()
    {
        Debug.Assert(localCurrency != null, $"Can't find currency {currency.type}");

        if (numberBehaviour == NumberBehaviour.INSTANT)
            localCurrency.onChanged += RefreshInstant;

        displayMoney = localCurrency.amount;
        Refresh();
    }

    // Unity

    protected virtual void Awake()
    {
        text = new List<TextMeshProUGUI>(GetComponentsInChildren<TextMeshProUGUI>());
    }

    protected virtual void Start()
    {

        if (owner == null)
        {
            Debug.LogError("Currency display is missing 'owner'");
            return;
        }

        localCurrency = currency.OnEntity(owner);
        Setup();

    }

    protected virtual void OnDestroy()
    {
        if (numberBehaviour == NumberBehaviour.INSTANT && localCurrency != null)
            localCurrency.onChanged -= RefreshInstant;
    }

    protected virtual void Update()
    {
        if (localCurrency == null) return;
        if (numberBehaviour == NumberBehaviour.INSTANT) return;

        // Add
        if (displayMoney < localCurrency.amount)
        {
            if (numberBehaviour == NumberBehaviour.COUNT_WHEN_ADDING || numberBehaviour == NumberBehaviour.COUNT_BOTH)
            {
                displayMoney += (localCurrency.amount - displayMoney) * Time.deltaTime * countSpeed;
                if (displayMoney > localCurrency.amount) displayMoney = localCurrency.amount;
            }
            else
            {
                displayMoney = localCurrency.amount;
            }
        }

        // Subtract
        if (displayMoney > localCurrency.amount)
        {
            if (numberBehaviour == NumberBehaviour.COUNT_WHEN_SPENDING || numberBehaviour == NumberBehaviour.COUNT_BOTH)
            {
                displayMoney += (localCurrency.amount - displayMoney) * Time.deltaTime * countSpeed;
                if (displayMoney < localCurrency.amount) displayMoney = localCurrency.amount;
            }
            else
            {
                displayMoney = localCurrency.amount;
            }
        }

        // Refresh
        if (displayMoney != lastDisplayMoney)
        {
            lastDisplayMoney = displayMoney;
            Refresh();
        }
        
    }

}
