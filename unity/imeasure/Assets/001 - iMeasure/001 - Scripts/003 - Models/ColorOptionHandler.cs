using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorOptionHandler : MonoBehaviour
{
    //=============================================================================================
    [SerializeField] private ModelCore modelCore;

    [SerializeField] private Color colorOption;
    [SerializeField] private string colorName;
    //=============================================================================================

    public void SelectThisColorForFrame()
    {

        modelCore.SetFrameColor(colorName, colorOption);
    }
}
