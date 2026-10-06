using Avalonia.Controls;

namespace AvaloniaApplication1.Views;

public partial class CalendarView : UserControl
{
    public CalendarView()
    {
        InitializeComponent();
        TitleText.Text = "Календарь";
        MonthText.Text = "Май 2024";
        D1.Text = "Пн";
        D2.Text = "Вт";
        D3.Text = "Ср";
        D4.Text = "Чт";
        D5.Text = "Пт";
        D6.Text = "Сб";
        D7.Text = "Вс";
    }
}