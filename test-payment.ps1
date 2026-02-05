# Test 1: Create Payment Preference
Write-Host "=== Test 1: Create Payment Preference ===" -ForegroundColor Cyan

$body = @{
    title = "Plano Pro - ContrateMe"
    quantity = 1
    price = 19.90
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/payment/create_preference" `
        -Method POST `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host "✓ Preference created successfully!" -ForegroundColor Green
    Write-Host "Preference ID: $($response.id)" -ForegroundColor Yellow
    Write-Host "Checkout URL: https://www.mercadopago.com.br/checkout/v1/redirect?pref_id=$($response.id)" -ForegroundColor Yellow
} catch {
    Write-Host "✗ Error creating preference" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

# Test 2: Test with different plans
Write-Host "=== Test 2: Test Different Plans ===" -ForegroundColor Cyan

$plans = @(
    @{ name = "Pro"; price = 19.90 },
    @{ name = "Ilimitado"; price = 39.90 }
)

foreach ($plan in $plans) {
    $body = @{
        title = "Plano $($plan.name) - ContrateMe"
        quantity = 1
        price = $plan.price
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:5000/api/payment/create_preference" `
            -Method POST `
            -Body $body `
            -ContentType "application/json"
        
        Write-Host "✓ $($plan.name) preference created: $($response.id)" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error creating $($plan.name) preference" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== All Tests Completed ===" -ForegroundColor Cyan
