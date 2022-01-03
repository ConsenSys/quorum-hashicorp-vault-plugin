set -e

VAULT_TOKEN=$(cat "${ROOT_TOKEN_PATH}")
VAULT_SSL_PARAMS=""
if [ -n "$VAULT_CACERT" ]; then
 VAULT_SSL_PARAMS="$VAULT_SSL_PARAMS --cacert $VAULT_CACERT"
fi  

if [ -n "$VAULT_CLIENT_CERT" ]; then
 VAULT_SSL_PARAMS="$VAULT_SSL_PARAMS --cert $VAULT_CLIENT_CERT"
fi     

if [ -n "$VAULT_CLIENT_KEY" ]; then
 VAULT_SSL_PARAMS="$VAULT_SSL_PARAMS --key $VAULT_CLIENT_KEY"
fi   
 
echo "[AGENT] Enabling approle auth"
curl -s --header "X-Vault-Token: ${VAULT_TOKEN}" --request POST ${VAULT_SSL_PARAMS} \
  --data '{"type": "approle"}' \
  ${VAULT_ADDR}/v1/sys/auth/approle

echo "[AGENT] Adding policy capabilities '${CAPABILITIES}' to '${PLUGIN_MOUNT_PATH}'"
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request PUT ${VAULT_SSL_PARAMS} \
  --data '{ "policy":"path \"'"${PLUGIN_MOUNT_PATH}/*"'\" { capabilities = '"${CAPABILITIES}"' }" }' \
  ${VAULT_ADDR}/v1/sys/policies/acl/allow_secrets

echo "[AGENT] Create an AppRole '${APP_ROLE}' with desired set of policies '${POLICIES}'"
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST ${VAULT_SSL_PARAMS} \
  --data '{"policies": '"${POLICIES}"'}' \
  ${VAULT_ADDR}/v1/auth/approle/role/${APP_ROLE}

echo "[AGENT] Fetching role identifier"
curl -s --header "X-Vault-Token: $VAULT_TOKEN" ${VAULT_SSL_PARAMS} \
  ${VAULT_ADDR}/v1/auth/approle/role/${APP_ROLE}/role-id > role.json
ROLE_ID=$(cat role.json | jq .data.role_id | tr -d '"')
echo $ROLE_ID > ${ROLE_FILE_PATH}
rm role.json
  
echo "[AGENT] Fetching role secret"
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST ${VAULT_SSL_PARAMS} \
  ${VAULT_ADDR}/v1/auth/approle/role/${APP_ROLE}/secret-id > secret.json
SECRET_ID=$(cat secret.json | jq .data.secret_id | tr -d '"')
echo $SECRET_ID > ${SECRET_FILE_PATH}
rm secret.json
