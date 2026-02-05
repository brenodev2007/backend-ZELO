# Direct Webhook Test and Plan Verification
Write-Host "=== Testing Webhook and Plan Upgrade ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5000"

# Step 1: Login as test user
Write-Host "Step 1: Logging in as test user..." -ForegroundColor Yellow
$loginBody = @{
    email = "breno.soriani@mail.com"
    password = "1234"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json"
    
    Write-Host "✓ Logged in successfully" -ForegroundColor Green
    Write-Host "  User: $($loginResponse.user.name)" -ForegroundColor Gray
    Write-Host "  Current Plan: $($loginResponse.user.plan)" -ForegroundColor Gray
    $userId = $loginResponse.user.id
    $token = $loginResponse.token
    $currentPlan = $loginResponse.user.plan
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Trying to create user..." -ForegroundColor Yellow
    
    # Try to register
    $registerBody = @{
        name = "Breno Soriani"
        email = "breno.soriani@mail.com"
        password = "1234"
        acceptedTerms = $true
    } | ConvertTo-Json
    
    try {
        $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" `
            -Method POST `
            -Body $registerBody `
            -ContentType "application/json"
        
        Write-Host "✓ User created successfully" -ForegroundColor Green
        $userId = $registerResponse.user.id
        $token = $registerResponse.token
        $currentPlan = $registerResponse.user.plan
    } catch {
        Write-Host "✗ Registration also failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# Step 2: Create payment preference for Pro plan
Write-Host "Step 2: Creating payment preference..." -ForegroundColor Yellow
$preferenceBody = @{
    title = "Plano Pro - ContrateMe"
    quantity = 1
    price = 19.90
    userId = $userId
    plan = "pro"
} | ConvertTo-Json

try {
    $preferenceResponse = Invoke-RestMethod -Uri "$baseUrl/api/payment/create_preference" `
        -Method POST `
        -Body $preferenceBody `
        -ContentType "application/json"
    
    Write-Host "✓ Payment preference created" -ForegroundColor Green
    Write-Host "  Preference ID: $($preferenceResponse.id)" -ForegroundColor Gray
    Write-Host "  Checkout URL: $($preferenceResponse.sandbox_init_point)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  🌐 Open this URL in your browser to complete payment:" -ForegroundColor Yellow
    Write-Host "  $($preferenceResponse.sandbox_init_point)" -ForegroundColor White
    Write-Host ""
    Write-Host "  💳 Use test card:" -ForegroundColor Yellow
    Write-Host "     Card: 5031 4332 1540 6351" -ForegroundColor Gray
    Write-Host "     CVV: 123" -ForegroundColor Gray
    Write-Host "     Expiry: 11/25" -ForegroundColor Gray
    Write-Host "     Name: APRO" -ForegroundColor Gray
} catch {
    Write-Host "✗ Error creating preference: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Manual Steps to Complete Test ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open the checkout URL above in your browser" -ForegroundColor Yellow
Write-Host "2. Complete the payment with the test card" -ForegroundColor Yellow
Write-Host "3. After payment, check backend console for webhook logs" -ForegroundColor Yellow
Write-Host "4. Run this script again to verify plan was upgraded" -ForegroundColor Yellow
Write-Host ""

# Step 3: Check current plan status
Write-Host "Step 3: Current plan status..." -ForegroundColor Yellow
try {
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/user" `
        -Method GET `
        -Headers @{ Authorization = "Bearer $token" }
    
    Write-Host "  Plan: $($userResponse.plan)" -ForegroundColor $(if ($userResponse.plan -eq 'pro') { 'Green' } else { 'Gray' })
    
    if ($userResponse.plan -eq 'pro') {
        Write-Host ""
        Write-Host "✓✓✓ SUCCESS! User plan is PRO ✓✓✓" -ForegroundColor Green
        Write-Host "  The webhook successfully upgraded the user!" -ForegroundColor Green
    } else {
        Write-Host "  ⏳ Plan is still '$($userResponse.plan)'" -ForegroundColor Yellow
        Write-Host "  Complete the payment to see the upgrade" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error checking user: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
