#!/bin/bash

echo "=========================================="
echo "  S2 Code Shop - Auto Deploy Script"
echo "  Developer: Tạ Ngọc Long"
echo "=========================================="

read -p "Nhập link GitHub repo (vd: https://github.com/user/s2-code-shop.git): " GITHUB_URL
read -p "Nhập domain (vd: tangoclong.website): " DOMAIN
read -p "Nhập mật khẩu PostgreSQL muốn đặt: " DB_PASS
read -p "Nhập SESSION_SECRET (chuỗi bất kỳ): " SESSION_SECRET
read -p "Nhập RESEND_API_KEY: " RESEND_API_KEY
read -p "Nhập PAYOS_CLIENT_ID: " PAYOS_CLIENT_ID
read -p "Nhập PAYOS_API_KEY: " PAYOS_API_KEY
read -p "Nhập PAYOS_CHECKSUM_KEY: " PAYOS_CHECKSUM_KEY
read -p "Nhập TURNSTILE_SITE_KEY: " TURNSTILE_SITE_KEY
read -p "Nhập TURNSTILE_SECRET_KEY: " TURNSTILE_SECRET_KEY

echo ""
echo ">>> [1/7] Cài đặt phần mềm..."
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs postgresql nginx certbot python3-certbot-nginx git
sudo npm install -g pm2

echo ""
echo ">>> [2/7] Tạo database PostgreSQL..."
sudo -u postgres psql -c "CREATE USER s2code WITH PASSWORD '$DB_PASS';" 2>/dev/null
sudo -u postgres psql -c "CREATE DATABASE s2codeshop OWNER s2code;" 2>/dev/null
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE s2codeshop TO s2code;" 2>/dev/null

echo ""
echo ">>> [3/7] Clone code từ GitHub..."
cd /home/ubuntu
if [ -d "s2-code-shop" ]; then
  cd s2-code-shop && git pull
else
  git clone "$GITHUB_URL" s2-code-shop
  cd s2-code-shop
fi

echo ""
echo ">>> [4/7] Cài đặt dependencies..."
npm install

echo ""
echo ">>> [5/7] Tạo file .env..."
cat > .env << EOF
APP_DOMAIN=https://${DOMAIN}
DATABASE_URL=postgresql://s2code:${DB_PASS}@localhost:5432/s2codeshop
PGHOST=localhost
PGPORT=5432
PGUSER=s2code
PGPASSWORD=${DB_PASS}
PGDATABASE=s2codeshop
SESSION_SECRET=${SESSION_SECRET}
RESEND_API_KEY=${RESEND_API_KEY}
RESEND_FROM_EMAIL=S2 Code Shop <noreply@tangoclong.website>
PAYOS_CLIENT_ID=${PAYOS_CLIENT_ID}
PAYOS_API_KEY=${PAYOS_API_KEY}
PAYOS_CHECKSUM_KEY=${PAYOS_CHECKSUM_KEY}
TURNSTILE_SITE_KEY=${TURNSTILE_SITE_KEY}
TURNSTILE_SECRET_KEY=${TURNSTILE_SECRET_KEY}
EOF

echo ""
echo ">>> [6/7] Cấu hình Nginx..."
sudo tee /etc/nginx/sites-available/s2codeshop > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/s2codeshop /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

echo ""
echo ">>> [7/7] Khởi động app bằng PM2..."
pm2 stop s2codeshop 2>/dev/null
pm2 delete s2codeshop 2>/dev/null
pm2 start src/server.js --name s2codeshop
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu 2>/dev/null

echo ""
echo "=========================================="
echo "  XONG! Web đã chạy tại http://$DOMAIN"
echo "=========================================="
echo ""
echo "Để cài SSL (HTTPS), chạy lệnh:"
echo "  sudo certbot --nginx -d $DOMAIN"
echo ""
echo "Sau này cập nhật code:"
echo "  cd /home/ubuntu/s2-code-shop && git pull && npm install && pm2 restart s2codeshop"
echo ""
