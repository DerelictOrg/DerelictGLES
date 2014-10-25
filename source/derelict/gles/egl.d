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
module derelict.gles.egl;

public {
    import derelict.gles.eglext;
    import derelict.gles.egltypes;
}

private {
    import derelict.util.loader;
    import derelict.util.exception;
    import derelict.util.system;
    import std.conv;

    static if( Derelict_OS_Posix ) {
        enum libNames = "libEGL.so.1,libEGL.so";
    } else
        static assert( 0, "Need to implement EGL libNames for this operating system." );
}

enum : ubyte {
    EGL_FALSE        = 0,
    EGL_TRUE         = 1,
}

/* Out-of-band handle values */
enum EGLNativeDisplayType EGL_DEFAULT_DISPLAY = cast(EGLNativeDisplayType)0;
enum EGLContext EGL_NO_CONTEXT = null;
enum EGLDisplay EGL_NO_DISPLAY = null;
enum EGLSurface EGL_NO_SURFACE = null;
enum EGLSync EGL_NO_SYNC       = null;

/* Out-of-band attribute value */
enum EGLint EGL_DONT_CARE = -1;

enum : EGLint {
    /* Errors / GetError return values */
    EGL_SUCCESS                     = 0x3000,
    EGL_NOT_INITIALIZED             = 0x3001,
    EGL_BAD_ACCESS                  = 0x3002,
    EGL_BAD_ALLOC                   = 0x3003,
    EGL_BAD_ATTRIBUTE               = 0x3004,
    EGL_BAD_CONFIG                  = 0x3005,
    EGL_BAD_CONTEXT                 = 0x3006,
    EGL_BAD_CURRENT_SURFACE         = 0x3007,
    EGL_BAD_DISPLAY                 = 0x3008,
    EGL_BAD_MATCH                   = 0x3009,
    EGL_BAD_NATIVE_PIXMAP           = 0x300A,
    EGL_BAD_NATIVE_WINDOW           = 0x300B,
    EGL_BAD_PARAMETER               = 0x300C,
    EGL_BAD_SURFACE                 = 0x300D,
    EGL_CONTEXT_LOST                = 0x300E,  /* EGL 1.1 - IMG_power_management */
    /* Reserved 0x300F-0x301F for additional errors */

    /* Config attributes */
    EGL_BUFFER_SIZE                 = 0x3020,
    EGL_ALPHA_SIZE                  = 0x3021,
    EGL_BLUE_SIZE                   = 0x3022,
    EGL_GREEN_SIZE                  = 0x3023,
    EGL_RED_SIZE                    = 0x3024,
    EGL_DEPTH_SIZE                  = 0x3025,
    EGL_STENCIL_SIZE                = 0x3026,
    EGL_CONFIG_CAVEAT               = 0x3027,
    EGL_CONFIG_ID                   = 0x3028,
    EGL_LEVEL                       = 0x3029,
    EGL_MAX_PBUFFER_HEIGHT          = 0x302A,
    EGL_MAX_PBUFFER_PIXELS          = 0x302B,
    EGL_MAX_PBUFFER_WIDTH           = 0x302C,
    EGL_NATIVE_RENDERABLE           = 0x302D,
    EGL_NATIVE_VISUAL_ID            = 0x302E,
    EGL_NATIVE_VISUAL_TYPE          = 0x302F,
    EGL_SAMPLES                     = 0x3031,
    EGL_SAMPLE_BUFFERS              = 0x3032,
    EGL_SURFACE_TYPE                = 0x3033,
    EGL_TRANSPARENT_TYPE            = 0x3034,
    EGL_TRANSPARENT_BLUE_VALUE      = 0x3035,
    EGL_TRANSPARENT_GREEN_VALUE     = 0x3036,
    EGL_TRANSPARENT_RED_VALUE       = 0x3037,
    EGL_NONE                        = 0x3038,  /* Attrib list terminator */
    EGL_BIND_TO_TEXTURE_RGB         = 0x3039,
    EGL_BIND_TO_TEXTURE_RGBA        = 0x303A,
    EGL_MIN_SWAP_INTERVAL           = 0x303B,
    EGL_MAX_SWAP_INTERVAL           = 0x303C,
    EGL_LUMINANCE_SIZE              = 0x303D,
    EGL_ALPHA_MASK_SIZE             = 0x303E,
    EGL_COLOR_BUFFER_TYPE           = 0x303F,
    EGL_RENDERABLE_TYPE             = 0x3040,
    EGL_MATCH_NATIVE_PIXMAP         = 0x3041,  /* Pseudo-attribute (not queryable) */
    EGL_CONFORMANT                  = 0x3042,

