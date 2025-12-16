using UnityEngine;

namespace ADC.Core
{

    /// <summary>
    /// Base class for monobehaviours that contain a type.
    /// Inherit from this to easily add a reference editor
    /// </summary>
    public class BaseMonoBehaviourType : MonoBehaviour
    {

        [Header("Type (ID)")]

        public string type;

    }

}