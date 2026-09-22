param([int]$Port = 8123)
# Servidor estático mínimo (solo para probar la app en local)
$root = $PSScriptRoot
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Host "Sirviendo $root en http://localhost:$Port/"
while ($l.IsListening) {
  $c = $l.GetContext()
  $path = $c.Request.Url.LocalPath.TrimStart('/')
  if ($path -eq '') { $path = 'index.html' }
  $file = Join-Path $root $path
  if (Test-Path $file -PathType Leaf) {
    $bytes = [IO.File]::ReadAllBytes($file)
    $c.Response.ContentType = if ($file -like '*.html') { 'text/html; charset=utf-8' } else { 'application/octet-stream' }
    $c.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else { $c.Response.StatusCode = 404 }
  $c.Response.Close()
}
