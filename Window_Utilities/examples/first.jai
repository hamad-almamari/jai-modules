// This Example shows you how to use Window_Utilities with default Window_Creation and Input modules.
#import "Basic";
WC    :: #import "Window_Creation";
Input :: #import "Input";

WU    :: #import "Window_Utilities";

main :: () {

    nwh   := WC.create_window(700, 350, "Hello Sailor!!");
    quit := false;

    flags                       := WU.get_window_flags(nwh);
    width, height               := WU.get_window_size(nwh);
    border_width, border_height := WU.get_window_size(nwh, true);
    m_width, m_height           := WU.get_window_display_size(nwh);

    log("Window Size: %X% , Window Border Size: %X% ", width, height, border_width, border_height);
    log("Window Monitor Size: %X%", m_width, m_height);
    log("Window Flags: %", flags);

    log("---------[START]----------");
    log("use the following keys:");
    log("M - to maximize");
    log("N - to minimize (Note you can not restore when your window minmized due to loos of input data)");
    log("R - to restore");
    log("F - to fullscreen_on");
    log("G/esc - to fullscreen_off");
    log("C - to close");

    fullscreen_data : WU.Window_Fullscreen_Backup;

    while !quit {
        Input.update_window_events();

        for Input.events_this_frame {
            if it.type == .QUIT {
              quit = true;
              nwh = null;   
            } 

            if it.type == .KEYBOARD {
                if it.key_pressed == 0 continue;

                if it.key_code == xx #char "M" {
                    success := WU.window_maximize(nwh);
                    if success log("[maximized] FLAGS: %", WU.get_window_flags(nwh));

                } else if it.key_code == xx #char "N" {
                    success := WU.window_minimize(nwh);
                    if success log("[minimized] FLAGS: %", WU.get_window_flags(nwh));

                } else if it.key_code == xx #char "R" {
                    success := WU.window_restore(nwh);
                    if success log("[restored] FLAGS: %", WU.get_window_flags(nwh));
                    
                } else if it.key_code == xx #char "F" {
                    backup, success := WU.window_fullscreen_on(nwh);
                    if success {
                        fullscreen_data = backup;
                        log("[fullscreen_on] FLAGS: %", WU.get_window_flags(nwh));
                    }
                    
                } else if it.key_code == xx #char "G" || it.key_code == .ESCAPE {
                    success := WU.window_fullscreen_off(nwh, *fullscreen_data);
                    if success log("[fullscreen_off] FLAGS: %", WU.get_window_flags(nwh));
                    
                } else if it.key_code == xx #char "C" {
                    WU.window_close(nwh);
                    log("[closed] FLAGS: %", WU.get_window_flags(nwh));
            
                } 

            }
        }
        sleep_milliseconds(2);
    }
    log("---------[END]----------");
    log("[closed] FLAGS: %", WU.get_window_flags(nwh));
    
}
