using System;
using System.Runtime.InteropServices;

class RawPrinterHelper {
    [DllImport("winspool.Drv", EntryPoint = "OpenPrinterA", SetLastError = true)]
    public static extern bool OpenPrinter(string szPrinter, out IntPtr hPrinter, IntPtr pd);

    [DllImport("winspool.Drv", EntryPoint = "ClosePrinter")]
    public static extern bool ClosePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "StartDocPrinterA")]
    public static extern bool StartDocPrinter(IntPtr hPrinter, int level, IntPtr di);

    [DllImport("winspool.Drv", EntryPoint = "StartPagePrinter")]
    public static extern bool StartPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "WritePrinter")]
    public static extern bool WritePrinter(IntPtr hPrinter, byte[] pBytes, int dwCount, out int dwWritten);

    [DllImport("winspool.Drv", EntryPoint = "EndPagePrinter")]
    public static extern bool EndPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "EndDocPrinter")]
    public static extern bool EndDocPrinter(IntPtr hPrinter);

    public static bool SendBytesToPrinter(string printerName, byte[] bytes) {
        IntPtr hPrinter;
        if (!OpenPrinter(printerName, out hPrinter, IntPtr.Zero)) return false;
        StartDocPrinter(hPrinter, 1, IntPtr.Zero);
        StartPagePrinter(hPrinter);
        int dwWritten = 0;
        bool success = WritePrinter(hPrinter, bytes, bytes.Length, out dwWritten);
        EndPagePrinter(hPrinter);
        EndDocPrinter(hPrinter);
        ClosePrinter(hPrinter);
        return success;
    }
}

class Program {
    static void Main() {
        string printerName = "XPRINTER";  // ✅ Use the exact name from Control Panel > Printers
        byte[] drawerCommand = new byte[] { 27, 112, 0, 25, 250 };
        bool result = RawPrinterHelper.SendBytesToPrinter(printerName, drawerCommand);
        Console.WriteLine(result ? "✅ Drawer opened" : "❌ Failed to open drawer");
    }
}