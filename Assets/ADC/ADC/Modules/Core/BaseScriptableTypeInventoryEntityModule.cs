using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using SimpleJSON;

namespace ADC.Core
{

    /// <summary>
    /// Base entity module for inventories which hold quantities of a BaseScriptableType
    /// </summary>
    /// <typeparam name="Scriptable">BaseScriptableType</typeparam>
    /// <typeparam name="Reference">BaseScriptableReferenceType<Scriptable></typeparam>
    /// <typeparam name="Quantity">BaseScriptableTypeQuantity<Reference, Scriptable></typeparam>
    public abstract class BaseScriptableTypeInventoryEntityModule<Scriptable, Reference, Quantity> : EntityModule where Scriptable : BaseScriptableType where Reference : BaseScriptableTypeReference<Scriptable> where Quantity : BaseScriptableTypeQuantity<Reference, Scriptable>
    {
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Events

        public System.Action onDisplayedContentsChanged;
        public System.Action<Quantity> onDisplayedItemAdded;
        public System.Action<Quantity> onDisplayedItemRemoved;

        public System.Action onContentsChanged;
        public System.Action<Quantity> onItemAdded;
        public System.Action<Quantity> onItemRemoved;

        public System.Action onTotalItemsLimitChanged;

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Accessors

        public double totalItems => contents.Sum(c => c.amount);
        public double totalDisplayedItems => displayedContents.Sum(c => c.amount);

        public double totalItemLimit => totalItemsMax;

        public bool isFull => totalItemsMax <= 0 ? false : (totalItems >= totalItemsMax);
        public bool isEmpty => totalItems == 0;
        //public bool isWaitingForAnimations => reservedAmounts.Where(ra => ra.amount != 0).Count() > 0;


        /// <summary>
        /// The inventory contents
        /// </summary>
        public readonly List<Quantity> contents = new List<Quantity>();

        /// <summary>
        /// The displayed inventory contents - play nicely with animations
        /// </summary>
        public readonly List<Quantity> displayedContents = new List<Quantity>();

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Internal

        protected virtual Reference CreateReference(string type)
        {
            return (Reference)System.Activator.CreateInstance(typeof(Reference), type);
        }

        protected virtual Quantity CreateQuantity(Reference type, double amount)
        {
            return (Quantity)System.Activator.CreateInstance(typeof(Quantity), type, amount);
        }

        protected virtual Quantity CreateQuantity(string type, double amount)
        {
            return CreateQuantity(CreateReference(type), amount);
        }

        protected virtual Quantity GetOrAddContent(Reference type)
        {
            Quantity item = contents.Find(item => item.reference.type == type);
            if (item == null)
            {
                item = CreateQuantity(type, 0);
                contents.Add(item);
            }
            return item;
        }
        protected virtual Quantity GetOrAddDisplayedContent(Reference type)
        {
            Quantity item = displayedContents.Find(item => item.reference.type == type);
            if (item == null)
            {
                item = CreateQuantity(type, 0);
                displayedContents.Add(item);
            }
            return item;
        }

        /// <summary>
        /// Gets the maximum amount we can add of a type
        /// </summary>
        /// <param name="type">Type to imagine adding</param>
        /// <param name="amount">Amount to imagine adding</param>
        /// <param name="allowOverflow">Allow to go over the resource limit?</param>
        /// <param name="includeReserved">Include reserved amounts in the check?</param>
        /// <returns>How many we can add</returns>
        public virtual double VirtualAdd(Reference type, double amount, bool allowOverflow = false)
        {
            Debug.Assert(amount >= 0, $"VirtualAdd recevied a negative value? ({amount})");

            double amountToAdd = amount;

            // Total items limit
            double _totalItems = totalItems;
            double totalItemsOverflowAmount = 0;
            if (!allowOverflow)
            {
                if (totalItemsMax > 0 && _totalItems + amountToAdd > totalItemsMax)
                {
                    totalItemsOverflowAmount = (_totalItems + amountToAdd) - totalItemsMax;
                    amountToAdd = System.Math.Max(amountToAdd - totalItemsOverflowAmount, 0);
                }
            }

            // Check here that we still have something to add
            if (amountToAdd == 0) return 0;

            // Individual item limit
            Quantity item = GetOrAddContent(type);
            double _currentAmount = item.amount;
            double individualItemOverflowAmount = 0;
            if (!allowOverflow)
            {
                if (item.maxAmount > 0 && _currentAmount + amountToAdd > item.maxAmount)
                {
                    individualItemOverflowAmount = (_currentAmount + amountToAdd) - item.maxAmount;
                    amountToAdd = System.Math.Max(amountToAdd - individualItemOverflowAmount, 0);
                }
            }

            // Return the amount that was added
            return amountToAdd;
        }

