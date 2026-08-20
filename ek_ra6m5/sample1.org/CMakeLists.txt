# Please see README.md for build instructions

cmake_minimum_required(VERSION 3.16.4)

set(CMAKE_SYSTEM_NAME Generic)

# クロスコンパイラの動作確認テストでリンクを行わない（ARM向けclangはホスト用CRTを持たないため）
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_CONFIGURATION_TYPES Debug Release RelWithDebInfo MinSizeRel)

if(BUILD_KIT)
	message("Build Kit is defined as ${BUILD_KIT}")
endif()

message("CMAKE_CURRENT_BINARY_DIR is defined as ${CMAKE_CURRENT_BINARY_DIR}")

get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

if(isMultiConfig)
    message("Multi-config generator(${CMAKE_GENERATOR}) is active")
else()
    message("Single-config generator(${CMAKE_GENERATOR}) is active")
	if(DEFINED CMAKE_BUILD_TYPE)
	 	message("CMAKE_BUILD_TYPE is defined as ${CMAKE_BUILD_TYPE}")
	elseif(DEFINED BUILD_TYPE)
		set(CMAKE_BUILD_TYPE ${BUILD_TYPE})
		message("CMAKE_BUILD_TYPE is set to BUILD_TYPE ENV ${CMAKE_BUILD_TYPE}")
	else()
		message(FATAL_ERROR "Please specify the CMAKE_BUILD_TYPE with -DCMAKE_BUILD_TYPE=")
	endif()
    #set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
	message("CMAKE_RUNTIME_OUTPUT_DIRECTORY is defined as ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
endif()

cmake_minimum_required(VERSION 3.16.4)

# 例えば、sampleフォルダのex1.cfgを使用する場合はこちら
set(ASP3_APPLDIR  ${CMAKE_CURRENT_LIST_DIR})
set(ASP3_APPLNAME ex1)

# Project configuration
project(asp3_fsp
	VERSION 1.0.0
	LANGUAGES C CXX ASM)

set(CMAKE_CROSSCOMPILING "TRUE")
set(CMAKE_EXPORT_COMPILE_COMMANDS "TRUE")

include(${CMAKE_CURRENT_LIST_DIR}/Config.cmake)


# RASC(LLVMARM) が生成する GCC/Clang 向け -f* オプションは、
# IAR iccarm では「-f <command file>」解釈されてビルド失敗する。
# 生成ファイルは再生成で上書きされるため、ここで後処理して除去する。
if(CMAKE_C_COMPILER_ID STREQUAL "IAR")
    set(RASC_CMAKE_ASM_FLAGS "")
    set(RASC_CMAKE_C_FLAGS "")
    set(RASC_CMAKE_CXX_FLAGS "")
    set(RASC_CMAKE_EXE_LINKER_FLAGS "")
    set(RASC_DEBUG_FLAGS "")
    set(RASC_RELEASE_FLAGS "")
    set(RASC_MIN_SIZE_RELEASE_FLAGS "")
    set(RASC_RELEASE_WITH_DEBUG_INFO "")
    set(CMAKE_C_FLAGS_DEBUG "")
    set(CMAKE_CXX_FLAGS_DEBUG "")
    set(CMAKE_ASM_FLAGS_DEBUG "")
endif()



# RASCで生成されるra/・ra_gen/が無いとGeneratedSrc.cmakeのGLOBが空になり
# 1回目のビルドでソース不足によるリンクエラーが発生するため、
# configure時にRASCを実行してコンテンツを先に生成しておく
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ra" OR NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ra_gen")
    message(STATUS "Generating FSP content using RASC (initial configure)...")
    execute_process(
        COMMAND ${RASC_EXE_PATH} -nosplash --launcher.suppressErrors --generate
                --devicefamily ra --compiler LLVMARM
                --toolchainversion ${CMAKE_C_COMPILER_VERSION}
                ${CMAKE_CURRENT_SOURCE_DIR}/configuration.xml
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE _rasc_result
    )
    if(NOT _rasc_result EQUAL 0)
        message(FATAL_ERROR "RASC content generation failed (exit ${_rasc_result}). Check RASC_EXE_PATH=${RASC_EXE_PATH}")
    endif()
    # ビルド時のpre-buildカスタムコマンドが直後に再実行されないようstampを作成
    file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    file(TOUCH ${CMAKE_CURRENT_BINARY_DIR}/configuration.xml.stamp)
endif()


# ===== TOPPERS/ASP3 Core 取り込み（submodule＋ライブラリ専用モード） =====
# 旧 bundled asp3/(fork) を廃止し、純カーネル asp3_core を submodule 参照する構成。
# 経緯：asp3/asp3_core/docs/dev/fsp-integration.md

# TOPPERS/ASP3 のターゲット依存部を指定
set(ASP3_TARGET ek_ra6m5)

# asp3_core 直接呼び出しの代わりに、asp3/CMakeLists.txt ラッパーを利用する。
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../../asp3 asp3)

# TOPPERS/ASP3 を使うための FSP の設定（現状なし）
# asp3_set_fsp_options(${CMAKE_PROJECT_NAME}.elf)

# TOPPERS/ASP3 のチェックを行う（シンボルがGCされるとエラーになるので省略）
# asp3_cfg_check(${CMAKE_PROJECT_NAME}.elf)

