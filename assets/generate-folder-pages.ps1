# =============================================================================
# generate-folder-pages.ps1  (v2)
# Génère un index.html dans chaque dossier 000/ → 053/ contenant une
# galerie des curseurs (.ani / .cur) avec aperçu PNG (data URL base64).
# Le PNG est extrait à la volée depuis l'en-tête .cur / .ani via .NET
# afin que la galerie reste visible dans TOUS les navigateurs, même
# ceux qui refusent d'afficher .ani / .cur en <img>.
# =============================================================================

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
Write-Host "Racine : $root"

# --- Conversion d'un Icon .NET vers PNG base64 -----------------------------
function ConvertTo-PngBase64 {
    param([System.Drawing.Icon]$Icon)
    try {
        $bmp = $Icon.ToBitmap()
        $ms  = New-Object System.IO.MemoryStream
        $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        $b64 = [Convert]::ToBase64String($ms.ToArray())
        $bmp.Dispose()
        $ms.Dispose()
        return $b64
    } catch {
        return $null
    }
}

# --- Extraction du premier "icon" d'un .ani (RIFF / chunks 'fram') ---------
function Get-AniFirstIconBytes {
    param([byte[]]$Bytes)
    if ($Bytes.Length -lt 12) { return $null }
    $riff = [System.Text.Encoding]::ASCII.GetString($Bytes, 0, 4)
    if ($riff -ne 'RIFF') { return $null }
    $form = [System.Text.Encoding]::ASCII.GetString($Bytes, 8, 4)
    if ($form -ne 'ACON') { return $null }

    $offset = 12
    while ($offset -lt $Bytes.Length - 8) {
        $id = [System.Text.Encoding]::ASCII.GetString($Bytes, $offset, 4)
        $sz = [BitConverter]::ToInt32($Bytes, $offset + 4)
        $offset += 8

        if ($id -eq 'LIST') {
            $listType = [System.Text.Encoding]::ASCII.GetString($Bytes, $offset, 4)
            if ($listType -eq 'fram') {
                $sub = $offset + 4
                $end = $offset + $sz
                while ($sub -lt $end - 8) {
                    $subId = [System.Text.Encoding]::ASCII.GetString($Bytes, $sub, 4)
                    $subSz = [BitConverter]::ToInt32($Bytes, $sub + 4)
                    $sub += 8
                    if ($subId -eq 'icon') {
                        $iconBytes = New-Object byte[] $subSz
                        [Array]::Copy($Bytes, $sub, $iconBytes, 0, $subSz)
                        return $iconBytes
                    }
                    $sub += $subSz
                    if ($subSz % 2 -ne 0) { $sub += 1 }
                }
            }
            $offset += $sz
        } else {
            $offset += $sz
            if ($sz % 2 -ne 0) { $offset += 1 }
        }
    }
    return $null
}

# --- Conversion d'un fichier curseur en PNG base64 ------------------------
# Beaucoup de fichiers .cur de cette collection sont en réalité au format
# ANI (RIFF/ACON) malgré l'extension .cur. On détecte donc le format
# d'après les premiers octets, indépendamment de l'extension.
# De plus, System.Drawing.Icon refuse strictement le type=2 (CUR). On force
# byte[2]=1 (ICO) avant de l'instancier — c'est sans risque pour le rendu.
function Get-CursorPngBase64 {
    param([string]$Path, [string]$Ext)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        if ($bytes.Length -lt 8) { return $null }

        $head = [System.Text.Encoding]::ASCII.GetString($bytes, 0, 4)
        if ($head -eq 'RIFF') {
            # Format ANI : extraire le premier chunk 'icon' (ICO embarqué)
            $iconBytes = Get-AniFirstIconBytes -Bytes $bytes
            if (-not $iconBytes -or $iconBytes.Length -lt 4) { return $null }
            $iconBytes[2] = 1   # ICO
            $ms   = New-Object System.IO.MemoryStream(,$iconBytes)
            $icon = New-Object System.Drawing.Icon($ms)
            $b64  = ConvertTo-PngBase64 -Icon $icon
            $icon.Dispose()
            $ms.Dispose()
            return $b64
        } else {
            # Format CUR / ICO direct
            $copy = [byte[]]::new($bytes.Length)
            [Array]::Copy($bytes, $copy, $bytes.Length)
            if ($copy.Length -ge 4) { $copy[2] = 1 }
            $ms   = New-Object System.IO.MemoryStream(,$copy)
            $icon = New-Object System.Drawing.Icon($ms)
            $b64  = ConvertTo-PngBase64 -Icon $icon
            $icon.Dispose()
            $ms.Dispose()
            return $b64
        }
    } catch {
        return $null
    }
}

# --- Dimensions d'un .cur (octets 6 et 7) ---------------------------------
function Get-CurDimensions {
    param([string]$Path)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        if ($bytes.Length -lt 8) { return $null }
        $w = $bytes[6]; $h = $bytes[7]
        if ($w -eq 0) { $w = 256 }
        if ($h -eq 0) { $h = 256 }
        return "$w x $h"
    } catch { return $null }
}

