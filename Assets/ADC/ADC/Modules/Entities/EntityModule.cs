using UnityEngine;
using SimpleJSON;


/// <summary>
/// Serves as a base class for entity modules, giving initialization & serialization
/// The general idea behind using entity modules is that they can be mass serialized and provide a consistent way to initialize them
/// </summary>
public partial class EntityModule : MonoBehaviour, ISaveLoad, IJsonSerializable
{

    // Owner & Initialization

    /// <summary>
    /// The entity which owns this module
    /// </summary>
    public Entity owner { get; protected set; }

    /// <summary>
    // Initialize is called by InitializeModule, which we generally do in Awake
    /// </summary>
    /// <param name="entity">Owning entity</param>
    public virtual void Initialize(Entity entity)
    {
        owner = entity;
        UnityEngine.Debug.Assert(owner != null, $"An entity module was Initialized with null character? ({entity.id})");
    }


    // JSON Serialization
    public virtual JSONNode SerializeJSON()
    {
        return new JSONObject();
    }

    public virtual void DeserializeJSON(JSONNode data)
    {

    }

    // ISaveLoad

    public virtual void Save()
    {

    }

    public virtual void Load()
    {

    }

}

