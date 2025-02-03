using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using GalaSoft.MvvmLight;
using ServiceMonitor.Properties;

namespace ServiceMonitor
{
    public class ProcessMonitor : ViewModelBase
    {
        private CancellationTokenSource _cancellationTokenSource;
        private readonly TimeZoneInfo _timeZoneInfo;
        public IEnumerable<NanoLockProcess> Processes { get; private set; }
        public bool HasStarted { get; private set; }

        private DateTimeOffset _lastCheck;
        public DateTimeOffset LastCheck { get => _lastCheck; set => this.Set(nameof(LastCheck), ref _lastCheck, value); }

        private bool _alwaysOnTop;
        public bool AlwaysOnTop { get => _alwaysOnTop; set => this.Set(nameof(AlwaysOnTop), ref _alwaysOnTop, value); }

        public ProcessMonitor(IEnumerable<NanoLockProcess> processes)
        {
            this.Processes = processes;
            _timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(Settings.Default.TimeZone);
        }

        public void Start()
        {
            if (this.HasStarted)
            {
                return;
            }
            _cancellationTokenSource = new CancellationTokenSource();
            this.StartInternal(_cancellationTokenSource.Token);
        }

        public void Stop()
        {
            if (this.HasStarted)
            {
                _cancellationTokenSource.Cancel();
            }
        }

        public void StartInternal(CancellationToken cancellationToken)
        {
            Task.Factory.StartNew(() =>
            {
                while (!cancellationToken.IsCancellationRequested)
                {

                    var lastCheck = TimeZoneInfo.ConvertTime(DateTimeOffset.UtcNow, _timeZoneInfo);
                    foreach (var process in this.Processes)
                    {
                        process.CheckIfProcessAlive();
                    }
                    Application.Current.Dispatcher.BeginInvoke(new Action(() => this.LastCheck = lastCheck));
                    cancellationToken.WaitHandle.WaitOne(Settings.Default.Interval);
                }
            },
            cancellationToken, TaskCreationOptions.LongRunning, TaskScheduler.Default);

        }
    }
}
