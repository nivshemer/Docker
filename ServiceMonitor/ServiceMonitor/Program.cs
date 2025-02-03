using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using Newtonsoft.Json;
using ServiceMonitor.Properties;

namespace ServiceMonitor
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            AppDomain.CurrentDomain.UnhandledException += (s, e) =>
            {
                MessageBox.Show(e.ExceptionObject.ToString(), "Application Error", MessageBoxButton.OK, MessageBoxImage.Error);
            };
            var processes = JsonConvert.DeserializeObject<NanoLockProcessInformation[]>(Settings.Default.Processes)
                .Select(p => new NanoLockProcess(p.ProcessName, p.DisplayName, p.CommandLine)).ToArray();
            var dataContext = new ProcessMonitor(processes);
            var window = new MainWindow { DataContext = dataContext };
            dataContext.Start();
            new Application().Run(window);
            dataContext.Stop();
        }
    }
}
