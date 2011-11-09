#find Qt3D
include(FindLibraryWithDebug)

find_package(Qt4 COMPONENTS QtOpenGL)
find_path(QT_3D_INCLUDE_DIR qt3dglobal.h PATH ${QT_INCLUDE_DIR}/Qt3D NO_DEFAULT_PATH)
find_library_with_debug(QT_3D_LIBRARIES
                  WIN32_DEBUG_POSTFIX d
                  NAMES Qt3D
                  HINTS ${QT_LIBRARY_DIR}
                  )

if(QT_3D_LIBRARIES AND QT_3D_INCLUDE_DIR)
	message( STATUS "Found Qt3D: ${QT_3D_LIBRARIES}")
	set(QT_3D_FOUND true )
else(QT_3D_LIBRARIES AND QT_3D_INCLUDE_DIR)
	message( STATUS "Could NOT find Qt3D")
endif( QT_3D_LIBRARIES AND QT_3D_INCLUDE_DIR)
