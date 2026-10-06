using Avalonia;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Styling;

namespace AvaloniaApplication1.Views;

public partial class SettingsView : UserControl
{
    public SettingsView()
    {
        InitializeComponent();
        TitleText.Text = "Настройки";
        AppearanceTitle.Text = "Внешний вид";
        ThemeLabel.Text = "Тёмная тема";
        ThemeDesc.Text = "Переключить между светлой и тёмной темой";
        ThemeToggle.IsChecked = Application.Current!.ActualThemeVariant == ThemeVariant.Dark;
    }

    private void ThemeToggle_IsCheckedChanged(object? sender, RoutedEventArgs e)
    {
        if (sender is ToggleSwitch toggle)
        {
            Application.Current!.RequestedThemeVariant =
                toggle.IsChecked == true ? ThemeVariant.Dark : ThemeVariant.Light;
        }
    }
}