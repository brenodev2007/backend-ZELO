import { Request, Response } from 'express';
import { MercadoPagoConfig, Preference, Payment } from 'mercadopago';
import pool from '../config/db';

const client = new MercadoPagoConfig({ accessToken: process.env.MP_ACCESS_TOKEN as string });

export const createPreference = async (req: Request, res: Response) => {
  try {
    const { title, quantity, price, userId, plan } = req.body;

    const body = {
      items: [
        {
          id: plan || '1234',
          title: title,
          quantity: Number(quantity),
          unit_price: Number(price),
          currency_id: 'BRL',
        },
      ],
      back_urls: {
        success: `http://localhost:5173/payment/success`,
        failure: `http://localhost:5173/payment/failure`,
        pending: `http://localhost:5173/payment/pending`,
      },
      auto_return: 'approved' as const,
      notification_url: 'http://localhost:5000/api/payment/webhook',
      metadata: {
        user_id: userId,
        plan: plan,
      },
    };

    const preference = new Preference(client);
    const result = await preference.create({ body });
    
    res.json({
      id: result.id,
      init_point: result.init_point,
      sandbox_init_point: result.sandbox_init_point,
    });
  } catch (error) {
    console.error('Error creating preference:', error);
    res.status(500).json({
      error: 'Error creating preference',
    });
  }
};

export const handleWebhook = async (req: Request, res: Response) => {
  try {
    const { type, data } = req.body;

    console.log('Webhook received:', { type, data });

    // Respond immediately to Mercado Pago
    res.status(200).send('OK');

    // Process payment notification
    if (type === 'payment') {
      const paymentId = data.id;
      
      // Get payment details from Mercado Pago
      const payment = new Payment(client);
      const paymentInfo = await payment.get({ id: paymentId });

      console.log('Payment info:', paymentInfo);

      if (paymentInfo.status === 'approved') {
        const userId = paymentInfo.metadata?.user_id;
        const plan = paymentInfo.metadata?.plan;

        if (userId && plan) {
          // Update user plan
          await pool.query(
            'UPDATE users SET plan = ? WHERE id = ?',
            [plan, userId]
          );

          // Create subscription record
          await pool.query(
            'INSERT INTO subscriptions (user_id, preapproval_id, status, plan, amount) VALUES (?, ?, ?, ?, ?)',
            [userId, paymentInfo.id, 'active', plan, paymentInfo.transaction_amount]
          );

          console.log(`User ${userId} upgraded to ${plan} plan`);
        }
      }
    }
  } catch (error) {
    console.error('Webhook error:', error);
    // Don't send error to Mercado Pago, already responded with 200
  }
};

export const verifyPayment = async (req: Request, res: Response) => {
  try {
    const paymentId = Array.isArray(req.params.paymentId) 
      ? req.params.paymentId[0] 
      : req.params.paymentId;
    
    const payment = new Payment(client);
    const paymentInfo = await payment.get({ id: paymentId });

    res.json({
      status: paymentInfo.status,
      statusDetail: paymentInfo.status_detail,
      amount: paymentInfo.transaction_amount,
    });
  } catch (error) {
    console.error('Error verifying payment:', error);
    res.status(500).json({
      error: 'Error verifying payment',
    });
  }
};
