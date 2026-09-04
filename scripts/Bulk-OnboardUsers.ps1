# Import Active Directory Module
Import-Module ActiveDirectory

# Define Path to Employee CSV
$CsvPath = "C:\LabProjects\Ad-homelab-azure\scripts\ADUsers.csv"

# Check if CSV exists before proceeding
if (-not (Test-Path $CsvPath)) {
    Write-Host "Error: CSV file not found at $CsvPath" -ForegroundColor Red
    exit
}

$Users = Import-Csv -Path $CsvPath
$DefaultPassword = ConvertTo-SecureString "P@ssw0rd2026!" -AsPlainText -Force

foreach ($User in $Users) {
    # Dynamically build target OU path under Novexus Workloads
    $TargetOU = "OU=$($User.Department),OU=Novexus Workloads,DC=novexus,DC=local"
    
    # Check if user already exists in Active Directory
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($User.Username)'")) {
        New-ADUser `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -Name "$($User.FirstName) $($User.LastName)" `
            -SamAccountName $User.Username `
            -UserPrincipalName "$($User.Username)@novexus.local" `
            -Title $User.Title `
            -Department $User.Department `
            -Path $TargetOU `
            -AccountPassword $DefaultPassword `
            -Enabled $true `
            -PasswordNeverExpires $true
        
        Write-Host "Successfully created user: $($User.Username) in $TargetOU" -ForegroundColor Green
    } else {
        Write-Host "User '$($User.Username)' already exists. Skipping..." -ForegroundColor Yellow
    }
}