using TMPro;
using UnityEngine;

public class QuotationEntryHandler : MonoBehaviour
{
    //=============================================================================================
    [SerializeField] private TextMeshProUGUI quotationNameTMP;
    [SerializeField] private TextMeshProUGUI quotationPriceTMP;
    //=============================================================================================

    public void InitializeQuotationEntry(string name, string price)
    {
        quotationNameTMP.text = name;
        quotationPriceTMP.text = "PHP " + price;
    }
}
