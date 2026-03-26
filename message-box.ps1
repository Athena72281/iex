Add-Type -AssemblyName PresentationFramework
$Title="test"
$Message="this is a poc"

$request = [System.Net.HttpWebRequest]::Create("http://parrot.live");
$response = $request.GetResponse();
$receiveStream = $response.GetResponseStream();
$readStream = [System.IO.StreamReader]::new($receiveStream);

$Button=[System.Windows.MessageBoxButton]::YesNo
$MessageBoxTitle=$Title
$MessageBoxBody=$Message
$MessageIcon=[System.Windows.MessageBoxImage]::Warning;[System.Windows.MessageBox]::show($MessageBoxBody, $MessageBoxTitle, $Button, $MessageIcon)

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
