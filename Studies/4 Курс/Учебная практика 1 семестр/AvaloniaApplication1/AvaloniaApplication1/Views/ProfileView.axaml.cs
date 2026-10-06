using Avalonia.Controls;
using ProjectStudio;

namespace AvaloniaApplication1.Views;

public partial class ProfileView : UserControl
{
    public ProfileView()
    {
        InitializeComponent();
        TitleText.Text = "Личный кабинет";
        FullNameText.Text = AppState.FullName;
        PositionText.Text = "Менеджер проектов";
        InfoTitle.Text = "Информация";
        LblFio.Text = "ФИО:";
        ValFio.Text = AppState.FullName;
        LblPos.Text = "Должность:";
        ValPos.Text = "Менеджер проектов";
        LblStatus.Text = "Статус:";
        ValStatus.Text = "Активен";
    }
}