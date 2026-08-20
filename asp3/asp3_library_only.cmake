#
#  TOPPERS/ASP3 library-only build entry for SDK integration projects.
#
#  This script is extracted from asp3_core/CMakeLists.txt library-only path so
#  external apps can build asp3 without add_subdirectory(asp3_core) and without
#  evaluating asp3_core/CMakeLists.txt.
#

include(${ASP3_CORE_DIR}/asp3_core.cmake)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(PYTHON_EXE ${Python3_EXECUTABLE} -B)

set(CFG_PY ${ASP3_ROOT_DIR}/cfg/cfg.py)

list(APPEND ASP3_SYMVAL_TABLES
    ${ASP3_ROOT_DIR}/kernel/kernel_sym.def
)

list(APPEND ASP3_API_TABLES
    ${ASP3_ROOT_DIR}/kernel/kernel_api.def
)

list(APPEND ASP3_INCLUDE_DIRS
    ${ASP3_ROOT_DIR}/include
)

list(APPEND ASP3_COMPILE_DEFS
    TOPPERS_OMIT_TECS
)

if(DEFINED ASP3_EXTRA_COMPILE_DEFS)
    list(APPEND ASP3_COMPILE_DEFS ${ASP3_EXTRA_COMPILE_DEFS})
endif()

set(CFG_GEN_DIR ${CMAKE_BINARY_DIR}/generated)
set(CFG1_OUT_FILE ${CFG_GEN_DIR}/cfg1_out.c)
set(CFG1_OUT cfg1_out)
set(OFFSET_H_FILE ${CFG_GEN_DIR}/offset.h)
set(CFG1_OUT_SYMS_FILE ${CFG_GEN_DIR}/cfg1_out.syms)
set(CFG1_OUT_MAP_FILE ${CFG_GEN_DIR}/cfg1_out.map)
set(CFG1_OUT_SREC_FILE ${CFG_GEN_DIR}/cfg1_out.srec)
set(CFG1_OUT_DB_FILE ${CFG_GEN_DIR}/cfg1_out.db)
set(CFG2_OUT_DB_FILE ${CFG_GEN_DIR}/cfg2_out.db)
file(MAKE_DIRECTORY ${CFG_GEN_DIR})

if(NOT EXISTS ${CFG_GEN_DIR}/tecsgen.cfg)
    file(WRITE ${CFG_GEN_DIR}/tecsgen.cfg
        "INCLUDE(\"syssvc/syslog.cfg\");\n"
        "INCLUDE(\"syssvc/banner.cfg\");\n"
        "INCLUDE(\"syssvc/serial.cfg\");\n")
endif()

if(NOT DEFINED ASP3_APPLNAME)
    set(ASP3_APPLNAME sample1)
endif()
if(NOT DEFINED ASP3_APPLDIR)
    set(ASP3_APPLDIR ${ASP3_ROOT_DIR}/sample)
endif()
if(NOT IS_ABSOLUTE ${ASP3_APPLDIR})
    set(ASP3_APPLDIR ${ASP3_ROOT_DIR}/${ASP3_APPLDIR})
endif()
if(DEFINED ASP3_EXTRA_APP_C_FILES)
    set(_extra_app_c_files "")
    foreach(path IN LISTS ASP3_EXTRA_APP_C_FILES)
        if(NOT IS_ABSOLUTE ${path})
            set(path ${ASP3_ROOT_DIR}/${path})
        endif()
        list(APPEND _extra_app_c_files ${path})
    endforeach()
    set(ASP3_EXTRA_APP_C_FILES ${_extra_app_c_files})
endif()
if(DEFINED ASP3_APPCFGNAME)
    set(ASP3_APP_CFG_FILE ${ASP3_APPLDIR}/${ASP3_APPCFGNAME}.cfg)
else()
    set(ASP3_APP_CFG_FILE ${ASP3_APPLDIR}/${ASP3_APPLNAME}.cfg)
endif()
list(APPEND ASP3_APP_INCLUDE_DIRS ${ASP3_APPLDIR})

include(${ASP3_TARGET_DIR}/target.cmake)

option(ASP3_ENABLE_TRACE "Enable kernel trace log (arch/tracelog)" OFF)
if(ASP3_ENABLE_TRACE)
    list(APPEND ASP3_COMPILE_DEFS TOPPERS_ENABLE_TRACE)
    list(APPEND ASP3_ARCH_C_FILES
        ${ASP3_ROOT_DIR}/arch/tracelog/trace_log.c
        ${ASP3_ROOT_DIR}/arch/tracelog/trace_dump.c
        ${ASP3_ROOT_DIR}/arch/tracelog/trace_slog.c
    )
endif()

