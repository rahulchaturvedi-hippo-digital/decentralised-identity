export $(cat .env | xargs)
az login --tenant $ARM_TENANT_ID