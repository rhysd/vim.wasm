/* vi:set ts=8 sts=4 sw=4:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *	      Implemented by rhysd <https://github.com/rhysd>
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * gui_wasm.c: Wasm port of Vim by @rhysd.
 */

#ifdef FEAT_GUI_WASM
#include "vim.h"

/*
 * ------------------------------------------------------------
 * GUI_MCH functionality
 * ------------------------------------------------------------
 */

void
gui_mch_mousehide(int hide)
{
}

/*
 * Parse the GUI related command-line arguments.  Any arguments used are
 * deleted from argv, and *argc is decremented accordingly.  This is called
 * when vim is started, whether or not the GUI has been started.
 */
void
gui_mch_prepare(int *argc, char **argv)
{
}

#ifndef ALWAYS_USE_GUI
/*
 * Check if the GUI can be started.  Called before gvimrc is sourced.
 * Return OK or FAIL.
 */
    int
gui_mch_init_check(void)
{
    return OK;
}
#endif /* ALWAYS_USE_GUI */

/*
 * Initialise the GUI.  Create all the windows, set up all the call-backs
 * etc.
 */
int
gui_mch_init(void)
{
    return OK;
}

/*
 * Called when the foreground or background color has been changed.
 */
void
gui_mch_new_colors(void)
{
}

/*
 * Open the GUI window which was created by a call to gui_mch_init().
 */
int
gui_mch_open(void)
{
    return OK;
}

void
gui_mch_exit(int rc)
{
}

/*
 * Get the position of the top left corner of the window.
 */
int
gui_mch_get_winpos(int *x, int *y)
{
    return OK;
}

/*
 * Set the position of the top left corner of the window to the given
 * coordinates.
 */
void
gui_mch_set_winpos(int x, int y)
{
}

void
gui_mch_set_shellsize(
    int		width,
    int		height,
    int		min_width,
    int		min_height,
    int		base_width,
    int		base_height,
    int		direction)
{
}

/*
 * Get the screen dimensions.
 * Allow 10 pixels for horizontal borders, 40 for vertical borders.
 * Is there no way to find out how wide the borders really are?
 * TODO: Add live update of those value on suspend/resume.
 */
void
gui_mch_get_screen_dimensions(int *screen_w, int *screen_h)
{
}

/*
 * Initialise vim to use the font with the given name.	Return FAIL if the font
 * could not be loaded, OK otherwise.
 */
int
gui_mch_init_font(char_u *font_name, int fontset)
{
    return OK;
}

/*
 * Adjust gui.char_height (after 'linespace' was changed).
 */
int
gui_mch_adjust_charheight(void)
{
    return OK;
}

/*
 * Get a font structure for highlighting.
 */
GuiFont
gui_mch_get_font(char_u *name, int giveErrorIfMissing)
{
    return NOFONT;
}

#if defined(FEAT_EVAL) || defined(PROTO)
/*
 * Return the name of font "font" in allocated memory.
 * Don't know how to get the actual name, thus use the provided name.
 */
    char_u *
gui_mch_get_fontname(GuiFont font, char_u *name)
{
    return NULL;
}
#endif

/*
 * Set the current text font.
 */
void
gui_mch_set_font(GuiFont font)
{
}

/*
 * If a font is not going to be used, free its structure.
 */
void
gui_mch_free_font(GuiFont font)
{
    // Free font when "font" is not 0.
}

/*
 * Return the Pixel value (color) for the given color name.  This routine was
 * pretty much taken from example code in the Silicon Graphics OSF/Motif
 * Programmer's Guide.
 * Return INVALCOLOR when failed.
 */
guicolor_T
gui_mch_get_color(char_u *name)
{
    return INVALCOLOR;
}

guicolor_T
gui_mch_get_rgb_color(int r, int g, int b)
{
    return INVALCOLOR;
}

/*
 * Set the current text foreground color.
 */
void
gui_mch_set_fg_color(guicolor_T color)
{
}

/*
 * Set the current text background color.
 */
void
gui_mch_set_bg_color(guicolor_T color)
{
}

/*
 * Set the current text special color.
 */
void
gui_mch_set_sp_color(guicolor_T color)
{
}

void
gui_mch_draw_string(int row, int col, char_u *s, int len, int flags)
{
}

/*
 * Return OK if the key with the termcap name "name" is supported.
 */
int
gui_mch_haskey(char_u *name)
{
    return OK;
}

void
gui_mch_beep(void)
{
}

void
gui_mch_flash(int msec)
{
}

/*
 * Invert a rectangle from row r, column c, for nr rows and nc columns.
 */