    /* Reserved 0x3041-0x304F for additional config attributes */

    /* Config attribute values */
    EGL_SLOW_CONFIG                 = 0x3050,  /* EGL_CONFIG_CAVEAT value */
    EGL_NON_CONFORMANT_CONFIG       = 0x3051,  /* EGL_CONFIG_CAVEAT value */
    EGL_TRANSPARENT_RGB             = 0x3052,  /* EGL_TRANSPARENT_TYPE value */
    EGL_RGB_BUFFER                  = 0x308E,  /* EGL_COLOR_BUFFER_TYPE value */
    EGL_LUMINANCE_BUFFER            = 0x308F,  /* EGL_COLOR_BUFFER_TYPE value */

    /* More config attribute values, for EGL_TEXTURE_FORMAT */
    EGL_NO_TEXTURE                  = 0x305C,
    EGL_TEXTURE_RGB                 = 0x305D,
    EGL_TEXTURE_RGBA                = 0x305E,
    EGL_TEXTURE_2D                  = 0x305F,

    /* Config attribute mask bits */
    EGL_PBUFFER_BIT                 = 0x0001,  /* EGL_SURFACE_TYPE mask bits */
    EGL_PIXMAP_BIT                  = 0x0002,  /* EGL_SURFACE_TYPE mask bits */
    EGL_WINDOW_BIT                  = 0x0004,  /* EGL_SURFACE_TYPE mask bits */
    EGL_VG_COLORSPACE_LINEAR_BIT    = 0x0020,  /* EGL_SURFACE_TYPE mask bits */
    EGL_VG_ALPHA_FORMAT_PRE_BIT     = 0x0040,  /* EGL_SURFACE_TYPE mask bits */
    EGL_MULTISAMPLE_RESOLVE_BOX_BIT = 0x0200,  /* EGL_SURFACE_TYPE mask bits */
    EGL_SWAP_BEHAVIOR_PRESERVED_BIT = 0x0400,  /* EGL_SURFACE_TYPE mask bits */

    EGL_OPENGL_ES_BIT               = 0x0001,  /* EGL_RENDERABLE_TYPE mask bits */
    EGL_OPENVG_BIT                  = 0x0002,  /* EGL_RENDERABLE_TYPE mask bits */
    EGL_OPENGL_ES2_BIT              = 0x0004,  /* EGL_RENDERABLE_TYPE mask bits */
    EGL_OPENGL_BIT                  = 0x0008,  /* EGL_RENDERABLE_TYPE mask bits */

    /* QueryString targets */
    EGL_VENDOR                      = 0x3053,
    EGL_VERSION                     = 0x3054,
    EGL_EXTENSIONS                  = 0x3055,
    EGL_CLIENT_APIS                 = 0x308D,

    /* QuerySurface / SurfaceAttrib / CreatePbufferSurface targets */
    EGL_HEIGHT                      = 0x3056,
    EGL_WIDTH                       = 0x3057,
    EGL_LARGEST_PBUFFER             = 0x3058,
    EGL_TEXTURE_FORMAT              = 0x3080,
    EGL_TEXTURE_TARGET              = 0x3081,
    EGL_MIPMAP_TEXTURE              = 0x3082,
    EGL_MIPMAP_LEVEL                = 0x3083,
    EGL_RENDER_BUFFER               = 0x3086,
    EGL_VG_COLORSPACE               = 0x3087,
    EGL_VG_ALPHA_FORMAT             = 0x3088,
    EGL_HORIZONTAL_RESOLUTION       = 0x3090,
    EGL_VERTICAL_RESOLUTION         = 0x3091,
    EGL_PIXEL_ASPECT_RATIO          = 0x3092,
    EGL_SWAP_BEHAVIOR               = 0x3093,
    EGL_MULTISAMPLE_RESOLVE         = 0x3099,

