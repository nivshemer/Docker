using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Data;

namespace ServiceMonitor
{
    public class BooleanToVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            bool invert = false;
            if (parameter is bool?)
            {
                invert = ((bool?)parameter).GetValueOrDefault();
            }
            else if (parameter != null)
            {
                bool.TryParse(parameter.ToString(), out invert);
            }
            var flag = ((bool?)value).GetValueOrDefault();
            if (flag)
            {
                return invert ? Visibility.Collapsed : Visibility.Visible;
            }
            return invert ? Visibility.Visible : Visibility.Collapsed;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
