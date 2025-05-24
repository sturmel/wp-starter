#!/bin/bash

echo "[ConfigureMSMTP] Configuring msmtp..."

MSMTP_CONFIG_FILE="/etc/msmtprc"

MSMTP_CONTENT="defaults\\n"
MSMTP_CONTENT+="auth ${MSMTP_AUTH:-on}\\n"
MSMTP_CONTENT+="tls ${MSMTP_TLS:-off}\\n"
MSMTP_CONTENT+="tls_starttls ${MSMTP_TLS_STARTTLS:-on}\\n"
MSMTP_CONTENT+="tls_trust_file /etc/ssl/certs/ca-certificates.crt\\n"
if [ -n "${MSMTP_LOGFILE:-}" ]; then
    MSMTP_CONTENT+="logfile ${MSMTP_LOGFILE}\\n" 
else
    MSMTP_CONTENT+="logfile /dev/null\\n" 
fi
MSMTP_CONTENT+="\\naccount default\\n"
MSMTP_CONTENT+="host ${MSMTP_HOST}\\n"
MSMTP_CONTENT+="port ${MSMTP_PORT}\\n"
MSMTP_CONTENT+="from ${MSMTP_FROM}\\n"

if [ "${MSMTP_AUTH:-on}" = "on" ] && [ -n "${MSMTP_USER:-}" ]; then
    MSMTP_CONTENT+="user ${MSMTP_USER}\\n"
    MSMTP_CONTENT+="password ${MSMTP_PASSWORD}\\n"
fi

echo -e "${MSMTP_CONTENT}" > "${MSMTP_CONFIG_FILE}"
chmod 644 "${MSMTP_CONFIG_FILE}"
echo "[ConfigureMSMTP] ${MSMTP_CONFIG_FILE} configured from environment variables."