# --- Infos d'un .ani (frames + dimensions) --------------------------------
function Get-AniInfo {
    param([string]$Path)
    try {
        $fs = [System.IO.File]::OpenRead($Path)
        $br = New-Object System.IO.BinaryReader($fs)
        $riff = [System.Text.Encoding]::ASCII.GetString($br.ReadBytes(4))
        if ($riff -ne 'RIFF') { $br.Close(); return $null }
        $null = $br.ReadInt32()
        $form = [System.Text.Encoding]::ASCII.GetString($br.ReadBytes(4))
        if ($form -ne 'ACON') { $br.Close(); return $null }
        while ($fs.Position -lt $fs.Length - 8) {
            $id = [System.Text.Encoding]::ASCII.GetString($br.ReadBytes(4))
            $sz = $br.ReadInt32()
            if ($id -eq 'anih') {
                $null    = $br.ReadInt32()
                $nFrames = $br.ReadInt32()
                $null    = $br.ReadInt32()
                $iWidth  = $br.ReadInt32()
                $iHeight = $br.ReadInt32()
                $br.Close()
                if ($iWidth -eq 0)  { $iWidth = 32 }
                if ($iHeight -eq 0) { $iHeight = 32 }
                return @{ Frames = $nFrames; Dim = "$iWidth x $iHeight" }
            } else {
                $fs.Position += $sz
                if ($sz % 2 -ne 0) { $fs.Position += 1 }
            }
        }
        $br.Close()
        return $null
    } catch { return $null }
}

# --- Taille humaine -------------------------------------------------------
function Format-Size {
    param([long]$Bytes)
    if ($Bytes -lt 1024)    { return "$Bytes o" }
    if ($Bytes -lt 1048576) { return ("{0:N1} Ko" -f ($Bytes / 1024)) }
    return ("{0:N1} Mo" -f ($Bytes / 1048576))
}

# --- Echappement HTML -----------------------------------------------------
function Encode-Html {
    param([string]$Text)
    return $Text.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;')
}

# --- Boucle dossiers ------------------------------------------------------
$folders = Get-ChildItem -LiteralPath $root -Directory | Where-Object { $_.Name -match '^\d{3}$' } | Sort-Object Name
$totalFolders = $folders.Count
Write-Host "Dossiers détectés : $totalFolders"

$pageSize = 250
$drawerIndex = 0

