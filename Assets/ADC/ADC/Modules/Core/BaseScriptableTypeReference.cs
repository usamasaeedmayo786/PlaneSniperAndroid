using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ADC.Core
{
    /// <summary>
    /// Base class for editor scriptable type references
    /// </summary>
    [System.Serializable] 
    public abstract class BaseScriptableTypeReference<ScriptableType> where ScriptableType : BaseScriptableType
    {
        public string type = "NONE";

        /// <summary>
        /// Returns data from the database
        /// </summary>
        public abstract ScriptableType data
        {
            get;
        }

        public BaseScriptableTypeReference() { }
        public BaseScriptableTypeReference(string type) { this.type = type; }

        // Comparison Operators
        public override bool Equals(object obj)
        {
            BaseScriptableTypeReference<ScriptableType> rr = obj as BaseScriptableTypeReference<ScriptableType>;

            if (rr is null)
            {
                string str = obj as string;
                if (str is null) return false;

                return str == type;
            }
            if (Object.ReferenceEquals(this, rr)) return true;
            return (type == rr.type);
        }

        public override int GetHashCode() => (type).GetHashCode();

        public static bool operator ==(BaseScriptableTypeReference<ScriptableType> lhs, BaseScriptableTypeReference<ScriptableType> rhs)
        {
            if (lhs is null)
            {
                if (rhs is null) return true;
                return false;
            }
            return lhs.Equals(rhs);
        }
        public static bool operator !=(BaseScriptableTypeReference<ScriptableType> lhs, BaseScriptableTypeReference<ScriptableType> rhs) => !(lhs == rhs);

        public static bool operator ==(BaseScriptableTypeReference<ScriptableType> lhs, string rhs)
        {
            if (lhs is null)
            {
                if (rhs is null) return true;
                return false;
            }
            return lhs.Equals(rhs);
        }
        public static bool operator !=(BaseScriptableTypeReference<ScriptableType> lhs, string rhs) => !(lhs == rhs);

        public static bool operator ==(string lhs, BaseScriptableTypeReference<ScriptableType> rhs)
        {
            if (lhs is null)
            {
                if (rhs is null) return true;
                return false;
            }
            return rhs.Equals(lhs);
        }
        public static bool operator !=(string lhs, BaseScriptableTypeReference<ScriptableType> rhs) => !(rhs == lhs);
    }

}