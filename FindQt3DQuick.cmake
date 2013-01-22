#find Qt3D
find_package(Qt3D QUIET)
find_qt_module(Qt3DQuick
    GLOBAL_HEADER qt3dquickglobal.h
    HEADERS_DIR Qt3DQuick
)