    /* EGL_RENDER_BUFFER values / BindTexImage / ReleaseTexImage buffer targets */
    EGL_BACK_BUFFER                 = 0x3084,
    EGL_SINGLE_BUFFER               = 0x3085,

    /* OpenVG color spaces */
    EGL_VG_COLORSPACE_sRGB          = 0x3089,  /* EGL_VG_COLORSPACE value */
    EGL_VG_COLORSPACE_LINEAR        = 0x308A,  /* EGL_VG_COLORSPACE value */

    /* OpenVG alpha formats */
    EGL_VG_ALPHA_FORMAT_NONPRE      = 0x308B,  /* EGL_ALPHA_FORMAT value */
    EGL_VG_ALPHA_FORMAT_PRE         = 0x308C,  /* EGL_ALPHA_FORMAT value */

    /* Constant scale factor by which fractional display resolutions &
     * aspect ratio are scaled when queried as integer values.
     */
    EGL_DISPLAY_SCALING             = 10000,

    /* Unknown display resolution/aspect ratio */
    EGL_UNKNOWN                     = -1,

    /* Back buffer swap behaviors */
    EGL_BUFFER_PRESERVED            = 0x3094,  /* EGL_SWAP_BEHAVIOR value */
    EGL_BUFFER_DESTROYED            = 0x3095,  /* EGL_SWAP_BEHAVIOR value */

    /* CreatePbufferFromClientBuffer buffer types */
    EGL_OPENVG_IMAGE                = 0x3096,

    /* QueryContext targets */
    EGL_CONTEXT_CLIENT_TYPE         = 0x3097,

    /* CreateContext attributes */
    EGL_CONTEXT_CLIENT_VERSION      = 0x3098,

    /* Multisample resolution behaviors */
    EGL_MULTISAMPLE_RESOLVE_DEFAULT = 0x309A,  /* EGL_MULTISAMPLE_RESOLVE value */
    EGL_MULTISAMPLE_RESOLVE_BOX     = 0x309B,  /* EGL_MULTISAMPLE_RESOLVE value */

    /* BindAPI/QueryAPI targets */
    EGL_OPENGL_ES_API               = 0x30A0,
    EGL_OPENVG_API                  = 0x30A1,
    EGL_OPENGL_API                  = 0x30A2,

    /* GetCurrentSurface targets */
    EGL_DRAW                        = 0x3059,
    EGL_READ                        = 0x305A,

    /* WaitNative engines */
    EGL_CORE_NATIVE_ENGINE          = 0x305B,

    /* EGL 1.2 tokens renamed for consistency in EGL 1.3 */
    EGL_COLORSPACE                  = EGL_VG_COLORSPACE,
    EGL_ALPHA_FORMAT                = EGL_VG_ALPHA_FORMAT,
    EGL_COLORSPACE_sRGB             = EGL_VG_COLORSPACE_sRGB,
    EGL_COLORSPACE_LINEAR           = EGL_VG_COLORSPACE_LINEAR,
    EGL_ALPHA_FORMAT_NONPRE         = EGL_VG_ALPHA_FORMAT_NONPRE,
    EGL_ALPHA_FORMAT_PRE            = EGL_VG_ALPHA_FORMAT_PRE,

