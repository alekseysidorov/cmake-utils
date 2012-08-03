#find Qt3D
find_package(Qt3D REQUIRED)
find_qt_module(Qt3DQuick
    GLOBAL_HEADER qt3dquickglobal.h
    HEADERS_DIR Qt3DQuick
)

##find Qt3DQuick
#if(APPLE)
#	find_library(QT_3DQUICK_LIBRARIES
#		NAMES Qt3DQuick
#		HINTS ${QT_LIBRARY_DIR}
#	)
#	if(QT_3DQUICK_LIBRARIES)
#		message(STATUS "Found Qt3DQuick framework: ${QT_3DQUICK_LIBRARIES}")
#		set(QT_3DQUICK_FOUND true)
#		list(APPEND QT_LIBRARIES
#			${QT_3DQUICK_LIBRARIES}
#		)
#		set(QT_3DQUICK_INCLUDE_DIR "${QT_3DQUICK_LIBRARIES}/Headers")
#		list(APPEND QT_INCLUDES
#			${QT_3DQUICK_INCLUDE_DIR}
#		)
#	else()
#		message(STATUS "Could NOT find Qt3DQuick")
#	endif()
#else()
#	include(FindLibraryWithDebug)
#	find_path(QT_3DQUICK_INCLUDE_DIR qt3dquickglobal.h PATH ${QT_INCLUDE_DIR}/Qt3DQuick NO_DEFAULT_PATH)
#	find_library_with_debug(QT_3DQUICK_LIBRARIES
#					  WIN32_DEBUG_POSTFIX d
#					  NAMES Qt3DQuick
#					  HINTS ${QT_LIBRARY_DIR}
#					  )

#	if(QT_3DQUICK_LIBRARIES AND QT_3DQUICK_INCLUDE_DIR)
#		message(STATUS "Found Qt3DQuick: ${QT_3DQUICK_LIBRARIES}")
#		set(QT_3DQUICK_FOUND true)
#		list(APPEND QT_LIBRARIES
#			${QT_3DQUICK_LIBRARIES}
#		)
#		list(APPEND QT_INCLUDES
#			${QT_3DQUICK_INCLUDE_DIR}
#		)
#	else()
#		message( STATUS "Could NOT find Qt3DQuick")
#	endif()
#endif()
