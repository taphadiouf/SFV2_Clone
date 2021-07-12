# Warning : Script used to reset you local develop branch in order to to make it match exactly origin/develop
echo "Warning : Script used to reset you local develop branch in order to to make it match exactly origin/develop"
git checkout develop
git fetch --all
git reset --hard origin/develop
