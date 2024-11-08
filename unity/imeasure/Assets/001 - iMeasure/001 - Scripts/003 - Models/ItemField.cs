using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class ItemField
{
    public string name;
    public bool isMandatory;

    [Header("PRICES")]
    public string priceBasis;
    public float brownPrice;
    public float mattBlackPrice;
    public float mattGrayPrice;
    public float woodFinishPrice;
    public float whitePrice;
}
