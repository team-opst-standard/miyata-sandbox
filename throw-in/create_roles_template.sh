#!/bin/sh

CURRENT=`pwd`
ROLE_NAME=$1
TARGET_DIR=${2:-$CURRENT}

if [ "$ROLE_NAME" = "" ]; then
    echo "Argument 1 (as Role Name) is required."
    exit
fi

ROLES_DIRECTORIES=("handlers" "tasks" "template" "vars" "meta" "files" "defaults")
GIT_KEEP_FILE=".gitkeep"
MAIN_FILE="main.yml"

yml_template() {
cat << EOF >> $1
- name: Hello, world!!
  command: "/bin/echo 'Hello, world!!'"
EOF
}

mkdir $TARGET_DIR/$ROLE_NAME
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

