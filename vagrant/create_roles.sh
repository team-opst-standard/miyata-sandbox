#!/bin/sh

CURRENT=`pwd`
ROLE_NAME=$1

if [ "$ROLE_NAME" = "" ]; then
    echo "Argument 1 (as Role Name) is required."
    exit
fi

TARGET_DIR=$CURRENT/playbook/roles
ROLES_DIRECTORIES=("handlers" "tasks" "templates" "vars" "meta" "files" "defaults")
GIT_KEEP_FILE=".gitkeep"
MAIN_FILE="main.yml"

yml_template() {
cat << EOF > $1
- name: Hello, world!!
  command: "/bin/echo 'Hello, world!!'"
EOF
}

mkdir -p $TARGET_DIR/$ROLE_NAME
for i in ${ROLES_DIRECTORIES[@]}; do
    echo "mkdir $TARGET_DIR/$ROLE_NAME/$i"
    mkdir $TARGET_DIR/$ROLE_NAME/$i

    if [ "$i" = "tasks" ]; then
        echo "touch $TARGET_DIR/$ROLE_NAME/$i/$MAIN_FILE"
        touch $TARGET_DIR/$ROLE_NAME/$i/$MAIN_FILE
        yml_template $TARGET_DIR/$ROLE_NAME/$i/$MAIN_FILE
    else
        echo "touch $TARGET_DIR/$ROLE_NAME/$i/$GIT_KEEP_FILE"
        touch $TARGET_DIR/$ROLE_NAME/$i/$GIT_KEEP_FILE
    fi
done

cd $CURRENT

