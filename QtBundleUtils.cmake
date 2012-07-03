if(NOT CMAKE_DEBUG_POSTFIX)
    if(APPLE)
        set(CMAKE_DEBUG_POSTFIX _debug)
    else()
        set(CMAKE_DEBUG_POSTFIX d)
    endif()
endif()

macro(DEPLOY_QT_PLUGIN _path)
    get_filename_component(_dir ${_path} PATH)
    get_filename_component(name ${_path} NAME_WE)
    string(TOUPPER ${CMAKE_BUILD_TYPE} _type)
    if(${_type} STREQUAL "DEBUG")
         set(name "${name}${CMAKE_DEBUG_POSTFIX}")
    endif()

    set(name "${CMAKE_SHARED_LIBRARY_PREFIX}${name}")
    set(PLUGIN "${QT_PLUGINS_DIR}/${_dir}/${name}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    #trying to search lib with suffix 4
    if(NOT EXISTS ${PLUGIN})
        set(name "${name}4")
        set(PLUGIN "${QT_PLUGINS_DIR}/${_dir}/${name}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    endif()

    #message(${PLUGIN})
    if(EXISTS ${PLUGIN})
        message(STATUS "Deployng ${_path} plugin")
        install(FILES ${PLUGIN} DESTINATION "${PLUGINSDIR}/${_dir}" COMPONENT Runtime)
    else()
            message(STATUS "Could not deploy ${_path} plugin")
    endif()
endmacro()

macro(DEPLOY_QT_PLUGINS)
    foreach(plugin ${ARGN})
            deploy_qt_plugin(${plugin})
    endforeach()
endmacro()

macro(DEPLOY_QML_MODULE _path)
    string(TOUPPER ${CMAKE_BUILD_TYPE} _type)
    set(_importPath "${QT_IMPORTS_DIR}/${_path}")
    if(EXISTS ${_importPath})
        if(${_type} STREQUAL "DEBUG")
                set(_libPattern "[^${CMAKE_DEBUG_POSTFIX}]${CMAKE_SHARED_LIBRARY_SUFFIX}$")
        else()
                set(_libPattern "${CMAKE_DEBUG_POSTFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}$")
        endif()

        #evil version
        message(STATUS "Deployng ${_path} QtQuick module")
        INSTALL(DIRECTORY ${_importPath} DESTINATION ${IMPORTSDIR} COMPONENT Runtime
                REGEX "${_libPattern}" EXCLUDE
                PATTERN "*.pdb" EXCLUDE
        )
    else()
        message(STATUS "Could not deploy ${_path} QtQuick module")
    endif()
endmacro()

macro(DEPLOY_QML_MODULES)
    foreach(plugin ${ARGN})
            deploy_qml_module(${plugin})
    endforeach()
endmacro()

macro(DEFINE_BUNDLE_PATHS _name)
    include(UseBundlePaths)
endmacro()
