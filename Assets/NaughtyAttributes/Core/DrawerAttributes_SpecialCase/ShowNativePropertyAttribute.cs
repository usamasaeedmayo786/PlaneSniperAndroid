using System;

namespace NaughtyAttributes
{
	[AttributeUsage(AttributeTargets.Property, AllowMultiple = false, Inherited = true)]
	public class ShowNativePropertyAttribute : SpecialCaseDrawerAttribute
	{
		public string Label { get; private set; }

		public ShowNativePropertyAttribute()
		{

		}

		public ShowNativePropertyAttribute(string label)
		{
			Label = label;
		}
	}
}
