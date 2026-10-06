using Avalonia.Controls;
using Avalonia.Interactivity;
using AvaloniaApplication1.Views;
using AvaloniaApplication1.Views;
using ProjectStudio;

namespace AvaloniaApplication1;

public partial class MainWindow : Window
{
    private Button? _activeButton;

    public MainWindow()
    {
        InitializeComponent();
        txtUserName.Text = AppState.FullName;
        PageHost.Content = new OverviewView();
    }

    private void Navigate(object? sender, RoutedEventArgs e)
    {
        if (sender is not Button btn || btn.Tag is not string pageName) return;

        // Снимаем выделение со всех кнопок
        foreach (var child in ((StackPanel)btn.Parent!).Children)
        {
            if (child is Button b) b.Classes.Remove("active");
        }
        btn.Classes.Add("active");
        _activeButton = btn;

        PageHost.Content = pageName switch
        {
            "Overview" => new OverviewView(),
            "Projects" => new ProjectsView(),
            "Tasks" => new TasksView(),
            "Calendar" => new CalendarView(),
            "Team" => new TeamView(),
            "Settings" => new SettingsView(),
            _ => new TextBlock { Text = "Страница не найдена" }
        };
    }

    private void ShowProfile(object? sender, RoutedEventArgs e)
    {
        PageHost.Content = new ProfileView();
        foreach (var child in ((StackPanel)((Button)sender!).Parent!).Children)
        {
            if (child is Button b) b.Classes.Remove("active");
        }
    }

    private void Logout(object? sender, RoutedEventArgs e)
    {
        AppState.IsAuthorized = false;
        this.Close();
        new AuthWindow().Show();
    }
}