    /* EGL 1.5 */
    EGL_CONTEXT_MAJOR_VERSION       = 0x3098,
    EGL_CONTEXT_MINOR_VERSION       = 0x30FB,
    EGL_CONTEXT_OPENGL_PROFILE_MASK = 0x30FD,
    EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY = 0x31BD,
    EGL_NO_RESET_NOTIFICATION       = 0x31BE,
    EGL_LOSE_CONTEXT_ON_RESET       = 0x31BF,
    EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT = 0x00000001,
    EGL_CONTEXT_OPENGL_COMPATIBILITY_PROFILE_BIT = 0x00000002,
    EGL_CONTEXT_OPENGL_DEBUG        = 0x31B0,
    EGL_CONTEXT_OPENGL_FORWARD_COMPATIBLE = 0x31B1,
    EGL_CONTEXT_OPENGL_ROBUST_ACCESS = 0x31B2,
    EGL_OPENGL_ES3_BIT              = 0x00000040,
    EGL_CL_EVENT_HANDLE             = 0x309C,
    EGL_SYNC_CL_EVENT               = 0x30FE,
    EGL_SYNC_CL_EVENT_COMPLETE      = 0x30FF,
    EGL_SYNC_PRIOR_COMMANDS_COMPLETE = 0x30F0,
    EGL_SYNC_TYPE                   = 0x30F7,
    EGL_SYNC_STATUS                 = 0x30F1,
    EGL_SYNC_CONDITION              = 0x30F8,
    EGL_SIGNALED                    = 0x30F2,
    EGL_UNSIGNALED                  = 0x30F3,
    EGL_SYNC_FLUSH_COMMANDS_BIT     = 0x0001,
    EGL_TIMEOUT_EXPIRED             = 0x30F5,
    EGL_CONDITION_SATISFIED         = 0x30F6,
    EGL_SYNC_FENCE                  = 0x30F9,
    EGL_GL_COLORSPACE               = 0x309D,
    EGL_GL_COLORSPACE_SRGB          = 0x3089,
    EGL_GL_COLORSPACE_LINEAR        = 0x308A,
    EGL_GL_RENDERBUFFER             = 0x30B9,
    EGL_GL_TEXTURE_2D               = 0x30B1,
    EGL_GL_TEXTURE_LEVEL            = 0x30BC,
    EGL_GL_TEXTURE_3D               = 0x30B2,
    EGL_GL_TEXTURE_ZOFFSET          = 0x30BD,
    EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_X = 0x30B3,
    EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_X = 0x30B4,
    EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Y = 0x30B5,
    EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = 0x30B6,
    EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Z = 0x30B7,
    EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = 0x30B8,
}

static const EGLTime EGL_FOREVER = 0xFFFFFFFFFFFFFFFFUL;

// This is a Derelict type, not from OpenGLES
enum EGLVersion {
    None,
    EGL10,
    EGL11,
    EGL12,
    EGL13,
    EGL14,
    EGL15,
    HighestSupported = EGL15,
}

