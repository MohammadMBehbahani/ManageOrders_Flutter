using System;
using System.Runtime.InteropServices;

class RawPrinterHelper
{
    [DllImport("winspool.Drv", EntryPoint = "OpenPrinterA", SetLastError = true)]
    public static extern bool OpenPrinter(string printerName, out IntPtr hPrinter, IntPtr pDefault);

    [DllImport("winspool.Drv", EntryPoint = "ClosePrinter")]
    public static extern bool ClosePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "StartDocPrinterA")]
    public static extern bool StartDocPrinter(IntPtr hPrinter, int level, IntPtr docInfo);

    [DllImport("winspool.Drv", EntryPoint = "EndDocPrinter")]
    public static extern bool EndDocPrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "StartPagePrinter")]
    public static extern bool StartPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "EndPagePrinter")]
    public static extern bool EndPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "WritePrinter")]
    public static extern bool WritePrinter(IntPtr hPrinter, byte[] data, int count, out int written);

    public static bool SendBytesToPrinter(string printerName, byte[] data)
    {
        IntPtr hPrinter;
        int written = 0;

        if (!OpenPrinter(printerName, out hPrinter, IntPtr.Zero))
        {
            Console.WriteLine("❌ Failed to open printer.");
            return false;
        }

        bool success = StartDocPrinter(hPrinter, 1, IntPtr.Zero)
            && StartPagePrinter(hPrinter)
            && WritePrinter(hPrinter, data, data.Length, out written)
            && EndPagePrinter(hPrinter)
            && EndDocPrinter(hPrinter);

        ClosePrinter(hPrinter);

        return success;
    }
}

class Program
{
    static void Main()
    {
        // Change this to your actual printer name (check Get-Printer or Printer Settings)
        string printerName = "ZJ-80"; // or "XPRINTER"
        byte[] drawerCommand = new byte[] { 27, 112, 0, 25, 250 };

        Console.WriteLine($"📤 Sending drawer open command to '{printerName}'...");
        bool result = RawPrinterHelper.SendBytesToPrinter(printerName, drawerCommand);

        if (result)
        {
            Console.WriteLine("✅ Drawer opened successfully.");
        }
        else
        {
            Console.WriteLine("❌ Failed to open the drawer.");
        }

        Console.WriteLine("Press Enter to exit...");
        Console.ReadLine();
    }
}