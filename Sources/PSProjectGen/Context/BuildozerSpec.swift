//
//  BuildozerSpec.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 07/08/2025.
//

import Foundation
import TOMLKit
import INIParser
import PathKit




public class BuildozerSpecReader {
    
    let path: Path
    let spec: INIParser
    
    public init(path: Path) throws {
        self.path = path
        spec = try INIParser(path.string)
    }
    
    public func export() throws -> TOMLTable {
        let app_toml = TOMLTable()
        
        guard let app = spec.sections["app"] else { fatalError() }
        for (key, value) in app {
            if let tkey = SpecKeys(rawValue: key) {
                if key.contains(".") {
                    let skey = key.split(separator: ".").map(String.init)
                    if app_toml.contains(key: skey[0]) {
                        app_toml[skey[0]]?[skey[1]] = tkey.tomlValue(value: value)
                    } else {
                        app_toml.insert(TOMLTable([skey[1]: tkey.tomlValue(value: value)]), at: skey[0])
                    }
                } else {
                    app_toml[key] = tkey.tomlValue(value: value)
                }
            }
            
        }
        return .init(["buildozer-app": app_toml])
    }
    
}

extension BuildozerSpecReader {
    
    public enum SpecType {
        case bool
        case list
        case number
        case string
    }
    
    public enum SpecKeys: String {
        case title
        case package_name = "package.name"
        case package_domain = "package.domain"
        case source_dir = "source.dir"
        
        case source_include_exts = "source.include_exts"
        case source_include_patterns = "source.include_patterns"
        case source_exclude_exts = "source.exclude_exts"
        case source_exclude_dirs = "source.exclude_dirs"
        case source_exclude_patterns = "source.exclude_patterns"
        
        case version
        case version_regex = "version.regex"
        case version_filename = "version.filename"
        
        case requirements
        case requirements_source_kivy = "requirements.source.kivy"
        case presplash_filename = "presplash.filename"
        case icon_filename = "icon.filename"
        case orientation
        case services
        
        // Android specific
        case fullscreen
        case android_presplash_color = "android.presplash_color"
        case android_presplash_lottie = "android.presplash_lottie"
        case icon_adaptive_foreground_filename = "icon.adaptive_foreground.filename"
        case icon_adaptive_background_filename = "icon.adaptive_background.filename"
        
        case android_permissions = "android.permissions"
        case android_features = "android.features"
        case android_api = "android.api"
        case android_minapi = "android.minapi"
        case android_sdk = "android.sdk"
        case android_ndk = "android.ndk"
        case android_ndk_api = "android.ndk_api"
        case android_ndk_path = "android.ndk_path"
        case android_sdk_path = "android.sdk_path"
        case android_ant_path = "android.ant_path"
        case android_skip_update = "android.skip_update"
        case android_accept_sdk_license = "android.accept_sdk_license"
        case android_entrypoint = "android.entrypoint"
        case android_activity_class_name = "android.activity_class_name"
        case android_extra_manifest_xml = "android.extra_manifest_xml"
        case android_extra_manifest_application_arguments = "android.extra_manifest_application_arguments"
        case android_service_class_name = "android.service_class_name"
        case android_apptheme = "android.apptheme"
        
        case android_whitelist = "android.whitelist"
        case android_whitelist_src = "android.whitelist_src"
        case android_blacklist_src = "android.blacklist_src"
        case android_home_app = "android.home_app"
        case android_add_jars = "android.add_jars"
        case android_add_src = "android.add_src"
        case android_add_aars = "android.add_aars"
        case android_add_assets = "android.add_assets"
        case android_add_resources = "android.add_resources"
        case android_gradle_dependencies = "android.gradle_dependencies"
        case android_enable_androidx = "android.enable_androidx"
        case android_add_compile_options = "android.add_compile_options"
        case android_add_gradle_repositories = "android.add_gradle_repositories"
        case android_add_packaging_options = "android.add_packaging_options "
        case android_add_activities = "android.add_activities"
        
        case android_ouya_category = "android.ouya.category"
        case android_ouya_icon_filename = "android.ouya.icon.filename"
        case android_manifest_intent_filters = "android.manifest.intent_filters"
        case android_res_xml = "android.res_xml"
        case android_manifest_launch_mode = "android.manifest.launch_mode"
        
        case android_manifest_orientation = "android.manifest.orientation"
        case android_add_libs_armeabi = "android.add_libs_armeabi"
        case android_add_libs_armeabi_v7a = "android.add_libs_armeabi_v7a"
        case android_add_libs_arm64_v8a = "android.add_libs_arm64_v8a"
        case android_add_libs_x86 = "android.add_libs_x86"
        case android_add_libs_mips = "android.add_libs_mips"
        case android_wakelock = "android.wakelock"
        case android_meta_data = "android.meta_data"
        case android_library_references = "android.library_references"
        case android_uses_library = "android.uses_library"
        case android_logcat_filters = "android.logcat_filters"
        case android_logcat_pid_only = "android.logcat_pid_only"
        case android_adb_args = "android.adb_args"
        case android_copy_libs = "android.copy_libs"
        case android_archs = "android.archs"
        case android_numeric_version = "android.numeric_version"
        case android_allow_backup = "android.allow_backup"
        case android_backup_rules = "android.backup_rules"
        case android_manifest_placeholders = "android.manifest_placeholders"
        case android_no_byte_compile_python = "android.no-byte-compile-python"
        case android_release_artifact = "android.release_artifact"
        case android_debug_artifact = "android.debug_artifact"
        case android_display_cutout = "android.display_cutout"
        //
        case p4a_url = "p4a.url"
        case p4a_fork = "p4a.fork"
        case p4a_branch = "p4a.branch"
        case p4a_commit = "p4a.commit"
        case p4a_source_dir = "p4a.source_dir"
        case p4a_local_recipes = "p4a.local_recipes"
        case p4a_hook = "p4a.hook"
        case p4a_bootstrap = "p4a.bootstrap"
        case p4a_port = "p4a.port"
        case p4a_setup_py = "p4a.setup_py"
        case p4a_extra_args = "p4a.extra_args"
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //
        
    }
    
