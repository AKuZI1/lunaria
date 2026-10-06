using Avalonia.Controls;
using Avalonia.Interactivity;
using ProjectStudio;

namespace AvaloniaApplication1;

public partial class AuthWindow : Window
{
    public AuthWindow()
    {
        InitializeComponent();
        SubtitleText.Text = "Войдите в свой аккаунт";
        LblFio.Text = "ФИО";
        LblPass.Text = "Пароль";
        btnLogin.Content = "Войти";
    }

    private void Login_Click(object? sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtFullName.Text))
        {
            txtError.Text = "Введите ФИО!";
            return;
        }

        AppState.FullName = txtFullName.Text;
        AppState.IsAuthorized = true;

        var mainWindow = new MainWindow();
        mainWindow.Show();
        this.Close();
    }
}