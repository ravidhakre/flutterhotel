const nodemailer = require('nodemailer');

// Configure SMTP Transporter (Uses environment variables or default fallback config)
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.SMTP_SECURE === 'true', // true for 465, false for 587
  auth: {
    user: process.env.SMTP_USER || 'sales@flutterhotel.com',
    pass: process.env.SMTP_PASS || 'demo_app_password'
  },
  tls: {
    rejectUnauthorized: false
  }
});

/**
 * Generate Luxury HTML Email Template for Room Booking Confirmation
 */
function generateBookingEmailHTML(booking, room) {
  return `
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="utf-8">
    <style>
      body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 0; color: #333333; }
      .email-container { max-width: 650px; margin: 30px auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.08); border: 1px solid #e2e8f0; }
      .email-header { background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); padding: 35px 30px; text-align: center; color: #ffffff; }
      .brand-title { font-family: 'Georgia', serif; font-size: 24px; font-weight: bold; letter-spacing: 2px; color: #ffffff; margin: 0; }
      .brand-sub { font-size: 11px; letter-spacing: 3px; color: #f59e0b; text-transform: uppercase; margin-top: 5px; }
      .email-body { padding: 40px 35px; }
      .badge-success { background-color: #dcfce7; color: #166534; font-size: 13px; font-weight: bold; padding: 6px 16px; border-radius: 20px; display: inline-block; margin-bottom: 20px; }
      .greeting-title { font-size: 22px; font-weight: bold; color: #0f172a; margin-top: 0; margin-bottom: 10px; }
      .greeting-text { font-size: 15px; color: #475569; line-height: 1.7; margin-bottom: 25px; }
      .booking-card { background-color: #f8fafc; border-radius: 10px; padding: 25px; border: 1.5px solid #e2e8f0; margin-bottom: 30px; }
      .card-header { border-bottom: 2px dashed #cbd5e1; padding-bottom: 15px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }
      .booking-id-tag { font-size: 18px; font-weight: bold; color: #5F86C1; }
      .info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
      .info-label { color: #64748b; font-weight: 500; }
      .info-value { color: #0f172a; font-weight: 600; text-align: right; }
      .total-row { display: flex; justify-content: space-between; padding-top: 15px; margin-top: 10px; border-top: 2px solid #e2e8f0; font-size: 18px; font-weight: bold; }
      .total-price { color: #5F86C1; font-size: 22px; }
      .instructions-box { background-color: #eff6ff; border-left: 4px solid #5F86C1; padding: 18px; border-radius: 6px; margin-bottom: 30px; font-size: 14px; color: #1e3a8a; line-height: 1.6; }
      .email-footer { background-color: #0f172a; color: #94a3b8; padding: 25px; text-align: center; font-size: 13px; line-height: 1.6; }
      .btn-contact { background-color: #5F86C1; color: #ffffff !important; padding: 12px 25px; border-radius: 25px; text-decoration: none; font-weight: bold; font-size: 14px; display: inline-block; margin-top: 10px; }
    </style>
  </head>
  <body>
    <div class="email-container">
      <div class="email-header">
        <h1 class="brand-title">FLUTTER HOTELS & RESORTS</h1>
        <div class="brand-sub">Hill Resort in Lansdowne, Uttarakhand</div>
      </div>
      
      <div class="email-body">
        <div style="text-align: center;">
          <span class="badge-success">✔ BOOKING CONFIRMED</span>
        </div>
        <h2 class="greeting-title">Dear ${booking.guestName},</h2>
        <p class="greeting-text">
          Thank you for choosing <strong>Flutter Hotels & Resorts</strong>. We are delighted to confirm your room reservation. Below are your booking details for your upcoming stay in Lansdowne.
        </p>

        <div class="booking-card">
          <div class="card-header">
            <span style="font-size: 13px; color: #64748b; text-transform: uppercase;">Reservation Reference</span>
            <span class="booking-id-tag">${booking.id}</span>
          </div>

          <div class="info-row">
            <span class="info-label">Guest Name:</span>
            <span class="info-value">${booking.guestName}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Contact Phone:</span>
            <span class="info-value">${booking.phone || 'N/A'}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Reserved Suite:</span>
            <span class="info-value">${booking.roomName}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Check-in Date:</span>
            <span class="info-value">${booking.checkIn} (From 12:00 PM)</span>
          </div>
          <div class="info-row">
            <span class="info-label">Check-out Date:</span>
            <span class="info-value">${booking.checkOut} (By 10:00 AM)</span>
          </div>
          <div class="info-row">
            <span class="info-label">Total Guests:</span>
            <span class="info-value">${booking.guests} Guest(s)</span>
          </div>
          <div class="info-row">
            <span class="info-label">Payment Method:</span>
            <span class="info-value">${booking.paymentMethod || 'Pay at Hotel Check-in'}</span>
          </div>

          <div class="total-row">
            <span>Total Payable Amount:</span>
            <span class="total-price">₹${booking.totalPrice}</span>
          </div>
        </div>

        <div class="instructions-box">
          <strong>Important Check-in Guidelines:</strong><br>
          • Check-in time starts at <strong>12:00 PM</strong> and Check-out is by <strong>10:00 AM</strong>.<br>
          • Please carry a valid Government-issued Photo ID proof (Aadhaar Card, Driving License, Voter ID, or Passport) for all adult guests.<br>
          • Hotel Address: Palkot–Lansdowne, Pauri Garhwal, Uttarakhand – 246155, India.
        </div>

        <div style="text-align: center;">
          <a href="https://wa.me/918929232740?text=Hi,%20I%20have%20a%20question%20regarding%20Booking%20ID%20${booking.id}" class="btn-contact">Chat With Resort Concierge</a>
        </div>
      </div>

      <div class="email-footer">
        <strong>Flutter Hotels & Resorts, Lansdowne</strong><br>
        Palkot–Lansdowne, Pauri Garhwal, Uttarakhand – 246155, India<br>
        Phone: +91 89 2923 2740 / +91 13 8629 9133 | Email: sales@flutterhotel.com<br>
        © 2026 Flutter Hotels & Resorts. All Rights Reserved.
      </div>
    </div>
  </body>
  </html>
  `;
}

/**
 * Send Booking Confirmation Email to Guest and Admin
 */
async function sendBookingConfirmationEmail(booking, room) {
  try {
    const htmlContent = generateBookingEmailHTML(booking, room);

    const mailOptions = {
      from: '"Flutter Hotels & Resorts" <sales@flutterhotel.com>',
      to: booking.email,
      cc: 'sales@flutterhotel.com', // Sends copy to Admin as requested
      subject: `Booking Confirmed [${booking.id}] — Flutter Hotels & Resorts, Lansdowne`,
      html: htmlContent
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`[Email Service] Confirmation email dispatched for Booking ID: ${booking.id}. Message ID: ${info.messageId}`);
    return true;
  } catch (err) {
    console.warn(`[Email Service] Email dispatch simulation fallback for Booking ID ${booking.id}:`, err.message);
    return false;
  }
}

module.exports = {
  sendBookingConfirmationEmail,
  generateBookingEmailHTML
};
