# Restart Caddy
sudo systemctl restart caddy
if [ $? -eq 0 ]; then
    echo "Caddy restarted successfully."
else
    echo "Failed to restart Caddy."
fi

# Restart PostgreSQL
sudo systemctl restart postgresql
if [ $? -eq 0 ]; then
    echo "PostgreSQL restarted successfully."
else
    echo "Failed to restart PostgreSQL."
fi

# Restart Matrix Synapse
sudo systemctl restart matrix-synapse
if [ $? -eq 0 ]; then
    echo "Matrix Synapse restarted successfully."
else
    echo "Failed to restart Matrix Synapse."
fi

# Restart Eturnal

sudo eturnalctl restart
if [ $? -eq 0 ]; then
    echo "Eturnal restarted successfully."
else
    echo "Failed to restart Eturnal."
fi
