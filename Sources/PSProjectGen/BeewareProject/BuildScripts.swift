//
//  BuildScripts.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 04/08/2025.
//

import ProjectSpec
import PathKit

extension BuildScript {
    static func installPyModulesIphoneOS(pythonProject: Path) -> BuildScript {
        .init(
            script: .script("""
            set -e

            PYTHON="$PROJECT_DIR/python3"

            mkdir -p "$CODESIGNING_FOLDER_PATH/python/lib"
            if [ "$EFFECTIVE_PLATFORM_NAME" = "-iphonesimulator" ]; then
                echo "Installing Python modules for iOS Simulator"
                rsync -au --delete "$PROJECT_DIR/Support/ios-arm64_x86_64-simulator/lib/" "$CODESIGNING_FOLDER_PATH/python/lib/" 
                rsync -au --delete "$PROJECT_DIR/site_packages.iphonesimulator/" "$CODESIGNING_FOLDER_PATH/site_packages" 
            else
                echo "Installing Python modules for iOS Device"
                rsync -au --delete "$PROJECT_DIR/Support/ios-arm64/lib/" "$CODESIGNING_FOLDER_PATH/python/lib" 
                rsync -au --delete "$PROJECT_DIR/site_packages.iphoneos/" "$CODESIGNING_FOLDER_PATH/site_packages" 
            fi

            PY_APP="$CODESIGNING_FOLDER_PATH/app"
            rsync -au --delete "\(pythonProject)/" $PY_APP
            #$PYTHON -m compileall -f -b -o2 $PY_APP
            #find $PY_APP -regex '.*\\.py' -delete

            PY_SITE="$CODESIGNING_FOLDER_PATH/site_packages"
            #$PYTHON -m compileall -f -b -o2 $PY_SITE
            #find $PY_SITE -regex '.*\\.py' -print -delete
            #find $PY_SITE -name '__pycache__' -type d -print -exec rm -r {} + -depth

            """),
            name: "Install target specific Python modules"
        )
    }
    
    static func signPythonBinaryIphoneOS() -> BuildScript {
        .init(
            script: .script("""
            set -e

            install_dylib () {
                INSTALL_BASE=$1
                FULL_EXT=$2

                # The name of the extension file
                EXT=$(basename "$FULL_EXT")
                # The location of the extension file, relative to the bundle
                RELATIVE_EXT=${FULL_EXT#$CODESIGNING_FOLDER_PATH/} 
                # The path to the extension file, relative to the install base
                PYTHON_EXT=${RELATIVE_EXT/$INSTALL_BASE/}
                # The full dotted name of the extension module, constructed from the file path.
                FULL_MODULE_NAME=$(echo $PYTHON_EXT | cut -d "." -f 1 | tr "/" "."); 
                # A bundle identifier; not actually used, but required by Xcode framework packaging
                FRAMEWORK_BUNDLE_ID=$(echo $PRODUCT_BUNDLE_IDENTIFIER.$FULL_MODULE_NAME | tr "_" "-")
                # The name of the framework folder.
                FRAMEWORK_FOLDER="Frameworks/$FULL_MODULE_NAME.framework"

                # If the framework folder doesn't exist, create it.
                if [ ! -d "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER" ]; then
                    echo "Creating framework for $RELATIVE_EXT" 
                    mkdir -p "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER"

                    cp "$CODESIGNING_FOLDER_PATH/dylib-Info-template.plist" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/Info.plist"
                    plutil -replace CFBundleExecutable -string "$FULL_MODULE_NAME" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/Info.plist"
                    plutil -replace CFBundleIdentifier -string "$FRAMEWORK_BUNDLE_ID" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/Info.plist"
                fi
                
                echo "Installing binary for $FRAMEWORK_FOLDER/$FULL_MODULE_NAME" 
                mv "$FULL_EXT" "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/$FULL_MODULE_NAME"
                # Create a placeholder .fwork file where the .so was
                echo "$FRAMEWORK_FOLDER/$FULL_MODULE_NAME" > ${FULL_EXT%.so}.fwork
                # Create a back reference to the .so file location in the framework
                echo "${RELATIVE_EXT%.so}.fwork" > "$CODESIGNING_FOLDER_PATH/$FRAMEWORK_FOLDER/$FULL_MODULE_NAME.origin"     
            }

            echo "Install standard library extension modules..."
            find "$CODESIGNING_FOLDER_PATH/python/lib/python3.11/lib-dynload" -name "*.so" | while read FULL_EXT; do
                install_dylib python/lib/python3.11/lib-dynload/ "$FULL_EXT"
            done
            echo "Install app package extension modules..."
            find "$CODESIGNING_FOLDER_PATH/site_packages" -name "*.so" | while read FULL_EXT; do
                install_dylib app_packages/ "$FULL_EXT"
            done
            echo "Install app extension modules..."
            find "$CODESIGNING_FOLDER_PATH/app" -name "*.so" | while read FULL_EXT; do
                install_dylib app/ "$FULL_EXT"
            done

            # Clean up dylib template 
            rm -f "$CODESIGNING_FOLDER_PATH/dylib-Info-template.plist"

            echo "Signing frameworks as $EXPANDED_CODE_SIGN_IDENTITY_NAME ($EXPANDED_CODE_SIGN_IDENTITY)..."
            find "$CODESIGNING_FOLDER_PATH/Frameworks" -name "*.framework" -exec /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" ${OTHER_CODE_SIGN_FLAGS:-} -o runtime --timestamp=none --preserve-metadata=identifier,entitlements,flags --generate-entitlement-der "{}" \\; 
            """),
            name: "Sign Python Binary Modules"
        )
    }
}
