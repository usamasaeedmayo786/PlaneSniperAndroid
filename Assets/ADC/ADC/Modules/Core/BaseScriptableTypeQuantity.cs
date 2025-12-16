using SimpleJSON;

namespace ADC.Core
{

    /// <summary>
    /// Base class to hold reference to some BaseScriptableType and contain a quantity of it
    /// </summary>
    /// <typeparam name="Reference"></typeparam>
    /// <typeparam name="Scriptable"></typeparam>
    public class BaseScriptableTypeQuantity<Reference, Scriptable> : IJsonSerializable where Reference : BaseScriptableTypeReference<Scriptable> where Scriptable : BaseScriptableType
    {
        public BaseScriptableTypeQuantity(Reference reference)
        {
            this.reference = reference;
        }

        public BaseScriptableTypeQuantity(Reference reference, double amount)
        {
            this.reference = reference;
            this.quantity = amount;
        }

        // Public Data

        public Reference reference { get; protected set; }
        public Scriptable data => reference.data;

        public virtual double amount => quantity;
        public virtual double maxAmount => maxQuantity;

        // Events

        public System.Action onChanged = null;

        // Internal

        protected double quantity = 0;
        protected double maxQuantity = -1;

        protected virtual void OnChanged()
        {
            onChanged?.Invoke();
        }

        /// <summary>
        /// Clamps a virtual quantity based on limits
        /// </summary>
        /// <param name="allowOverflow"></param>
        /// <param name="quantity"></param>
        /// <returns>The quantity after being limited</returns>
        protected virtual double VirtualQuantityOverflow(bool allowOverflow, double quantity)
        {
            if (!allowOverflow)
            {
                // Max
                if (maxQuantity > 0 && quantity > maxQuantity)
                {
                    quantity = maxQuantity;
                }
                // Min
                if (quantity < 0)
                {
                    quantity = 0;
                }
            }

            return quantity;
        }

        protected virtual double ManageOverflow(bool allowOverflow)
        {
            double originalQuantity = quantity;
            quantity = VirtualQuantityOverflow(allowOverflow, quantity);
            
            return originalQuantity - quantity;
        }

        // Public Interface

        /// <summary>
        /// Imagines what would happen if we added x items
        /// </summary>
        /// <param name="addAmount">Amount to imagine adding</param>
        /// <param name="allowOverflow"></param>
        /// <returns>The imagined number of items that would have been added</returns>
        public virtual double VirtualAdd(double addAmount, bool allowOverflow = false)
        {
            double virtualQuantity = VirtualQuantityOverflow(allowOverflow, quantity + addAmount);
            return virtualQuantity - quantity;
        }

        /// <summary>
        /// Adds to amount owned
        /// </summary>
        /// <param name="amount">Amount to add</param>
        /// <param name="allowOverflow">Allow to overflow the min/max quantity?</param>
        /// <param name="surpressEvent">Surpress the onChanged event?</param>
        /// <returns>Amount of items actually added or removed (positive value in both cases)</returns>
        public virtual double Add(double amount, bool allowOverflow = false, bool surpressEvent = false)
        {
            amount = System.Math.Ceiling(amount);
            quantity += amount;

            // Check overflow
            double overflow = ManageOverflow(allowOverflow);

            // Event
            if (!surpressEvent) OnChanged();

            // Error check
            UnityEngine.Debug.Assert(quantity >= 0, $"Quantity was left with < 0 after overflow!? quantity: {quantity} overflow: {overflow}");

            return System.Math.Abs( amount - overflow );
        }

        /// <summary>
        /// Adds to amount owned
        /// </summary>
        /// <param name="quantity">Type to add, if types mismatch then nothing is added</param>
        /// <param name="allowOverflow">Allow to overflow the min/max quantity?</param>
        /// <param name="surpressEvent">Surpress the onChanged event?</param>
        /// <returns>Amount of items actually added</returns>
        public virtual double Add(BaseScriptableTypeQuantity<Reference, Scriptable> quantity, bool allowOverflow = false, bool surpressEvent = false)
        {
            if (quantity.data.type != data.type) return 0;
            return Add(quantity.amount, allowOverflow, surpressEvent);
        }

        /// <summary>
        /// Subtracts from amount owned
        /// </summary>
        /// <param name="amount">Amount to subtract</param>
        /// <param name="allowOverflow">Allow to overflow the min/max quantity?</param>
        /// <param name="surpressEvent">Surpress the onChanged event?</param>
        /// <returns>Amount of items actually subtracted (positive value)</returns>
        public virtual double Subtract(double amount, bool allowOverflow = false, bool surpressEvent = false)
        {
            return Add(-amount, allowOverflow, surpressEvent);
        }

        /// <summary>
        /// Subtracts from amount owned
        /// </summary>
        /// <param name="quantity">Type to add, if types mismatch then nothing is added</param>
        /// <param name="allowOverflow">Allow to overflow the min/max quantity?</param>
        /// <param name="surpressEvent">Surpress the onChanged event?</param>
        /// <returns>Amount of items actually subtracted (positive value)</returns>
        public virtual double Subtract(BaseScriptableTypeQuantity<Reference, Scriptable> quantity, bool allowOverflow = false, bool surpressEvent = false)
        {
            if (quantity.data.type != data.type) return 0;
            return Subtract(quantity.amount, allowOverflow, surpressEvent);
        }

        /// <summary>
        /// Sets the amount owned
        /// </summary>
        /// <param name="amount">Amount to set</param>
        /// <param name="allowOverflow">Allow to overflow min/max limits, true by default on set</param>
        /// <param name="surpressEvent">Surpress the onChanged event?</param>
        public virtual void Set(double amount, bool allowOverflow = true, bool surpressEvent = false)
        {
            amount = System.Math.Ceiling(amount);

            quantity = amount;

            // Check overflow
            ManageOverflow(allowOverflow);

            // Event
            if (!surpressEvent) OnChanged();
        }

        /// <summary>
        /// Do we own enough to buy something?
        /// </summary>
        /// <param name="amount">Amount to check</param>
        /// <returns>TRUE if we can afford</returns>
        public virtual bool CanAfford(double amount)
        {
            return quantity >= System.Math.Ceiling(amount);
        }

        /// <summary>
        /// Sets the maximum amount we can own
        /// </summary>
        /// <param name="amount">Maximum</param>
        /// <param name="allowOverflow">If we currently own more, should we trim the amount owned?</param>
        /// <returns>Amount overflowed</returns>
        public virtual double SetMaxAmount(double amount, bool allowOverflow = true)
        {
            maxQuantity = amount;

            // Check overflow
            return ManageOverflow(allowOverflow);
        }

        /// <summary>
        /// Returns the maximum amount we can own
        /// </summary>
        /// <returns></returns>
        public virtual double GetMaxAmount()
        {
            return maxQuantity;
        }

        // IJSONSerializable

        public virtual JSONNode SerializeJSON()
        {
            JSONNode node = new JSONObject();
            //node.Add("type", data.type);
            //node.Add("amount", amount);
            node.Add(data.type, amount);
            return node;
        }

        public virtual void DeserializeJSON(JSONNode data)
        {
            if (data.HasKey(this.data.type)) quantity = data[this.data.type].AsDouble;
        }

    }

}