void
gui_mch_invert_rectangle(int r, int c, int nr, int nc)
{
}

/*
 * Iconify the GUI window.
 */
    void
gui_mch_iconify(void)
{
}

#if defined(FEAT_EVAL) || defined(PROTO)
/*
 * Bring the Vim window to the foreground.
 */
void
gui_mch_set_foreground(void)
{
}
#endif

/*
 * Draw a cursor without focus.
 */
void
gui_mch_draw_hollow_cursor(guicolor_T color)
{
}

/*
 * Draw part of a cursor, only w pixels wide, and h pixels high.
 */
void
gui_mch_draw_part_cursor(int w, int h, guicolor_T color)
{
}

/*
 * Catch up with any queued X events.  This may put keyboard input into the
 * input buffer, call resize call-backs, trigger timers etc.  If there is
 * nothing in the X event queue (& no timers pending), then we return
 * immediately.
 */
void
gui_mch_update(void)
{
}

/*
 * GUI input routine called by gui_wait_for_chars().  Waits for a character
 * from the keyboard.
 *  wtime == -1	    Wait forever.
 *  wtime == 0	    This should never happen.
 *  wtime > 0	    Wait wtime milliseconds for a character.
 * Returns OK if a character was found to be available within the given time,
 * or FAIL otherwise.
 */
int
gui_mch_wait_for_chars(int wtime)
{
    return FAIL;
}

/* Flush any output to the screen */
void
gui_mch_flush(void)
{
}

/*
 * Clear a rectangular region of the screen from text pos (row1, col1) to
 * (row2, col2) inclusive.
 */
void
gui_mch_clear_block(int row1, int col1, int row2, int col2)
{
}

/*
 * Clear the whole text window.
 */
void
gui_mch_clear_all(void)
{
}

/*
 * Delete the given number of lines from the given row, scrolling up any
 * text further down within the scroll region.
 */
void
gui_mch_delete_lines(int row, int num_lines)
{
}

/*
 * Insert the given number of lines before the given row, scrolling down any
 * following text within the scroll region.
 */
void
gui_mch_insert_lines(int row, int num_lines)
{
}

void
clip_mch_request_selection(VimClipboard *cbd)
{
}

void
clip_mch_lose_selection(VimClipboard *cbd)
{
}

int
clip_mch_own_selection(VimClipboard *cbd)
{
    return OK;
}

/*
 * Send the current selection to the clipboard.
 */
void
clip_mch_set_selection(VimClipboard *cbd)
{
}

void
gui_mch_set_text_area_pos(int x, int y, int w, int h)
{
}

/*
 * Menu stuff.
 */

void
gui_mch_enable_menu(int flag)
{
    /*
     * Menu is always active.
     */
}

void
gui_mch_set_menu_pos(int x, int y, int w, int h)
{
    /*
     * The menu is always at the top of the screen.
     */
}

/*
 * Add a sub menu to the menu bar.
 */
void
gui_mch_add_menu(vimmenu_T *menu, int idx)
{
}

/*
 * Add a menu item to a menu
 */
void
gui_mch_add_menu_item(vimmenu_T *menu, int idx)
{
}

void
gui_mch_toggle_tearoffs(int enable)
{
    /* no tearoff menus */
}

/*
 * Destroy the machine specific menu widget.
 */
void
gui_mch_destroy_menu(vimmenu_T *menu)
{
}

/*
 * Make a menu either grey or not grey.
 */
void
gui_mch_menu_grey(vimmenu_T *menu, int grey)
{
}

/*
 * Make menu item hidden or not hidden
 */
void
gui_mch_menu_hidden(vimmenu_T *menu, int hidden)
{
}

/*
 * This is called after setting all the menus to grey/hidden or not.
 */
void
gui_mch_draw_menubar(void)
{
}

/*
 * Scrollbar stuff.
 */

void
gui_mch_enable_scrollbar(
	scrollbar_T	*sb,
	int		flag)
{
}

void
gui_mch_set_scrollbar_thumb(
	scrollbar_T *sb,
	long val,
	long size,
	long max)
{
}

void
gui_mch_set_scrollbar_pos(
	scrollbar_T *sb,
	int x,
	int y,
	int w,
	int h)
{
}

void
gui_mch_create_scrollbar(
	scrollbar_T *sb,
	int orient)	/* SBAR_VERT or SBAR_HORIZ */
{
}

void
gui_mch_destroy_scrollbar(scrollbar_T *sb)
{
}

int
gui_mch_is_blinking(void)
{
    return FALSE;
}

int
gui_mch_is_blink_off(void)
{
    return FALSE;
}