foreach ($f in $folders) {
    $drawerIndex++
    $files = Get-ChildItem -LiteralPath $f.FullName -File | Where-Object { $_.Extension -in '.ani', '.cur' } | Sort-Object Name
    if ($files.Count -eq 0) {
        Write-Host ("[{0}/{1}] {2} : vide" -f $drawerIndex, $totalFolders, $f.Name)
        continue
    }

    $totalFiles = $files.Count
    $pageCount  = [math]::Ceiling($totalFiles / $pageSize)

    for ($p = 1; $p -le $pageCount; $p++) {
        $startIdx = ($p - 1) * $pageSize
        $slice    = $files | Select-Object -Skip $startIdx -First $pageSize

        $pageFile = if ($p -eq 1) { 'index.html' } else { "page$p.html" }
        $outPath  = Join-Path $f.FullName $pageFile

        $cardsHtml = New-Object System.Text.StringBuilder
        foreach ($file in $slice) {
            $name = $file.Name
            $size = Format-Size $file.Length
            $dim  = $null
            $extra = ''
            if ($file.Extension -eq '.cur') {
                $dim = Get-CurDimensions $file.FullName
            } else {
                $info = Get-AniInfo $file.FullName
                if ($info) { $dim = $info.Dim; $extra = " · $($info.Frames) img" }
            }
            $dimStr = if ($dim) { "$dim$extra" } else { 'curseur Windows' }

            # PNG base64 — aperçu universel
            $b64 = Get-CursorPngBase64 -Path $file.FullName -Ext $file.Extension
            $imgTag = if ($b64) {
                "<img src=`"data:image/png;base64,$b64`" alt=`"`" loading=`"lazy`">"
            } else {
                ""
            }

            $href    = [System.Uri]::EscapeDataString($name)
            $nameEsc = Encode-Html $name
            $cardsHtml.AppendLine(@"
    <div class="cursor-card" style="cursor: url('$href'), auto;">
      <span class="preview" aria-hidden="true">$imgTag</span>
      <div class="filename" title="$nameEsc">$nameEsc</div>
      <div class="meta">$size · $dimStr</div>
      <a class="dl" href="$href" download title="Clic droit → Enregistrer sous">⤓ Télécharger</a>
    </div>
"@) | Out-Null
        }

        # Pagination
        $pagerHtml = ''
        if ($pageCount -gt 1) {
            $links = @()
            for ($k = 1; $k -le $pageCount; $k++) {
                $h = if ($k -eq 1) { 'index.html' } else { "page$k.html" }
                if ($k -eq $p) {
                    $links += "<span class='current'>$k</span>"
                } else {
                    $links += "<a href='$h'>$k</a>"
                }
            }
            $pagerHtml = "<nav class='pagination'>" + ($links -join '') + "</nav>"
        }

        # Liens tiroirs précédent / suivant
        $prevNum = $drawerIndex - 2
        $nextNum = $drawerIndex
        $prevLink = ''
        $nextLink = ''
        if ($prevNum -ge 0) {
            $prevLink = "<a href='../$('{0:D3}' -f $prevNum)/index.html'>← Tiroir $('{0:D3}' -f $prevNum)</a>"
        }
        if ($nextNum -lt $totalFolders) {
            $nextLink = "<a href='../$('{0:D3}' -f $nextNum)/index.html'>Tiroir $('{0:D3}' -f $nextNum) →</a>"
        }

        $folderName = $f.Name
        $title = "Tiroir $folderName — $totalFiles curseurs"
        if ($pageCount -gt 1) { $title += " (page $p/$pageCount)" }

        $html = @"
<!DOCTYPE html>
<!--
  ============================================================================
  $folderName/$pageFile — Galerie du tiroir $folderName
  Généré automatiquement par assets/generate-folder-pages.ps1
  Les aperçus sont des PNG (data URL base64) extraits des en-têtes .cur/.ani
  ============================================================================
-->
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>

  <!-- Externe -->
  <link rel="canonical" href="https://filedn.eu/llN3kr5vmyEBPIWCwFj3O6h/">
  <link rel="icon" href="https://filedn.eu/llN3kr5vmyEBPIWCwFj3O6h/Site_Web/favicondepascal.png" type="image/png">
  <link rel="icon" href="https://filedn.eu/llN3kr5vmyEBPIWCwFj3O6h/Site_Web/favicondepascal.ico" type="image/x-icon">
  <link rel="stylesheet" type="text/css" href="https://filedn.eu/llN3kr5vmyEBPIWCwFj3O6h/Site_Web/style.css">
  <script src="https://filedn.eu/llN3kr5vmyEBPIWCwFj3O6h/Site_Web/script.js"></script>
  <script src="https://filedn.eu/llN3kr5vmyEBPIWCwFj3O6h/Site_Web/menu.js" defer></script>
  <link rel="stylesheet" href="https://filedn.eu/llN3kr5vmyEBPIWCwFj3O6h/Site_Web/basedusite.css">

  <!-- Local -->
  <link rel="stylesheet" href="../assets/style.css">
  <script src="../assets/menu.js" defer></script>
  <script src="../assets/script.js" defer></script>
</head>
<body>

  <nav class="social-menu">
    <ul>
      <li><a href="https://fr.pinterest.com/pascal509/mes-tableaux-tous-genre/" target="_blank" rel="noopener">Pinterest</a></li>
      <li><a href="https://www.flickr.com/photos/delfossepascal" target="_blank" rel="noopener">Flickr</a></li>
      <li><a href="https://www.tumblr.com/lestoilesdepascal" target="_blank" rel="noopener">Tumblr</a></li>
      <li><a href="https://x.com/PascalDelfossee" target="_blank" rel="noopener">X</a></li>
      <li><a href="https://www.youtube.com/c/DelfossePascal" target="_blank" rel="noopener">YouTube</a></li>
    </ul>
  </nav>

  <header></header>

  <div class="toolbar">
    <button id="btn-theme" type="button">Mode clair</button>
  </div>

  <a class="btn-home" href="../home.html" title="Retour à l'accueil">← Accueil</a>

  <main>

    <h1 style="text-align:center; font-family: var(--font-title); color: var(--accent); margin-top: 1rem;">
      Tiroir $folderName
    </h1>

    <section class="context">
      <p>
        Vous parcourez le <strong>tiroir n°$folderName</strong> de la
        collection : <strong>$totalFiles</strong> curseurs Windows y sont
        rangés.
        <br>
        Survolez une carte pour voir le pointeur prendre la forme du
        curseur correspondant. <strong>Clic gauche sur l'aperçu</strong>
        pour agrandir (Echap pour fermer). <strong>Clic droit</strong> sur
        <em>Télécharger</em> → <em>Enregistrer sous</em> pour conserver
        le fichier.
      </p>
    </section>

    <div class="cursor-grid">
$($cardsHtml.ToString())
    </div>

    $pagerHtml

    <nav class="pagination" style="margin-top:2.5rem;">
      $prevLink
      <a href="../home.html">⌂ Accueil</a>
      $nextLink
    </nav>

  </main>

  <footer>
    <p>Tiroir $folderName · $totalFiles fichiers · Site local</p>
  </footer>

</body>
</html>
"@

        [System.IO.File]::WriteAllText($outPath, $html, (New-Object System.Text.UTF8Encoding($false)))
    }

    Write-Host ("[{0}/{1}] {2} : {3} fichiers, {4} page(s)" -f $drawerIndex, $totalFolders, $f.Name, $totalFiles, $pageCount)
}

Write-Host ""
Write-Host "Génération terminée."
