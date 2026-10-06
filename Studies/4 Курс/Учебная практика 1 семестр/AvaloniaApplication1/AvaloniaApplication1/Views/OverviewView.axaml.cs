using Avalonia.Controls;

namespace AvaloniaApplication1.Views;

public partial class OverviewView : UserControl
{
    public OverviewView()
    {
        InitializeComponent();

        // Находим все TextBlock и задаём текст через C#
        // Это гарантирует, что кириллица будет отображаться корректно

        // Заголовок
        var title = this.FindControl<TextBlock>("TitleText");
        if (title != null) title.Text = "Обзор";

        // Карточки статистики
        var projectsLabel = this.FindControl<TextBlock>("ProjectsLabel");
        if (projectsLabel != null) projectsLabel.Text = "Проекты";

        var projectsSub = this.FindControl<TextBlock>("ProjectsSub");
        if (projectsSub != null) projectsSub.Text = "Активных проектов";

        var tasksLabel = this.FindControl<TextBlock>("TasksLabel");
        if (tasksLabel != null) tasksLabel.Text = "Задачи";

        var tasksSub = this.FindControl<TextBlock>("TasksSub");
        if (tasksSub != null) tasksSub.Text = "В работе";

        var teamLabel = this.FindControl<TextBlock>("TeamLabel");
        if (teamLabel != null) teamLabel.Text = "Команда";

        var teamSub = this.FindControl<TextBlock>("TeamSub");
        if (teamSub != null) teamSub.Text = "Участников";

        var deadlinesLabel = this.FindControl<TextBlock>("DeadlinesLabel");
        if (deadlinesLabel != null) deadlinesLabel.Text = "Сроки";

        var deadlinesSub = this.FindControl<TextBlock>("DeadlinesSub");
        if (deadlinesSub != null) deadlinesSub.Text = "Просрочено";

        // Активные проекты
        var activeProjectsTitle = this.FindControl<TextBlock>("ActiveProjectsTitle");
        if (activeProjectsTitle != null) activeProjectsTitle.Text = "Активные проекты";

        var project1Name = this.FindControl<TextBlock>("Project1Name");
        if (project1Name != null) project1Name.Text = "Мобильное приложение";

        var project1Badge = this.FindControl<TextBlock>("Project1Badge");
        if (project1Badge != null) project1Badge.Text = "Разработка";

        var project2Name = this.FindControl<TextBlock>("Project2Name");
        if (project2Name != null) project2Name.Text = "Корпоративный сайт";

        var project2Badge = this.FindControl<TextBlock>("Project2Badge");
        if (project2Badge != null) project2Badge.Text = "Разработка";

        var project1DesignBadge = this.FindControl<TextBlock>("Project1DesignBadge");
        if (project1DesignBadge != null) project1DesignBadge.Text = "Дизайн";

        // Календарь
        var calendarTitle = this.FindControl<TextBlock>("CalendarTitle");
        if (calendarTitle != null) calendarTitle.Text = "Май 2024";

        var dayMon = this.FindControl<TextBlock>("DayMon");
        if (dayMon != null) dayMon.Text = "Пн";

        var dayTue = this.FindControl<TextBlock>("DayTue");
        if (dayTue != null) dayTue.Text = "Вт";

        var dayWed = this.FindControl<TextBlock>("DayWed");
        if (dayWed != null) dayWed.Text = "Ср";

        var dayThu = this.FindControl<TextBlock>("DayThu");
        if (dayThu != null) dayThu.Text = "Чт";

        var dayFri = this.FindControl<TextBlock>("DayFri");
        if (dayFri != null) dayFri.Text = "Пт";

        var daySat = this.FindControl<TextBlock>("DaySat");
        if (daySat != null) daySat.Text = "Сб";

        var daySun = this.FindControl<TextBlock>("DaySun");
        if (daySun != null) daySun.Text = "Вс";

        // Последние задачи
        var recentTasksTitle = this.FindControl<TextBlock>("RecentTasksTitle");
        if (recentTasksTitle != null) recentTasksTitle.Text = "Последние задачи";

        var task1Name = this.FindControl<TextBlock>("Task1Name");
        if (task1Name != null) task1Name.Text = "Разработать макет главной страницы";

        var task1Badge = this.FindControl<TextBlock>("Task1Badge");
        if (task1Badge != null) task1Badge.Text = "Дизайн";

        var task2Name = this.FindControl<TextBlock>("Task2Name");
        if (task2Name != null) task2Name.Text = "Реализовать авторизацию";

        var task2Badge = this.FindControl<TextBlock>("Task2Badge");
        if (task2Badge != null) task2Badge.Text = "Разработка";

        var task3Name = this.FindControl<TextBlock>("Task3Name");
        if (task3Name != null) task3Name.Text = "Подготовить презентацию";

        var task3Badge = this.FindControl<TextBlock>("Task3Badge");
        if (task3Badge != null) task3Badge.Text = "Маркетинг";
    }
}