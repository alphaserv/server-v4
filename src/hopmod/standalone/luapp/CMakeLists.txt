
add_definitions(-DNO_EVENTS -DNO_CORE_TABLE)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../shared
    ${CMAKE_CURRENT_SOURCE_DIR}/../../
    ${LUA_INCLUDE_DIRS}
    ${BOOST_INCLUDE_DIRS}
    ${FUNGU_INCLUDE_DIRS})

add_executable(luapp luapp.cpp ../../lua.cpp)

target_link_libraries(luapp ${LUA_LIBRARY} ${BOOST_SYSTEM_LIBRARY} ${FUNGU_STRING_LIBRARY} ${FUNGU_HTTP_LIBRARY} lua_modules -lrt -lz)

install(TARGETS luapp RUNTIME DESTINATION ${INSTALL_RUNTIME_DIR}/utils)

