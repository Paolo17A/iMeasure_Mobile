using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModelController : MonoBehaviour
{
    [SerializeField] private ModelCore modelCore;

    private void Awake()
    {
        UnityGameManager.Instance.SceneController.ActionPass = true;
    }

    public void Start()
    {
        modelCore.DisplayProperModel();
        modelCore.SetInitialSliderValues();
        if (UnityGameManager.Instance.ItemType == "WINDOW")
            modelCore.InitializeGlass();
        else
            modelCore.HideSelectedGlassContainer();
    }
}
