#
#		アーキテクチャ依存部のCMake定義（ARM-Mコア共通）
#
#  target.cmake からincludeされる．CPU固有のフラグ（-mcpu等）と
#  コア種別の定義（TOPPERS_CORTEX_M33等）はtarget.cmake側で
#  ASP3_COMPILE_OPTIONS／ASP3_COMPILE_DEFS に積む．
#

get_filename_component(_ASP3_ARCH_BASE_DIR ${CMAKE_CURRENT_LIST_DIR}/../../.. ABSOLUTE)

list(APPEND ASP3_SYMVAL_TABLES
    ${ARCHDIR}/common/core_sym.def
)

list(APPEND ASP3_OFFSET_TRB_FILES
    ${ARCHDIR}/common/core_offset.py
)

list(APPEND ASP3_INCLUDE_DIRS
    ${CHIPDIR}
    ${ARCHDIR}/common
    ${_ASP3_ARCH_BASE_DIR}/arch/iccarm
)

list(APPEND ASP3_COMPILE_DEFS
    TOPPERS_CORTEX_M85
    __TARGET_ARCH_THUMB=5
    __TARGET_FPU_FPV5_D16
    TOPPERS_ENABLE_TRUSTZONE
)

list(APPEND ASP3_ARCH_C_FILES
    ${ARCHDIR}/common/core_kernel_impl.c
    ${ARCHDIR}/common/core_support.S
)
set_property(SOURCE ${ARCHDIR}/common/core_support.S APPEND PROPERTY COMPILE_OPTIONS "${RASC_CMAKE_ASM_FLAGS}")

set(ARCH_SERIAL ${CHIPDIR}/chip_serial.c)