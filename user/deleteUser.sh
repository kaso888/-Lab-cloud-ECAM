#!/bin/bash

user_name=$1
profile=lab
group=EcamUser

export AWS_PROFILE=$profile


keys=("$(aws iam list-access-keys --user-name "${user_name}" | jq -r '.AccessKeyMetadata[] | .AccessKeyId')")
if [[ "${#keys}" -gt "0" ]]; then
    # shellcheck disable=SC2068
    for key in ${keys[@]}; do
        aws iam delete-access-key --user-name "${user_name}" --access-key-id "${key}" 
    done
fi

aws iam remove-user-from-group  --group-name $group --user-name ${user_name}

aws iam delete-login-profile --user-name ${user_name} 

aws iam delete-user --user-name ${user_name} 
