#! /usr/bin/env bash

rootFolder = OntarioVerify 
set -xf
function rename_files {
    find=$1
    replace_with=$2
    wildcard=$3
    if [[ $wildcard ]]; then
        files_to_rename=$(find ../OntarioVerify -name "*$find*")
    else
        files_to_rename=$(find ../OntarioVerify -name "$find")
    fi
    if [[ $files_to_rename ]]; then
        IFS=$'\n'       # make newlines the only separator
        set -f          # disable globbing
        for file in $files_to_rename; do
            if [[ $wildcard ]]; then
                mv "$file" "${file/$find/$replace_with}"
            else
                mv "$file" "${file/\/$find//$replace_with}"
            fi
        done
        IFS=''
    fi
}

# ggrep is an alias on Mac for gnu grep - brew install grep
function replace_inside_files {
    find=$1
    replace_with=$2
    files=$(ggrep --exclude-dir=../OntarioVerify/builds \
                  --exclude-dir=../OntarioVerify/openverify/sources \
                  --exclude=../OntarioVerify/openverify/transform.sh \
                  --exclude=../OntarioVerify/README.md \
                  --exclude=../OntarioVerify/README-fr.md \
                  --exclude-dir=../OntarioVerify/node_modules \
                  --exclude-dir=../OntarioVerify/ios/Pods \
                  --exclude-dir=../OntarioVerify/.git \
                  --recursive \
                  --files-with-matches "$find" .)
    if [[ $files ]]; then
        IFS=$'\n'       # make newlines the only separator
        set -f          # disable globbing
        for file in $files; do
            sed -i "" "s~${find}~${replace_with}~g" "$file"
        done
        IFS=''
    fi
}

function replace {
    find=$1
    replace_with=$2
    replace_inside_files "$find" "$replace_with"
    rename_files "$find" "$replace_with" "1"
}
BACKUP_FOLDER=".git-backup-$(date "+%Y%m%d%H%M%S")"
mv .git "../${BACKUP_FOLDER}"
replace "Verify Ontario" "Open Verify"
replace "VerifyOntario" "OpenVerify"
replace "OntarioVerify" "OpenVerify"
replace "ca.ontario.verify" "openverify.replace.me"
replace "VérifOntario" "VérifOuverte"
replace "OntarioLogo" "OpenVerifyLogo"
replace "OntarioQR" "OpenVerifyQR"
replace "OntarioCheckBox" "OpenVerifyCheckBox"
replace 'accessibilityLabel="Ontario"' 'accessibilityLabel="Open Verify"'
replace '"OpenVerifyLogoAlt": "Open Verify"' '"OpenVerifyLogoAlt": "Open Verify"'
replace "ontario-icon-alert-warning" "openverify-icon-alert-warning"
replace "ontario-icon-close" "openverify-icon-close"
replace "ontario_back_blue" "openverify_back_blue"
replace "ontario_base_logo" "openverify_base_logo"
replace "ontario_camera_logo" "openverify_camera_logo"
replace "ontario-icon-alert-error" "openverify-icon-alert-error"
replace "ontario_base_logo_dark" "openverify_base_logo_dark"
sed -i "" "s~# Firebase~~g" ".gitignore"
sed -i "" "s~/ios/GoogleService-Info.plist~~g" ".gitignore"
sed -i "" "s~/android/app/google-services.json~~g" ".gitignore"
rename_files "ca" "openverify" ""
rename_files "ontario" "replace" ""
rename_files "verify" "me" ""
set +f
rm -Rf .github
rm ./*.sh
rm Contributing.md
rm -Rf src/__mocks__/trust
cp openverify/sources/README.md ../OntarioVerify
cp openverify/sources/README-fr.md ../OntarioVerify
cp openverify/sources/tsconfig.json ../OntarioVerify
cp openverify/sources/.env.template ../OntarioVerify
cp openverify/sources/LICENSE.txt ../OntarioVerify
cp openverify/sources/package.json ../OntarioVerify
cp openverify/sources/src/__mocks/*.json ../OntarioVerify/src/__mocks__/
cp openverify/sources/src/assets/images/* ../OntarioVerify/src/assets/images/
cp openverify/sources/src/containers/home/*.tsx ../OntarioVerify/src/containers/home/
cp openverify/sources/android/app/*.json ../OntarioVerify/android/app/
cp -R openverify/sources/android/app/src/main/res/mipmap-hdpi/*.png ../OntarioVerify/android/app/src/main/res/mipmap-hdpi/
cp -R openverify/sources/android/app/src/main/res/mipmap-ldpi/*.png ../OntarioVerify/android/app/src/main/res/mipmap-ldpi/
cp -R openverify/sources/android/app/src/main/res/mipmap-mdpi/*.png ../OntarioVerify/android/app/src/main/res/mipmap-mdpi/
cp -R openverify/sources/android/app/src/main/res/mipmap-xhdpi/*.png ../OntarioVerify/android/app/src/main/res/mipmap-xhdpi/
cp -R openverify/sources/android/app/src/main/res/mipmap-xxhdpi/*.png ../OntarioVerify/android/app/src/main/res/mipmap-xxhdpi/
cp -R openverify/sources/android/app/src/main/res/mipmap-xxxhdpi/*.png ../OntarioVerify/android/app/src/main/res/mipmap-xxxhdpi/
cp -R openverify/sources/ios/OpenVerify/Images.xcassets ../OntarioVerify/ios/OpenVerify/
cp openverify/sources/ios/*.plist ../OntarioVerify/ios/
sed -i "" "s~Open Verify~VérifOuverte~g" ../OntarioVerify/src/translations/fr.json

STAR_COMMENT_LICENSE=$(cat <<EOF
/*
   Copyright 2021 Queen’s Printer for Ontario

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
EOF
)
set -f
files=$(ggrep '--exclude-dir=../OntarioVerify/android/builds' \
                '--exclude-dir=../OntarioVerify/openverify/sources' \
                '--exclude=../OntarioVerify/transform.sh' \
                '--exclude-dir=../OntarioVerify/node_modules' \
                '--exclude-dir=../OntarioVerify/ios/Pods' \
                '--exclude-dir=../OntarioVerify/.git' \
                '--exclude-dir=../OntarioVerify/test-data' \
                '--recursive' \
                '--files-without-match' \
                "Copyright " . \
                | ggrep -E '(\.ts|\.tsx|\.js|\.jsx|\.h|\.m|\.strings|\.java)$')
if [[ $files ]]; then
    IFS=$'\n'       # make newlines the only separator
    set -f          # disable globbing
    for file in $files; do
        echo -e "$STAR_COMMENT_LICENSE\n$(cat "$file")" > "$file"
    done
fi

cp -R "../${BACKUP_FOLDER}" ./.git

#yarn
#yarn prettier -w --bracket-same-line 'src' '!src/__mocks__'
#yarn eslint src
#yarn tsc
#yarn jest
#cd ios && npx pod-install
