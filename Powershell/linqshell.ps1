function global:runlinq($file) {
    $tempFile = New-TemporaryFile
    $wrapperTop = @"
class App {
"@
    $wrapperBottom= @"
}
"@
    $code = Get-Content $file
    $writer = $tempFile.AppendText();
    $writer.Write($wrapperTop);
    foreach ($line in $code) {
        $writer.Write($line)
    }
    $writer.Write($wrapperBottom);
    $writer.Flush();

    Write-Host $tempFile;
}