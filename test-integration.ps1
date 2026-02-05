# Integration Test: Complete Payment Flow
Write-Host "=== Mercado Pago Integration Test ===" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:5000"
$frontendUrl = "http://localhost:5173"

# Test 1: Register a test user
Write-Host "Test 1: Creating test user..." -ForegroundColor Yellow
$registerBody = @{
    name = "Test Payment User"
    email = "payment-test@test.com"
    password = "test123"
    acceptedTerms = $true
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" `
        -Method POST `
        -Body $registerBody `
        -ContentType "application/json"
    
    Write-Host "✓ User registered successfully" -ForegroundColor Green
    Write-Host "  User ID: $($registerResponse.user.id)" -ForegroundColor Gray
    $userId = $registerResponse.user.id
    $token = $registerResponse.token
} catch {
    if ($_.Exception.Message -like "*already exists*") {
        Write-Host "! User already exists, logging in..." -ForegroundColor Yellow
        
        # Login instead
        $loginBody = @{
            email = "payment-test@test.com"
            password = "test123"
        } | ConvertTo-Json
        
        $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" `
            -Method POST `
            -Body $loginBody `
            -ContentType "application/json"
        
        Write-Host "✓ User logged in successfully" -ForegroundColor Green
        $userId = $loginResponse.user.id
        $token = $loginResponse.token
    } else {
        Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# Test 2: Check current user plan
Write-Host "Test 2: Checking current user plan..." -ForegroundColor Yellow
try {
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/user" `
        -Method GET `
        -Headers @{ Authorization = "Bearer $token" }
    
    Write-Host "✓ Current plan: $($userResponse.plan)" -ForegroundColor Green
    $currentPlan = $userResponse.plan
} catch {
    Write-Host "✗ Error checking plan: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Create payment preference
Write-Host "Test 3: Creating payment preference for Pro plan..." -ForegroundColor Yellow
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
    Write-Host "  Sandbox URL: $($preferenceResponse.sandbox_init_point)" -ForegroundColor Gray
    $preferenceId = $preferenceResponse.id
} catch {
    Write-Host "✗ Error creating preference: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 4: Simulate webhook notification
Write-Host "Test 4: Simulating Mercado Pago webhook..." -ForegroundColor Yellow
Write-Host "  (This simulates what happens when payment is approved)" -ForegroundColor Gray

# Create a mock payment ID
$mockPaymentId = "12345678901"

# Note: We can't actually call the webhook with a fake payment ID
# because it will try to verify with Mercado Pago API
Write-Host "  ⚠ Webhook requires real payment ID from Mercado Pago" -ForegroundColor Yellow
Write-Host "  To test webhook:" -ForegroundColor Yellow
Write-Host "    1. Complete a payment in Mercado Pago sandbox" -ForegroundColor Gray
Write-Host "    2. Mercado Pago will call the webhook automatically" -ForegroundColor Gray
Write-Host "    3. Check backend logs for webhook processing" -ForegroundColor Gray

Write-Host ""

# Test 5: Manual plan upgrade (simulating successful payment)
Write-Host "Test 5: Manually upgrading user plan (simulating webhook success)..." -ForegroundColor Yellow
Write-Host "  This simulates what the webhook would do after payment approval" -ForegroundColor Gray

# We'll create a direct database update script
$sqlScript = @"
-- Simulate successful payment webhook processing
UPDATE users SET plan = 'pro' WHERE id = $userId;

INSERT INTO subscriptions (user_id, preapproval_id, status, plan, amount)
VALUES ($userId, 'TEST-PAYMENT-$mockPaymentId', 'active', 'pro', 19.90);

-- Verify the update
SELECT id, name, email, plan FROM users WHERE id = $userId;
SELECT * FROM subscriptions WHERE user_id = $userId ORDER BY created_at DESC LIMIT 1;
"@

$sqlScript | Out-File -FilePath "upgrade-user-plan.sql" -Encoding UTF8
Write-Host "✓ SQL script created: upgrade-user-plan.sql" -ForegroundColor Green
Write-Host "  Run this script in MySQL to simulate successful payment" -ForegroundColor Gray

Write-Host ""

# Test 6: Instructions for manual testing
Write-Host "=== Manual Testing Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Complete Payment in Sandbox:" -ForegroundColor Yellow
Write-Host "   - Open: $($preferenceResponse.sandbox_init_point)" -ForegroundColor Gray
Write-Host "   - Use test card: 5031 4332 1540 6351" -ForegroundColor Gray
Write-Host "   - CVV: 123, Expiry: 11/25" -ForegroundColor Gray
Write-Host "   - Name: APRO (for approved)" -ForegroundColor Gray
Write-Host ""

Write-Host "2. OR Simulate with SQL:" -ForegroundColor Yellow
Write-Host "   mysql -u root -p zelo < upgrade-user-plan.sql" -ForegroundColor Gray
Write-Host ""

Write-Host "3. Verify Plan Update:" -ForegroundColor Yellow
Write-Host "   - Login to app with: payment-test@test.com / test123" -ForegroundColor Gray
Write-Host "   - Go to Profile page" -ForegroundColor Gray
Write-Host "   - Check if plan shows 'Pro'" -ForegroundColor Gray
Write-Host "   - Check if tokens show 50" -ForegroundColor Gray
Write-Host ""

Write-Host "=== Test Summary ===" -ForegroundColor Cyan
Write-Host "✓ User created/logged in" -ForegroundColor Green
Write-Host "✓ Payment preference created" -ForegroundColor Green
Write-Host "✓ Sandbox checkout URL generated" -ForegroundColor Green
Write-Host "⏳ Webhook testing requires live payment or SQL simulation" -ForegroundColor Yellow
Write-Host ""
Write-Host "User Details:" -ForegroundColor Cyan
Write-Host "  Email: payment-test@test.com" -ForegroundColor Gray
Write-Host "  Password: test123" -ForegroundColor Gray
Write-Host "  User ID: $userId" -ForegroundColor Gray
Write-Host "  Current Plan: $currentPlan" -ForegroundColor Gray
Write-Host ""
