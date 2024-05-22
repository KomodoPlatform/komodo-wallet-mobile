chmod u+rw,g+r /home/komodo/workspace
mkdir -p android/app/src/main/cpp/libs/armeabi-v7a
mkdir -p android/app/src/main/cpp/libs/arm64-v8a
/home/komodo/.venv/bin/pip install -r .docker/requirements.txt 
/home/komodo/.venv/bin/python .docker/update_api.py