        /// <summary>
        /// Gets the maximum amount we can subtract of a type (takes a positive integer)
        /// </summary>
        /// <param name="type"></param>
        /// <param name="amount"></param>
        /// <param name="includeReserved"></param>
        /// <returns>How many we can actually subtract, positive value</returns>
        protected virtual double VirtualSubtract(Reference type, double amount)
        {
            Debug.Assert(amount >= 0, $"VirtualSubtract recevied a negative value? ({amount})");

            double amountToSubtract = amount;

            // Individual item limit
            double _currentAmount = GetAmount(type);
            if (_currentAmount - amount < 0)
            {
                amountToSubtract = _currentAmount;
            }

            // Return the amount that was added
            return amountToSubtract;
        }

        /// <summary>
        /// Immediately adds a displayed resource
        /// </summary>
        protected virtual void _AddDisplayed(Reference type, double amount)
        {
            Debug.Assert(amount >= 0, $"Tried to add negative ({amount}) of {type} to displayed inventory");

            // Regular add
            Quantity item = GetOrAddDisplayedContent(type);
            item.Add(amount);

            onDisplayedContentsChanged?.Invoke();
            onDisplayedItemAdded?.Invoke(CreateQuantity(type, amount));
        }

        /// <summary>
        /// Immediately subtracts a displayed resource
        /// </summary>
        protected virtual void _RemoveDisplayed(Reference type, double amount)
        {
            Debug.Assert(amount >= 0, $"Tried to remove negative ({amount}) of {type} to displayed inventory");

            // Regular subtract
            Quantity item = GetOrAddDisplayedContent(type);
            item.Subtract(amount);

            onDisplayedContentsChanged?.Invoke();
            onDisplayedItemRemoved?.Invoke(CreateQuantity(type, amount));
        }

        /// <summary>
        /// Immediately sets a displayed resource
        /// </summary>
        protected virtual void _SetDisplayed(Reference type, double amount)
        {
            Debug.Assert(amount >= 0, $"Tried to set negative ({amount}) of {type} to displayed inventory");

            // Regular subtract
            Quantity item = GetOrAddDisplayedContent(type);
            item.Set(amount);

            onDisplayedContentsChanged?.Invoke();
            onDisplayedItemRemoved?.Invoke(CreateQuantity(type, amount));
        }

        /// <summary>
        /// Immediately adds a resource
        /// </summary>
        /// <returns>Amount of items actually added</returns>
        protected virtual double _Add(Reference type, double amount, bool allowOverflow = false)
        {
            Debug.Assert(amount >= 0, $"Tried to add negative ({amount}) of {type} to inventory");

            // Perform a virtual add to check how many we can actually add
            double amountToAdd = VirtualAdd(type, amount, allowOverflow);

            // Regular add
            Quantity item = GetOrAddContent(type);
            amountToAdd = System.Math.Min(item.Add(amountToAdd, allowOverflow), amountToAdd);

            // Fire events
            onItemAdded?.Invoke(CreateQuantity(type, amountToAdd));
            onContentsChanged?.Invoke();
            Save();

            // Return the amount that was added
            return amountToAdd;
        }

