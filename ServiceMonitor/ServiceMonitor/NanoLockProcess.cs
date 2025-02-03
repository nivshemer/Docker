using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;

namespace ServiceMonitor
{
    public class NivshemerProcess : ViewModelBase
    {
        public string ProcessName { get; private set; }

        public string DisplayName { get; set; }

        public string CommandLine { get; set; }

        public bool IsAlive { get => this.Image == Images.LedOn; }

        private ImageSource _image;
        public ImageSource Image
        {
            get { return _image; }
            set { this.Set(nameof(this.Image), ref _image, value); }
        }

        public ICommand ButtonClick { get; private set; }

        public NivshemerProcess(string processName, string displayName, string commandLine)
        {
            this.ProcessName = processName;
            this.DisplayName = displayName;
            this.CommandLine = commandLine;
            _image = Images.LedOff;
            this.ButtonClick = new RelayCommand(this.ExecuteButtonClick);
        }

        public void CheckIfProcessAlive()
        {
            var isAlive = Process.GetProcesses().Any(p => p.ProcessName.Equals(this.ProcessName, StringComparison.OrdinalIgnoreCase));
            using (var searcher = new ManagementObjectSearcher($"SELECT CommandLine FROM Win32_Process WHERE Name = 'dotnet.exe'"))
            {
                foreach (var instance in searcher.Get())
                {
                    var commandLine = (string)instance["CommandLine"];
                    if (!string.IsNullOrWhiteSpace(commandLine))
                    {
                        var arguments = CommandLineHelper.SplitCommandLine(commandLine).Skip(1);
                        isAlive |= arguments.Any(a => CommandLineHelper.IsArgumentEqualsToProcessName(a, this.ProcessName));
                    }
                }
            }
            Application.Current?.Dispatcher?.BeginInvoke(new Action(() => this.Image = isAlive ? Images.LedOn : Images.LedOff));
        }

        private void ExecuteButtonClick()
        {
            if (this.IsAlive)
            {
                var process = Process.GetProcesses().FirstOrDefault(p => p.ProcessName.Equals(this.ProcessName, StringComparison.OrdinalIgnoreCase));
                if (process != null)
                {
                    process.Kill();
                }
                else
                {
                    using (var searcher = new ManagementObjectSearcher($"SELECT ProcessId, CommandLine FROM Win32_Process WHERE Name = 'dotnet.exe'"))
                    {
                        foreach (var instance in searcher.Get())
                        {
                            var commandLine = (string)instance["CommandLine"];
                            if (!string.IsNullOrWhiteSpace(commandLine))
                            {
                                var arguments = CommandLineHelper.SplitCommandLine(commandLine).Skip(1);
                                if (arguments.Any(a => CommandLineHelper.IsArgumentEqualsToProcessName(a, this.ProcessName)))
                                {
                                    var processId = (uint)instance["ProcessId"];
                                    process = Process.GetProcessById((int)processId);
                                    if (process != null)
                                    {
                                        process.Kill();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                var tempFile = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString() + ".bat");
                try
                {
                    File.WriteAllText(tempFile, this.CommandLine);
                    Process.Start(tempFile).WaitForExit();
                }
                finally
                {
                    File.Delete(tempFile);
                }
            }
        }
    }
}
