using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterLove.Collections;
using NaughtyAttributes;

/// <summary>
/// Provides an interface to animate things in C#, includes many common helper functions
/// </summary>
public class SimpleAnimation : SafeInstancedManagerMonobehaviour<SimpleAnimation>
{

    public enum TimeStep
    {
        LINEAR,
        SMOOTH
    }

    public class Animation
    {
        public string tag;
        public float time;
        public float delay;
        public TimeStep timeStep;
        public System.Action<float> onFrame;
        public System.Action onComplete;

        public bool isActive;
        public bool isStopped;
        public float dt;

        public void Stop()
        {
            isActive = false;
            isStopped = true;
        }

    }

    [ShowNativeProperty]
    public int numAnimations => animations.Count;

    // Static Interface

    /// <summary>
    /// Core animation function
    /// </summary>
    /// <param name="time">Length of animation</param>
    /// <param name="delay">Delay before animation begins</param>
    /// <param name="timeStep">Use smooth or linear time</param>
    /// <param name="onFrame">Called each frame of the animation, guarenteed to be called on first & last frames</param>
    /// <param name="onComplete">Called when the animation completes</param>
    /// <returns></returns>
    static public Animation Animate(float time, float delay, TimeStep timeStep, System.Action<float> onFrame = null, System.Action onComplete = null, string tag = null)
    {
        Animation anim = instance.animationPool.GetItem();
        anim.time = time;
        anim.delay = delay;
        anim.timeStep = timeStep;
        anim.onFrame = onFrame;
        anim.onComplete = onComplete;
        anim.isActive = true;
        anim.isStopped = false;
        anim.dt = 0;
        anim.tag = tag;

        if (anim.onFrame != null) anim.onFrame.Invoke(0);
        instance.toAdd.Add(anim);

        return anim;
    }

    /// <summary>
    /// Cancels all animations with given tag
    /// </summary>
    /// <param name="tag"></param>
    static public void CancelAnimations(string tag)
    {
        foreach (Animation anim in instance.animations)
        {
            if (!string.IsNullOrEmpty(anim.tag) && anim.tag == tag)
            anim.isStopped = true;
        }
    }

    static public Animation AnimateLinear(float time, float delay, System.Action<float> onFrame = null, System.Action onComplete = null, string tag = null)
    {
        return Animate(time, delay, TimeStep.LINEAR, onFrame, onComplete, tag);
    }

    static public Animation AnimateLinear(float time, System.Action<float> onFrame = null, System.Action onComplete = null, string tag = null)
    {
        return AnimateLinear(time, 0, onFrame, onComplete, tag);
    }

    // Position

    static public Animation AnimatePosition(float time, Transform t, Vector3 to, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.position;
        return Animate(time, 0, timeStep, (float dt) => { t.position = Vector3.Lerp(start, to, dt); }, onComplete, tag);
    }

    static public Animation AnimateLocalPosition(float time, Transform t, Vector3 to, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.localPosition;
        return Animate(time, 0, timeStep, (float dt) => { if (t == null) return;  t.localPosition = Vector3.Lerp(start, to, dt); }, onComplete, tag);
    }

    static public Animation AnimatePosition(float time, Transform t, Transform to, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.position;
        return Animate(time, 0, timeStep, (float dt) => { t.position = Vector3.Lerp(start, to.position, dt); }, onComplete, tag);
    }

    // Rotation

    static public Animation AnimateRotation(float time, Transform t, Quaternion to, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Quaternion startRot = t.rotation;
        return Animate(time, 0, timeStep, (float dt) => { t.rotation = Quaternion.Slerp(startRot, to, dt); }, onComplete, tag);
    }

    static public Animation AnimateRotation(float time, Transform t, Transform to, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Quaternion startRot = t.rotation;
        return Animate(time, 0, timeStep, (float dt) => { t.rotation = Quaternion.Slerp(startRot, to.rotation, dt); }, onComplete, tag);
    }

    // Position & Rotation

    static public Animation AnimatePositionRotation(float time, Transform t, Vector3 toPos, Quaternion toRot, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 startPos = t.position;
        Quaternion startRot = t.rotation;
        return Animate(time, 0, timeStep, (float dt) => {
            t.position = Vector3.Lerp(startPos, toPos, dt);
            t.rotation = Quaternion.Slerp(startRot, toRot, dt);
        }, onComplete, tag);
    }

    static public Animation AnimatePositionRotation(float time, Transform t, Transform toPos, Quaternion toRot, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 startPos = t.position;
        Quaternion startRot = t.rotation;
        return Animate(time, 0, timeStep, (float dt) => {
            t.position = Vector3.Lerp(startPos, toPos.position, dt);
            t.rotation = Quaternion.Slerp(startRot, toRot, dt);
        }, onComplete, tag);
    }

    // Position with height curve

    static public Animation AnimateLocalPositionHeightCurve(float time, Transform t, Vector3 to, float height = 1.5f, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.localPosition;
        return Animate(time, 0, timeStep, (float dt) => {
            if (t == null) return;
            t.localPosition = Vector3.Lerp(start, to, dt) + Vector3.up * Mathf.Sin(dt * Mathf.PI) * height; 
        }, onComplete, tag);
    }

