/*
Original Copyright (c) 2015 Funonium (Jade Skaggs)
Modified by ADC (Paul Blower)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Enables invokation of functions without regard to timeScale
/// </summary>
public class CInvoker : MonoBehaviour {

	/// <summary>
	/// Timed function handle that allows to cancel it or change repetitions
	/// </summary>
	public class CallHandle
    {
		string id;
		public CallHandle(string id) { this.id = id; }

		/// <summary>
		/// Adds repetitions to a timer.
		/// </summary>
		public void AddRepetitions(int num)
        {
			CInvoker.AddRepetitions(id, num);
        }

		/// <summary>
		/// Returns false if the timer has expired / been removed
		/// </summary>
		/// <returns></returns>
		public bool IsValid()
        {
			return CInvoker.HasTimer(id);
        }

		/// <summary>
		/// Attempts to cancel the timer, assuming it didn't already finish
		/// </summary>
		public void Cancel()
        {
			CInvoker.CancelInvoke(id);
        }
    }

	private class InvokableItem
	{
		public System.Action func;
		public float executeAtTime;
		public string id;
		public float delay;
		public int repetitions;
		public InvokableItem(System.Action func, float delay, string id = "", int repetitions = 1)
		{
			this.func = func;
			this.id = id;
			this.delay = delay;
			this.repetitions = repetitions;

			// realtimeSinceStartup is never 0, and Time.time is affected by timescale (though it is 0 on startup).  Use a combination 
			// http://forum.unity3d.com/threads/205773-realtimeSinceStartup-is-not-0-in-first-Awake()-call
			if (Time.time == 0) 
				this.executeAtTime = delay;
			else
				this.executeAtTime = Time.realtimeSinceStartup + delay;
			
		}
	}
	
	private static CInvoker _instance = null;
	public static CInvoker Instance
	{
		get
		{
			if( _instance == null )
			{
				GameObject go = new GameObject();
				go.AddComponent<CInvoker>();
				go.name = "_FunoniumInvoker";
				_instance = go.GetComponent<CInvoker>();
			}
			return _instance;
		}
	}

	float fRealTimeLastFrame = 0;
	float fRealDeltaTime = 0;

	List<InvokableItem> invokeList = new List<InvokableItem>();
	List<InvokableItem> invokeListPendingAddition = new List<InvokableItem>();

	public float RealDeltaTime()
	{
		return fRealDeltaTime;	
	}
	/// <summary>
	/// Invokes the function with a time delay. This is NOT affected by timeScale
	/// </summary>
	/// <param name='func'>
	/// Function to invoke
	/// </param>
	/// <param name='delaySeconds'>
	/// Delay in seconds.
	/// </param>
	public static void InvokeDelayed(System.Action func, float delaySeconds = 0, string id = "")
	{
		Instance.invokeListPendingAddition.Add(new InvokableItem(func, delaySeconds, id));
	}

	/// <summary>
	/// Invokes a repeating function after some delay
	/// </summary>
	/// <param name="func">Function to invoke</param>
	/// <param name="delaySeconds">Delay in seconds.</param>
	/// <param name="repetitions">Number of repetitions</param>
	/// <param name="id">Optional timer id for use in changing repetitions or cancelling</param>
	public static void InvokeDelayedRepeating(System.Action func, float delaySeconds = 0, int repetitions = 1, string id = "")
	{
		Instance.invokeListPendingAddition.Add(new InvokableItem(func, delaySeconds, id, repetitions));
	}

	/// <summary>
	/// Invokes the function with a time delay. This is NOT affected by timeScale
	/// </summary>
	/// <param name="func">Function to invoke</param>
	/// <param name="delaySeconds">Delay in seconds.</param>
	/// <param name="repetitions">Number of repetitions</param>
	/// <returns>CallHandle object that allows you to cancel the timer or modify its repetitions</returns>
	public static CallHandle InvokeDelayedCancelable(System.Action func, float delaySeconds = 0, int repetitions = 1)
	{
		string id = System.Guid.NewGuid().ToString();
		Instance.invokeListPendingAddition.Add(new InvokableItem(func, delaySeconds, id, repetitions));
		return new CallHandle(id);
	}

	/// <summary>
	/// Cancels all active invoke calls
	/// </summary>
	public static void CancelAll()
	{
		Instance.invokeList.ForEach(item => item.repetitions = 0);
	}

	/// <summary>
	/// Cancel the invokation of a timer with given id
	/// </summary>
	/// <param name="id"></param>
	/// <returns>true if one or more timers were found to cancel</returns>
	new public static bool CancelInvoke(string id)
	{
		List<InvokableItem> matches = Instance.invokeList.FindAll(item => item.id == id);
		matches.ForEach(item => item.repetitions = 0);

		return matches.Count > 0;
	}

	/// <summary>
	/// Do we own a timer with ID?
	/// </summary>
	/// <param name="id"></param>
	/// <returns></returns>
	public static bool HasTimer(string id)
    {
		return Instance.invokeList.FindIndex(item => item.id == id) >= 0;
    }

	/// <summary>
	/// Adds repetitions to a timer.
	/// </summary>
	/// <param name="timerID"></param>
	/// <param name="num"></param>
	/// <returns></returns>
	public static void AddRepetitions(string timerID, int num)
	{
		List<InvokableItem> matches = Instance.invokeList.FindAll(item => item.id == timerID);
		matches.ForEach(item => item.repetitions += num);
	}

	void Start() {
		DontDestroyOnLoad( gameObject );
	}

	// must be maanually called from a game controller or something similar every frame
	public void Update()
	{
		fRealDeltaTime = Time.realtimeSinceStartup - fRealTimeLastFrame;
		fRealTimeLastFrame = Time.realtimeSinceStartup;
		
		// Copy pending additions into the list (Pending addition list 
		// is used because some invokes add a recurring invoke, and
		// this would modify the collection in the next loop, 
		// generating errors)
		foreach(InvokableItem item in invokeListPendingAddition)
		{
			invokeList.Add(item);	
		}
		invokeListPendingAddition.Clear();

		// make calls
		foreach (InvokableItem item in invokeList)
		{
			if (item.executeAtTime <= Time.realtimeSinceStartup)	
			{
				// execute - double check the repetitions here, as  0 would mean it got cancelled
				if (item.repetitions > 0) item.func?.Invoke();

				// repetition
				item.repetitions = item.repetitions - 1;
				if (item.repetitions > 0)
                {
					item.executeAtTime = Time.realtimeSinceStartup + item.delay;
				}

			}
		}

		// Remove invoked items from the list.
		invokeList.RemoveAll(item => item.repetitions <= 0);
	}
}