/*
 * Cursor blink functions.
 *
 * This is a simple state machine:
 * BLINK_NONE	not blinking at all
 * BLINK_OFF	blinking, cursor is not shown
 * BLINK_ON blinking, cursor is shown
 */
void
gui_mch_set_blinking(long wait, long on, long off)
{
}

/*
 * Stop the cursor blinking.  Show the cursor if it wasn't shown.
 */
void
gui_mch_stop_blink(int may_call_gui_update_cursor)
{
}

/*
 * Start the cursor blinking.  If it was already blinking, this restarts the
 * waiting time and shows the cursor.
 */
void
gui_mch_start_blink(void)
{
}

/*
 * Return the RGB value of a pixel as long.
 */
guicolor_T
gui_mch_get_rgb(guicolor_T pixel)
{
    return INVALCOLOR;
}

#ifdef FEAT_BROWSE
/*
 * Pop open a file browser and return the file selected, in allocated memory,
 * or NULL if Cancel is hit.
 *  saving  - TRUE if the file will be saved to, FALSE if it will be opened.
 *  title   - Title message for the file browser dialog.
 *  dflt    - Default name of file.
 *  ext     - Default extension to be added to files without extensions.
 *  initdir - directory in which to open the browser (NULL = current dir)
 *  filter  - Filter for matched files to choose from.
 *  Has a format like this:
 *  "C Files (*.c)\0*.c\0"
 *  "All Files\0*.*\0\0"
 *  If these two strings were concatenated, then a choice of two file
 *  filters will be selectable to the user.  Then only matching files will
 *  be shown in the browser.  If NULL, the default allows all files.
 *
 *  *NOTE* - the filter string must be terminated with TWO nulls.
 */
char_u *
gui_mch_browse(
    int saving,
    char_u *title,
    char_u *dflt,
    char_u *ext,
    char_u *initdir,
    char_u *filter)
{
    return NULL;
}
#endif /* FEAT_BROWSE */

#ifdef FEAT_GUI_DIALOG
/*
 * Stuff for dialogues
 */

/*
 * Create a dialogue dynamically from the parameter strings.
 * type       = type of dialogue (question, alert, etc.)
 * title      = dialogue title. may be NULL for default title.
 * message    = text to display. Dialogue sizes to accommodate it.
 * buttons    = '\n' separated list of button captions, default first.
 * dfltbutton = number of default button.
 *
 * This routine returns 1 if the first button is pressed,
 *	    2 for the second, etc.
 *
 *	    0 indicates Esc was pressed.
 *	    -1 for unexpected error
 *
 * If stubbing out this fn, return 1.
 */

int
gui_mch_dialog(
    int		type,
    char_u	*title,
    char_u	*message,
    char_u	*buttons,
    int		dfltbutton,
    char_u	*textfield,
    int		ex_cmd)
{
    return 0; // ???
}
#endif /* FEAT_GUI_DIALOG */

/*
 * Get current mouse coordinates in text window.
 */
void
gui_mch_getmouse(int *x, int *y)
{
}

void
gui_mch_setmouse(int x, int y)
{
}

void
gui_mch_show_popupmenu(vimmenu_T *menu)
{
}

#ifdef FEAT_TITLE
/*
 * Set the window title and icon.
 * (The icon is not taken care of).
 */
void
gui_mch_settitle(char_u *title, char_u *icon)
{
}
#endif /* FEAT_TITLE */


#if (defined(FEAT_MBYTE) && defined(USE_CARBONKEYHANDLER)) || defined(PROTO)
/*
 * Input Method Control functions.
 */

/*
 * Notify cursor position to IM.
 */
void
im_set_position(int row, int col)
{
}

/*
 * Set IM status on ("active" is TRUE) or off ("active" is FALSE).
 */
void
im_set_active(int active)
{
}

/*
 * Get IM status.  When IM is on, return not 0.  Else return 0.
 */
    int
im_get_status(void)
{
    return FALSE;
}
#endif /* (defined(FEAT_MBYTE) && defined(USE_CARBONKEYHANDLER)) || defined(PROTO) */

#if defined(FEAT_GUI_TABLINE) || defined(PROTO)
/*
 * Show or hide the tabline.
 */
    void
gui_mch_show_tabline(int showit)
{
}

/*
 * Return TRUE when tabline is displayed.
 */
int
gui_mch_showing_tabline(void)
{
    return FALSE;
}

/*
 * Set the current tab to "nr".  First tab is 1.
 */
void
gui_mch_set_curtab(int nr)
{
}

#endif /* defined(FEAT_GUI_TABLINE) || defined(PROTO) */

#endif /* FEAT_GUI_WASM */
