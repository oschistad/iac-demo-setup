# Login to Azure
# Create subscription
# Create service principal
# Authorize SP in subscription
az login
# Logs in and lists subscription id + tenant id
export subscription_id="0b93712e-3fca-419d-8a68-5ce454ce7e9a"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${subscription_id}"