        /// <summary>
        /// Immediately consumes a resource. 
        /// </summary>
        /// <returns>Amount of items actually taken (positive)</returns>
        protected virtual double _Consume(Reference type, double amount)
        {
            // Perform a virtual subtract to check how many we can actually take - value will be negative
            double amountToSubtract = VirtualSubtract(type, amount);

            // Subtract, checking how many we actually took
            Quantity item = GetOrAddContent(type);
            amountToSubtract = System.Math.Min(item.Subtract(amountToSubtract), amountToSubtract);

            // Fire events
            onItemRemoved?.Invoke(CreateQuantity(type, amountToSubtract));
            onContentsChanged?.Invoke();
            Save();

            // Return the amount that was added
            return amountToSubtract;
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Public Interface

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Get

        /// <summary>
        /// Gets the amount currently in the inventory
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public virtual double GetAmount(Reference type)
        {
            Quantity item = contents.Find(item => item.data.type == type);
            return item == null ? 0 : item.amount;
        }

        /// <summary>
        /// Gets the amount currently displayed in the inventory
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public virtual double GetDisplayedAmount(Reference type)
        {
            Quantity item = displayedContents.Find(item => item.data.type == type);
            return item == null ? 0 : System.Math.Max(item.amount, 0);
        }

        public virtual bool CanAfford(Reference type, double amount)
        {
            return GetAmount(type) >= amount;
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Limits

        /// <summary>
        /// Set a limit on a particular type
        /// </summary>
        /// <param name="type">The type</param>
        /// <param name="max">Maximum we can hold</param>
        /// <param name="allowOverflow">Should any existing quantities of this type be allowed to remain above the Maximum as we make this call</param>
        public virtual void SetLimit(Reference type, double max, bool allowOverflow = true)
        {
            Quantity item = GetOrAddContent(type);
            item.SetMaxAmount(max, allowOverflow);
        }

        public virtual double GetLimit(Reference type, double max, bool allowOverflow = true)
        {
            Quantity item = GetOrAddContent(type);
            return item.GetMaxAmount();
        }

        protected double totalItemsMax = 0;

        /// <summary>
        /// Set a limit on the total items in the inventory
        /// </summary>
        /// <param name="max"></param>
        public virtual void SetTotalLimit(double max)
        {
            totalItemsMax = max;
            onContentsChanged?.Invoke();
            onDisplayedContentsChanged?.Invoke();
            onTotalItemsLimitChanged?.Invoke();
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Set
        /* not recommended to use this as im not sure how it plays with animation timing
        /// <summary>
        /// Sets the amount of a resource
        /// </summary>
        /// <param name="type">Resource type</param>
        /// <param name="amount">Amount to set</param>
        /// <param name="allowOverflow">Allow the set amount to bypass any existing limits?</param>
        public void SetAmount(Reference type, double amount, bool allowOverflow = true)
        {
            Quantity item = GetOrAddContent(type);
            item.Set(amount, allowOverflow);
            Save();
            onContentsChanged.Invoke();
        }
        */

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Transfer

        /// <summary>
        /// Transfers set number of type to another inventory (and plays an animation)
        /// </summary>
        /// <param name="type">Resource type</param>
        /// <param name="amount">Amount to transfer</param>
        /// <param name="target">Target inventory to transfer to</param>
        /// <param name="playHaptics">Play haptics during the animation?</param>
        /// <param name="callback">Callback when animation completes</param>
        /// <param name="allowOverflow">Allow the target inventory to overflow?</param>
        /// <returns>The amount of items that were transferred</returns>
        public virtual double Transfer(BaseScriptableTypeInventoryEntityModule<Scriptable, Reference, Quantity> target, Reference type, double amount, bool playHaptics = true, System.Action callback = null, int? animationAmount = null, bool allowOverflow = false)
        {
            if (GetAmount(type) < amount) amount = GetAmount(type); // trim to max we own
            double amountGiven = target.AddAmount(type, amount, owner.transferAnimationTransform, playHaptics, callback, animationAmount, allowOverflow);

            // Consume with a non-rendering animation
            ConsumeAmount(type, amountGiven, target.owner.transferAnimationTransform, false, null, null, false);

            return amountGiven;
        }

        /// <summary>
        /// Transfers all items of type to another inventory (and plays an animation)
        /// </summary>
        /// <param name="type">Resource type</param>
        /// <param name="amount">Amount to transfer</param>
        /// <param name="target">Target inventory to transfer to</param>
        /// <param name="playHaptics">Play haptics during the animation?</param>
        /// <param name="callback">Callback when animation completes</param>
        /// <param name="allowOverflow">Allow the target inventory to overflow?</param>
        /// <returns>The amount of items that were transferred</returns>
        public virtual double Transfer(BaseScriptableTypeInventoryEntityModule<Scriptable, Reference, Quantity> target, Reference type, bool playHaptics = true, System.Action callback = null, int? animationAmount = null, bool allowOverflow = false)
        {
            double amount = GetAmount(type);
            return Transfer(target, type, amount, playHaptics, callback, animationAmount, allowOverflow);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Adding

        /// <summary>
        /// Adds item to inventory with animation
        /// </summary>
        /// <param name="type">Type</param>
        /// <param name="amount">Amount</param>
        /// <param name="animateFromPosition">If non-null, will play a transfer animation to this poistion</param>
        /// <param name="playHaptics">Play haptics during transfer animation?</param>
        /// <param name="callback">Callback when transfer animation is complete</param>
        /// <param name="animationAmount">Override the number of items that get animated</param>
        /// <param name="allowOverflow">Allow to go over the resource limit?</param>
        /// <returns>Amount of items actually added</returns>
        public virtual double AddAmount(Reference type, double amount, Transform animateFromPosition, bool playHaptics = false, System.Action callback = null, int? animationAmount = null, bool allowOverflow = false)
        {
            Debug.Assert(animateFromPosition != null, "Target transform was null for add inventory transfer animation");

            double amountAdded = _Add(type, amount, allowOverflow);
            double amountAddedByAnimation = 0;

            // TODO: take > 1 per anim cycle to make the stack anim smoother
            //Debug.Log($"Requested to transfer {amount} items, managed to reserve {amountAdded} items");

            void perItemCallback()
            {
                _AddDisplayed(type, 1); 
                amountAddedByAnimation += 1;
            }

            void finishedCallback()
            {
                _SetDisplayed(type, GetAmount(type));
                callback?.Invoke();
            }

            // Animate if we actually managed to add items
            if (amountAdded > 0)
                MakeTransferAnimation(CreateQuantity(type, animationAmount.HasValue ? animationAmount.Value : amountAdded), animateFromPosition, owner.transferAnimationTransform, playHaptics, finishedCallback, perItemCallback);

            return amountAdded;
        }

        /// <summary>
        /// Adds item to inventory without animation
        /// </summary>
        /// <param name="type">Type</param>
        /// <param name="amount">Amount</param>
        /// <param name="allowOverflow">Allow to go over the resource limit?</param>
        /// <returns>Amount of items actually added</returns>
        public virtual double AddAmount(Reference type, double amount, bool allowOverflow = false)
        {
            double amountAdded = _Add(type, amount, allowOverflow);
            _AddDisplayed(type, amountAdded);
            return amountAdded;
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Consumption

        /// <summary>
        /// Consumes an amount of resources from the inventory
        /// </summary>
        /// <param name="type">Type</param>
        /// <param name="amount">Amount to take</param>
        /// <param name="animateToPosition">Position to animate them to</param>
        /// <param name="playHaptics">Play haptics</param>
        /// <param name="callback">Callback when aniamtion is completed</param>
        /// <param name="animationAmount">Override the amount that is animated across</param>
        /// <returns>The amount that was actually consumed (may differ from requested amount if we did not have that many)</returns>
        public virtual double ConsumeAmount(Reference type, double amount, Transform animateToPosition, bool playHaptics = false, System.Action callback = null, int? animationAmount = null, bool render = true)
        {
            Debug.Assert(animateToPosition != null, "Target transform was null for consume inventory transfer animation");

            double amountSubtracted = _Consume(type, amount);
            double amountTakenByAnimation = 0;

            void perItemCallback()
            {
                _RemoveDisplayed(type, 1);
                amountTakenByAnimation += 1;
            }

            void finishedCallback()
            {
                _SetDisplayed(type, GetAmount(type));
                callback?.Invoke();
            }

            // Animate if we actually managed to subtract items
            if (amountSubtracted > 0)
                MakeTransferAnimation(CreateQuantity(type, animationAmount.HasValue ? animationAmount.Value : amountSubtracted), owner.transferAnimationTransform, animateToPosition, playHaptics, finishedCallback, perItemCallback, TransferAnimation.PerItemCallbackTiming.ON_BEGIN, render);

            return amountSubtracted;
        }

        /// <summary>
        /// Instantly consume items with no animation
        /// </summary>
        /// <param name="type"></param>
        /// <param name="amount"></param>
        /// <returns>The amount that was actually consumed (may differ from requested amount if we did not have that many)</returns>
        public virtual double ConsumeAmount(Reference type, double amount)
        {
            double amountTaken = _Consume(type, amount);
            _RemoveDisplayed(type, amountTaken);
            return amountTaken;
        }

        /// <summary>
        /// Consumes an amount of resources from the inventory
        /// </summary>
        /// <param name="type">Type</param>
        /// <param name="amount">Amount to take</param>
        /// <param name="animateToPosition">Position to animate them to</param>
        /// <param name="playHaptics">Play haptics</param>
        /// <param name="callback">Callback when aniamtion is completed</param>
        /// <param name="animationAmount">Override the amount that is animated across</param>
        /// <returns>The amount that was actually consumed (may differ from requested amount if we did not have that many)</returns>
        public virtual void ConsumeAmount(List<Quantity> consume, Transform animateToPosition = null, bool playHaptics = false, System.Action callback = null)
        {
            consume.ForEach(item => ConsumeAmount(item.reference, item.amount, animateToPosition, playHaptics, callback));
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Clear

        /// <summary>
        /// Clears resources from inventory. Not safe to call if isWaitingForAnimations = TRUE
        /// </summary>
        /// <param name="references"></param>
        public virtual void Clear(List<Reference> references)
        {
            contents.RemoveAll(c => references.Contains(c.reference));
            displayedContents.RemoveAll(c => references.Contains(c.reference));
            onContentsChanged?.Invoke();
            Save();
        }

        /// <summary>
        /// Clears a resource from inventory. Not safe to call if isWaitingForAnimations = TRUE
        /// </summary>
        /// <param name="references"></param>
        public virtual void Clear(Reference resource)
        {
            contents.RemoveAll(c => c.reference == resource);
            displayedContents.RemoveAll(c => c.reference == resource);
            onContentsChanged?.Invoke();
            Save();
        }

        /// <summary>
        /// Clears the inventory. Not safe to call if isWaitingForAnimations = TRUE
        /// </summary>
        /// <param name="references"></param>
        public virtual void Clear()
        {
            contents.Clear();
            displayedContents.Clear();
            onContentsChanged?.Invoke();
            Save();
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Debug

        public virtual void DebugContents()
        {
            UnityEngine.Debug.Log("Inventory:");
            foreach (Quantity item in contents) Debug.Log(item.reference.type + ": " + item.amount);
        }
        /*
        public string DebugReserved()
        {
            string o = "contents:\n";
            foreach (Quantity item in contents) o += item.reference.type + ": " + item.amount + "\n";
            o += "reserved:\n";
            foreach (Quantity item in reservedAmounts) o += item.reference.type + ": " + item.amount + "\n";
            return o;
        }
        */

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Abstract methods

        public abstract void MakeTransferAnimation(Quantity quantity, Transform fromPosition, Transform toPosition, bool playHaptics = false, System.Action callback = null, System.Action perItemCallback = null, TransferAnimation.PerItemCallbackTiming perItemCallbackTiming = TransferAnimation.PerItemCallbackTiming.ON_FINISH, bool render = true);

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // BaseEntityModule

        public override void Initialize(Entity character)
        {
            base.Initialize(character);
            Load();
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // IJsonSerializable

        public override JSONNode SerializeJSON()
        {
            JSONObject node = new JSONObject();
            foreach (Quantity item in contents) node.Add(item.data.type, item.amount);
            return node;
        }

        public override void DeserializeJSON(JSONNode data)
        {
            contents.Clear();
            foreach (string key in data.Keys) contents.Add( CreateQuantity(key, data[key].AsDouble) );
            displayedContents.Clear();
            foreach (string key in data.Keys) displayedContents.Add(CreateQuantity(key, data[key].AsDouble));
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // ISaveLoad

        public virtual string saveKey => "inventory";

        public override void Save()
        {
            Database.WriteAsync(owner.id, saveKey, SerializeJSON().ToString(), (success, error) => { });
        }

        public override void Load()
        {
            Database.ReadAsync<string>(owner.id, saveKey, (success, data) => {
                if (success && !string.IsNullOrEmpty(data))
                    DeserializeJSON(JSON.Parse(data));
            });
        }

    }

}