list(APPEND ASP3_CFG_FILES
    ${ASP3_APP_CFG_FILE}
)

list(APPEND ASP3_INCLUDE_DIRS
    ${ASP3_ROOT_DIR}
    ${CFG_GEN_DIR}
)

if(DEFINED ASP3_LDSCRIPT)
    list(APPEND ASP3_LINK_OPTIONS -Wl,-T,${ASP3_LDSCRIPT})
endif()

foreach(path IN LISTS ASP3_SYMVAL_TABLES)
    list(APPEND CFG_SYMVAL_TABLES "--symval-table" ${path})
endforeach()

foreach(path IN LISTS ASP3_API_TABLES)
    list(APPEND CFG_API_TABLES "--api-table" "${path}")
endforeach()

foreach(path IN LISTS ASP3_OFFSET_TRB_FILES)
    list(APPEND CFG_OFFSET_TRB_FILES "-T" ${path})
endforeach()

foreach(path IN LISTS ASP3_KERNEL_CFG_TRB_FILES)
    list(APPEND CFG_KERNEL_CFG_TRB_FILES "-T" "${path}")
endforeach()

foreach(path IN LISTS ASP3_CHECK_TRB_FILES)
    list(APPEND CFG_CHECK_TRB_FILES "-T" ${path})
endforeach()

foreach(path IN LISTS ASP3_INCLUDE_DIRS ASP3_APP_INCLUDE_DIRS)
    list(APPEND CFG_INCLUDE_DIRS "-I${path}")
endforeach()

set(CFG_GEN_H_FILES ${CFG_GEN_DIR}/kernel_cfg.h)
set(CFG_GEN_C_FILES ${CFG_GEN_DIR}/kernel_cfg.c)

add_custom_command(
    OUTPUT ${CFG1_OUT_FILE} ${CFG1_OUT_DB_FILE}
    WORKING_DIRECTORY ${CFG_GEN_DIR}
    COMMAND ${PYTHON_EXE} ${CFG_PY} --pass 1 --kernel asp
            ${CFG_INCLUDE_DIRS} ${CFG_API_TABLES} ${CFG_SYMVAL_TABLES}
            -M ${CFG_GEN_DIR}/cfg1_out_c.d ${ASP3_CFG_FILES}
    DEPENDS ${CFG_PY} ${ASP3_SYMVAL_TABLES} ${ASP3_API_TABLES} ${ASP3_CFG_FILES}
    COMMENT "Running cfg pass 1 to generate cfg1_out.c"
)

add_executable(${CFG1_OUT} ${ASP3_START_FILES} ${CFG1_OUT_FILE})
target_include_directories(${CFG1_OUT}
    PRIVATE ${ASP3_INCLUDE_DIRS} ${ASP3_APP_INCLUDE_DIRS}
    PRIVATE ${ASP3_ROOT_DIR}/kernel
)
target_compile_definitions(${CFG1_OUT} PRIVATE ${ASP3_COMPILE_DEFS})
target_compile_options(${CFG1_OUT} PRIVATE ${ASP3_COMPILE_OPTIONS})
set(CFG1_LINK_OPTIONS ${ASP3_LINK_OPTIONS})
list(REMOVE_ITEM CFG1_LINK_OPTIONS "-Wl,--gc-sections")
target_link_options(${CFG1_OUT} PRIVATE ${CFG1_LINK_OPTIONS} --map ${CFG1_OUT_MAP_FILE})
target_link_libraries(${CFG1_OUT} PRIVATE ${ASP3_LINK_LIBS})

add_custom_command(
    OUTPUT ${CFG1_OUT_SYMS_FILE}
    COMMAND ${PYTHON_EXE} ${CMAKE_SOURCE_DIR}/${CMAKE_PYTHON_NM} ${CFG1_OUT_MAP_FILE} ${CFG1_OUT_SYMS_FILE}
    DEPENDS ${CFG1_OUT}
    COMMENT "Generating cfg1_out.syms"
)

add_custom_command(
    OUTPUT ${CFG1_OUT_SREC_FILE}
    COMMAND ${CMAKE_OBJCOPY} --srec $<TARGET_FILE:${CFG1_OUT}> ${CFG1_OUT_SREC_FILE}
    DEPENDS ${CFG1_OUT}
    COMMENT "Generating cfg1_out.srec"
)

if(ASP3_OFFSET_TRB_FILES)
    add_custom_command(
        OUTPUT ${OFFSET_H_FILE}
        WORKING_DIRECTORY ${CFG_GEN_DIR}
        COMMAND ${PYTHON_EXE} ${CFG_PY} --pass 2 -O --kernel asp
                ${CFG_INCLUDE_DIRS} ${CFG_OFFSET_TRB_FILES}
                --rom-symbol ${CFG1_OUT_SYMS_FILE} --rom-image ${CFG1_OUT_SREC_FILE}
        DEPENDS ${CFG_PY} ${ASP3_OFFSET_TRB_FILES}
                ${CFG1_OUT_SYMS_FILE} ${CFG1_OUT_SREC_FILE} ${CFG1_OUT_DB_FILE}
        COMMENT "Running cfg pass 2 to generate offset.h"
    )
