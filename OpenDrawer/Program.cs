using System;
using System.Runtime.InteropServices;
using System.Text;

class Program
{
    // Native Win32 APIs
    [DllImport("winspool.drv", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool OpenPrinter(string pPrinterName, out IntPtr phPrinter, IntPtr pDefault);

    [DllImport("winspool.drv", SetLastError = true)]
    public static extern bool ClosePrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    public static extern bool StartDocPrinter(IntPtr hPrinter, int level, [In] ref DOC_INFO_1 di);

    [DllImport("winspool.drv", SetLastError = true)]
    public static extern bool EndDocPrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    public static extern bool StartPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    public static extern bool EndPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    public static extern bool WritePrinter(IntPtr hPrinter, IntPtr pBytes, int dwCount, out int dwWritten);

    [StructLayout(LayoutKind.Sequential)]
    public struct DOC_INFO_1
    {
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDocName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pOutputFile;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDataType;
    }

    static void Main()
    {
        string printerName = @"ZJ-80";
        byte[] openDrawerCommand = new byte[] { 27, 112, 0, 25, 250 };

        Console.WriteLine($"🧾 Attempting to open cash drawer on printer '{printerName}'...");

        try
        {
            IntPtr hPrinter;
            if (!OpenPrinter(printerName, out hPrinter, IntPtr.Zero))
            {
                int err = Marshal.GetLastWin32Error();
                Console.WriteLine($"❌ OpenPrinter failed with error code: {err}");
                Console.ReadLine();
                return;
            }

            DOC_INFO_1 docInfo = new DOC_INFO_1
            {
                pDocName = "Open Cash Drawer",
                pDataType = "RAW"
            };

            if (!StartDocPrinter(hPrinter, 1, ref docInfo))
            {
                int err = Marshal.GetLastWin32Error();
                Console.WriteLine($"❌ StartDocPrinter failed: {err}");
                ClosePrinter(hPrinter);
                Console.ReadLine();
                return;
            }

            if (!StartPagePrinter(hPrinter))
            {
                Console.WriteLine("❌ StartPagePrinter failed.");
                EndDocPrinter(hPrinter);
                ClosePrinter(hPrinter);
                Console.ReadLine();
                return;
            }

            IntPtr unmanagedBytes = Marshal.AllocHGlobal(openDrawerCommand.Length);
            Marshal.Copy(openDrawerCommand, 0, unmanagedBytes, openDrawerCommand.Length);

            int bytesWritten;
            bool success = WritePrinter(hPrinter, unmanagedBytes, openDrawerCommand.Length, out bytesWritten);
            Marshal.FreeHGlobal(unmanagedBytes);

            EndPagePrinter(hPrinter);
            EndDocPrinter(hPrinter);
            ClosePrinter(hPrinter);

            if (!success || bytesWritten != openDrawerCommand.Length)
            {
                Console.WriteLine("❌ Failed to write data to printer.");
            }
            else
            {
                Console.WriteLine("✅ Drawer command sent successfully.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❗ Error occurred:\n{ex.Message}");
        }

        Console.WriteLine("\nPress Enter to exit...");
        Console.ReadLine();
    }
}