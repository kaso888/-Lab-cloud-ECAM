#!/bin/bash

user_name=$1
group=EcamUser


password="$(date +%s | sha256sum | base64 | head -c 32 ; echo)0"

aws iam create-user --user-name ${user_name} --path /ecam/${user_name}/ 

aws iam create-login-profile --user-name ${user_name} --password ${password} --no-password-reset-required 


access_key_creation=$(aws iam create-access-key --user-name ${user_name})

access_key_id=$(echo $access_key_creation | jq --raw-output '.AccessKey.AccessKeyId')
secret_key=$(echo $access_key_creation | jq --raw-output '.AccessKey.SecretAccessKey')


aws iam add-user-to-group  --group-name $group --user-name ${user_name}

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
  REPLY="${encoded}"
}

secret_key_encoded=$(rawurlencode $secret_key)

mkdir -p public


aws_console_url="https://${AWS_GLOBAL_ACCOUNT}.signin.aws.amazon.com/console"

echo "" >> public/${user_name}.env

echo "Console AWS : " >> public/${user_name}.env
echo "Url : <a href="${aws_console_url}" >${aws_console_url}</a>" >> public/${user_name}.env
echo "Nom d'utilisateur : ${user_name}" >> public/${user_name}.env
echo "Mot de passe : ${password}" >> public/${user_name}.env
echo "" >> public/${user_name}.env

echo "Clé d'accès via API : " >> public/${user_name}.env
echo "Access key : ${access_key_id}" >> public/${user_name}.env
echo "Secret key : ${secret_key}" >> public/${user_name}.env
