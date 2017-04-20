Asphyre 4.1.0, snapshot 30-Mar-2007

This version requires BDS 2006 or Turbo Delphi. The installation
is pretty straightforward: extract the package to some folder on
your hard drive and run Delphi. In "Tools -> Options -> Environment
Options -> Delphi Options -> Library - Win32 -> Library path" add
the path to Asphyre \Source folder, e.g.:
 $(BDS)\lib;$(BDS)\Imports;$(BDS)\Lib\Indy10;c:\Asphyre\Source
 
Notice that applications using Asphyre 4 will require 'd3dx9_31.dll'
file to run. It is provided conveniently in \DLLs folder for testing 
purposes on developer machine. However, this file is not for 
redistribution. For redistribution you can use the following
package: http://asphyre.afterwarp.net/files/RedistDLLAsphyre4.7z

In the same folder \DLLs you will find additional dlls, which can
be optionally used by Asphyre to load all types of media from 
archives. 

Additional examples may require "Newton.dll" to be copied to the
system folder of Windows and/or to the application folder.

Remember that Asphyre 4 is still under development so keep checking
our website at http://www.afterwarp.net for the updates and other
important information.

You can view any information about Asphyre on Wiki:
 http://asphyre.afterwarp.net/wiki/

Also, you can discuss the development of Asphyre 4 on our forums at:
 http://www.afterwarp.net/forum
 
or you can talk to one of the developers directly on IRC:

IRC Server : irc.shadowfire.org
IRC Channel: #asphyre

Remember that this library and its source code are protected
by Mozilla Public License 1.1. You must agree to use this package
under the terms of Mozilla Public License 1.1 or permamently
remove the package from your hard drive.