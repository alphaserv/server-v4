
set(LUA_LPEG_LIBRARY liblpeg CACHE INTERNAL "lpeg lua library")

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${LUA_INCLUDE_DIRS}
)

set(LPEG_SOURCES
    lpeg.c
)

add_library(${LUA_LPEG_LIBRARY} SHARED ${LPEG_SOURCES})
target_link_libraries(${LUA_LPEG_LIBRARY} -lz ${LUA_LIBRARY})

install(TARGETS 
            ${LUA_LPEG_LIBRARY}
        LIBRARY DESTINATION 
            ${INSTALL_LIBRARY_DIR}
        ARCHIVE DESTINATION
            ${INSTALL_ARCHIVE_DIR})

