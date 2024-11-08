using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class GlassDataHandler : MonoBehaviour
{
    //=============================================================================================
    [ReadOnly] public GlassData thisGlassData;
    [SerializeField][ReadOnly] private ModelCore modelCore;
    [SerializeField] private TextMeshProUGUI glassNameTMP;
    [SerializeField] private TextMeshProUGUI glassPriceTMP;
    //=============================================================================================

    public void InitializeGlassDataHandler(ModelCore modelCore, GlassData glassData)
    {
        this.modelCore = modelCore;
        thisGlassData = glassData;
        glassNameTMP.text = thisGlassData.glassTypeName;
        glassPriceTMP.text = "PHP " + thisGlassData.pricePerSFT.ToString("n0");
    }

    public void SelectThisGlass()
    {
        modelCore.SetSelectedGlass(thisGlassData);
    }
}
