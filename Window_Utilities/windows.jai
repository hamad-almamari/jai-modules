#assert(OS == .WINDOWS);
#scope_file
#import "Windows";
#scope_export

get_window_size :: (nwh: HWND, including_border_rect := false) -> (width: u32, height: u32) 
{
    assert(nwh != null);
    if !including_border_rect {
        rect: RECT;
        GetClientRect(nwh, *rect);
        return xx (rect.right - rect.left), xx (rect.bottom - rect.top);
    } else {
        rect := get_window_border_rect(nwh);
        return xx (rect.right - rect.left), xx (rect.bottom - rect.top);
    }
}

get_window_position :: (nwh: HWND) -> (x: s32, y: s32) 
{ // return left, top
    assert(nwh != null);
    rect: RECT;
    GetWindowRect(nwh, *rect);
    return rect.left, rect.top;
}

// this return border rect.
get_window_border_rect :: (nwh: HWND) -> Window_Rect 
{ 
    assert(nwh != null);
    rect: RECT;
    GetWindowRect(nwh, *rect);
    r : Window_Rect;
    r.left   = rect.left;
    r.top    = rect.top;
    r.right  = rect.right;
    r.bottom = rect.bottom;
    return r;
}

get_window_flags :: (nwh: HWND) -> Window_Flags
 {
    if nwh == null return 0;
    result  : Window_Flags;
    style   := GetWindowLongW(nwh, GWL_STYLE);
    // style
    if style & WS_CAPTION     then result |= .TOPBAR;
    if style & WS_MINIMIZEBOX then result |= .MINIMIZE_BUTTON;
    if style & WS_MAXIMIZEBOX then result |= .MAXIMIZE_BUTTON;
    if style & WS_THICKFRAME  then result |= .RESIZEABLE;
    if style & WS_VSCROLL     then result |= .V_SCROLLABLE;
    if style & WS_HSCROLL     then result |= .H_SCROLLABLE;
    // state
    if style & WS_MINIMIZE    then result |= .MINIMIZED;
    if style & WS_MAXIMIZE    then result |= .MAXIMIZED;
    // fullscreen
    m_width, m_height := get_window_display_size(nwh);
    w_rect_width, w_rect_height := get_window_size(nwh, true);
    if (w_rect_width == m_width && w_rect_height == m_height) then result |= .FULLSCREEN;

    return result;
}

get_window_display_size :: (nwh: HWND) -> (width: u32, height: u32)
{
    assert(nwh != null);
    m_info: MONITORINFO;
    m_info.cbSize = size_of(type_of(m_info));
    success := GetMonitorInfoW(MonitorFromWindow(nwh, MONITOR_DEFAULTTONEAREST), *m_info);
    if success {
        m_width  : u32 = xx (m_info.rcMonitor.right  - m_info.rcMonitor.left);
        m_height : u32 = xx (m_info.rcMonitor.bottom - m_info.rcMonitor.top);
        return m_width, m_height;
    } else {
        log_error("GetMonitorInfoW failed!!");
        return 0, 0;
    }
}

window_fullscreen_on :: (nwh: HWND) -> Window_Fullscreen_Backup, bool
{
    assert(nwh != null);
    backup : Window_Fullscreen_Backup;;
    backup.border_rect  = get_window_border_rect(nwh);
    backup.flags = get_window_flags(nwh);
    if backup.flags & .FULLSCREEN return backup, false;

    old_style       := GetWindowLongW(nwh, GWL_STYLE);
    old_ex_style    := GetWindowLongW(nwh, GWL_EXSTYLE);
    // update style
    SetWindowLongW(nwh, GWL_STYLE,   old_style    & ~cast(s32)(WS_CAPTION | WS_THICKFRAME));
    SetWindowLongW(nwh, GWL_EXSTYLE, old_ex_style & ~cast(s32)(WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE));
    // update width and height
    m_width, m_height := get_window_display_size(nwh);
    SetWindowPos(nwh, HWND_TOPMOST, 0, 0, xx m_width, xx m_height, SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED);
    return backup, true;
}

window_fullscreen_off :: (nwh: HWND, backup: *Window_Fullscreen_Backup) -> bool
{
    assert(nwh != null);
    assert(backup != null);
    flags := get_window_flags(nwh);
    if backup.flags         == 0 || !(flags & .FULLSCREEN) then return false;
    // restore style
    style := GetWindowLongW(nwh, GWL_STYLE);
    if backup.flags & .TOPBAR     then style |= WS_CAPTION;
    if backup.flags & .RESIZEABLE then style |= WS_THICKFRAME;
    SetWindowLongW(nwh, GWL_STYLE, cast(s32)style);
    // for now we don't care about ex style, we just add the style which we removed
    ex_style    := GetWindowLongW(nwh, GWL_EXSTYLE);
    SetWindowLongW(nwh, GWL_EXSTYLE, ex_style | cast(s32)(WS_EX_DLGMODALFRAME | WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE | WS_EX_STATICEDGE));
    // restore window rect
    SetWindowPos(nwh, HWND_TOP, backup.left, backup.top, backup.right, backup.bottom, SWP_FRAMECHANGED);
    // delete backup
    backup = null;
    return true;
}

window_maximize :: (nwh: HWND) -> bool {
    assert(nwh != null);
    flags := get_window_flags(nwh);
    if flags & .FULLSCREEN return false;
    ShowWindow(nwh, SW_MAXIMIZE);
    UpdateWindow(nwh);
    return true;
}

window_minimize :: (nwh: HWND) -> bool {
    assert(nwh != null);
    flags := get_window_flags(nwh);
    if flags & .MINIMIZED return false;
    ShowWindow(nwh, SW_MINIMIZE);
    return true;
}

window_restore :: (nwh: HWND) -> bool {
    assert(nwh != null);
    flags := get_window_flags(nwh);
    if flags & .FULLSCREEN return false;
    ShowWindow(nwh, SW_RESTORE);
    UpdateWindow(nwh);
    return true;
}

window_close :: (nwh: HWND) {
    assert(nwh != null);
    // we do not use DestroyWindow(nwh) here, we post WM_CLOSE to send the event to window proc.
    // meby the user do not want us to close the window.
    user32       :: #foreign_system_library "user32";
    PostMessageW :: (hwnd: HWND, msg: u32, wParam: WPARAM, lParam: LPARAM) -> BOOL #foreign user32;
    PostMessageW(nwh, WM_CLOSE, 0 , 0);
    // Note this proc does not close the window immediatly, it just post message
    // so after that the window proc will handle it (Input module).
}
