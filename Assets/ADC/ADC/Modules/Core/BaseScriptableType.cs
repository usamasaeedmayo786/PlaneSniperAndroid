using UnityEngine;

namespace ADC.Core
{

    /// <summary>
    /// Base class for scriptables that contain a type.
    /// Inherit from this to easily add a reference editor
    /// </summary>
    public class BaseScriptableType : ScriptableObject
    {

        [Header("Type (ID)")]

        public string type;

        // Public Interface

        /// <summary>
        /// Called when you create an instance of a ScriptableObject through XDatabase.CreateInstance()
        /// </summary>
        public virtual void OnInstanceInitialized()
        {

        }
    }

}