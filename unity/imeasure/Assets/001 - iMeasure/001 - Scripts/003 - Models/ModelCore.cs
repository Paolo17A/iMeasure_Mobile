using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ModelCore : MonoBehaviour
{
    //=============================================================================================
    [SerializeField] private List<ModelDataHandler> allItemModels;

    [Header("MEASUREMENTS")]
    [SerializeField] private Transform windowContainer;
    [SerializeField] private TextMeshProUGUI widthTMP;
    [SerializeField] private Slider widthSlider;
    [SerializeField] private TextMeshProUGUI heightTMP;
    [SerializeField] private Slider heightSlider;

    [Header("COLOR")]
    [SerializeField][ReadOnly] private string frameColorName;
    [SerializeField] private Material frameMaterial;

    [Header("GLASS")]
    [SerializeField] private TextMeshProUGUI SelectedGlassNameTMP;
    [SerializeField][ReadOnly] private GlassData SelectedGlassData;
    [SerializeField] private List<GlassData> AllAvailableGlass;
    [SerializeField] private GameObject glassContainer;
    [SerializeField] private Transform glassEntriesContainer;
    [SerializeField] private GlassDataHandler glassDataEntryPrefab;
    [SerializeField] private GameObject selectedGlassContainer;
    [SerializeField] private Material glassMaterial;

    [Header("QUOTATION")]
    [SerializeField] private GameObject quotationContainer;
    [SerializeField] private Transform quotationEntriesContainer;
    [SerializeField] private QuotationEntryHandler quotationEntryPrefab;
    [SerializeField] private TextMeshProUGUI totalPriceTMP;

    [Header("DONE")]
    [SerializeField] private GameObject doneContainer;

    //=============================================================================================

    #region INITIALIZATION
    public void DisplayProperModel()
    {
        //  MODEL INITIALIZATION
        foreach (var model in allItemModels)
            model.gameObject.SetActive(false);

        foreach (var model in allItemModels)
            if (model.GetModelName() == UnityGameManager.Instance.CorrespondingModel)
            {
                model.gameObject.SetActive(true);
                break;
            }
        frameColorName = "WHITE";
    }

    public void SetInitialSliderValues()
    {
        widthSlider.minValue = UnityGameManager.Instance.MinWidth;
        widthSlider.maxValue = UnityGameManager.Instance.MaxWidth;
        widthSlider.value = widthSlider.minValue;
        SetNewWidth();
        heightSlider.minValue = UnityGameManager.Instance.MinHeight;
        heightSlider.maxValue = UnityGameManager.Instance.MaxHeight;
        heightSlider.value = heightSlider.minValue;
        SetNewHeight();
    }

    public void InitializeGlass()
    {
        SetSelectedGlass(AllAvailableGlass[0]);
        foreach (Transform child in glassEntriesContainer.transform)
            Destroy(child.gameObject);

        foreach (GlassData glassData in AllAvailableGlass)
        {
            GlassDataHandler glassDataHandler = Instantiate(glassDataEntryPrefab);
            glassDataHandler.InitializeGlassDataHandler(this, glassData);
            glassDataHandler.gameObject.transform.SetParent(glassEntriesContainer);
            glassDataHandler.gameObject.transform.localScale = Vector3.one;
            glassDataHandler.gameObject.transform.localPosition = new Vector3(glassDataHandler.gameObject.transform.localPosition.x, glassDataHandler.gameObject.transform.localPosition.y, 0);
        }
    }

    public void HideSelectedGlassContainer()
    {
        selectedGlassContainer.SetActive(false);
    }

    public void ExitModelScene()
    {
        UnityGameManager.Instance.SceneController.CurrentScene = "MainMenuScene";
    }
    #endregion

    #region MEASUREMENTS
    public void SetNewWidth()
    {
        widthTMP.text = widthSlider.value.ToString("F2") + "FT";
        windowContainer.localScale = new Vector3(1 + (widthSlider.value / 10), windowContainer.localScale.y, windowContainer.localScale.z);
    }

    public void SetNewHeight()
    {
        heightTMP.text = heightSlider.value.ToString("F2") + "FT";
        windowContainer.localScale = new Vector3(windowContainer.localScale.x, 1 + (heightSlider.value / 10), windowContainer.localScale.z);
    }
    #endregion

    #region COLOR
    public void SetFrameColor(string name, Color color)
    {
        frameColorName = name;
        frameMaterial.color = color;
    }
    #endregion

    #region GLASS
    public void SetSelectedGlass(GlassData glassData)
    {
        SelectedGlassData = glassData;
        SelectedGlassNameTMP.text = SelectedGlassData.glassTypeName;
        CloseGlassContainer();
        glassMaterial.color = glassData.glassColor;
    }

    public void DisplayGlassContainer()
    {
        glassContainer.SetActive(true);
    }
    public void CloseGlassContainer()
    {
        glassContainer.SetActive(false);
    }
    #endregion

    #region QUOTATION
    public void GenerateQuotation()
    {
        foreach (Transform child in quotationEntriesContainer.transform)
            Destroy(child.gameObject);
        CalculateTotalMandatoryPayment(frameColorName, UnityGameManager.Instance.ItemFields.Where(itemField => itemField.isMandatory).ToList());
        quotationContainer.SetActive(true);

    }

    public void HideQuotationContainer()
    {
        quotationContainer.SetActive(false);
    }
    private void CalculateTotalMandatoryPayment(string selectedColor,
       List<ItemField> mandatoryWindowFields)
    {
        float totalMandatoryPayment = 0f;

        foreach (var windowSubField in mandatoryWindowFields)
        {
            string priceBasis = windowSubField.priceBasis;
            float price;

            switch (selectedColor)
            {
                case "BROWN":
                    price = (windowSubField.brownPrice) / 21;
                    break;
                case "WHITE":
                    price = (windowSubField.whitePrice) / 21;
                    break;
                case "MATT BLACK":
                    price = (windowSubField.mattBlackPrice) / 21;
                    break;
                case "MATT GRAY":
                    price = (windowSubField.mattGrayPrice) / 21;
                    break;
                case "WOOD FINISH":
                    price = (windowSubField.woodFinishPrice) / 21;
                    break;
                default:
                    price = 0;
                    break;
            }
            QuotationEntryHandler quotationEntry = Instantiate(quotationEntryPrefab);
            quotationEntry.transform.SetParent(quotationEntriesContainer);
            quotationEntry.transform.localScale = Vector3.one;
            quotationEntry.transform.localPosition = new Vector3(quotationEntry.transform.localPosition.x, quotationEntry.transform.localPosition.y, 0);
            switch (priceBasis)
            {
                case "HEIGHT":
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * (heightSlider.value)).ToString("N2"));
                    totalMandatoryPayment += price * (heightSlider.value);
                    break;

                case "WIDTH":
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * (widthSlider.value)).ToString("N2"));
                    totalMandatoryPayment += price * (widthSlider.value);
                    break;

                case "PERIMETER":
                    float perimeter = 2 * ((widthSlider.value) + (heightSlider.value));
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * perimeter).ToString("N2"));
                    totalMandatoryPayment += price * perimeter;
                    break;

                case "PERIMETER DOUBLED":
                    float doubledPerimeter = 2 * 2 * (widthSlider.value + heightSlider.value);
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * doubledPerimeter).ToString("N2"));
                    totalMandatoryPayment += price * doubledPerimeter;
                    break;

                case "STACKED WIDTH":
                    float stackedValue = (2 * heightSlider.value) + (6 * widthSlider.value);
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * stackedValue).ToString("N2"));
                    totalMandatoryPayment += price * stackedValue;
                    break;
            }
        }

        if (UnityGameManager.Instance.ItemType == "WINDOW")
        {
            float glassPrice = SelectedGlassData.pricePerSFT * widthSlider.value * heightSlider.value;
            QuotationEntryHandler quotationEntry = Instantiate(quotationEntryPrefab);
            quotationEntry.transform.SetParent(quotationEntriesContainer);
            quotationEntry.transform.localScale = Vector3.one;
            quotationEntry.transform.localPosition = new Vector3(quotationEntry.transform.localPosition.x, quotationEntry.transform.localPosition.y, 0);
            quotationEntry.InitializeQuotationEntry("Glass: " + SelectedGlassData.glassTypeName, glassPrice.ToString("N2"));
            totalMandatoryPayment += glassPrice;
        }
        totalPriceTMP.text = "PHP " + totalMandatoryPayment.ToString("N2");
    }
    #endregion

    #region CART
    public void AddQuotationToCart()
    {
        //  1. Serialize to JSON
        Dictionary<string, object> quotationMap = new Dictionary<string, object>
        {
            { "color", frameColorName },
            { "glassType", SelectedGlassData.glassTypeName },
            { "height", heightSlider.value },
            { "width", widthSlider.value },
            { "laborPrice", 0},
            { "optionalMap", new Dictionary<string, object>() }
        };

        float totalMandatoryPayment = 0;
        List<Dictionary<string, object>> mandatoryMapList = new List<Dictionary<string, object>>();
        foreach (var windowSubField in UnityGameManager.Instance.ItemFields.Where(itemField => itemField.isMandatory).ToList())
        {
            Dictionary<string, object> mapContent = new Dictionary<string, object>();
            string priceBasis = windowSubField.priceBasis;
            float price;

            //  Get the price based on the currently selected color
            switch (frameColorName)
            {
                case "BROWN":
                    price = (windowSubField.brownPrice) / 21;
                    break;
                case "WHITE":
                    price = (windowSubField.whitePrice) / 21;
                    break;
                case "MATT BLACK":
                    price = (windowSubField.mattBlackPrice) / 21;
                    break;
                case "MATT GRAY":
                    price = (windowSubField.mattGrayPrice) / 21;
                    break;
                case "WOOD FINISH":
                    price = (windowSubField.woodFinishPrice) / 21;
                    break;
                default:
                    price = 0;
                    break;
            }

            //  calculate the subfield's price based on the price basis
            switch (priceBasis)
            {
                case "HEIGHT":
                    mapContent.Add("field", windowSubField.name);
                    mapContent.Add("breakdownPrice", price * heightSlider.value);
                    totalMandatoryPayment += price * (heightSlider.value);
                    break;

                case "WIDTH":
                    mapContent.Add("field", windowSubField.name);
                    mapContent.Add("breakdownPrice", price * widthSlider.value);
                    totalMandatoryPayment += price * (widthSlider.value);
                    break;

                case "PERIMETER":
                    float perimeter = 2 * ((widthSlider.value) + (heightSlider.value));
                    mapContent.Add("field", windowSubField.name);
                    mapContent.Add("breakdownPrice", (price * perimeter));
                    totalMandatoryPayment += price * perimeter;
                    break;

                case "PERIMETER DOUBLED":
                    float doubledPerimeter = 2 * 2 * (widthSlider.value + heightSlider.value);
                    mapContent.Add("field", windowSubField.name);
                    mapContent.Add("breakdownPrice", (price * doubledPerimeter));
                    totalMandatoryPayment += price * doubledPerimeter;
                    break;

                case "STACKED WIDTH":
                    float stackedValue = (2 * heightSlider.value) + (6 * widthSlider.value);
                    mapContent.Add("field", windowSubField.name);
                    mapContent.Add("breakdownPrice", (price * stackedValue));
                    totalMandatoryPayment += price * stackedValue;
                    break;
            }
            mandatoryMapList.Add(mapContent);
        }
        if (UnityGameManager.Instance.ItemType == "WINDOW")
        {
            float glassPrice = SelectedGlassData.pricePerSFT * widthSlider.value * heightSlider.value;
            Dictionary<string, object> glassPair = new Dictionary<string, object>
            {
                { "field", "Glass" },
                { "breakdownPrice", glassPrice }
            };
                mandatoryMapList.Add(glassPair);
                totalMandatoryPayment += glassPrice;                                                                                                                                                    
        }


        quotationMap.Add("mandatoryMap", mandatoryMapList);
        quotationMap.Add("itemOverallPrice", totalMandatoryPayment);
        string serializedString = JsonConvert.SerializeObject(quotationMap);
        Debug.Log(serializedString);
        UnityGameManager.Instance.UnityMessageManager.SendMessageToFlutter(serializedString);
        quotationContainer.gameObject.SetActive(false);
        doneContainer.gameObject.SetActive(true);
    }

    public void RestartModelScene()
    {
        DisplayProperModel();
        SetInitialSliderValues();
        if (UnityGameManager.Instance.ItemType == "WINDOW")
            InitializeGlass();
        else
            HideSelectedGlassContainer();
        doneContainer.gameObject.SetActive(false);
    }
    #endregion

}

public static class WindowSubfields
{
    public const string PriceBasis = "priceBasis";
    public const string BrownPrice = "brownPrice";
    public const string WhitePrice = "whitePrice";
    public const string MattBlackPrice = "mattBlackPrice";
    public const string MattGrayPrice = "mattGrayPrice";
    public const string WoodFinishPrice = "woodFinishPrice";
}