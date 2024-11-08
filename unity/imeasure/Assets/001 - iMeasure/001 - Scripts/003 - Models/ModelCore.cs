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
    [SerializeField] private string frameColorName;
    [SerializeField] private Material frameMaterial;

    [Header("QUOTATION")]
    [SerializeField] private GameObject quotationContainer;
    [SerializeField] private Transform quotationEntriesContainer;
    [SerializeField] private QuotationEntryHandler quotationEntryPrefab;
    [SerializeField] private TextMeshProUGUI totalPriceTMP;
    //=============================================================================================

    #region INITIALIZATION
    public void DisplayProperModel()
    {
        foreach (var model in allItemModels)
            model.gameObject.SetActive(false);
        
        foreach (var model in allItemModels)
            if(model.GetModelName() == UnityGameManager.Instance.CorrespondingModel)
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


    #region QUOTATION
    public void GenerateQuotation()
    {
        foreach(Transform child in quotationEntriesContainer.transform) 
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
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * (heightSlider.value)).ToString("F2"));
                    totalMandatoryPayment += price * (heightSlider.value);
                    break;

                case "WIDTH":
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * (widthSlider.value)).ToString("F2"));
                    totalMandatoryPayment += price * (widthSlider.value);
                    break;

                case "PERIMETER":
                    float perimeter = 2 * ((widthSlider.value) + (heightSlider.value));
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * perimeter).ToString("F2"));
                    totalMandatoryPayment += price * perimeter;
                    break;

                case "PERIMETER DOUBLED":
                    float doubledPerimeter = 2 * 2 * (widthSlider.value + heightSlider.value);
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * doubledPerimeter).ToString("F2"));
                    totalMandatoryPayment += price * doubledPerimeter;
                    break;

                case "STACKED WIDTH":
                    float stackedValue = (2 * heightSlider.value) + (6 * widthSlider.value);
                    quotationEntry.InitializeQuotationEntry(windowSubField.name, (price * stackedValue).ToString("F2"));
                    totalMandatoryPayment += price * stackedValue;
                    break;
            }
        }

        totalPriceTMP.text = "PHP " + totalMandatoryPayment.ToString("F2");
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