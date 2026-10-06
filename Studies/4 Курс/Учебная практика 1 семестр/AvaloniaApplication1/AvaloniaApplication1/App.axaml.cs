using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;

namespace AvaloniaApplication1; // <-- ПРОВЕРЬТЕ, ЧТО ЭТО СОВПАДАЕТ С Program.cs

public partial class App : Application
{
    public override void Initialize()
    {
        AvaloniaXamlLoader.Load(this);
    }

    public override void OnFrameworkInitializationCompleted()
    {
        if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
        {
            desktop.MainWindow = new AuthWindow(); // Начинаем с окна авторизации
        }
        base.OnFrameworkInitializationCompleted();
    }
}