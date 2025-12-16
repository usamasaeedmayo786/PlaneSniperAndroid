using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

/// <summary>
/// Provides a static interface to create animations of multiple items travelling from one place to another
/// Rendering is done with instancing so the supplied materials must have instanced flag set in editor
/// </summary>
public class TransferAnimation : SafeInstancedManagerMonobehaviour<TransferAnimation>
{
    // Internal

    public class PositionRotationScale
    {
        public Vector3 position;
        public Quaternion rotation;
        public Vector3 scale;

        public PositionRotationScale(Vector3 position, Quaternion rotation, Vector3 scale)
        {
            this.position = position;
            this.rotation = rotation;
            this.scale = scale;
        }
    }

    public class RenderData
    {
        public bool finished = false; // flag to remove this item
        public bool draw = true;
        public Mesh mesh;
        public Material[] materials;

        public Matrix4x4 localMatrix;
        public Matrix4x4 worldMatrix;
    }

    static int MAX_DISPLAY_ITEMS = 32;

    // Internal

    protected Dictionary<Mesh, List<RenderData>> renderBatches = new Dictionary<Mesh, List<RenderData>>();

    private void LateUpdate()
    {
        // Render
        foreach (KeyValuePair<Mesh, List<RenderData>> kv in renderBatches)
        {
            if (kv.Value.Count == 0) continue;

            IEnumerable<RenderData> batch = kv.Value.Where(b => b.draw);
            int count = batch.Count();
            int subCount = Mathf.Min(count, 1024);
            int skip = 0;

            while (subCount > 0)
            {
                RenderData first = kv.Value[0];

                IEnumerable<RenderData> subBatch = batch.Skip(skip).Take(subCount);

                Matrix4x4[] matrixCache = subBatch.Select(item => item.worldMatrix * item.localMatrix).ToArray(); // I think this allocates GC - may be avoidable with ArrayPool

                for (int subMesh = 0; subMesh < first.materials.Length; subMesh++)
                    Graphics.DrawMeshInstanced(first.mesh, subMesh, first.materials[subMesh], matrixCache, subCount);

                skip += subCount;
                count -= subCount;
                subCount = Mathf.Min(count, 1024);
            }
        }

        // Purge
        foreach (KeyValuePair<Mesh, List<RenderData>> kv in renderBatches)
        {
            List<RenderData> batch = kv.Value;
            batch.RemoveAll(item => item.finished);
        }
    }

    private void OnDrawGizmos()
    {
        string o = renderBatches.Count + " batches\n";
        foreach (KeyValuePair<Mesh, List<RenderData>> kv in renderBatches) o += kv.Value.Count + "items\n";
        GameUtil.GizmoString(o, transform.position, 10, Color.black);
    }

    // Public

    public enum PerItemCallbackTiming
    {
        ON_BEGIN,
        ON_FINISH
    }

    static float animationTime => GameSettings.instance.transferAnimationTime;
    static float animationHeight => GameSettings.instance.transferAnimationHeight;
    static float animationRotation => GameSettings.instance.transferAnimationRotation;

    /// <summary>
    /// Creates a transfer animation
    /// </summary>
    /// <param name="mesh">Object mesh</param>
    /// <param name="materials">Object materials</param>
    /// <param name="localPosition">Local position offset of the model</param>
    /// <param name="amount">Amount to animate (may get clipped to MAX 32)</param>
    /// <param name="fromPos">From position</param>
    /// <param name="toPos">To position</param>
    /// <param name="playHaptics">Play haptics during the animation?</param>
    /// <param name="callback">Callback when all items are transferred</param>
    /// <param name="perItemCallback">Callback per each item animated across (may not match amount)</param>
    /// <param name="render">Render the transfer? Sometimes you just might want the callback timings</param>
    static public void CreateAnimation(Mesh mesh, Material[] materials, PositionRotationScale localPosition, double amount, Transform fromPos, Transform toPos, bool playHaptics, System.Action callback = null, System.Action perItemCallback = null, PerItemCallbackTiming perItemCallbackTiming = PerItemCallbackTiming.ON_FINISH, bool render = true)
    {
        instance._CreateAnimation(mesh, materials, localPosition, amount, fromPos, toPos, playHaptics, callback, perItemCallback, perItemCallbackTiming, render);
    }

