#!/bin/sh

# Migrations
python manage.py migrate --noinput

# Collectstatic (sauf si désactivé)
if [ "$DISABLE_COLLECTSTATIC" != "1" ]; then
    python manage.py collectstatic --noinput --clear --verbosity 2
    if [ $? -eq 0 ]; then
        echo "✅ collectstatic réussi"
    else
        echo "❌ collectstatic a échoué"
        exit 1
    fi
else
    echo "⚠️ collectstatic désactivé (DISABLE_COLLECTSTATIC=1)"
fi

# Créer un superutilisateur automatiquement (si non existant)
echo "from accounts.models import User; User.objects.filter(is_superuser=True).exists() or User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell

exec gunicorn core.wsgi:application --bind 0.0.0.0:10000