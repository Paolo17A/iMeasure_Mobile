using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "GlassData", menuName = ("iMeasure/Data/GlassData"))]
public class GlassData : ScriptableObject
{
    public string glassTypeName;
    public string thickness;
    public float pricePerSFT;
    public Color glassColor;
}