/* EGL Functions */
extern( System ) nothrow {
    alias da_eglGetError = EGLint function(  );
    alias da_eglGetDisplay = EGLDisplay function( EGLNativeDisplayType );
    alias da_eglInitialize = EGLBoolean function( EGLDisplay, EGLint*, EGLint* );
    alias da_eglTerminate = EGLBoolean function( EGLDisplay );
    alias da_eglQueryString = const( char )* function( EGLDisplay, EGLint );
    alias da_eglGetConfigs = EGLBoolean function( EGLDisplay, EGLConfig*, EGLint, EGLint* );
    alias da_eglChooseConfig = EGLBoolean function( EGLDisplay, const( EGLint )*, EGLConfig*, EGLint, EGLint* );
    alias da_eglGetConfigAttrib = EGLBoolean function( EGLDisplay, EGLConfig, EGLint, EGLint* );
    alias da_eglCreateWindowSurface = EGLSurface function( EGLDisplay, EGLConfig, EGLNativeWindowType, const( EGLint )* );
    alias da_eglCreatePbufferSurface = EGLSurface function( EGLDisplay, EGLConfig, const( EGLint )* );
    alias da_eglCreatePixmapSurface = EGLSurface function( EGLDisplay, EGLConfig, EGLNativePixmapType, const( EGLint )* );
    alias da_eglDestroySurface = EGLBoolean function( EGLDisplay, EGLSurface );
    alias da_eglQuerySurface = EGLBoolean function( EGLDisplay, EGLSurface, EGLint, EGLint* );
    alias da_eglBindAPI = EGLBoolean function( EGLenum );
    alias da_eglQueryAPI = EGLenum function(  );
    alias da_eglWaitClient = EGLBoolean function(  );
    alias da_eglReleaseThread = EGLBoolean function(  );
    alias da_eglCreatePbufferFromClientBuffer = EGLSurface function( EGLDisplay, EGLenum, EGLClientBuffer, EGLConfig, const( EGLint )* );
    alias da_eglSurfaceAttrib = EGLBoolean function( EGLDisplay, EGLSurface, EGLint, EGLint );
    alias da_eglBindTexImage = EGLBoolean function( EGLDisplay, EGLSurface, EGLint );
    alias da_eglReleaseTexImage = EGLBoolean function( EGLDisplay, EGLSurface, EGLint );
    alias da_eglSwapInterval = EGLBoolean function( EGLDisplay, EGLint );
    alias da_eglCreateContext = EGLContext function( EGLDisplay, EGLConfig, EGLContext, const( EGLint )* );
    alias da_eglDestroyContext = EGLBoolean function( EGLDisplay, EGLContext );
    alias da_eglMakeCurrent = EGLBoolean function( EGLDisplay, EGLSurface, EGLSurface, EGLContext );
    alias da_eglGetCurrentContext = EGLContext function(  );
    alias da_eglGetCurrentSurface = EGLSurface function( EGLint );
    alias da_eglGetCurrentDisplay = EGLDisplay function(  );
    alias da_eglQueryContext = EGLBoolean function( EGLDisplay, EGLContext, EGLint, EGLint* );
    alias da_eglWaitGL = EGLBoolean function(  );
    alias da_eglWaitNative = EGLBoolean function( EGLint );
    alias da_eglSwapBuffers = EGLBoolean function( EGLDisplay, EGLSurface );
    alias da_eglCopyBuffers = EGLBoolean function( EGLDisplay, EGLSurface, EGLNativePixmapType );

    /* This is a generic function pointer type, whose name indicates it must
     * be cast to the proper type *and calling convention* before use.
     */
    alias __eglMustCastToProperFunctionPointerType = void function(  );

    /* Now, define eglGetProcAddress using the generic function ptr. type */
    alias da_eglGetProcAddress = __eglMustCastToProperFunctionPointerType function( const( char )* );

    /* EGL 1.5 */
    alias da_eglCreateSync = EGLSync function ( EGLDisplay, EGLenum, const( EGLAttrib )* );
    alias da_eglDestroySync = EGLBoolean function ( EGLDisplay, EGLSync );
    alias da_eglClientWaitSync = EGLint function ( EGLDisplay, EGLSync, EGLint, EGLTime );
    alias da_eglGetSyncAttrib = EGLBoolean function ( EGLDisplay, EGLSync, EGLint, EGLAttrib* );
    alias da_eglGetPlatformDisplay = EGLDisplay function ( EGLenum, void*, const( EGLAttrib )* );
    alias da_eglCreatePlatformWindowSurface = EGLSurface function ( EGLDisplay, EGLConfig, void*, const( EGLAttrib )* );
    alias da_eglCreatePlatformPixmapSurface = EGLSurface function ( EGLDisplay, EGLConfig, void*, const( EGLAttrib )* );
    alias da_eglWaitSync = EGLBoolean function ( EGLDisplay, EGLSync, EGLint );
}

