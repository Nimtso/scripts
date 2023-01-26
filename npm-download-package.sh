ORIGINAL_PACKAGE=$1
SANDBOX_DIR="$PWD/sandbox"
DOWNLOAD_DIR="$PWD/downlaods"
URLS_FILE="$SANDBOX_DIR/deps.txt"


function clean_workspace {
    rm -r "$SANDBOX_DIR"
}

function create_workspace {
    mkdir "$SANDBOX_DIR"
    mkdir "$DOWNLOAD_DIR"
    cd "$SANDBOX_DIR"
    npm install $ORIGINAL_PACKAGE --save-dev|| echo "Failed to downlaod $ORIGINAL_PACKAGE"
}


function create_deps_file {
    while IFS= read -r line
    do
    # Check if the line begins with "resolved"
        if [[ $line == *"resolved"* ]]; then
            echo $line | grep -o 'https://[^"]*' >> $URLS_FILE
        fi
    done < "$SANDBOX_DIR/package-lock.json"
}

function donwload_deps {
    while IFS= read -r dep_url
    do
        declare file_name=$(echo "$dep_url" | sed 's#.*/-/\(.*\)#\1#')
        curl -o "$DOWNLOAD_DIR/$file_name" $dep_url
    done < "$URLS_FILE"
}

echo "Begining to download $ORIGINAL_PACKAGE and dependencies"
create_workspace
create_deps_file
donwload_deps
