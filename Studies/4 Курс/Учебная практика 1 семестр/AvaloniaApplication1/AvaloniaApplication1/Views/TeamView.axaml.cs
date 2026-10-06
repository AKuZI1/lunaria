using Avalonia.Controls;

namespace AvaloniaApplication1.Views;

public partial class TeamView : UserControl
{
    public TeamView()
    {
        InitializeComponent();
        TitleText.Text = "Команда";
        M1Name.Text = "Иван Петров";
        M1Role.Text = "Менеджер";
        M2Name.Text = "Анна Смирнова";
        M2Role.Text = "Дизайнер";
        M3Name.Text = "Дмитрий Иванов";
        M3Role.Text = "Разработчик";
        M4Name.Text = "Елена Козлова";
        M4Role.Text = "Маркетолог";
    }
}