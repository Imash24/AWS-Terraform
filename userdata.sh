#!/bin/bash
# Update package lists and install Apache
apt update
apt install -y apache2

# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
apt install -y awscli

# Download images from S3 bucket (Uncomment if needed)
# aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a stylish HTML page for the portfolio
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Ashwin's Portfolio</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      color: #333;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 800px;
      margin: 20px auto;
      padding: 20px;
      background-color: #fff;
      border-radius: 5px;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }
    h1 {
      color: #007bff;
      text-align: center;
    }
    h2 {
      color: #333;
    }
    p {
      color: #666;
    }
    .instance-info {
      border-top: 1px solid #ccc;
      padding-top: 10px;
    }
    .footer {
      text-align: center;
      margin-top: 20px;
      color: #777;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Welcome to Ashwin's Portfolio</h1>
    <p>Below are the details of the AWS EC2 instance:</p>
    <div class="instance-info">
      <h2>Instance ID:</h2>
      <p><span style="color: #007bff;">$INSTANCE_ID</span></p>
    </div>
    <div class="footer">
      <p>Powered by Apache on AWS EC2</p>
    </div>
  </div>
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2
