include(CompilerUtils)
include(QtBundleUtils)
include(MocUtils)

MACRO(LIST_CONTAINS var value)
  SET(${var})
  FOREACH (value2 ${ARGN})
    IF (${value} STREQUAL ${value2})
      SET(${var} TRUE)
    ENDIF (${value} STREQUAL ${value2})
  ENDFOREACH (value2)
ENDMACRO(LIST_CONTAINS)

MACRO(PARSE_ARGUMENTS prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option} FALSE)
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})
    LIST_CONTAINS(is_arg_name ${arg} ${arg_names})
    IF (is_arg_name)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name)
      LIST_CONTAINS(is_option ${arg} ${option_names})
      IF (is_option)
        SET(${prefix}_${arg} TRUE)
      ELSE (is_option)
        SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option)
    ENDIF (is_arg_name)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(PARSE_ARGUMENTS)

macro(UPDATE_COMPILER_FLAGS target)
    parse_arguments(FLAGS
        ""
        "DEVELOPER;CXX11"
        ${ARGN}
    )

    if(FLAGS_DEVELOPER)
        if(MSVC)
                update_cxx_compiler_flag("/W3" W3)
                update_cxx_compiler_flag("/WX" WX)
        else()
                update_cxx_compiler_flag("-Wall" WALL)
                update_cxx_compiler_flag("-Wextra" WEXTRA)
                update_cxx_compiler_flag("-Wnon-virtual-dtor" WDTOR)
                update_cxx_compiler_flag("-Werror" WERROR)
        endif()
    endif()

    if(FLAGS_CXX11)
        update_cxx_compiler_flag("-std=c++0x" CXX_11)
        #add check for c++11 support
    endif()
    #update_cxx_compiler_flag("-stdlib=libc++" STD_LIBCXX)

    get_target_property(${target}_TYPE ${target} TYPE)
    if (${target}_TYPE STREQUAL "STATIC_LIBRARY")
        update_cxx_compiler_flag("-fpic" PIC)
	elseif(${target}_TYPE STREQUAL "SHARED_LIBRARY")
        update_cxx_compiler_flag("-fvisibility=hidden" HIDDEN_VISIBILITY)
    endif()
    set_target_properties(${target} PROPERTIES COMPILE_FLAGS "${COMPILER_FLAGS}")
endmacro()

