# Hippo Credential Issuance and Verifier Service

## Summary
This decentralized ID project is a proof-of-concept (PoC) for issuing and verifying DID credentials. The goal is to have a service that issues a **Hippo Credential** according to a use case (e.g., confirming a person is over 18) and a verifier service that can prove its validity.

---

## Getting Started

### Prerequisites

Before running this project, make sure you have the following installed:

- **.NET 8 SDK**  
  Download from [here](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)

- **ngrok**  
  Download from [ngrok official site](https://ngrok.com/download) and follow the setup instructions.

---

## Setting Up `ngrok`

Ngrok allows you to expose your local server to the internet. Follow these steps to install and run it.

### 1. Download ngrok

1. Go to the [ngrok download page](https://ngrok.com/download).  
2. Choose the version for your operating system (Windows, macOS, Linux).  
3. Extract the downloaded archive to a folder of your choice.

### 2. Connect Your ngrok Account (Optional but Recommended)

1. Sign up for a free ngrok account: [https://dashboard.ngrok.com/signup](https://dashboard.ngrok.com/signup)  
2. Once logged in, get your **authtoken** from [https://dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)  
3. In your terminal, run:
   ```bash
   ngrok config add-authtoken <YOUR_AUTHTOKEN>

## Running the Application (Quick Start)

From the terminal, run this single command from anywhere to start the application:

```bash
cd /decentralised-identity-1/1-asp-net-core-api-idtokenhint && chmod +x run-me.sh && ./run-me.sh
