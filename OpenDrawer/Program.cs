using System;
using System.Runtime.InteropServices;
using System.Text;

class Program
{
    [DllImport("winspool.drv", SetLastError = true)]
    static extern bool OpenPrinter(string pPrinterName, out IntPtr phPrinter, IntPtr pDefault);

    [DllImport("winspool.drv", SetLastError = true)]
    static extern bool ClosePrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    static extern bool StartDocPrinter(IntPtr hPrinter, int level, ref DOCINFO pDocInfo);

    [DllImport("winspool.drv", SetLastError = true)]
    static extern bool EndDocPrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    static extern bool StartPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    static extern bool EndPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", SetLastError = true)]
    static extern bool WritePrinter(IntPtr hPrinter, IntPtr pBytes, int dwCount, out int dwWritten);

    [StructLayout(LayoutKind.Sequential)]
    public struct DOCINFO
    {
        [MarshalAs(UnmanagedType.LPStr)] public string pDocName;
        [MarshalAs(UnmanagedType.LPStr)] public string pOutputFile;
        [MarshalAs(UnmanagedType.LPStr)] public string pDataType;
    }

    static void Main(string[] args)
    {
        string printerName = args.Length > 0 ? args[0] :"ZJ-80"; // Make sure it's exactly like shown in Get-Printer
        Console.WriteLine($"🔍 Attempting to open cash drawer on printer: '{printerName}'...");

        IntPtr hPrinter;
        if (!OpenPrinter(printerName, out hPrinter, IntPtr.Zero))
        {
            int error = Marshal.GetLastWin32Error();
            Console.WriteLine($"❌ OpenPrinter failed. Error: {error}");
            Console.ReadLine();
            return;
        }

        DOCINFO docInfo = new DOCINFO
        {
            pDocName = "OpenDrawer",
            pDataType = "RAW"
        };

        if (!StartDocPrinter(hPrinter, 1, ref docInfo))
        {
            int error = Marshal.GetLastWin32Error();
            Console.WriteLine($"❌ StartDocPrinter failed. Error: {error}");
            ClosePrinter(hPrinter);
            Console.ReadLine();
            return;
        }

        if (!StartPagePrinter(hPrinter))
        {
            int error = Marshal.GetLastWin32Error();
            Console.WriteLine($"❌ StartPagePrinter failed. Error: {error}");
            EndDocPrinter(hPrinter);
            ClosePrinter(hPrinter);
            Console.ReadLine();
            return;
        }

        byte[] drawerCommand = new byte[] { 27, 112, 0, 25, 250 }; // ESC p 0 25 250
        IntPtr unmanagedBytes = Marshal.AllocHGlobal(drawerCommand.Length);
        Marshal.Copy(drawerCommand, 0, unmanagedBytes, drawerCommand.Length);

        if (!WritePrinter(hPrinter, unmanagedBytes, drawerCommand.Length, out int bytesWritten))
        {
            int error = Marshal.GetLastWin32Error();
            Console.WriteLine($"❌ WritePrinter failed. Error: {error}");
        }
        else
        {
            Console.WriteLine($"✅ Sent drawer command ({bytesWritten} bytes).");
        }

        Marshal.FreeHGlobal(unmanagedBytes);
        EndPagePrinter(hPrinter);
        EndDocPrinter(hPrinter);
        ClosePrinter(hPrinter);

        Console.WriteLine("🎉 Done. Press Enter to exit...");
        Console.ReadLine();
    }
}