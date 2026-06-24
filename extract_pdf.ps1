# Use iTextSharp-style approach: search for BT/ET text blocks
# and also try to find readable text between parentheses in uncompressed streams

$filePath = "d:\Project_Sales\Stirling 01\pradeep-portfolio\Profile.pdf"
$bytes = [System.IO.File]::ReadAllBytes($filePath)

# Try to decompress FlateDecode streams
Add-Type -AssemblyName System.IO.Compression

$text = [System.Text.Encoding]::ASCII.GetString($bytes)
$allText = ""

# Find all stream...endstream pairs
$pattern = 'stream\r?\n'
$endPattern = '\r?\nendstream'

$streamStarts = [regex]::Matches($text, $pattern)
$streamEnds = [regex]::Matches($text, $endPattern)

for ($i = 0; $i -lt [Math]::Min($streamStarts.Count, $streamEnds.Count); $i++) {
    $start = $streamStarts[$i].Index + $streamStarts[$i].Length
    $end = $streamEnds[$i].Index
    if ($end -le $start) { continue }
    
    $streamBytes = $bytes[$start..($end-1)]
    
    try {
        # Try to decompress with DeflateStream
        $ms = New-Object System.IO.MemoryStream(,$streamBytes)
        # Skip first 2 bytes (zlib header)
        $null = $ms.ReadByte()
        $null = $ms.ReadByte()
        $ds = New-Object System.IO.Compression.DeflateStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
        $sr = New-Object System.IO.StreamReader($ds)
        $decompressed = $sr.ReadToEnd()
        $sr.Close()
        $ds.Close()
        $ms.Close()
        
        # Extract text between parentheses (PDF text operators)
        $textMatches = [regex]::Matches($decompressed, '\(([^\\)]*(?:\\.[^\\)]*)*)\)')
        foreach ($m in $textMatches) {
            $val = $m.Groups[1].Value
            # Unescape PDF text
            $val = $val -replace '\\n',"`n"
            $val = $val -replace '\\r',"`r"
            $val = $val -replace '\\t',"`t"
            $val = $val -replace '\\([\\()])', '$1'
            $allText += $val
        }
        
        # Also look for Tj and TJ operators
        $tjMatches = [regex]::Matches($decompressed, '\[([^\]]*)\]\s*TJ')
        foreach ($m in $tjMatches) {
            $inner = $m.Groups[1].Value
            $innerTexts = [regex]::Matches($inner, '\(([^\\)]*(?:\\.[^\\)]*)*)\)')
            foreach ($it in $innerTexts) {
                $allText += $it.Groups[1].Value
            }
        }
        
        $allText += "`n"
    } catch {
        # Not a compressed stream, skip
    }
}

Write-Host $allText
