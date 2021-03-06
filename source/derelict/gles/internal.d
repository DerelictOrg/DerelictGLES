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
module derelict.gles.internal;

private {
    import core.stdc.string;

    import derelict.util.exception;
    import derelict.gles.egl;
    import derelict.gles.types2;
    import derelict.gles.constants2;
    import derelict.gles.functions2;
}

package {
    void bindGLFunc( void** ptr, string symName ) {
        auto sym = eglGetProcAddress( symName.ptr );
        if( !sym )
            throw new SymbolLoadException( "Failed to load OpenGLES symbol [" ~ symName ~ "]" );
        *ptr = sym;
    }

    bool isExtSupported( string name ) {
        auto ext = glGetString( GL_EXTENSIONS );
        return checkExt( ext, name );
    }

    bool isEGLExtSupported( EGLDisplay disp, string name ) {
        const( char )* ext = eglQueryString( disp, EGL_EXTENSIONS );
        return checkExt( ext, name );
    }

    bool checkExt( const( char )* ext, string name ) {
        if( !ext )
            return false;

        auto res = strstr( ext, name.ptr );

        while( res ) {
            // It's possible that the extension name is actually a
            // substring of another extension. If not, then the
            // character following the name in the extension string
            // should be a space (or possibly the null character ).
            if( res[ name.length ] == ' ' || res[ name.length ] == '\0' )
                return true;
            res = strstr( res + name.length, name.ptr );
        }

        return false;
    }
}
