using System.Text;

/// <summary>
/// Provides functions for formatting currency values
/// </summary>
public class CurrencyUtil
{
    // Static Util

    static public string[] suffixes = new string[] { "k", "M", "B", "T", "Qd", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qud", "Qid", "Sxd", "Spd", "Ocd", "Nod" };

    static public string GetSuffix(double value)
    {
        for (int i = suffixes.Length - 1; i >= 0; i--)
        {
            double b = System.Math.Pow(10, i * 3 + 3);
            if (value / b >= 1)
            {
                return suffixes[i];
            }
        }
        return "";
    }

    static public double GetSuffixMultiplier(string suffix)
    {
        for (int i = suffixes.Length - 1; i >= 0; i--)
        {
            double b = System.Math.Pow(10, i * 3 + 3);
            if (suffixes[i] == suffix)
            {
                return b;
            }
        }
        return 1;
    }

    static public string Format(double value, double decimalPlaces = 2, string symbol = null)
    {
        StringBuilder builder = new StringBuilder();
        for (int i = suffixes.Length - 1; i >= 0; i--)
        {
            double b = System.Math.Pow(10, i * 3 + 3);

            if (value / b >= 1)
            {
                if (!string.IsNullOrEmpty(symbol)) builder.Append(symbol);
                builder.Append((System.Math.Round(value / (b / System.Math.Pow(10, decimalPlaces))) / System.Math.Pow(10, decimalPlaces)));
                //builder.Append(" ");
                builder.Append(suffixes[i]);
                return builder.ToString();
            }
        }

        if (!string.IsNullOrEmpty(symbol)) builder.Append(symbol);
        builder.Append(System.Math.Round(value * System.Math.Pow(10, decimalPlaces)) / System.Math.Pow(10, decimalPlaces));
        return builder.ToString();
    }

    /// <summary>
    /// Formats a number value to a string. Decimal places are always used, eg: 1 = 1.00, 1231 = 1.23k
    /// </summary>
    static public string FormatNumber(double value, double decimalPlaces = 2, string prefix = null, string suffix = null)
    {
        StringBuilder builder = new StringBuilder();
        if (!string.IsNullOrEmpty(prefix)) builder.Append(prefix);
        for (int i = suffixes.Length - 1; i >= 0; i--)
        {
            double b = System.Math.Pow(10, i * 3 + 3);

            if (value / b >= 1)
            {
                builder.Append((System.Math.Round(value / (b / System.Math.Pow(10, decimalPlaces))) / System.Math.Pow(10, decimalPlaces)));
                builder.Append(suffixes[i]);
                return builder.ToString();
            }
        }

        builder.Append(System.Math.Round(value * System.Math.Pow(10, decimalPlaces)) / System.Math.Pow(10, decimalPlaces));
        if (!string.IsNullOrEmpty(suffix)) builder.Append(suffix);
        return builder.ToString();
    }

}