else()
    set(OFFSET_H_FILE "")
endif()

add_custom_command(
    OUTPUT ${CFG_GEN_H_FILES} ${CFG_GEN_C_FILES} ${CFG2_OUT_DB_FILE}
    WORKING_DIRECTORY ${CFG_GEN_DIR}
    COMMAND ${PYTHON_EXE} ${CFG_PY} --pass 2 --kernel asp
            ${CFG_INCLUDE_DIRS} ${CFG_KERNEL_CFG_TRB_FILES}
            --rom-symbol ${CFG1_OUT_SYMS_FILE} --rom-image ${CFG1_OUT_SREC_FILE}
    DEPENDS ${CFG_PY} ${ASP3_KERNEL_CFG_TRB_FILES}
            ${CFG1_OUT_SYMS_FILE} ${CFG1_OUT_SREC_FILE} ${CFG1_OUT_DB_FILE}
    COMMENT "Running cfg pass 2 to generate kernel_cfg.c/h"
)

add_custom_target(generate_cfg_gen_files
    DEPENDS ${OFFSET_H_FILE} ${CFG_GEN_H_FILES} ${CFG_GEN_C_FILES}
)

add_library(asp3 STATIC
    ${ASP3_ARCH_C_FILES}
    ${ASP3_TARGET_C_FILES}
    ${ASP3_ROOT_DIR}/kernel/alarm.c
    ${ASP3_ROOT_DIR}/kernel/cyclic.c
    ${ASP3_ROOT_DIR}/kernel/dataqueue.c
    ${ASP3_ROOT_DIR}/kernel/eventflag.c
    ${ASP3_ROOT_DIR}/kernel/exception.c
    ${ASP3_ROOT_DIR}/kernel/interrupt.c
    ${ASP3_ROOT_DIR}/kernel/mempfix.c
    ${ASP3_ROOT_DIR}/kernel/mutex.c
    ${ASP3_ROOT_DIR}/kernel/pridataq.c
    ${ASP3_ROOT_DIR}/kernel/semaphore.c
    ${ASP3_ROOT_DIR}/kernel/startup.c
    ${ASP3_ROOT_DIR}/kernel/sys_manage.c
    ${ASP3_ROOT_DIR}/kernel/task.c
    ${ASP3_ROOT_DIR}/kernel/task_manage.c
    ${ASP3_ROOT_DIR}/kernel/task_refer.c
    ${ASP3_ROOT_DIR}/kernel/task_sync.c
    ${ASP3_ROOT_DIR}/kernel/task_term.c
    ${ASP3_ROOT_DIR}/kernel/taskhook.c
    ${ASP3_ROOT_DIR}/kernel/time_event.c
    ${ASP3_ROOT_DIR}/kernel/time_manage.c
    ${ASP3_ROOT_DIR}/kernel/wait.c
    ${CFG_GEN_C_FILES}
)
add_dependencies(asp3 generate_cfg_gen_files)

target_include_directories(asp3
    PUBLIC ${ASP3_INCLUDE_DIRS} ${ASP3_APP_INCLUDE_DIRS}
    PRIVATE ${ASP3_ROOT_DIR}/kernel
)
target_compile_definitions(asp3
    PRIVATE ALLFUNC
    PUBLIC ${ASP3_COMPILE_DEFS}
)
target_compile_options(asp3 PUBLIC ${ASP3_COMPILE_OPTIONS})

list(APPEND PASS3_ARGS ${PYTHON_EXE} ${CFG_PY} --pass 3 --kernel asp -O)
list(APPEND PASS3_ARGS ${CFG_INCLUDE_DIRS} ${CFG_CHECK_TRB_FILES})

function(asp3_cfg_check TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
        WORKING_DIRECTORY ${CFG_GEN_DIR}
        COMMAND ${PYTHON_EXE} ${CMAKE_SOURCE_DIR}/${CMAKE_PYTHON_NM} ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.map ${TARGET}.syms
        COMMAND ${CMAKE_OBJCOPY} -O srec -S $<TARGET_FILE:${TARGET}> ${TARGET}.srec
        COMMAND ${PASS3_ARGS} --rom-symbol ${TARGET}.syms --rom-image ${TARGET}.srec
        COMMENT "Running cfg pass 3 to check configuration"
    )
endfunction()
