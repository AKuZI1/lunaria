using Avalonia.Controls;

namespace AvaloniaApplication1.Views;

public partial class ProjectsView : UserControl
{
    public ProjectsView()
    {
        InitializeComponent();
        TitleText.Text = "Проекты";
        NewProjectBtn.Content = "+ Новый проект";
        P1Title.Text = "Avalonia UI Redesign";
        P1Desc.Text = "Редизайн интерфейса";
        P1Progress.Text = "65% завершено";
        P2Title.Text = "Мобильное приложение";
        P2Desc.Text = "iOS и Android";
        P2Progress.Text = "40% завершено";
        P3Title.Text = "Корпоративный сайт";
        P3Desc.Text = "Веб-портал компании";
        P3Progress.Text = "80% завершено";
    }
}