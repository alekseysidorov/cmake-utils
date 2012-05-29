#find Qt3D
find_package(Qt4 COMPONENTS QtOpenGL)
if(APPLE)
	find_library(QT_3D_LIBRARIES
		NAMES Qt3D
		HINTS ${QT_LIBRARY_DIR}
	)
	if(QT_3D_LIBRARIES)
		message( STATUS "Found Qt3D framework: ${QT_3D_LIBRARIES}")
		set(QT_3D_FOUND true)
		list(APPEND QT_LIBRARIES
			${QT_3D_LIBRARIES}
		)
		set(QT_3D_INCLUDE_DIR "${QT_3D_LIBRARIES}/Headers")
		list(APPEND QT_INCLUDES
			${QT_3D_INCLUDE_DIR}
		)
	else()
		message( STATUS "Could NOT find Qt3D")
	endif()
else()
	include(FindLibraryWithDebug)
	find_path(QT_3D_INCLUDE_DIR qt3dglobal.h PATH ${QT_INCLUDE_DIR}/Qt3D NO_DEFAULT_PATH)
	find_library_with_debug(QT_3D_LIBRARIES
					  WIN32_DEBUG_POSTFIX d
					  NAMES Qt3D
					  HINTS ${QT_LIBRARY_DIR}
					  )

	if(QT_3D_LIBRARIES AND QT_3D_INCLUDE_DIR)
		message( STATUS "Found Qt3D: ${QT_3D_LIBRARIES}")
		set(QT_3D_FOUND true)
		list(APPEND QT_LIBRARIES
			${QT_3D_LIBRARIES}
		)
		list(APPEND QT_INCLUDES
			${QT_3D_INCLUDE_DIR}
		)
	else(QT_3D_LIBRARIES AND QT_3D_INCLUDE_DIR)
		message(STATUS "Could NOT find Qt3D")
	endif(QT_3D_LIBRARIES AND QT_3D_INCLUDE_DIR)
endif()