__gshared {
    da_eglGetError eglGetError;
    da_eglGetDisplay eglGetDisplay;
    da_eglInitialize eglInitialize;
    da_eglTerminate eglTerminate;
    da_eglQueryString eglQueryString;
    da_eglGetConfigs eglGetConfigs;
    da_eglChooseConfig eglChooseConfig;
    da_eglGetConfigAttrib eglGetConfigAttrib;
    da_eglCreateWindowSurface eglCreateWindowSurface;
    da_eglCreatePbufferSurface eglCreatePbufferSurface;
    da_eglCreatePixmapSurface eglCreatePixmapSurface;
    da_eglDestroySurface eglDestroySurface;
    da_eglQuerySurface eglQuerySurface;
    da_eglBindAPI eglBindAPI;
    da_eglQueryAPI eglQueryAPI;
    da_eglWaitClient eglWaitClient;
    da_eglReleaseThread eglReleaseThread;
    da_eglCreatePbufferFromClientBuffer eglCreatePbufferFromClientBuffer;
    da_eglSurfaceAttrib eglSurfaceAttrib;
    da_eglBindTexImage eglBindTexImage;
    da_eglReleaseTexImage eglReleaseTexImage;
    da_eglSwapInterval eglSwapInterval;
    da_eglCreateContext eglCreateContext;
    da_eglDestroyContext eglDestroyContext;
    da_eglMakeCurrent eglMakeCurrent;
    da_eglGetCurrentContext eglGetCurrentContext;
    da_eglGetCurrentSurface eglGetCurrentSurface;
    da_eglGetCurrentDisplay eglGetCurrentDisplay;
    da_eglQueryContext eglQueryContext;
    da_eglWaitGL eglWaitGL;
    da_eglWaitNative eglWaitNative;
    da_eglSwapBuffers eglSwapBuffers;
    da_eglCopyBuffers eglCopyBuffers;
    da_eglGetProcAddress eglGetProcAddress;
    da_eglCreateSync eglCreateSync;
    da_eglDestroySync eglDestroySync;
    da_eglClientWaitSync eglClientWaitSync;
    da_eglGetSyncAttrib eglGetSyncAttrib;
    da_eglGetPlatformDisplay eglGetPlatformDisplay;
    da_eglCreatePlatformWindowSurface eglCreatePlatformWindowSurface;
    da_eglCreatePlatformPixmapSurface eglCreatePlatformPixmapSurface;
    da_eglWaitSync eglWaitSync;
}

class DerelictEGLLoader : SharedLibLoader
{
    private EGLVersion _loadedVersion;

