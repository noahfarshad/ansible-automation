CERT_REQUEST=$1
MSCA=$2
USER=$3
PASS=$4
OUTPUT=$5

CERT=`cat $CERT_REQUEST | tr -d '\n\r'`
DATA="Mode=newreq&CertRequest=${CERT}&C&TargetStoreFlags=0&SaveCert=yes"
CERT=`echo ${CERT} | sed 's/+/%2B/g'`
CERT=`echo ${CERT} | tr -s ' ' '+'`
CERTATTRIB="CertificateTemplate%3AWebServer%0D%0AUserAgent%3AMozilla%2F5.0+%28X11%3B+Linux+x86_64%3B+rv%3A57.0%29+Gecko%2F20100101+Firefox%2F57.0%0D%0"

# Sign Request
OUTPUTLINK=`curl -k -u "$USER":$PASS --ntlm \
"https://${MSCA}/certsrv/certfnsh.asp" \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.5' \
-H 'Connection: keep-alive' \
-H "Host: ${MSCA}" \
-H "Referer: https://${MSCA}/certsrv/certrqxt.asp" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko' \
-H 'Content-Type: application/x-www-form-urlencoded' \
--data "Mode=newreq&CertRequest=${CERT}&CertAttrib=${CERTATTRIB}&TargetStoreFlags=0&SaveCert=yes&ThumbPrint=" | grep -A 1 'function handleGetCert() {' | tail -n 1 | cut -d '"' -f 2`
CERTLINK="https://${MSCA}/certsrv/${OUTPUTLINK}?&Enc=b64"

# Retrieve Request &Enc=b64
curl -k -u "$USER":$PASS --ntlm $CERTLINK \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
-H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: en-US,en;q=0.5' \
-H 'Connection: keep-alive' \
-H "Host: ${MSCA}" \
-H "Referer: https://${MSCA}/certsrv/certrqxt.asp" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko' \
-H 'Content-Type: application/x-www-form-urlencoded' > $OUTPUT