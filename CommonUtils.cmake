include(CompilerUtils)
include(QtBundleUtils)
include(MocUtils)

macro(UPDATE_COMPILER_FLAGS target)    
    if(MSVC)
        list(APPEND COMPILER_FLAGS "/W3")
    else()
        list(APPEND COMPILER_FLAGS "-Wall -Wextra -Wnon-virtual-dtor")
    endif()

    update_cxx_compiler_flag("-std=c++0x" CXX_0X)
    update_cxx_compiler_flag("-fvisibility=hidden" HIDDEN_VISIBILITY)

    get_target_property(${target}_TYPE ${target} TYPE)
    if (${target}_TYPE STREQUAL "STATIC_LIBRARY")
        update_cxx_compiler_flag("-fPIC" PIC)
    endif()
    set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${COMPILER_FLAGS}")
endmacro()

macro(ADD_SIMPLE_LIBRARY target type)
    if(NOT DEFINED type)
        set(type STATIC)
    endif()
    message(STATUS "Searching ${target} source and headers")

    #Search for source and headers in source directory
    file(GLOB_RECURSE SRC "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
    file(GLOB_RECURSE HDR "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
    file(GLOB_RECURSE FORMS "${CMAKE_CURRENT_SOURCE_DIR}/*.ui")
    file(GLOB_RECURSE QRC "${CMAKE_CURRENT_SOURCE_DIR}/*.qrc")
    if(APPLE)
        file(GLOB_RECURSE MM RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/" "${CMAKE_CURRENT_SOURCE_DIR}/*.mm" )
    endif()

    qt4_wrap_ui(UIS_H ${FORMS})
    moc_wrap_cpp(MOC_SRCS ${HDR})
    qt4_add_resources(QRC_SOURCES ${QRC})

    # This project will generate library
    add_library(${target} ${type} ${SRC} ${MM} ${HDR} ${UIS_H} ${MOC_SRCS} ${QRC_SOURCES})

    include_directories(${CMAKE_CURRENT_BINARY_DIR}

    )
    update_compiler_flags(${target})

    target_link_libraries(${target}
        ${QT_LIBRARIES}
    )

    install(TARGETS ${target}
        RUNTIME DESTINATION ${RLIBDIR}
        LIBRARY DESTINATION ${LIBDIR}
        ARCHIVE DESTINATION ${LIBDIR}
    )
endmacro()

macro(APPEND_TARGET_LOCATION target list)
    get_target_property(${target}_LOCATION ${target} LOCATION)
    list(APPEND ${list} ${${target}_LOCATION})
endmacro()

macro(CHECK_DIRECTORY_EXIST directory exists)
    if(EXISTS ${directory})
       set(_exists FOUND)
    else()
        set(_exists NOT_FOUND)
    endif()
    set(exists ${_exists})
endmacro()

macro(CHECK_QML_MODULE name exists)
    check_directory_exist("${QT_IMPORTS_DIR}/${name}" _exists)
    message(STATUS "Checking qml module ${name} - ${_exists}")
    set(${exists} ${_exists})
endmacro()

macro(ADD_PUBLIC_HEADER header)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${header}
        ${CMAKE_CURRENT_BINARY_DIR}/include/${header} COPYONLY)
    list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/include/${header})
endmacro()

macro(GENERATE_PUBLIC_HEADER header name)
    add_public_header(${header})
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/include/${name}
        "#include \"${name}\"\n"
    )
    list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/include/${name})
endmacro()
