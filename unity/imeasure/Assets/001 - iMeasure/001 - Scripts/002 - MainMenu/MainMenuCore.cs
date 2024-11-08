using Newtonsoft.Json;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Networking;
using static MainMenuCore;

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
            DocumentResponse document = JsonConvert.DeserializeObject<DocumentResponse>(jsonResponse);
            Debug.Log(jsonResponse); // Log or process data here
     

            UnityGameManager.Instance.ItemType = document.fields["itemType"].stringValue;
            UnityGameManager.Instance.Name = document.fields["name"].stringValue;
            UnityGameManager.Instance.MinWidth = document.fields["minWidth"].integerValue ?? 0;
            UnityGameManager.Instance.MaxWidth = document.fields["maxWidth"].integerValue ?? 0;
            UnityGameManager.Instance.MinHeight = document.fields["minHeight"].integerValue ?? 0;
            UnityGameManager.Instance.MaxHeight = document.fields["maxHeight"].integerValue ?? 0;
            UnityGameManager.Instance.CorrespondingModel = document.fields["correspondingModel"].stringValue;

            UnityGameManager.Instance.ItemFields.Clear();
            for (int i = 0; i < document.fields["windowFields"].arrayValue.values.Count; i++)
            {
                Dictionary<string, Dictionary<string, object>> itemFields = document.fields["windowFields"].arrayValue.values[i]["mapValue"]["fields"];
                ItemField itemField = new ItemField();
                itemField.name = itemFields["name"]["stringValue"].ToString();
                itemField.isMandatory = (bool) itemFields["isMandatory"]["booleanValue"];
                itemField.priceBasis = itemFields["priceBasis"]["stringValue"].ToString();

                itemField.brownPrice =  itemFields["brownPrice"].ContainsKey("doubleValue") 
                    ? float.Parse(itemFields["brownPrice"]["doubleValue"].ToString()) 
                    : int.Parse(itemFields["brownPrice"]["integerValue"].ToString());
                itemField.whitePrice = itemFields["whitePrice"].ContainsKey("doubleValue") 
                    ? float.Parse(itemFields["whitePrice"]["doubleValue"].ToString()) 
                    : int.Parse(itemFields["whitePrice"]["integerValue"].ToString());
                itemField.woodFinishPrice = itemFields["woodFinishPrice"].ContainsKey("doubleValue") 
                    ? float.Parse(itemFields["woodFinishPrice"]["doubleValue"].ToString()) 
                    : int.Parse(itemFields["woodFinishPrice"]["integerValue"].ToString());
                itemField.mattBlackPrice = itemFields["mattBlackPrice"].ContainsKey("doubleValue") 
                    ? float.Parse(itemFields["mattBlackPrice"]["doubleValue"].ToString()) 
                    : int.Parse(itemFields["mattBlackPrice"]["integerValue"].ToString());
                itemField.mattGrayPrice = itemFields["mattGrayPrice"].ContainsKey("doubleValue") 
                    ? float.Parse(itemFields["mattGrayPrice"]["doubleValue"].ToString()) 
                    : int.Parse(itemFields["mattGrayPrice"]["integerValue"].ToString());

                UnityGameManager.Instance.ItemFields.Add(itemField);
            }
            UnityGameManager.Instance.LoadingPanel.SetActive(false);
            UnityGameManager.Instance.SceneController.CurrentScene = "ModelScene";
        }
        else
        {
            Debug.LogError("Failed to fetch document: " + request.error);
        }
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
        public DocumentResponse fields { get; set; }   
    }

    public class ArrayValue
    {
       public List<Dictionary<string, Dictionary<string, Dictionary<string, Dictionary<string, object>>>>> values;
    }
}