    void _CreateAnimation(Mesh mesh, Material[] materials, PositionRotationScale localPosition, double amount, Transform fromPos, Transform toPos, bool playHaptics, System.Action callback = null, System.Action perItemCallback = null, PerItemCallbackTiming perItemCallbackTiming = PerItemCallbackTiming.ON_FINISH, bool render = true)
    {
        // Find batch or create one
        List<RenderData> batch;
        List<RenderData> localBatch = new List<RenderData>(MAX_DISPLAY_ITEMS);
        if (renderBatches.ContainsKey(mesh)) batch = renderBatches[mesh];
        else
        {
            batch = new List<RenderData>(MAX_DISPLAY_ITEMS);
            renderBatches.Add(mesh, batch);
        }

        // Create Render Data and add to batch
        for (int i = 0; i < ((amount > MAX_DISPLAY_ITEMS) ? MAX_DISPLAY_ITEMS : amount); i++)
        {
            RenderData rd = new RenderData()
            {
                draw = false,
                mesh = mesh,
                materials = materials,
                localMatrix = Matrix4x4.TRS(localPosition.position, localPosition.rotation, localPosition.scale),
                worldMatrix = Matrix4x4.TRS(fromPos.position, Quaternion.Euler(0, Random.Range(0, 360), 0), Vector3.one),
            };

            if (render) batch.Add(rd);
            localBatch.Add(rd);
        }

        // Find optimal timing
        float delayPerItem = Mathf.Lerp(animationTime / 30f, animationTime / 40f, (localBatch.Count / MAX_DISPLAY_ITEMS));

        // Fire Anims - technically this could all be done more optimally in a single animation.
        for (int i = 0; i < localBatch.Count; i++)
        {
            int index = i;

            CInvoker.InvokeDelayed(() =>
            {

                Vector3 startPos = fromPos.position;
                Quaternion startRot = localBatch[index].worldMatrix.rotation;
                Quaternion endRot = startRot * Quaternion.Euler(0, animationRotation, 0);

                localBatch[index].draw = true;

                // Callback
                if (perItemCallbackTiming == PerItemCallbackTiming.ON_BEGIN)
                {
                    perItemCallback?.Invoke();
                }

                SimpleAnimation.Animate(animationTime, 0, SimpleAnimation.TimeStep.SMOOTH, (dt) =>
                {
                    if (render) localBatch[index].worldMatrix.SetTRS(Vector3.Lerp(startPos, toPos.position, dt) + Vector3.up * FastSin(dt * Mathf.PI) * animationHeight, Quaternion.Slerp(startRot, endRot, dt), Vector3.one);
                },
                () =>
                {
                    if (render)
                    {
                        // Haptic
                        if (playHaptics) HapticUtil.LimitedHaptic(0.1f);

                        // Stop drawing
                        localBatch[index].draw = false;
                        localBatch[index].finished = true;

                        // Reduce FX by only doing one every other hit
                        //if (index % 2 == 0) FXManager.MakeCollectEndEffect(toPos.position);
                    }

                    // Callback
                    if (perItemCallbackTiming == PerItemCallbackTiming.ON_FINISH)
                    {
                        perItemCallback?.Invoke();
                    }

                    // Animation finished event
                    if (index == localBatch.Count - 1)
                    {
                        callback?.Invoke();
                    }

                });

            }, delayPerItem * i);

        }

    }

    // Utility

    // Utility
    static public Vector3 FindMeshScale(Mesh obj, float maxWorldSize)
    {
        Bounds b = obj.bounds;

        float aspect = 0;

        if (b.size.x > b.size.y && b.size.x > b.size.z)         // largest side is x
            aspect = maxWorldSize / b.size.x;
        else if (b.size.y > b.size.x && b.size.y > b.size.z)    // largest side is y
            aspect = maxWorldSize / b.size.y;
        else                                                    // largest side is z
            aspect = maxWorldSize / b.size.z;

        return Vector3.one * aspect;
    }

    static float FastSin(float x) //x in radians
    {
        float sinn;
        if (x < -3.14159265f)
            x += 6.28318531f;
        else
        if (x > 3.14159265f)
            x -= 6.28318531f;

        if (x < 0)
        {
            sinn = 1.27323954f * x + 0.405284735f * x * x;

            if (sinn < 0)
                sinn = 0.225f * (sinn * -sinn - sinn) + sinn;
            else
                sinn = 0.225f * (sinn * sinn - sinn) + sinn;
            return sinn;
        }
        else
        {
            sinn = 1.27323954f * x - 0.405284735f * x * x;

            if (sinn < 0)
                sinn = 0.225f * (sinn * -sinn - sinn) + sinn;
            else
                sinn = 0.225f * (sinn * sinn - sinn) + sinn;
            return sinn;

        }
    }

}