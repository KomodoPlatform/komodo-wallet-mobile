cmake_minimum_required(VERSION 3.4.1)

find_library(log-lib log)
find_package(ZLIB)

set(IMPORT_DIR ${CMAKE_SOURCE_DIR}/libs)

add_library(mm2-lib
            SHARED
            mm2_native.cpp
)

add_library(mm2-api
            STATIC
            IMPORTED
)

set_target_properties(mm2-api
                      PROPERTIES IMPORTED_LOCATION
                      ${IMPORT_DIR}/${ANDROID_ABI}/libmm2.a
)

target_link_libraries(mm2-lib
                      mm2-api
                      ${log-lib}
                      ZLIB::ZLIB
)
