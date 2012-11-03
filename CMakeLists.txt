project(hopmod)

cmake_minimum_required(VERSION 2.6)

set(INSTALL_DIR ${PROJECT_SOURCE_DIR})
set(BIN_DIR ${INSTALL_DIR}/bin)
set(INSTALL_LIBRARY_DIR ${BIN_DIR}/lib)
set(INSTALL_ARCHIVE_DIR ${BIN_DIR}/lib)
set(INSTALL_RUNTIME_DIR ${BIN_DIR})
set(INSTALL_LUA_PACKAGE_DIR ${INSTALL_DIR}/script/package)

set(CMAKE_MODULE_PATH 
        ${CMAKE_MODULE_PATH} 
        ${CMAKE_CURRENT_SOURCE_DIR}/src/build/CMakeModules)

add_subdirectory(src)

