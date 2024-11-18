using Newtonsoft.Json;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Networking;

public class MainMenuCore : MonoBehaviour
{
    private string baseUrl = "https://firestore.googleapis.com/v1/projects/imeasure-capstone/databases/(default)/documents";

    public void GetItemDocumentFromFirebase()
    {
        string url = $"{baseUrl}/{"items"}/{UnityGameManager.Instance.ItemID}";
        StartCoroutine(GetDocumentCoroutine(url));
    }

    private IEnumerator GetDocumentCoroutine(string url)
    {
        UnityGameManager.Instance.LoadingPanel.SetActive(true);
        UnityWebRequest request = UnityWebRequest.Get(url);

        yield return request.SendWebRequest();

        if (request.result == UnityWebRequest.Result.Success)
        {
            Debug.Log("Document fetched successfully");
            string jsonResponse = request.downloadHandler.text;
            // Parse JSON response if needed
            Debug.Log(jsonResponse); // Log or process data here

            DocumentResponse document = JsonConvert.DeserializeObject<DocumentResponse>(jsonResponse);


            UnityGameManager.Instance.ItemType = document.fields["itemType"].stringValue;
            UnityGameManager.Instance.Name = document.fields["name"].stringValue;
            UnityGameManager.Instance.MinWidth = document.fields["minWidth"].integerValue ?? 0;
            UnityGameManager.Instance.MaxWidth = document.fields["maxWidth"].integerValue ?? 0;
            UnityGameManager.Instance.MinHeight = document.fields["minHeight"].integerValue ?? 0;
            UnityGameManager.Instance.MaxHeight = document.fields["maxHeight"].integerValue ?? 0;
            UnityGameManager.Instance.CorrespondingModel = document.fields["correspondingModel"].stringValue;
            UnityGameManager.Instance.HasGlass = document.fields["hasGlass"].booleanValue ?? false;
            UnityGameManager.Instance.ItemFields.Clear();
            for (int i = 0; i < document.fields["windowFields"].arrayValue.values.Count; i++)
            {
                //Dictionary<string, Dictionary<string, object>> itemFields = document.fields["windowFields"].arrayValue.values[i]["mapValue"]["fields"];

                FirestoreField itemFieldsMap = document.fields["windowFields"].arrayValue.values[i];
                Debug.Log("itemFieldsMap: " + itemFieldsMap.mapValue);
                Dictionary<string, FirestoreField> itemFields = itemFieldsMap.mapValue.fields;

                ItemField itemField = new ItemField();
                itemField.name = itemFields["name"].stringValue;
                itemField.isMandatory = (bool)itemFields["isMandatory"].booleanValue;
                itemField.priceBasis = itemFields["priceBasis"].stringValue;
                itemField.brownPrice = itemFields["brownPrice"].doubleValue ?? (float)itemFields["brownPrice"].integerValue.GetValueOrDefault();
                itemField.whitePrice = itemFields["whitePrice"].doubleValue ?? (float)itemFields["whitePrice"].integerValue.GetValueOrDefault();
                itemField.woodFinishPrice = itemFields["woodFinishPrice"].doubleValue ?? (float)itemFields["woodFinishPrice"].integerValue.GetValueOrDefault();
                itemField.mattBlackPrice = itemFields["mattBlackPrice"].doubleValue ?? (float)itemFields["mattBlackPrice"].integerValue.GetValueOrDefault();
                itemField.mattGrayPrice = itemFields["mattGrayPrice"].doubleValue ?? (float)itemFields["mattGrayPrice"].integerValue.GetValueOrDefault();

                UnityGameManager.Instance.ItemFields.Add(itemField);
            }
            for(int i = 0; i < document.fields["accessoryFields"].arrayValue.values.Count; i++)
            {
                FirestoreField accessoryFieldsMap = document.fields["accessoryFields"].arrayValue.values[i];
                Dictionary<string, FirestoreField> accessoryFields = accessoryFieldsMap.mapValue.fields;

                AccessoryField accessoryField = new AccessoryField();
                accessoryField.name = accessoryFields["name"].stringValue;
                accessoryField.price = accessoryFields["price"].doubleValue ?? (float)accessoryFields["price"].integerValue.GetValueOrDefault();
                UnityGameManager.Instance.AccessoryFields.Add(accessoryField);
            }
            UnityGameManager.Instance.LoadingPanel.SetActive(false);
            UnityGameManager.Instance.SceneController.CurrentScene = "ModelScene";
        }
        else
        {
            Debug.LogError("Failed to fetch document: " + request.error);
        }
    }

    public void QuitGameplay()
    {
        UnityGameManager.Instance.UnityMessageManager.SendMessageToFlutter("QUIT");
    }

    public class DocumentResponse
    {
        public Dictionary<string, FirestoreField> fields { get; set; }
    }

    public class FirestoreField
    {
        public string stringValue { get; set; }
        public int? integerValue { get; set; }
        public float? doubleValue { get; set; }
        public bool? booleanValue { get; set; }
        public ArrayValue arrayValue { get; set; }
        public MapValue mapValue { get; set; }
        //public DocumentResponse fields { get; set; }   
    }

    //public class ArrayValue
    //{
    //   public List<Dictionary<string, Dictionary<string, Dictionary<string, Dictionary<string, object>>>>> values;
    //}

    public class ArrayValue
    {
        public List<FirestoreField> values { get; set; }
    }

    public class MapValue
    {
        public Dictionary<string, FirestoreField> fields { get; set; }
    }
}
