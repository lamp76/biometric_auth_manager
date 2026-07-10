import os
import zipfile

def create_directory(path):
    if not os.path.exists(path):
        os.makedirs(path)
        print(f"Created directory: {path}")

def generate_aar_placeholder(target_path):
    print("Generating Android AAR placeholder...")
    # An AAR is a zip file containing AndroidManifest.xml and classes.jar
    aar_dir = os.path.dirname(target_path)
    create_directory(aar_dir)
    
    manifest_content = """<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.biometric_core">
</manifest>
"""
    
    # Create a dummy classes.jar (which is a zip)
    classes_jar_path = "temp_classes.jar"
    with zipfile.ZipFile(classes_jar_path, 'w') as jar:
        # Just write an empty file to make it a valid zip
        jar.writestr("placeholder.txt", "This is a placeholder for classes.jar")
        
    with zipfile.ZipFile(target_path, 'w') as aar:
        aar.writestr("AndroidManifest.xml", manifest_content)
        aar.write(classes_jar_path, "classes.jar")
        
    if os.path.exists(classes_jar_path):
        os.remove(classes_jar_path)
        
    print(f"AAR placeholder generated at: {target_path}")

def generate_xcframework_placeholder(target_path):
    print("Generating iOS XCFramework placeholder...")
    # Define folder structure
    create_directory(target_path)
    
    # Write Info.plist for xcframework
    info_plist_content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AvailableLibraries</key>
	<array>
		<dict>
			<key>BinaryPath</key>
			<string>BiometricCore.framework/BiometricCore</string>
			<key>LibraryIdentifier</key>
			<string>ios-arm64</string>
			<key>LibraryPath</key>
			<string>BiometricCore.framework</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>ios</string>
		</dict>
		<dict>
			<key>BinaryPath</key>
			<string>BiometricCore.framework/BiometricCore</string>
			<key>LibraryIdentifier</key>
			<string>ios-arm64_x86_64-simulator</string>
			<key>LibraryPath</key>
			<string>BiometricCore.framework</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
				<string>x86_64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>ios</string>
			<key>SupportedPlatformVariant</key>
			<string>simulator</string>
		</dict>
	</array>
	<key>CFBundlePackageType</key>
	<string>XFWK</string>
	<key>XCFrameworkFormatVersion</key>
	<string>1.0</string>
</dict>
</plist>
"""
    with open(os.path.join(target_path, "Info.plist"), "w", encoding="utf-8") as f:
        f.write(info_plist_content)
        
    # Create directories for slices
    slices = ["ios-arm64", "ios-arm64_x86_64-simulator"]
    for slice_name in slices:
        framework_path = os.path.join(target_path, slice_name, "BiometricCore.framework")
        create_directory(framework_path)
        create_directory(os.path.join(framework_path, "Headers"))
        create_directory(os.path.join(framework_path, "Modules"))
        
        # Write dummy binary file
        with open(os.path.join(framework_path, "BiometricCore"), "w", encoding="utf-8") as f:
            f.write("DUMMY_MACH_O_BINARY_PLACEHOLDER")
            
        # Write Info.plist for framework
        slice_info_plist = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>BiometricCore</string>
	<key>CFBundleIdentifier</key>
	<string>com.example.BiometricCore</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>BiometricCore</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>MinimumOSVersion</key>
	<string>12.0</string>
</dict>
</plist>
"""
        with open(os.path.join(framework_path, "Info.plist"), "w", encoding="utf-8") as f:
            f.write(slice_info_plist)
            
        # Write Header
        header_content = """#import <Foundation/Foundation.h>

//! Project version number for BiometricCore.
FOUNDATION_EXPORT double BiometricCoreVersionNumber;

//! Project version string for BiometricCore.
FOUNDATION_EXPORT const unsigned char BiometricCoreVersionString[];
"""
        with open(os.path.join(framework_path, "Headers", "BiometricCore.h"), "w", encoding="utf-8") as f:
            f.write(header_content)
            
        # Write Modulemap
        modulemap_content = """framework module BiometricCore {
  umbrella header "BiometricCore.h"
  export *
  module * { export * }
}
"""
        with open(os.path.join(framework_path, "Modules", "module.modulemap"), "w", encoding="utf-8") as f:
            f.write(modulemap_content)
            
    print(f"XCFramework placeholder generated at: {target_path}")

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    aar_path = os.path.join(base_dir, "android", "libs", "biometric_core.aar")
    generate_aar_placeholder(aar_path)
    
    xcframework_path = os.path.join(base_dir, "ios", "Frameworks", "BiometricCore.xcframework")
    generate_xcframework_placeholder(xcframework_path)
    
    print("All placeholders generated successfully!")
