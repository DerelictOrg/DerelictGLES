/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.gles.eglplatform;

import derelict.util.system;

static if(Derelict_OS_Windows) {
    alias EGLint = int;

    // No need to pull in core.sys.windows.windows here --
    // handles are all void*
    alias EGLNativeDisplayType = void*; // HDC
    alias EGLNativePixmapType = void*;  // HBITMAP
    alias EGLNativeWindowType = void*;  // HWND
}
else static if( Derelict_OS_Android ) {
    alias EGLint = int;

    struct ANativeWindow;
    struct egl_native_pixmap_t;

    alias EGLNativeWindowType = ANativeWindow*;
    alias EGLNativePixmapType = egl_native_pixmap_t*;
    alias EGLNativeDisplayType = void*;
}
else static if( Derelict_OS_Posix && !Derelict_OS_Mac ) {
    alias EGLint = int;

    // static if( wayland ) {
    // struct wl_display;
    // struct wl_egl_pixmap;
    // struct wl_egl_window;

    // alias EGLNativeWindowType = wl_display*;
    // alias EGLNativePixmapType = wl_egl_pixmap*;
    // alias EGLNativeDisplayType = wl_egl_window*;
    // } else {
    // FIXME: Assume X for now.
    struct Display;

    alias EGLNativeWindowType = Display*;
    alias EGLNativePixmapType = uint;
    alias EGLNativeDisplayType = uint;
    // }
}
else
    static assert( 0, "Need to implement EGL types for this operating system." );
