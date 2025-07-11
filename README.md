# 🚀 Order Fulfillment & Tracking System  
**Python-based | Miami, Florida • May 2025**  


## 🔍 Overview  
Order_fullfillment_Project is a cloud-native, scalable solution to automate and streamline order processing, validation, invoice generation, and real-time tracking. Leveraging AWS Lambda, Step Functions, DynamoDB, and Terraform, it provides an efficient backend for shipping and order management. The project features modular Flask APIs, Dockerized development, and robust CI/CD pipelines using GitHub Actions and Pytest.

---

## 🧊 Render Free Tier Notice

This app is hosted on [Render](https://render.com) using the **free instance tier**, which may introduce a delay of **up to ~50 seconds** on first access after idle periods.

> Render services spin down after ~15 minutes of inactivity to conserve resources. When a new request arrives, the instance wakes up and boots the app before responding.

---

**Homepage:** [Order Fullfillment Project Live](https://order-fullfillment-project.onrender.com)  
**Repository:** [GitHub](https://github.com/Stefodan21/Order_fullfillment_Project)  
**License:** MIT

## 🧩 Core Features  
- **Automated Order Tracking:** Terraform, REST API, AWS Lambda, Step Functions, and Docker.
- **Seamless CI/CD Pipelines:** GitHub Actions & Jenkins for rapid, reliable deployment.
- **Scalable Architecture:** Serverless execution optimizes fulfillment.
- **Invoice Generation:** AWS Lambda-powered PDF invoices, stored in S3 with automated lifecycle.
- **Order Validation & Shipping Suggestions:** Modular Lambda functions integrated with Flask API.

## 💡 Technical Highlights  
- **Infrastructure as Code:** Managed via Terraform (`Infra/` directory).
- **Containerized Deployment:** Docker ensures consistency.
- **Continuous Deployment:** GitHub Actions + Jenkins automate delivery.
- **Real-Time API Integration:** Flask-based REST APIs for order operations.
- **AWS Services:** Lambda, DynamoDB, S3, API Gateway.
- **PDF Generation:** fpdf library for invoices.

## 📁 Key Components  
- `api.py`: Main Flask API, routes for order validation, invoice generation, shipping suggestion, and order tracking.
- `Infra/`: Terraform files for AWS infrastructure—S3, Lambda, DynamoDB, providers, outputs.
- `InvoiceGenerator/`: PDF generation logic for invoices.
- `OrderStatusTracking/`: Utilities for real-time order status updates.
- `requirements.txt`: Project dependencies (Flask, boto3, pytest, fpdf, etc.).

> **Note:** Only a subset of files and directories are shown. [View more files](https://github.com/Stefodan21/Order_fullfillment_Project/search) in the GitHub repository.

## 🔧 Installation

```bash
git clone https://github.com/Stefodan21/Order_fullfillment_Project
cd Order_fullfillment_Project
pip install -r requirements.txt
# For Dockerized dev
docker build -t order_fullfillment .
docker run -p 5000:5000 order_fullfillment
```

## 🚀 Usage

- **API Endpoints:**  
  - `/order_validation` — Validate incoming orders  
  - `/invoiceGenerator` — Generate invoices  
  - `/ShippingSuggestion` — Get shipping recommendations  
  - `/OrderStatusTracking` — Track order status  

- **Infrastructure:**  
  - Deploy resources using Terraform in the `Infra/` directory:
    ```bash
    cd Infra
    terraform init
    terraform apply
    ```

## 🧪 Testing

- **Pytest** is used for unit and integration tests.
  ```bash
  pytest
  ```

## 🛠️ Development

- Modular code: Each major feature (validation, tracking, invoicing) is implemented as a separate Lambda function and integrated via Flask.
- Extensible: Easily add new endpoints or Lambda logic.
- Docker and virtualenv for reproducible development.

## 📃 License

This project is licensed under the MIT License.

---

For more details, see the [documentation](https://github.com/Stefodan21/Order_fullfillment_Project/wiki) or [open an issue](https://github.com/Stefodan21/Order_fullfillment_Project/issues) if you have questions.