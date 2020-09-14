cmake_minimum_required(VERSION 3.4.1)

find_library(log-lib log)

add_library(mm2-lib SHARED mm2_native.cpp)

# Include all libmm2.a symbols to this shared library
# set(LINK_FLAGS ${LINK_FLAGS} "-Wl, -whole-archive")

target_link_libraries(mm2-lib
    # TODO consider using ${CMAKE_PREFIX_PATH}
    ${CMAKE_SOURCE_DIR}/libmm2.a ${log-lib}
)
