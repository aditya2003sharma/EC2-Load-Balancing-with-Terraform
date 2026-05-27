#!/bin/bash

# Update system packages
sudo apt update -y

# Install Apache2
sudo apt install apache2 -y

# Start Apache service
sudo systemctl start apache2

# Enable Apache service on boot
sudo systemctl enable apache2

# Create a custom web page
sudo bash -c 'cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Project 1</title>
</head>
<body>
    <h1>Hello! This is Terraform Project 1</h1>
    <h2>Apache Server Installed Successfully</h2>
</body>
</html>
EOF'

# Display Apache status
sudo systemctl status apache2 --no-pager

echo "Apache installation and deployment completed successfully!"