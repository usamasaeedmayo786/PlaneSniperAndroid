using UnityEngine;
using NaughtyAttributes;


/// <summary>
/// Base Game Settings - stores variables that are useful to have globally
/// </summary>

[CreateAssetMenu(menuName = "ADC/GameSettings")]
public partial class GameSettings : SafeInstancedScriptableObject<GameSettings>
{

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Developer Mode

    /// <summary>
    /// General Flag to use 'developer mode' where the game behaves differently
    /// </summary>
    [Header("Developer Mode")]

    public bool useDeveloperMode = false;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Animation Timings

    [Header("Transfer Animation Settings")]

    public float transferAnimationTime = 1.5f;
    public float transferAnimationHeight = 4f;
    public float transferAnimationRotation = 180;

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Layer Utility - Provides faster access to layers than using FindByName

    [Header("Default Layer Lookups")]

    /// <summary>
    /// Player layer. Collides with world layer.
    /// </summary>
    [Layer]
    public int layerPlayer;

    /// <summary>
    /// World layer. Anything that hits the player.
    /// </summary>
    [Layer]
    public int layerWorld;

    /// <summary>
    /// Debris layer. Anything that hits the world but not the player.
    /// </summary>
    [Layer]
    public int layerDebris;

    /// <summary>
    /// Ragdoll layer. For ragdolls!
    /// </summary>
    [Layer]
    public int layerRagdoll;

    /// <summary>
    /// Hitbox layer. Used by some damage systems to determine object hits
    /// </summary>
    [Layer]
    public int layerHitbox;

}

