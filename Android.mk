# Copyright (C) 2015 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
LOCAL_PATH := $(call my-dir)

# We have a special case here where we build the library's resources
# independently from its code, so we need to find where the resource
# class source got placed in the course of building the resources.
# Thus, the magic here.
# Also, this module cannot depend directly on the R.java file; if it
# did, the PRIVATE_* vars for R.java wouldn't be guaranteed to be correct.
# Instead, it depends on the R.stamp file, which lists the corresponding
# R.java file as a prerequisite.
cm_platform_res := APPS/org.cyanogenmod.platform-res_intermediates/src

# List of packages used in cm-api-stubs
cm_stub_packages := cyanogenmod.alarmclock:cyanogenmod.app:cyanogenmod.content:cyanogenmod.externalviews:cyanogenmod.hardware:cyanogenmod.media:cyanogenmod.os:cyanogenmod.preference:cyanogenmod.profiles:cyanogenmod.providers:cyanogenmod.platform:cyanogenmod.power:cyanogenmod.themes:cyanogenmod.util:cyanogenmod.weather:cyanogenmod.weatherservice

# The CyanogenMod Platform Framework Library
# ============================================================
include $(CLEAR_VARS)

cyanogenmod_sdk_src := sdk/src/java/cyanogenmod
cyanogenmod_sdk_internal_src := sdk/src/java/org/cyanogenmod/internal
library_src := cm/lib/main/java

LOCAL_MODULE := org.cyanogenmod.platform
LOCAL_MODULE_TAGS := optional

cmsdk_LOCAL_JAVA_LIBRARIES := \
    android-support-v7-preference \
    android-support-v7-recyclerview \
    android-support-v14-preference

LOCAL_JAVA_LIBRARIES := \
    services \
    org.cyanogenmod.hardware \
    $(cmsdk_LOCAL_JAVA_LIBRARIES)

LOCAL_SRC_FILES := \
    $(call all-java-files-under, $(cyanogenmod_sdk_src)) \
    $(call all-java-files-under, $(cyanogenmod_sdk_internal_src)) \
    $(call all-java-files-under, $(library_src))

## READ ME: ########################################################
##
## When updating this list of aidl files, consider if that aidl is
## part of the SDK API.  If it is, also add it to the list below that
## is preprocessed and distributed with the SDK.  This list should
## not contain any aidl files for parcelables, but the one below should
## if you intend for 3rd parties to be able to send those objects
## across process boundaries.
##
## READ ME: ########################################################
LOCAL_SRC_FILES += \
    $(call all-Iaidl-files-under, $(cyanogenmod_sdk_src)) \
    $(call all-Iaidl-files-under, $(cyanogenmod_sdk_internal_src))

cmplat_LOCAL_INTERMEDIATE_SOURCES := \
    $(cm_platform_res)/cyanogenmod/platform/R.java \
    $(cm_platform_res)/cyanogenmod/platform/Manifest.java \
    $(cm_platform_res)/org/cyanogenmod/platform/internal/R.java

LOCAL_INTERMEDIATE_SOURCES := \
    $(cmplat_LOCAL_INTERMEDIATE_SOURCES)

# Include aidl files from cyanogenmod.app namespace as well as internal src aidl files
LOCAL_AIDL_INCLUDES := $(LOCAL_PATH)/sdk/src/java
LOCAL_AIDL_FLAGS := -n

include $(BUILD_JAVA_LIBRARY)
cm_framework_module := $(LOCAL_INSTALLED_MODULE)

# Make sure that R.java and Manifest.java are built before we build
# the source for this library.
cm_framework_res_R_stamp := \
    $(call intermediates-dir-for,APPS,org.cyanogenmod.platform-res,,COMMON)/src/R.stamp
$(full_classes_compiled_jar): $(cm_framework_res_R_stamp)
$(built_dex_intermediate): $(cm_framework_res_R_stamp)

$(cm_framework_module): | $(dir $(cm_framework_module))org.cyanogenmod.platform-res.apk

cm_framework_built := $(call java-lib-deps, org.cyanogenmod.platform)

# ====  org.cyanogenmod.platform.xml lib def  ========================
include $(CLEAR_VARS)

LOCAL_MODULE := org.cyanogenmod.platform.xml
LOCAL_MODULE_TAGS := optional

LOCAL_MODULE_CLASS := ETC

# This will install the file in /system/etc/permissions
LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions

LOCAL_SRC_FILES := $(LOCAL_MODULE)

include $(BUILD_PREBUILT)
