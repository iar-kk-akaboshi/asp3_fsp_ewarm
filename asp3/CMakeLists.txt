#
# TOPPERS/ASP3 Core wrapper for FSP integration projects.
#
# This directory exposes the same behavior that application CMakeLists previously
# implemented directly: resolve FSP-targeted ASP3 paths, build asp3_core as a
# library-only subproject, and provide an asp3syssvc helper library.
#

# Keep main project name available for generated-content dependency wiring.
if(NOT DEFINED ASP3_MAIN_PROJECT_NAME)
    set(ASP3_MAIN_PROJECT_NAME ${CMAKE_PROJECT_NAME})
endif()

# Default target can be overridden by caller before add_subdirectory().
if(NOT DEFINED ASP3_TARGET)
    set(ASP3_TARGET ek_ra6m5)
endif()

# Resolve ASP3_CORE_DIR / ASP3_TARGET_DIR / ASP3_ROOT_DIR.
include(${CMAKE_CURRENT_LIST_DIR}/asp3_fsp.cmake)

# Use asp3_core sample app definition unless caller overrides.
if(NOT DEFINED ASP3_APPLDIR)
    set(ASP3_APPLDIR ${ASP3_CORE_DIR}/sample)
endif()
if(NOT DEFINED ASP3_APPLNAME)
    set(ASP3_APPLNAME sample1)
endif()

# Build kernel as library-only mode without using asp3_core/CMakeLists.txt.
set(ASP3_LIBRARY_ONLY ON CACHE BOOL "build asp3 as library only" FORCE)
include(${CMAKE_CURRENT_LIST_DIR}/asp3_library_only.cmake)

# Build system service helper library linked against asp3.
add_library(asp3syssvc STATIC)
set_target_properties(asp3syssvc PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
asp3_add_syssvc(asp3syssvc)
target_link_libraries(asp3syssvc PUBLIC asp3)

# Ensure cfg1_out waits for RASC-generated FSP content when that target exists.
if(TARGET generate_content_${ASP3_MAIN_PROJECT_NAME} AND TARGET cfg1_out)
    add_dependencies(cfg1_out generate_content_${ASP3_MAIN_PROJECT_NAME})
endif()