    static public Animation AnimatePositionHeightCurve(float time, Transform t, Vector3 to, float height = 1.5f, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.position;
        return Animate(time, 0, timeStep, (float dt) => {
            if (t == null) return;
            t.position = Vector3.Lerp(start, to, dt) + Vector3.up * Mathf.Sin(dt * Mathf.PI) * height;
        }, onComplete, tag);
    }

    static public Animation AnimatePositionHeightCurve(float time, Transform t, Transform to, float height = 1.5f, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.position;
        return Animate(time, 0, timeStep, (float dt) => {
            if (t == null || to == null) return; 
            t.position = Vector3.Lerp(start, to.position, dt) + Vector3.up * Mathf.Sin(dt * Mathf.PI) * height;
        }, onComplete, tag);
    }

    // Position and rotation with height curve

    static public Animation AnimatePositionRotationHeightCurve(float time, Transform t, Transform toPos, Quaternion toRot, float height = 1.5f, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 startPos = t.position;
        Quaternion startRot = t.rotation;
        return Animate(time, 0, timeStep, (float dt) => {
            if (t == null || toPos == null) return;
            t.position = Vector3.Lerp(startPos, toPos.position, dt) + Vector3.up * Mathf.Sin(dt * Mathf.PI) * height;
            t.rotation = Quaternion.Slerp(startRot, toRot, dt);
        }, onComplete, tag);
    }

    static public Animation AnimatePositionRotationHeightCurve(float time, Transform t, Vector3 toPos, Quaternion toRot, float height = 1.5f, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 startPos = t.position;
        Quaternion startRot = t.rotation;
        return Animate(time, 0, timeStep, (float dt) => {
            if (t == null) return;
            t.position = Vector3.Lerp(startPos, toPos, dt) + Vector3.up * Mathf.Sin(dt * Mathf.PI) * height;
            t.rotation = Quaternion.Slerp(startRot, toRot, dt);
        }, onComplete, tag);
    }

    static public Animation AnimateLocalPositionRotationHeightCurve(float time, Transform t, Vector3 toPos, Quaternion toRot, float height = 1.5f, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 startPos = t.localPosition;
        Quaternion startRot = t.localRotation;
        return Animate(time, 0, timeStep, (float dt) => {
            if (t == null) return;
            t.localPosition = Vector3.Lerp(startPos, toPos, dt) + Vector3.up * Mathf.Sin(dt * Mathf.PI) * height;
            t.localRotation = Quaternion.Slerp(startRot, toRot, dt);
        }, onComplete, tag);
    }

    // Scale

    static public Animation AnimateLocalScaleTo1(float time, Transform t, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.localScale;
        return Animate(time, 0, timeStep, (float dt) => { 
            if (t != null) 
                t.localScale = Vector3.one * dt;
        }, onComplete, tag);
    }

    static public Animation AnimateLocalScaleTo0(float time, Transform t, System.Action onComplete = null, TimeStep timeStep = TimeStep.LINEAR, string tag = null)
    {
        Vector3 start = t.localScale;
        return Animate(time, 0, timeStep, (float dt) => { 
            if (t != null) 
                t.localScale = start * (1-dt); 
        }, onComplete, tag);
    }

    // Internal

    const int MAX_ANIMATIONS = 200;

    private ObjectPool<Animation> animationPool;

    private List<Animation> animations = new List<Animation>(MAX_ANIMATIONS);
    private List<Animation> toAdd = new List<Animation>(MAX_ANIMATIONS);
    private List<Animation> toRemove = new List<Animation>(MAX_ANIMATIONS);

    private void Awake()
    {
        animationPool = new ObjectPool<Animation>(() => { return new Animation(); }, MAX_ANIMATIONS); // Note this creates a limit of 200 simultaneous animations - "should be enough" - mercior
    }

    private void Update()
    {
        toRemove.Clear();

        // Add
        if (toAdd.Count > 0)
        {
            foreach (Animation anim in toAdd) animations.Add(anim);
            toAdd.Clear();
        }

        // Update
        foreach (Animation anim in animations)
        {
            if (anim.delay > 0)
            {
                anim.delay -= Time.deltaTime;
                continue;
            }

            if (anim.isStopped)
            {
                toRemove.Add(anim);
                continue;
            }

            anim.dt = Mathf.Clamp01(anim.dt + Time.deltaTime / anim.time);

            anim.onFrame?.Invoke(anim.timeStep == TimeStep.LINEAR ? anim.dt : Mathf.SmoothStep(0, 1, anim.dt));

            if (anim.dt == 1)
            {
                anim.onComplete?.Invoke();
                toRemove.Add(anim);
                continue;
            }
        }

        // Remove
        foreach (Animation anim in toRemove)
        {
            anim.isActive = false;
            animations.Remove(anim);
            animationPool.ReleaseItem(anim);
        }
    }

}
