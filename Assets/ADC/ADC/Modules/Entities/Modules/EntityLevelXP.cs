using UnityEngine;
using SimpleJSON;

public class EntityLevelXP : EntityModule
{
    public System.Action onXPChanged = delegate () { };
    public System.Action onLevelUp = delegate () { };

    public double xp;
    public int level;

    /// <summary>
    /// XP required to Level
    /// </summary>
    public virtual double xp2l
    {
        get
        {
            return 10 * Mathf.Pow(2, level);
        }
    }

    /// <summary>
    /// Will we level up if we add this much XP ?
    /// </summary>
    /// <param name="addXP"></param>
    /// <returns></returns>
    public virtual bool WillLevelUp(double addXP)
    {
        return xp + addXP >= xp2l;
    }

    /// <summary>
    /// Adds XP, causing a level up event if it happens
    /// </summary>
    /// <param name="amt">Amount of XP to add</param>
    /// <param name="surpressEvent">Prevent onXPChanged from being called</param>
    /// <returns></returns>
    public virtual bool AddXP(double amt, bool surpressEvent = false)
    {
        bool levelledUp = false;
        double currentXP = xp;
        currentXP += amt;

        // Level Up
        if (currentXP >= xp2l)
        {
            levelledUp = true;
            currentXP = 0;
            level++;
            onLevelUp.Invoke();
        }

        xp = currentXP;

        Save();

        // Event
        if (!surpressEvent) onXPChanged.Invoke();

        return levelledUp;
    }

    /// <summary>
    /// Manually set the XP value
    /// </summary>
    /// <param name="amt">XP value</param>
    /// <param name="surpressEvent">Prevent onXPChanged from being called</param>
    public virtual void SetXP(double amt, bool surpressEvent = false)
    {
        xp = amt;
        Save();
        // Event
        if (!surpressEvent) onXPChanged.Invoke();
    }

    /// <summary>
    /// Is our level >= the supplied level?
    /// </summary>
    /// <param name="lvl">Level</param>
    /// <returns>TRUE if level is >= given value</returns>
    public virtual bool HasLevel(int lvl)
    {
        return level >= lvl;
    }

    // IJSONSerialzable
    public override JSONNode SerializeJSON()
    {
        JSONNode node = new JSONObject();
        node.Add("level", level);
        node.Add("xp", xp);
        return node;
    }

    public override void DeserializeJSON(JSONNode data)
    {
        if (data.HasKey("level")) level = data["level"].AsInt;
        if (data.HasKey("xp")) xp = data["xp"].AsDouble;
    }

    // ISaveLoad

    public override void Save()
    {
        Database.WriteAsync(owner.id, "levelxp", SerializeJSON().ToString(), (success, error) => { });
    }

    public override void Load()
    {
        Database.ReadAsync<string>(owner.id, "levelxp", (success, data) => {
            if (success && !string.IsNullOrEmpty(data))
                DeserializeJSON(JSON.Parse(data));
        });
    }
}

