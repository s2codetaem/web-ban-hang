# S2 Code Shop - Trang web bán tài khoản

## Overview
Trang web bán tài khoản (digital accounts) với đầy đủ tính năng: đăng ký/đăng nhập, xác minh email OTP, quên mật khẩu, Cloudflare Turnstile CAPTCHA, hệ thống ví tiền, nạp tiền qua PayOS, mua hàng tự trừ tiền. Hỗ trợ thuê tài khoản VPN với tính năng lấy mã 2FA tự động qua IMAP. Dev: Tạ Ngọc Long.

## Tech Stack
- **Backend**: Node.js + Express.js
- **Database**: PostgreSQL (Replit built-in)
- **View Engine**: EJS (server-side rendering)
- **Email**: Resend API (gửi OTP xác minh)
- **Payment**: PayOS API (nạp tiền)
- **CAPTCHA**: Cloudflare Turnstile
- **Auth**: Custom (bcryptjs + sessions)
- **IMAP**: node-imap + mailparser (lấy mã 2FA)

## Project Structure
```
src/
├── server.js              # Main server entry point
├── config/
│   └── database.js        # PostgreSQL config + schema init
├── middleware/
│   ├── auth.js            # Authentication middleware
│   └── turnstile.js       # Cloudflare Turnstile verification
├── utils/
│   ├── email.js           # Resend email service (OTP)
│   └── imap2fa.js         # IMAP service for fetching 2FA codes
├── routes/
│   ├── auth.js            # Register, Login, Forgot password
│   ├── shop.js            # Home, Category, Product, Buy, Orders, 2FA
│   ├── wallet.js          # Wallet, Topup via PayOS, Webhook
│   └── admin.js           # Admin panel routes
├── views/
│   ├── partials/
│   │   ├── header.ejs     # Nav bar with user info
│   │   └── footer.ejs     # Footer
│   ├── auth/
│   │   ├── register.ejs   # 2-step registration with OTP
│   │   ├── login.ejs      # Login with Turnstile CAPTCHA
│   │   └── forgot-password.ejs
│   ├── shop/
│   │   ├── home.ejs       # Product listing with categories
│   │   ├── product.ejs    # Product detail + buy
│   │   ├── wallet.ejs     # Balance + topup
│   │   └── orders.ejs     # Order history + 2FA code retrieval
│   └── admin/
│       ├── layout.ejs     # Admin layout header
│       ├── layout-end.ejs # Admin layout footer
│       ├── login.ejs      # Admin login page
│       ├── dashboard.ejs  # Dashboard with detailed stats
│       ├── categories.ejs # CRUD categories
│       ├── products.ejs   # CRUD products (with has_2fa toggle)
│       ├── product-items.ejs # Manage items with IMAP config
│       ├── users.ejs      # View users
│       └── orders.ejs     # View orders
└── public/
    └── css/
        ├── style.css      # Full responsive CSS (dark theme)
        └── admin.css      # Admin panel CSS
```

## Required Environment Variables
- `RESEND_API_KEY` - Resend API key for sending OTP emails
- `RESEND_FROM_EMAIL` - Sender email address (optional, defaults to onboarding@resend.dev)
- `TURNSTILE_SITE_KEY` - Cloudflare Turnstile site key
- `TURNSTILE_SECRET_KEY` - Cloudflare Turnstile secret key
- `PAYOS_CLIENT_ID` - PayOS client ID
- `PAYOS_API_KEY` - PayOS API key
- `PAYOS_CHECKSUM_KEY` - PayOS checksum key
- `SESSION_SECRET` - Session secret key

## Database Tables
- `users` - User accounts with balance, is_admin flag
- `otp_codes` - OTP verification codes
- `categories` - Product categories
- `products` - Products listing (has_2fa flag for IMAP support)
- `product_items` - Individual items with optional IMAP config (imap_host, imap_port, imap_user, imap_pass)
- `transactions` - Money transactions (topup/purchase)
- `orders` - Purchase orders
- `user_sessions` - Express sessions

## Key Features
1. Email OTP verification for registration
2. Password reset via email OTP
3. Cloudflare Turnstile CAPTCHA on login
4. Product categories with sidebar navigation
5. Wallet system with PayOS integration
6. Auto-deduct balance on purchase
7. Order history with account data display
8. Responsive mobile-friendly design (dark theme)
9. Admin panel with dashboard, CRUD, detailed stats
10. VPN account rental with automatic 2FA code retrieval via IMAP
11. Admin login auto-redirect to admin panel

## Admin Panel
- Login: /admin/login (admin@shopacc.com / So081220@@)
- Dashboard with detailed stats: revenue, orders, registrations (today/week/month/all)
- CRUD: categories, products, product items
- Products support has_2fa toggle for IMAP-based 2FA retrieval
- Product items can store IMAP credentials (host, port, user, pass)

## 2FA Feature Flow
1. Admin creates product with has_2fa=true
2. Admin adds items with IMAP credentials (email server, user, password)
3. User purchases the product, gets account credentials
4. In orders page, user clicks "Lấy mã 2FA" button
5. System connects to email via IMAP, reads recent emails, extracts 2FA code
6. Code displayed to user with copy button

## Recent Changes
- 2026-02-11: Renamed to S2 Code Shop with animated neon logo (Orbitron font)
- 2026-02-11: Updated footer: copyright 2026, dev Tạ Ngọc Long, Telegram contact
- 2026-02-11: Neon dark theme overhaul with animations (glow effects, fadeInUp, gradient shifts)
- 2026-02-11: Admin panel UI enhanced with neon effects
- 2026-02-11: Admin password updated to So081220@@
- 2026-02-11: Added Surfshark VPN rental with 2FA code retrieval via IMAP
- 2026-02-11: Enhanced admin dashboard with detailed revenue/orders/registration stats
- 2026-02-11: Admin auto-redirect on login
- 2026-02-10: Initial project setup with full features
