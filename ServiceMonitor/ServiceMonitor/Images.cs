using System;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace ServiceMonitor
{
    public static class Images
    {
        public static readonly ImageSource LedOff = new BitmapImage(new Uri(@"/images/led-off.png", UriKind.RelativeOrAbsolute));
        public static readonly ImageSource LedOn = new BitmapImage(new Uri(@"/images/led-on.png", UriKind.Relative));
    }
}