    public
    {
        this() {
            super( libNames );
        }

        EGLVersion loadedVersion() @property {
            return _loadedVersion;
        }

        protected override void loadSymbols() {
            // EGL 1.0
            bindFunc( cast( void** )&eglGetError, "eglGetError" );
            bindFunc( cast( void** )&eglGetDisplay, "eglGetDisplay" );
            bindFunc( cast( void** )&eglInitialize, "eglInitialize" );
            bindFunc( cast( void** )&eglTerminate, "eglTerminate" );

            EGLDisplay disp = eglGetDisplay( EGL_DEFAULT_DISPLAY );
            if( disp == EGL_NO_DISPLAY ) {
                throw new DerelictException( "Unable to get a display for EGL" );
            }
            EGLint major;
            EGLint minor;
            if( eglInitialize( disp, &major, &minor ) == EGL_FALSE ) {
                throw new DerelictException( "Failed to initialize the EGL display: " ~ to!string( eglGetError(  ) ) );
            }

            if( major != 1 ) {
                eglTerminate( disp );
                throw new DerelictException( "The EGL version is not recognized: " ~ to!string( eglGetError(  ) ) );
            }

            if( minor >= 0 ) {
                bindFunc( cast( void** )&eglQueryString, "eglQueryString" );
                bindFunc( cast( void** )&eglGetConfigs, "eglGetConfigs" );
                bindFunc( cast( void** )&eglChooseConfig, "eglChooseConfig" );
                bindFunc( cast( void** )&eglGetConfigAttrib, "eglGetConfigAttrib" );
                bindFunc( cast( void** )&eglCreateWindowSurface, "eglCreateWindowSurface" );
                bindFunc( cast( void** )&eglCreatePbufferSurface, "eglCreatePbufferSurface" );
                bindFunc( cast( void** )&eglCreatePixmapSurface, "eglCreatePixmapSurface" );
                bindFunc( cast( void** )&eglDestroySurface, "eglDestroySurface" );
                bindFunc( cast( void** )&eglQuerySurface, "eglQuerySurface" );
                bindFunc( cast( void** )&eglCreateContext, "eglCreateContext" );
                bindFunc( cast( void** )&eglDestroyContext, "eglDestroyContext" );
                bindFunc( cast( void** )&eglMakeCurrent, "eglMakeCurrent" );
                bindFunc( cast( void** )&eglGetCurrentSurface, "eglGetCurrentSurface" );
                bindFunc( cast( void** )&eglGetCurrentDisplay, "eglGetCurrentDisplay" );
                bindFunc( cast( void** )&eglQueryContext, "eglQueryContext" );
                bindFunc( cast( void** )&eglWaitGL, "eglWaitGL" );
                bindFunc( cast( void** )&eglWaitNative, "eglWaitNative" );
                bindFunc( cast( void** )&eglSwapBuffers, "eglSwapBuffers" );
                bindFunc( cast( void** )&eglCopyBuffers, "eglCopyBuffers" );
                bindFunc( cast( void** )&eglGetProcAddress, "eglGetProcAddress" );

                _loadedVersion = EGLVersion.EGL10;
            }
            if( minor >= 1 ) {
                bindFunc( cast( void** )&eglSurfaceAttrib, "eglSurfaceAttrib" );
                bindFunc( cast( void** )&eglBindTexImage, "eglBindTexImage" );
                bindFunc( cast( void** )&eglReleaseTexImage, "eglReleaseTexImage" );
                bindFunc( cast( void** )&eglSwapInterval, "eglSwapInterval" );

                _loadedVersion = EGLVersion.EGL11;
            }
            if( minor >= 2 ) {
                bindFunc( cast( void** )&eglBindAPI, "eglBindAPI" );
                bindFunc( cast( void** )&eglQueryAPI, "eglQueryAPI" );
                bindFunc( cast( void** )&eglWaitClient, "eglWaitClient" );
                bindFunc( cast( void** )&eglReleaseThread, "eglReleaseThread" );
                bindFunc( cast( void** )&eglCreatePbufferFromClientBuffer, "eglCreatePbufferFromClientBuffer" );

                _loadedVersion = EGLVersion.EGL12;
            }
            if( minor >= 3 ) {
                _loadedVersion = EGLVersion.EGL13;
            }
            if( minor >= 4 ) {
                bindFunc( cast( void** )&eglGetCurrentContext, "eglGetCurrentContext" );

                _loadedVersion = EGLVersion.EGL14;
            }
            if( minor >= 5 ) {
                bindFunc( cast( void** )&eglCreateSync, "eglCreateSync" );
                bindFunc( cast( void** )&eglDestroySync, "eglDestroySync" );
                bindFunc( cast( void** )&eglClientWaitSync, "eglClientWaitSync" );
                bindFunc( cast( void** )&eglGetSyncAttrib, "eglGetSyncAttrib" );
                bindFunc( cast( void** )&eglGetPlatformDisplay, "eglGetPlatformDisplay" );
                bindFunc( cast( void** )&eglCreatePlatformWindowSurface, "eglCreatePlatformWindowSurface" );
                bindFunc( cast( void** )&eglCreatePlatformPixmapSurface, "eglCreatePlatformPixmapSurface" );
                bindFunc( cast( void** )&eglWaitSync, "eglWaitSync" );

                _loadedVersion = EGLVersion.EGL15;
            }

            loadEXT( disp );
            if( eglTerminate( disp ) == EGL_FALSE ) {
                throw new DerelictException( "Failed to terminate the EGL display: " ~ to!string( eglGetError(  ) ) );
            }
        }
    }
}

__gshared DerelictEGLLoader DerelictEGL;

shared static this() {
    DerelictEGL = new DerelictEGLLoader;
}
