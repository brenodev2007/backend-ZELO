$body = @{
    name = "Breno Teste"
    email = "breno.teste@example.com"
    password = "senha123"
    acceptedTerms = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" -Method POST -Body $body -ContentType "application/json"
    Write-Host "✅ Conta criada com sucesso!" -ForegroundColor Green
    Write-Host "Token recebido: $($response.token.Substring(0, 20))..." -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erro ao criar conta:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message -ForegroundColor Yellow
    }
}
