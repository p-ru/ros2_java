#!/bin/bash

# Source ROS2 Jazzy, built from source
source ~/ros2_jazzy/install/local_setup.bash

# Setup Android NDK location
export ANDROID_NDK=/home/salldritt/downloads/android-sdk/ndk/26.3.11579264
export ANDROID_HOME=/home/salldritt/downloads/android-sdk

# Original
# export ANDROID_ABI=armeabi-v7a
# For Loomo, specifically
export ANDROID_ABI=x86_64

export ANDROID_NATIVE_API_LEVEL=android-22
export ANDROID_TOOLCHAIN_NAME=arm-linux-androideabi-clang
export ANDROID_STL=c++_shared

# Export Python paths
export PYTHON3_EXEC="$( which python3 )"

export PYTHON3_LIBRARY="$( ${PYTHON3_EXEC} -c 'import os.path; from distutils import sysconfig; print(os.path.realpath(os.path.join(sysconfig.get_config_var("LIBPL"), sysconfig.get_config_var("LDLIBRARY"))))' )"
export PYTHON3_INCLUDE_DIR="$( ${PYTHON3_EXEC} -c 'from distutils import sysconfig; print(sysconfig.get_config_var("INCLUDEPY"))' )"

export PYTHON_LIBRARY="$( ${PYTHON3_EXEC} -c 'import os.path; from distutils import sysconfig; print(os.path.realpath(os.path.join(sysconfig.get_config_var("LIBPL"), sysconfig.get_config_var("LDLIBRARY"))))' )"
export PYTHON_INCLUDE_DIR="$( ${PYTHON3_EXEC} -c 'from distutils import sysconfig; print(sysconfig.get_config_var("INCLUDEPY"))' )"

export Python3_LIBRARIES="$( ${PYTHON3_EXEC} -c 'import os.path; from distutils import sysconfig; print(os.path.realpath(os.path.join(sysconfig.get_config_var("LIBPL"), sysconfig.get_config_var("LDLIBRARY"))))' )"
export Python3_INCLUDE_DIRS="$( ${PYTHON3_EXEC} -c 'from distutils import sysconfig; print(sysconfig.get_config_var("INCLUDEPY"))' )"

# Fast-DDS TRY_RUN result:
# PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP
#
# Modifications:
# -DFORCE_BUILD_VENDOR_PKG=1 -> Force "building" spdlog_vendor
# -DFOONATHAN_MEMORY_FORCE_VENDORED_BUILD=1 -> Force "building" foonthan_memory_vendor
# -DBUILD_TESTING=0 -> Don't build rcutils tests which requires mimick_vendor that doesn't compile for ARMv7-a
# -DEPROSIMA_BUILD=1 \ -DEPROSIMA_BUILD_TESTS=0 \
# --packages-up-to rcljava \
#    -DBUILD_SHARED_LIBS=0 \
# Install SDKMAN!
# Update to gradle 8.7 `sdk install gradle`
#     --packages-up-to rclandroid \

colcon build \
   --packages-ignore test_ros2trace test_launch_testing lttngpy rosidl_generator_py uncrustify_vendor tf2 tf2_py tf2_geometry_msgs tf2_sensor_msgs tf2_kdl tf2_ros tf2_ros_py tf2_tools tf2_eigen tf2_eigen_kdl tf2_bullet test_tf2 examples_tf2_py  \
   --gradle-args \
   --debug --info -Pament.android_stl=${ANDROID_STL} -Pament.android_abi=${ANDROID_ABI} -Pament.android_ndk=${ANDROID_NDK} -Pament.android_variant=release \
   --cmake-args \
   -C "${PWD}/TryRunResults-Loomo-Android5.1.1.cmake" \
   -DPython3_EXECUTABLE=${PYTHON3_EXEC} \
   -DPython3_LIBRARY=${PYTHON3_LIBRARY} \
   -DPython3_INCLUDE_DIR=${PYTHON3_INCLUDE_DIR} \
   -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
   -DANDROID_FUNCTION_LEVEL_LINKING=OFF \
   -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL} \
   -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME} \
   -DANDROID_ABI=${ANDROID_ABI} \
   -DANDROID_NDK=${ANDROID_NDK} \
   -DANDROID_STL=${ANDROID_STL} \
   -DTHIRDPARTY=ON \
   -DCOMPILE_EXAMPLES=OFF \
   -DFORCE_BUILD_VENDOR_PKG=1 \
   -DFOONATHAN_MEMORY_FORCE_VENDORED_BUILD=1 \
   -DBUILD_TESTING=0 \
   -DTHIRDPARTY=FORCE \
   -DTHIRDPARTY_UPDATE=1 \
   -DROSIDL_CMAKE_CONFIG_EXTRAS=1 \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_FIND_ROOT_PATH="${PWD}/install"

# Build a "dependencies" folder that can be copied into the Android App
rm -rf ./dependencies
mkdir ./dependencies

# Copy the rclandroid.aar
mkdir -p ./dependencies/rclandroid/
cp -r ./install/rclandroid/share/rclandroid/android/rclandroid-release.aar ./dependencies/rclandroid/