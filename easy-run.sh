#!/bin/bash

# ── المدخلات البسيطة فقط ──
read -p "📛 اسم الـ client      : " NAME </dev/tty
read -p "🌐 البورت الخارجي     : " PORT </dev/tty
read -p "💬 بورت الـ chat       : " CHAT </dev/tty

# ── بيلاقي أول /29 فاضي تلقائياً ──
USED=$(docker network inspect $(docker network ls -q) \
  --format '{{range .IPAM.Config}}{{.Subnet}}{{"\n"}}{{end}}' 2>/dev/null | grep -v '^$')

FREE=""
for PREFIX in "10.0.0" "10.10.0"; do
  for j in $(seq 0 8 248); do
    if ! echo "$USED" | grep -q "${PREFIX}.${j}/"; then
      FREE="${PREFIX}.${j}"
      break 2
    fi
  done
done

if [ -z "$FREE" ]; then
  echo "❌ مفيش رينج فاضي!"
  exit 1
fi

# ── حساب الـ IPs تلقائياً ──
BASE=$(echo $FREE | cut -d. -f1-3)
START=$(echo $FREE | cut -d. -f4)

SUBNET="${FREE}/29"
GW="${BASE}.$((START+1))"
ODOO_IP="${BASE}.$((START+2))"
DB_IP="${BASE}.$((START+3))"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ هيستخدم الإعدادات دي تلقائياً:"
echo "   Subnet  : $SUBNET"
echo "   Gateway : $GW"
echo "   Odoo IP : $ODOO_IP"
echo "   DB IP   : $DB_IP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "تكمل؟ (y/n): " CONFIRM </dev/tty
[ "$CONFIRM" != "y" ] && exit 0

# ── تشغيل ──
curl -s https://raw.githubusercontent.com/mahmoudhashemm/test5/main/run.sh \
  | sudo bash -s "$NAME" "$PORT" "$CHAT" 8069 8072 "$SUBNET" "$GW" "$ODOO_IP" "$DB_IP" "$NAME"
