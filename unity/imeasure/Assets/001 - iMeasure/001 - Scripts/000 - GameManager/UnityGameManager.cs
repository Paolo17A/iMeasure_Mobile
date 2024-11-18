using FlutterUnityIntegration;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/* The GameManager is the central core of the game. It persists all throughout run-time 
 * and stores universal game objects and variables that need to be used in multiple scenes. */
public class UnityGameManager : MonoBehaviour
{
    #region VARIABLES
    //===========================================================
    private static UnityGameManager _instance;

    public static UnityGameManager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<UnityGameManager>();

                if (_instance == null)
                    _instance = new GameObject().AddComponent<UnityGameManager>();
            }

            return _instance;
        }
    }


    [field: SerializeField] public List<GameObject> GameMangerObj { get; set; }

    [field: SerializeField] public bool DebugMode { get; set; }
    [SerializeField] private string SceneToLoad;
    [field: SerializeField][field: ReadOnly] public bool CanUseButtons { get; set; }

    [field: Header("CAMERA")]
    [field: SerializeField] public Camera MainCamera { get; set; }
    [field: SerializeField] public Camera MyUICamera { get; set; }

    [field: Header("MISCELLANEOUS SCRIPTS")]  
    [field: SerializeField] public SceneController SceneController { get; set; }    
    [field: SerializeField] public AnimationsLT AnimationsLT { get; set; }
    [field: SerializeField] public UnityMessageManager UnityMessageManager { get; set; }

    [field: Header("ITEM VARIABLES")]
    [field: SerializeField] public string ItemID { get;set; }
    [field: SerializeField] public string ItemType { get;set; }
    [field: SerializeField] public string Name { get;set; }
    [field: SerializeField] public float MinWidth {  get; set; }
    [field: SerializeField] public float MaxWidth { get; set; }
    [field: SerializeField] public float MinHeight { get; set; }
    [field: SerializeField] public float MaxHeight { get; set; }
    [field: SerializeField] public bool HasGlass { get; set; }
    [field: SerializeField] public string CorrespondingModel { get; set; }
    [field: SerializeField] public List<ItemField> ItemFields { get;set; }
    [field: SerializeField] public List<AccessoryField> AccessoryFields { get; set; }

    [field: Header("LOADING PANEL")]
    [field: SerializeField] public GameObject LoadingPanel { get; set; }
    //===========================================================
    #endregion

    #region CONTROLLER FUNCTIONS
    private void Awake()
    {
        if (_instance != null)
        {
            for (int a = 0; a < GameMangerObj.Count; a++)
                Destroy(GameMangerObj[a]);
        }

        for (int a = 0; a < GameMangerObj.Count; a++)
            DontDestroyOnLoad(GameMangerObj[a]);
    }

    private void Start()
    {
        SceneController.CurrentScene = "MainMenuScene";
    }
    #endregion

    #region FLUTTER
    public void SetItem(string message)
    {
        ItemID = message;
    }
    #endregion
}
