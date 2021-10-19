#!/bin/bash

is_server_up=false

# make sure that Gitea server is up
for i in $(seq 1 10)
do
  curl -sSf http://localhost:3000/ > /dev/null
  if [[ "$?" == 0 ]]
  then
    is_server_up=true
    break
  fi
  sleep 3
done

if [[ $is_server_up == false ]]
then
  >&2 echo "Gitea server is not present at http://localhost:3000/"
  >&2 echo "Exiting with error code 1."
  exit 1
fi

# accept default configuration and finish installation
# creates user dev with password dev, this user has admin privileges
curl -X POST http://localhost:3000/ -H "Content-Type: application/x-www-form-urlencoded" -d "db_type=SQLite3&db_host=localhost%3A3306&db_user=root&db_passwd=&db_name=gitea&ssl_mode=disable&db_schema=&charset=utf8&db_path=%2Fdata%2Fgitea%2Fgitea.db&app_name=Gitea%3A+Git+with+a+cup+of+tea&repo_root_path=%2Fdata%2Fgit%2Frepositories&lfs_root_path=%2Fdata%2Fgit%2Flfs&run_user=git&domain=localhost&ssh_port=22&http_port=3000&app_url=http%3A%2F%2Flocalhost%3A3000%2F&log_root_path=%2Fdata%2Fgitea%2Flog&smtp_host=&smtp_from=&smtp_user=&smtp_passwd=&enable_federated_avatar=on&enable_open_id_sign_in=on&enable_open_id_sign_up=on&default_allow_create_organization=on&default_enable_timetracking=on&no_reply_address=noreply.localhost&password_algorithm=pbkdf2&admin_name=dev&admin_passwd=dev&admin_confirm_passwd=dev&admin_email=dev%40localhost"

sleep 3

# migrate companion repo from github, set name to FlaskApp
curl -u dev:dev -X POST http://localhost:3000/api/v1/repos/migrate -H 'accept: application/json' -H 'Content-Type: application/json' -d '{ "clone_addr": "https://github.com/MichalBoron/docker-pipeline-flask-app.git", "repo_name": "FlaskApp" }'
