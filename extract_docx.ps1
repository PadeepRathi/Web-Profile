# Extract ALL text from .docx including headers, footers, etc.
Add-Type -AssemblyName System.IO.Compression.FileSystem

$docxPath = "D:\Project_Sales\Stirling 01\pradeep-portfolio\Profile.docx"
$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)

# List all XML entries
foreach ($entry in $zip.Entries) {
    if ($entry.FullName -like "word/*.xml") {
        Write-Host "=== FILE: $($entry.FullName) ==="
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $xml = $reader.ReadToEnd()
        $reader.Close()
        $stream.Close()

        try {
            $xmlDoc = [xml]$xml
            $ns = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
            $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

            $paragraphs = $xmlDoc.SelectNodes("//w:p", $ns)
            foreach ($p in $paragraphs) {
                $texts = $p.SelectNodes(".//w:t", $ns)
                $line = ""
                foreach ($t in $texts) {
                    $line += $t.InnerText
                }
                if ($line.Trim() -ne "") {
                    Write-Host $line
                }
            }
        } catch {
            Write-Host "(could not parse as structured XML)"
        }
        Write-Host ""
    }
}

$zip.Dispose()
