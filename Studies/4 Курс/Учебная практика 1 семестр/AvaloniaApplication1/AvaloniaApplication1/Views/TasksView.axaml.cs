using Avalonia.Controls;

namespace AvaloniaApplication1.Views;

public partial class TasksView : UserControl
{
    public TasksView()
    {
        InitializeComponent();
        TitleText.Text = "Задачи";
        ColName.Text = "Название";
        ColCat.Text = "Категория";
        ColDate.Text = "Срок";
        T1Name.Text = "Разработать макет главной страницы";
        T1Badge.Text = "Дизайн";
        T2Name.Text = "Реализовать авторизацию";
        T2Badge.Text = "Разработка";
        T3Name.Text = "Подготовить презентацию";
        T3Badge.Text = "Маркетинг";
    }
}