function(__GET_SOURCES name)
    #Search for source and headers in source directory
    file(GLOB_RECURSE SRC "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
    file(GLOB_RECURSE HDR "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
    file(GLOB_RECURSE FORMS "${CMAKE_CURRENT_SOURCE_DIR}/*.ui")
    file(GLOB_RECURSE QRC "${CMAKE_CURRENT_SOURCE_DIR}/*.qrc")
    if(APPLE)
        file(GLOB_RECURSE MM "${CMAKE_CURRENT_SOURCE_DIR}/*.mm")
    endif()

    qt4_wrap_ui(UIS_H ${FORMS})
    moc_wrap_cpp(MOC_SRCS ${HDR})
    qt4_add_resources(QRC_SOURCES ${QRC})
    list(APPEND sources
        ${SRC}
        ${MM}
        ${HDR}
        ${UIS_H}
        ${MOC_SRCS}
        ${QRC_SOURCES}
    )
    set(${name} ${sources} PARENT_SCOPE)
endfunction()

macro(ADD_SIMPLE_LIBRARY target)
    parse_arguments(LIBRARY
        "LIBRARIES;INCLUDES;DEFINES;VERSION;SOVERSION;DEFINE_SYMBOL"
        "STATIC;INTERNAL;DEVELOPER;CXX11"
        ${ARGN}
    )
    if(LIBRARY_STATIC)
        set(type STATIC)
    else()
        set(type SHARED)
    endif()
	
    if(LIBRARY_DEVELOPER)
        list(APPEND opts DEVELOPER)
    endif()
    if(LIBRARY_CXX11)
        list(APPEND opts CXX11)
    endif()

    message(STATUS "Searching ${target} source and headers")
    __get_sources(SOURCES)
    # This project will generate library
    add_library(${target} ${type} ${SOURCES})
    foreach(_define ${LIBRARY_DEFINES})
        add_definitions(-D${_define})
    endforeach()
    set(LIBRARY_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

    include_directories(${CMAKE_CURRENT_BINARY_DIR}
        ${LIBRARY_SOURCE_DIR}
        ${LIBRARY_INCLUDES}
    )
    update_compiler_flags(${target} ${opts})
    set_target_properties(${target} PROPERTIES
            VERSION ${LIBRARY_VERSION}
            SOVERSION ${LIBRARY_SOVERSION}
            DEFINE_SYMBOL ${LIBRARY_DEFINE_SYMBOL}
    )

    target_link_libraries(${target}
        ${QT_LIBRARIES}
        ${LIBRARY_LIBRARIES}
    )

    if(NOT LIBRARY_INTERNAL)
        install(TARGETS ${target}
            RUNTIME DESTINATION ${RLIBDIR}
            LIBRARY DESTINATION ${LIBDIR}
            ARCHIVE DESTINATION ${LIBDIR}
        )
        set(INCDIR include/${target})
        #TODO add framework creation ability
        file(GLOB_RECURSE PUBLIC_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/*[^p].h")
        file(GLOB_RECURSE PRIVATE_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/*_p.h")

        install(FILES ${PUBLIC_HEADERS} DESTINATION ${INCDIR})
        install(FILES ${PRIVATE_HEADERS} DESTINATION ${INCDIR}/private/${LIBRARY_VERSION})
    endif()
endmacro()

macro(ADD_SIMPLE_EXECUTABLE target)
    parse_arguments(EXECUTABLE
        "LIBRARIES;INCLUDES;DEFINES"
        "INTERNAL;GUI;CXX11"
        ${ARGN}
    )

    if(EXECUTABLE_GUI)
        if(APPLE)
                set(type MACOSX_BUNDLE)
        else()
                set(type WIN32)
        endif()
    else()
        set(type "")
    endif()
    message(STATUS "Searching ${target} source and headers")
    __get_sources(SOURCES)
    # This project will generate library
    add_executable(${target} ${type} ${SOURCES})
    foreach(_define ${EXECUTABLE_DEFINES})
        add_definitions(-D${_define})
    endforeach()

    include_directories(${CMAKE_CURRENT_BINARY_DIR}
        .
        ${EXECUTABLE_INCLUDES}
    )

    if(EXECUTABLE_CXX11)
        list(APPEND opts CXX11)
    endif()

    update_compiler_flags(${target} ${opts})

    target_link_libraries(${target}
        ${QT_LIBRARIES}
        ${EXECUTABLE_LIBRARIES}
    )

    if(NOT EXECUTABLE_INTERNAL)
        install(TARGETS ${target}
            RUNTIME DESTINATION ${BINDIR}
            BUNDLE DESTINATION .
        )
    endif()
endmacro()

macro(ADD_SIMPLE_QT_TEST target)
    parse_arguments(TEST
        "LIBRARIES;RESOURCES"
        "CXX11"
        ${ARGN}
    )
    set(${target}_SRCS ${target}.cpp)
    qt4_add_resources(RCC ${TEST_RESOURCES})
    list(APPEND ${target}_SRCS ${RCC})
    include_directories(${CMAKE_CURRENT_BINARY_DIR} ${QT_QTTEST_INCLUDE_DIR})
    add_executable(${target} ${${target}_SRCS})
    target_link_libraries(${target} ${TEST_LIBRARIES} ${QT_QTTEST_LIBRARY} ${QT_LIBRARIES})
    if(TEST_CXX11)
        list(APPEND opts CXX11)
    endif()
    update_compiler_flags(${target} ${opts})
    add_test(NAME ${target} COMMAND ${target})
    message(STATUS "Added simple test: ${target} LIBRARIES: ${TEST_LIBRARIES}")
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

macro(ADD_CUSTOM_DIRECTORY sourceDir)
    parse_arguments(DIR
        "DESCRIPTION"
        ""
        ${ARGN}
    )

    get_filename_component(_basename ${sourceDir} NAME_WE)
    file(GLOB_RECURSE _files "${sourceDir}/*.*")
    add_custom_target(dir_${_basename} ALL
        SOURCES ${_files}
    )
    source_group(${DIR_DESCRIPTION} FILES ${_files})
endmacro()

macro(DEPLOY_FOLDER sourceDir)
    parse_arguments(FOLDER
        "DESCRIPTION;DESTINATION"
        ""
        ${ARGN}
    )

    get_filename_component(_basename ${sourceDir} NAME_WE)
    file(GLOB_RECURSE _files "${sourceDir}/*.*")
    message(STATUS "deploy qml folder: ${sourceDir}")
    add_custom_target(qml_${_basename} ALL
        SOURCES ${_files}
    )
    file(GLOB _files "${sourceDir}/*")
    foreach(_file ${_files})
        if(IS_DIRECTORY ${_file})
            install(DIRECTORY ${_file} DESTINATION  ${FOLDER_DESTINATION})
            get_filename_component(_name ${_file} NAME_WE)
            add_custom_command(TARGET qml_${_basename}
                                COMMAND ${CMAKE_COMMAND} -E copy_directory ${_file} "${CMAKE_BINARY_DIR}/${_name}"
            )
        else()
            install(FILES ${_file} DESTINATION  ${FOLDER_DESTINATION})
            add_custom_command(TARGET qml_${_basename}
                                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${_file} ${CMAKE_BINARY_DIR}
            )
        endif()
    endforeach()
    source_group(${FOLDER_DESCRIPTION} FILES ${_files})
endmacro()

macro(ENABLE_QML_DEBUG_SUPPORT target)

endmacro()
