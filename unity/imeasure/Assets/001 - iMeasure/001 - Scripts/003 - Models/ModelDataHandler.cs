using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModelDataHandler : MonoBehaviour
{
    //=============================================================================================
    [SerializeField] private string modelName;
    //=============================================================================================

    public string GetModelName()
    {
        return modelName;
    }
}
