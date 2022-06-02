choco install python --version=3.10.4

$env:path = "$env:path;C:\Python310;C:\Python310\Scripts"
New-Item -Path "C:\Python310\python3.exe" -ItemType SymbolicLink -Value "C:\Python310\python.exe"

python -m pip install -U pip

