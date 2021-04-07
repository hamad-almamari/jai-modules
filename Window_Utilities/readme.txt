This is simple Window Utilities module, it work perfecly with default Window_Creation and Input modules.
The idea is to provide simple Utilities module (platform independent) to work with diffrent modules.
and to be imported from diffrent modules like graphics or what ever when any one want information about
the window.

This module does not provide Window Creation, and does not depends on input module (or Window Proc).
The user may use any of window creation modules or even his own, all what this module
needs is the Native Window Handle (nwh) (for example: HWND in Windows)
you can use "Window_Type" default module or what ever you want.

for now this module only supports Windows.

 Hamad Almamari, 04-06-2021

Api:
Window_Flags :: enum_flags u32 {
    UNKNOWN        :: 0;
    // style
    TOPBAR          :: 1 << 1;
    MINIMIZE_BUTTON :: 1 << 2;
    MAXIMIZE_BUTTON :: 1 << 3;
    RESIZEABLE      :: 1 << 4;
    V_SCROLLABLE    :: 1 << 5;
    H_SCROLLABLE    :: 1 << 6;
    // state
    MINIMIZED       :: 1 << 10;
    MAXMIZED        :: 1 << 11;
    FULLSCREEN      :: 1 << 12;   
}

get_window_size         :: (nwh: Window_Type, including_border_rect := false) -> (width: u32, height: u32)
get_window_position     :: (nwh: Window_Type) -> (x: s32, y: s32)
get_window_border_rect  :: (nwh: Window_Type) -> Window_Rect
get_window_flags        :: (nwh: Window_Type) -> Window_Flags
get_window_display_size :: (nwh: Window_Type) -> (width: u32, height: u32)
window_fullscreen_on    :: (nwh: Window_Type) -> Window_Fullscreen_Backup, bool
window_fullscreen_off   :: (nwh: Window_Type, backup: *Window_Fullscreen_Backup) -> bool
window_maximize          :: (nwh: Window_Type) -> bool
window_minimize         :: (nwh: Window_Type) -> bool
window_restore          :: (nwh: Window_Type) -> bool
window_close            :: (nwh: Window_Type)



jai path/to/modules/examples/first.jai -import_dir path/to/modules
