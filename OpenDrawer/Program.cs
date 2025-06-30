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
            int err = Marshal.GetLastWin32Error();
            throw new Exception($"OpenPrinter failed with error code: {err}");
        }

        bool success =
            StartDocPrinter(hPrinter, 1, IntPtr.Zero) &&
            StartPagePrinter(hPrinter) &&
            WritePrinter(hPrinter, data, data.Length, out written) &&
            EndPagePrinter(hPrinter) &&
            EndDocPrinter(hPrinter);

        ClosePrinter(hPrinter);

        if (!success)
        {
            throw new Exception("One of the printer operations failed (StartDoc, Write, or End).");
        }

        return true;
    }
}

class Program
{
    static void Main()
    {
        string printerName = "ZJ-80"; // Or use "XPRINTER" depending on your setup
        byte[] drawerCommand = new byte[] { 27, 112, 0, 25, 250 }; // ESC p 0 25 250

        try
        {
            Console.WriteLine($"📤 Attempting to open cash drawer on printer '{printerName}'...");

            bool result = RawPrinterHelper.SendBytesToPrinter(printerName, drawerCommand);

            if (result)
            {
                Console.WriteLine("✅ Drawer command sent successfully.");
            }
            else
            {
                Console.WriteLine("❌ Failed to send drawer command.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("❌ Error occurred:");
            Console.WriteLine(ex.Message);
        }

        Console.WriteLine("\nPress Enter to exit...");
        Console.ReadLine();
    }
}