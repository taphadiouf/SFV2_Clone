# Warning : Script used to reset you local develop branch in order to to make it match exactly origin/develop
echo "Warning : Script used to reset you local develop branch in order to to make it match exactly origin/develop"
git checkout developEvo/b2b
git fetch --all
git reset --hard origin/developEvo/b2b
