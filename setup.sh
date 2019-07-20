if [ $# -eq 0 ]; then
    echo 'Usage: ./setup.sh database_name'
    exit 1
fi

source $(which virtualenvwrapper.sh)
mkvirtualenv --python=$(which $(cat runtime.txt)) ${PWD##*/} || exit 2
workon ${PWD##*/}
pip install -r requirements.lock

SECRET_KEY=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z0-9!@#$%^*(\-_=+)' | fold -w 50 | head -n 1)
sed "s|\(SECRET_KEY = \)REPLACE_ME|\1'$SECRET_KEY'|g" config/settings_common.py > _tmp
mv _tmp config/settings_common.py

sed "s|\(\s*'NAME': \)REPLACE_ME\(.*\)|\1'$1'\2|g" config/environments/dev/settings_local.py > _tmp
mv _tmp config/environments/dev/settings_local.py

cd config
ln -s environments/dev/settings_local.py settings_local.py

cd ..
rm setup.sh

rm -rf .git
git init
git add .
git commit -m "Initial commit."

echo "Done.  Run \`workon \${PWD##*/}\` and you're on your way."
