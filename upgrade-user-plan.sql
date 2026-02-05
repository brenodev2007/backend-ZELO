-- Simulate successful payment webhook processing
UPDATE users SET plan = 'pro' WHERE id = ;

INSERT INTO subscriptions (user_id, preapproval_id, status, plan, amount)
VALUES (, 'TEST-PAYMENT-12345678901', 'active', 'pro', 19.90);

-- Verify the update
SELECT id, name, email, plan FROM users WHERE id = ;
SELECT * FROM subscriptions WHERE user_id =  ORDER BY created_at DESC LIMIT 1;
