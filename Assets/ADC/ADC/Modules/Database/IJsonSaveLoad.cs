using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SimpleJSON;

public interface IJsonSerializable
{

    public JSONNode SerializeJSON();

    public void DeserializeJSON(JSONNode data);

}
