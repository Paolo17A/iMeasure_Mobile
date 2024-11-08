using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CanvasUICameraSetter : MonoBehaviour
{
    public Canvas canvas;

    private void OnEnable()
    {
        canvas.worldCamera = UnityGameManager.Instance.MyUICamera;
    }
}