    public enum OtherSpecKeys: String {
        case log_level
        case warn_on_root
        case build_dir
        case bin_dir
        
    }
    
   
}

extension BuildozerSpecReader.SpecKeys {
    func tomlArray(value: String) -> TOMLArray {
        let array = TOMLArray()
        for word in value.replacingOccurrences(of: " ", with: "").split(separator: ",") {
            array.append(String(word))
        }
        return array
    }
    public func tomlValue(value: String) -> TOMLValue {
        switch specType {
        case .bool:
            switch value {
            case "True": TOMLValue(true)
            case "False": TOMLValue(false)
            default: TOMLValue(false)
            }
        case .list:
            TOMLValue(tomlArray(value: value))
        case .number:
            TOMLValue(Int(value) ?? -1)
        case .string:
            TOMLValue(stringLiteral: value.replacingOccurrences(of: "\"", with: ""))
        }
    }
    
    public var specType: BuildozerSpecReader.SpecType {
        switch self {
        case .title:
                .string
        case .package_name:
                .string
        case .package_domain:
                .string
        case .source_dir:
                .string
        case .source_include_exts:
                .list
        case .source_include_patterns:
                .list
        case .source_exclude_exts:
                .list
        case .source_exclude_dirs:
                .list
        case .source_exclude_patterns:
                .list
        case .version:
                .string
        case .version_regex:
                .string
        case .version_filename:
                .string
        case .requirements:
                .list
        case .requirements_source_kivy:
                .string
        case .presplash_filename:
                .string
        case .icon_filename:
                .string
        case .orientation:
                .list
        case .services:
                .list
        case .fullscreen:
                .bool
        case .android_presplash_color:
                .string
        case .android_presplash_lottie:
                .string
        case .icon_adaptive_foreground_filename:
                .string
        case .icon_adaptive_background_filename:
                .string
        case .android_permissions:
                .list
        case .android_features:
                .list
        case .android_api:
                .number
        case .android_minapi:
                .number
        case .android_sdk:
                .number
        case .android_ndk:
                .string
        case .android_ndk_api:
                .number
        case .android_ndk_path:
                .string
        case .android_sdk_path:
                .string
        case .android_ant_path:
                .string
        case .android_skip_update:
                .string
        case .android_accept_sdk_license:
                .bool
        case .android_entrypoint:
                .string
        case .android_activity_class_name:
                .string
        case .android_extra_manifest_xml:
                .string
        case .android_extra_manifest_application_arguments:
                .string
        case .android_service_class_name:
                .string
        case .android_apptheme:
                .string
        case .android_whitelist:
                .list
        case .android_whitelist_src:
                .string
        case .android_blacklist_src:
                .string
        case .android_home_app:
                .string
        case .android_add_jars:
                .list
        case .android_add_src:
                .list
        case .android_add_aars:
                .list
        case .android_add_assets:
                .list
        case .android_add_resources:
                .list
        case .android_gradle_dependencies:
                .list
        case .android_enable_androidx:
                .bool
        case .android_add_compile_options:
                .list
        case .android_add_gradle_repositories:
                .list
        case .android_add_packaging_options:
                .list
        case .android_add_activities:
                .list
        case .android_ouya_category:
                .string
        case .android_ouya_icon_filename:
                .string
        case .android_manifest_intent_filters:
                .string
        case .android_res_xml:
                .list
        case .android_manifest_launch_mode:
                .string
        case .android_manifest_orientation:
                .string
        case .android_add_libs_armeabi:
                .list
        case .android_add_libs_armeabi_v7a:
                .list
        case .android_add_libs_arm64_v8a:
                .list
        case .android_add_libs_x86:
                .list
        case .android_add_libs_mips:
                .list
        case .android_wakelock:
                .bool
        case .android_meta_data:
                .list
        case .android_library_references:
                .list
        case .android_uses_library:
                .list
        case .android_logcat_filters:
                .string
        case .android_logcat_pid_only:
                .bool
        case .android_adb_args:
                .string
        case .android_copy_libs:
                .bool
        case .android_archs:
                .list
        case .android_numeric_version:
                .number
        case .android_allow_backup:
                .bool
        case .android_backup_rules:
                .string
        case .android_manifest_placeholders:
                .string
        case .android_no_byte_compile_python:
                .bool
        case .android_release_artifact:
                .string
        case .android_debug_artifact:
                .string
        case .android_display_cutout:
                .string
        case .p4a_url:
                .string
        case .p4a_fork:
                .string
        case .p4a_branch:
                .string
        case .p4a_commit:
                .string
        case .p4a_source_dir:
                .string
        case .p4a_local_recipes:
                .string
        case .p4a_hook:
                .string
        case .p4a_bootstrap:
                .string
        case .p4a_port:
                .number
        case .p4a_setup_py:
                .bool
        case .p4a_extra_args:
                .string
        }
    }
}
