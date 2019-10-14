/* vi:set ts=8 sts=4 sw=4:
 *
 * VIM - Vi IMproved            by Bram Moolenaar
 *            Implemented by rhysd <https://github.com/rhysd>
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * gui_wasm.c: Wasm port of Vim by @rhysd.
 */

#ifdef FEAT_GUI_WASM
#include <math.h>
#include "vim.h"


#if defined(RGB)
# undef RGB
#endif
#define RGB(r, g, b) (((r)<<16) | ((g)<<8) | (b))

static int clipboard_available = TRUE;

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
 * Display the saved error message(s).
 */
#ifdef USE_MCH_ERRMSG
void
display_errors(void)
{
    if (error_ga.ga_data == NULL)
        return;

    /* avoid putting up a message box with blanks only */
    for (char *p = (char *)error_ga.ga_data; *p; ++p) {
        if (!isspace(*p))
        {
            // TODO
            fprintf(stderr, "%s\n", p)
        }
    }
    ga_clear(&error_ga);
}
#endif

/*
 * Initialise the GUI.  Create all the windows, set up all the call-backs
 * etc.
 */
int
gui_mch_init(void)
{
    vimwasm_will_init();

    // Get Window Height not considering devicePixelRatio
    gui.dom_width = vimwasm_get_dom_width();
    gui.dom_height = vimwasm_get_dom_height();

    gui.scrollbar_width = 0;
    gui.scrollbar_height = 0;
    gui.border_width = 0;
    gui.border_offset = 0;

    gui.fg_color = INVALCOLOR;
    gui.fg_color_code[0] = '\0';
    gui.bg_color = INVALCOLOR;
    gui.bg_color_code[0] = '\0';
    gui.sp_color = INVALCOLOR;
    gui.sp_color_code[0] = '\0';

    gui.num_rows = gui.dom_height / gui.char_height;
    gui.num_cols = gui.dom_width / gui.char_width;
    gui.in_focus = TRUE;

    // Display any pending error messages
    display_errors();

    // Get background/foreground colors from system
    gui.norm_pixel = 0x00FFFFFF; // white
    gui.back_pixel = 0x00000000; // black

    // Get the colors from the "Normal" group (set in syntax.c or in a vimrc file).
    set_normal_colors();

    // Check that none of the colors are the same as the background color.
    // Then store the current values as the defaults.
    gui_check_colors();
    gui.def_norm_pixel = gui.norm_pixel;
    gui.def_back_pixel = gui.back_pixel;

    // Get the colors for the highlight groups (gui_check_colors() might have
    // changed them)
    highlight_gui_started();

#ifdef FEAT_MENU
    gui.menu_height = 0;
#endif

    Rows = gui.num_rows;
    Columns = gui.num_cols;

    // TODO: Create the tabline
    GUI_WASM_DBG("Rows=%ld Cols=%ld dom_width=%d dom_height=%d", Rows, Columns, gui.dom_width, gui.dom_height);

    return OK;
}

/*
 * Called when the foreground or background color has been changed.
 */
void
gui_mch_new_colors(void)
{
    // Called when `Normal` highlight is changed.
    // Nothing to do?
}

/*
 * Open the GUI window which was created by a call to gui_mch_init().
 */
int
gui_mch_open(void)
{
    // Called when gui_mch_init() creates a new window.
    // Usually a GUI window gains focus here.
    // Nothing to do.
    return OK;
}

void
gui_mch_exit(int rc)
{
    GUI_WASM_DBG("exit with status=%d", rc);
    exit(rc);
}

/*
 * Get the position of the top left corner of the window.
 */
int
gui_mch_get_winpos(int *x, int *y)
{
    *x = *y = 0;
    return OK;
}

/*
 * Set the position of the top left corner of the window to the given
 * coordinates.
 */
void
gui_mch_set_winpos(int x, int y)
{
    // TODO: Enable to move window position
}

void
gui_mch_set_shellsize(
    int width,
    int height,
    int min_width,
    int min_height,
    int base_width,
    int base_height,
    int direction)
{
    printf("TODO: set_shellsize %d %d %ld %ld\n", width, height, Rows, Columns);
}

/*
 * Get the screen dimensions.
 */
void
gui_mch_get_screen_dimensions(int *screen_w, int *screen_h)
{
    GUI_WASM_DBG("w=%d h=%d", gui.dom_width, gui.dom_height);
    *screen_w = gui.dom_width;
    *screen_h = gui.dom_height;
}

/*
 * Initialise vim to use the font with the given name.  Return FAIL if the font
 * could not be loaded, OK otherwise.
 * This function is also called when 'guifont' option is updated.
 */
int
gui_mch_init_font(char_u *font_name, int fontset)
{
    // Default value
    int font_height = 11;
    char_u *next_font = NULL;

    if (STRCMP(font_name, "*") == 0) {
        // TODO: Show font selector when font_name == "*"
        return FAIL;
    }

    if (font_name == NULL) {
        char const* const default_font = "Monaco,Consolas,monospace";
        next_font = vim_strsave((char_u *) default_font);
    } else {
        // Read font name considering {font name}:{height} like 'Monaco:h12'
        char_u const* const style_start = vim_strchr(font_name, ':');
        if (style_start == NULL || *(style_start + 1) != 'h') {
            // Dup font_name since it is owned by caller and will be free()ed after this function call.
            next_font = vim_strsave(font_name);
        } else {
            int const len = style_start - font_name;
            unsigned int height;

            if (len > 0) {
                next_font = alloc(len + 1);
                vim_strncpy(next_font, font_name, len); // Note: vim_strncvpy() sets NUL at the end
            }

            // Note: `+ 2` means skipping ':h' to adjust pointer to start of font size
            if (sscanf((char *)(style_start + 2), "%u", &height) == 1 && height > 0) {
                font_height = (int) height;
            }
        }
    }

    // TODO: Set bold_font, ital_font, boldital_font
    // TODO: Get font metrics for character height/width/ascent
    if (next_font != NULL) {
        if (gui.norm_font != NULL) {
            vim_free(gui.norm_font);
        }
        gui.norm_font = (GuiFont)next_font;
    }

    gui.font_height = font_height;
    // line-height of <canvas> is fixed to 1.2
    gui.char_height = (int) ceil(font_height * 1.2);
    // round up `font_height * 7 / 11`
    // https://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
    gui.char_width = 1 + (font_height * 7 - 1) / 11;
    // round up `font_height * 6 / 11`
    // https://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
    gui.char_ascent = 1 + (font_height * 6 - 1) / 11;

    vimwasm_set_font((char *)gui.norm_font, font_height);

    GUI_WASM_DBG(
        "font=%s font_height=%d char_height=%d char_width=%d char_ascent=%d",
        (char *)gui.norm_font,
        font_height,
        gui.char_height,
        gui.char_width,
        gui.char_ascent
    );

    return OK;
}

/*
 * Adjust gui.char_height (after 'linespace' was changed).
 */
int
gui_mch_adjust_charheight(void)
{
    // Do nothing since character height is managed in C
    return OK;
}

/*
 * Get a font structure for highlighting.
 */
GuiFont
gui_mch_get_font(char_u *name, int giveErrorIfMissing)
{
    if (vimwasm_is_font((char *)name)) {
        return (GuiFont)vim_strsave(name);
    }

    if (giveErrorIfMissing) {
        semsg(_(e_font), name);
    }

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
    if (name == NULL) {
        return NULL;
    }
    return vim_strsave(name);
}
#endif

/*
 * Set the current text font.
 */
void
gui_mch_set_font(GuiFont font)
{
    if (STRICMP(font, gui.norm_font) == 0) {
        // If it's the same value as previous, do nothing
        return;
    }

    GUI_WASM_DBG("name=%s size=%d", font, gui.font_height);

    vimwasm_set_font((char *)font, gui.font_height);
    gui.norm_font = (GuiFont) vim_strsave((char_u *)font);
}

/*
 * If a font is not going to be used, free its structure.
 */
void
gui_mch_free_font(GuiFont font)
{
    // Free font when "font" is not 0.
    vim_free(font);
}

// Generated with gen_gui_name_to_builtin_color.rb
static guicolor_T
gui_name_to_builtin_color(char_u *name)
{
    struct rgbcolor_table {
        char_u *name;
        guicolor_T color;
    };

    // Generated with gen_builtin_color_table.rb
    static struct rgbcolor_table builtin_color_table[] = {
        {(char_u *)"snow",			RGB(255, 250, 250)},
        {(char_u *)"ghost white",		RGB(248, 248, 255)},
        {(char_u *)"ghostwhite",		RGB(248, 248, 255)},
        {(char_u *)"white smoke",		RGB(245, 245, 245)},
        {(char_u *)"whitesmoke",		RGB(245, 245, 245)},
        {(char_u *)"gainsboro",			RGB(220, 220, 220)},
        {(char_u *)"floral white",		RGB(255, 250, 240)},
        {(char_u *)"floralwhite",		RGB(255, 250, 240)},
        {(char_u *)"old lace",			RGB(253, 245, 230)},
        {(char_u *)"oldlace",			RGB(253, 245, 230)},
        {(char_u *)"linen",			RGB(250, 240, 230)},
        {(char_u *)"antique white",		RGB(250, 235, 215)},
        {(char_u *)"antiquewhite",		RGB(250, 235, 215)},
        {(char_u *)"papaya whip",		RGB(255, 239, 213)},
        {(char_u *)"papayawhip",		RGB(255, 239, 213)},
        {(char_u *)"blanched almond",		RGB(255, 235, 205)},
        {(char_u *)"blanchedalmond",		RGB(255, 235, 205)},
        {(char_u *)"bisque",			RGB(255, 228, 196)},
        {(char_u *)"peach puff",		RGB(255, 218, 185)},
        {(char_u *)"peachpuff",			RGB(255, 218, 185)},
        {(char_u *)"navajo white",		RGB(255, 222, 173)},
        {(char_u *)"navajowhite",		RGB(255, 222, 173)},
        {(char_u *)"moccasin",			RGB(255, 228, 181)},
        {(char_u *)"cornsilk",			RGB(255, 248, 220)},
        {(char_u *)"ivory",			RGB(255, 255, 240)},
        {(char_u *)"lemon chiffon",		RGB(255, 250, 205)},
        {(char_u *)"lemonchiffon",		RGB(255, 250, 205)},
        {(char_u *)"seashell",			RGB(255, 245, 238)},
        {(char_u *)"honeydew",			RGB(240, 255, 240)},
        {(char_u *)"mint cream",		RGB(245, 255, 250)},
        {(char_u *)"mintcream",			RGB(245, 255, 250)},
        {(char_u *)"azure",			RGB(240, 255, 255)},
        {(char_u *)"alice blue",		RGB(240, 248, 255)},
        {(char_u *)"aliceblue",			RGB(240, 248, 255)},
        {(char_u *)"lavender",			RGB(230, 230, 250)},
        {(char_u *)"lavender blush",		RGB(255, 240, 245)},
        {(char_u *)"lavenderblush",		RGB(255, 240, 245)},
        {(char_u *)"misty rose",		RGB(255, 228, 225)},
        {(char_u *)"mistyrose",			RGB(255, 228, 225)},
        {(char_u *)"white",			RGB(255, 255, 255)},
        {(char_u *)"black",			RGB(0, 0, 0)},
        {(char_u *)"dark slate gray",		RGB(47, 79, 79)},
        {(char_u *)"darkslategray",		RGB(47, 79, 79)},
        {(char_u *)"dark slate grey",		RGB(47, 79, 79)},
        {(char_u *)"darkslategrey",		RGB(47, 79, 79)},
        {(char_u *)"dim gray",			RGB(105, 105, 105)},
        {(char_u *)"dimgray",			RGB(105, 105, 105)},
        {(char_u *)"dim grey",			RGB(105, 105, 105)},
        {(char_u *)"dimgrey",			RGB(105, 105, 105)},
        {(char_u *)"slate gray",		RGB(112, 128, 144)},
        {(char_u *)"slategray",			RGB(112, 128, 144)},
        {(char_u *)"slate grey",		RGB(112, 128, 144)},
        {(char_u *)"slategrey",			RGB(112, 128, 144)},
        {(char_u *)"light slate gray",		RGB(119, 136, 153)},
        {(char_u *)"lightslategray",		RGB(119, 136, 153)},
        {(char_u *)"light slate grey",		RGB(119, 136, 153)},
        {(char_u *)"lightslategrey",		RGB(119, 136, 153)},
        {(char_u *)"gray",			RGB(190, 190, 190)},
        {(char_u *)"grey",			RGB(190, 190, 190)},
        {(char_u *)"x11 gray",			RGB(190, 190, 190)},
        {(char_u *)"x11gray",			RGB(190, 190, 190)},
        {(char_u *)"x11 grey",			RGB(190, 190, 190)},
        {(char_u *)"x11grey",			RGB(190, 190, 190)},
        {(char_u *)"web gray",			RGB(128, 128, 128)},
        {(char_u *)"webgray",			RGB(128, 128, 128)},
        {(char_u *)"web grey",			RGB(128, 128, 128)},
        {(char_u *)"webgrey",			RGB(128, 128, 128)},
        {(char_u *)"light grey",		RGB(211, 211, 211)},
        {(char_u *)"lightgrey",			RGB(211, 211, 211)},
        {(char_u *)"light gray",		RGB(211, 211, 211)},
        {(char_u *)"lightgray",			RGB(211, 211, 211)},
        {(char_u *)"midnight blue",		RGB(25, 25, 112)},
        {(char_u *)"midnightblue",		RGB(25, 25, 112)},
        {(char_u *)"navy",			RGB(0, 0, 128)},
        {(char_u *)"navy blue",			RGB(0, 0, 128)},
        {(char_u *)"navyblue",			RGB(0, 0, 128)},
        {(char_u *)"cornflower blue",		RGB(100, 149, 237)},
        {(char_u *)"cornflowerblue",		RGB(100, 149, 237)},
        {(char_u *)"dark slate blue",		RGB(72, 61, 139)},
        {(char_u *)"darkslateblue",		RGB(72, 61, 139)},
        {(char_u *)"slate blue",		RGB(106, 90, 205)},
        {(char_u *)"slateblue",			RGB(106, 90, 205)},
        {(char_u *)"medium slate blue",		RGB(123, 104, 238)},
        {(char_u *)"mediumslateblue",		RGB(123, 104, 238)},
        {(char_u *)"light slate blue",		RGB(132, 112, 255)},
        {(char_u *)"lightslateblue",		RGB(132, 112, 255)},
        {(char_u *)"medium blue",		RGB(0, 0, 205)},
        {(char_u *)"mediumblue",		RGB(0, 0, 205)},
        {(char_u *)"royal blue",		RGB(65, 105, 225)},
        {(char_u *)"royalblue",			RGB(65, 105, 225)},
        {(char_u *)"blue",			RGB(0, 0, 255)},
        {(char_u *)"dodger blue",		RGB(30, 144, 255)},
        {(char_u *)"dodgerblue",		RGB(30, 144, 255)},
        {(char_u *)"deep sky blue",		RGB(0, 191, 255)},
        {(char_u *)"deepskyblue",		RGB(0, 191, 255)},
        {(char_u *)"sky blue",			RGB(135, 206, 235)},
        {(char_u *)"skyblue",			RGB(135, 206, 235)},
        {(char_u *)"light sky blue",		RGB(135, 206, 250)},
        {(char_u *)"lightskyblue",		RGB(135, 206, 250)},
        {(char_u *)"steel blue",		RGB(70, 130, 180)},
        {(char_u *)"steelblue",			RGB(70, 130, 180)},
        {(char_u *)"light steel blue",		RGB(176, 196, 222)},
        {(char_u *)"lightsteelblue",		RGB(176, 196, 222)},
        {(char_u *)"light blue",		RGB(173, 216, 230)},
        {(char_u *)"lightblue",			RGB(173, 216, 230)},
        {(char_u *)"powder blue",		RGB(176, 224, 230)},
        {(char_u *)"powderblue",		RGB(176, 224, 230)},
        {(char_u *)"pale turquoise",		RGB(175, 238, 238)},
        {(char_u *)"paleturquoise",		RGB(175, 238, 238)},
        {(char_u *)"dark turquoise",		RGB(0, 206, 209)},
        {(char_u *)"darkturquoise",		RGB(0, 206, 209)},
        {(char_u *)"medium turquoise",		RGB(72, 209, 204)},
        {(char_u *)"mediumturquoise",		RGB(72, 209, 204)},
        {(char_u *)"turquoise",			RGB(64, 224, 208)},
        {(char_u *)"cyan",			RGB(0, 255, 255)},
        {(char_u *)"aqua",			RGB(0, 255, 255)},
        {(char_u *)"light cyan",		RGB(224, 255, 255)},
        {(char_u *)"lightcyan",			RGB(224, 255, 255)},
        {(char_u *)"cadet blue",		RGB(95, 158, 160)},
        {(char_u *)"cadetblue",			RGB(95, 158, 160)},
        {(char_u *)"medium aquamarine",		RGB(102, 205, 170)},
        {(char_u *)"mediumaquamarine",		RGB(102, 205, 170)},
        {(char_u *)"aquamarine",		RGB(127, 255, 212)},
        {(char_u *)"dark green",		RGB(0, 100, 0)},
        {(char_u *)"darkgreen",			RGB(0, 100, 0)},
        {(char_u *)"dark olive green",		RGB(85, 107, 47)},
        {(char_u *)"darkolivegreen",		RGB(85, 107, 47)},
        {(char_u *)"dark sea green",		RGB(143, 188, 143)},
        {(char_u *)"darkseagreen",		RGB(143, 188, 143)},
        {(char_u *)"sea green",			RGB(46, 139, 87)},
        {(char_u *)"seagreen",			RGB(46, 139, 87)},
        {(char_u *)"medium sea green",		RGB(60, 179, 113)},
        {(char_u *)"mediumseagreen",		RGB(60, 179, 113)},
        {(char_u *)"light sea green",		RGB(32, 178, 170)},
        {(char_u *)"lightseagreen",		RGB(32, 178, 170)},
        {(char_u *)"pale green",		RGB(152, 251, 152)},
        {(char_u *)"palegreen",			RGB(152, 251, 152)},
        {(char_u *)"spring green",		RGB(0, 255, 127)},
        {(char_u *)"springgreen",		RGB(0, 255, 127)},
        {(char_u *)"lawn green",		RGB(124, 252, 0)},
        {(char_u *)"lawngreen",			RGB(124, 252, 0)},
        {(char_u *)"green",			RGB(0, 255, 0)},
        {(char_u *)"lime",			RGB(0, 255, 0)},
        {(char_u *)"x11 green",			RGB(0, 255, 0)},
        {(char_u *)"x11green",			RGB(0, 255, 0)},
        {(char_u *)"web green",			RGB(0, 128, 0)},
        {(char_u *)"webgreen",			RGB(0, 128, 0)},
        {(char_u *)"chartreuse",		RGB(127, 255, 0)},
        {(char_u *)"medium spring green",	RGB(0, 250, 154)},
        {(char_u *)"mediumspringgreen",		RGB(0, 250, 154)},
        {(char_u *)"green yellow",		RGB(173, 255, 47)},
        {(char_u *)"greenyellow",		RGB(173, 255, 47)},
        {(char_u *)"lime green",		RGB(50, 205, 50)},
        {(char_u *)"limegreen",			RGB(50, 205, 50)},
        {(char_u *)"yellow green",		RGB(154, 205, 50)},
        {(char_u *)"yellowgreen",		RGB(154, 205, 50)},
        {(char_u *)"forest green",		RGB(34, 139, 34)},
        {(char_u *)"forestgreen",		RGB(34, 139, 34)},
        {(char_u *)"olive drab",		RGB(107, 142, 35)},
        {(char_u *)"olivedrab",			RGB(107, 142, 35)},
        {(char_u *)"dark khaki",		RGB(189, 183, 107)},
        {(char_u *)"darkkhaki",			RGB(189, 183, 107)},
        {(char_u *)"khaki",			RGB(240, 230, 140)},
        {(char_u *)"pale goldenrod",		RGB(238, 232, 170)},
        {(char_u *)"palegoldenrod",		RGB(238, 232, 170)},
        {(char_u *)"light goldenrod yellow",	RGB(250, 250, 210)},
        {(char_u *)"lightgoldenrodyellow",	RGB(250, 250, 210)},
        {(char_u *)"light yellow",		RGB(255, 255, 224)},
        {(char_u *)"lightyellow",		RGB(255, 255, 224)},
        {(char_u *)"yellow",			RGB(255, 255, 0)},
        {(char_u *)"gold",			RGB(255, 215, 0)},
        {(char_u *)"light goldenrod",		RGB(238, 221, 130)},
        {(char_u *)"lightgoldenrod",		RGB(238, 221, 130)},
        {(char_u *)"goldenrod",			RGB(218, 165, 32)},
        {(char_u *)"dark goldenrod",		RGB(184, 134, 11)},
        {(char_u *)"darkgoldenrod",		RGB(184, 134, 11)},
        {(char_u *)"rosy brown",		RGB(188, 143, 143)},
        {(char_u *)"rosybrown",			RGB(188, 143, 143)},
        {(char_u *)"indian red",		RGB(205, 92, 92)},
        {(char_u *)"indianred",			RGB(205, 92, 92)},
        {(char_u *)"saddle brown",		RGB(139, 69, 19)},
        {(char_u *)"saddlebrown",		RGB(139, 69, 19)},
        {(char_u *)"sienna",			RGB(160, 82, 45)},
        {(char_u *)"peru",			RGB(205, 133, 63)},
        {(char_u *)"burlywood",			RGB(222, 184, 135)},
        {(char_u *)"beige",			RGB(245, 245, 220)},
        {(char_u *)"wheat",			RGB(245, 222, 179)},
        {(char_u *)"sandy brown",		RGB(244, 164, 96)},
        {(char_u *)"sandybrown",		RGB(244, 164, 96)},
        {(char_u *)"tan",			RGB(210, 180, 140)},
        {(char_u *)"chocolate",			RGB(210, 105, 30)},
        {(char_u *)"firebrick",			RGB(178, 34, 34)},
        {(char_u *)"brown",			RGB(165, 42, 42)},
        {(char_u *)"dark salmon",		RGB(233, 150, 122)},
        {(char_u *)"darksalmon",		RGB(233, 150, 122)},
        {(char_u *)"salmon",			RGB(250, 128, 114)},
        {(char_u *)"light salmon",		RGB(255, 160, 122)},
        {(char_u *)"lightsalmon",		RGB(255, 160, 122)},
        {(char_u *)"orange",			RGB(255, 165, 0)},
        {(char_u *)"dark orange",		RGB(255, 140, 0)},
        {(char_u *)"darkorange",		RGB(255, 140, 0)},
        {(char_u *)"coral",			RGB(255, 127, 80)},
        {(char_u *)"light coral",		RGB(240, 128, 128)},
        {(char_u *)"lightcoral",		RGB(240, 128, 128)},
        {(char_u *)"tomato",			RGB(255, 99, 71)},
        {(char_u *)"orange red",		RGB(255, 69, 0)},
        {(char_u *)"orangered",			RGB(255, 69, 0)},
        {(char_u *)"red",			RGB(255, 0, 0)},
        {(char_u *)"hot pink",			RGB(255, 105, 180)},
        {(char_u *)"hotpink",			RGB(255, 105, 180)},
        {(char_u *)"deep pink",			RGB(255, 20, 147)},
        {(char_u *)"deeppink",			RGB(255, 20, 147)},
        {(char_u *)"pink",			RGB(255, 192, 203)},
        {(char_u *)"light pink",		RGB(255, 182, 193)},
        {(char_u *)"lightpink",			RGB(255, 182, 193)},
        {(char_u *)"pale violet red",		RGB(219, 112, 147)},
        {(char_u *)"palevioletred",		RGB(219, 112, 147)},
        {(char_u *)"maroon",			RGB(176, 48, 96)},
        {(char_u *)"x11 maroon",		RGB(176, 48, 96)},
        {(char_u *)"x11maroon",			RGB(176, 48, 96)},
        {(char_u *)"web maroon",		RGB(128, 0, 0)},
        {(char_u *)"webmaroon",			RGB(128, 0, 0)},
        {(char_u *)"medium violet red",		RGB(199, 21, 133)},
        {(char_u *)"mediumvioletred",		RGB(199, 21, 133)},
        {(char_u *)"violet red",		RGB(208, 32, 144)},
        {(char_u *)"violetred",			RGB(208, 32, 144)},
        {(char_u *)"magenta",			RGB(255, 0, 255)},
        {(char_u *)"fuchsia",			RGB(255, 0, 255)},
        {(char_u *)"violet",			RGB(238, 130, 238)},
        {(char_u *)"plum",			RGB(221, 160, 221)},
        {(char_u *)"orchid",			RGB(218, 112, 214)},
        {(char_u *)"medium orchid",		RGB(186, 85, 211)},
        {(char_u *)"mediumorchid",		RGB(186, 85, 211)},
        {(char_u *)"dark orchid",		RGB(153, 50, 204)},
        {(char_u *)"darkorchid",		RGB(153, 50, 204)},
        {(char_u *)"dark violet",		RGB(148, 0, 211)},
        {(char_u *)"darkviolet",		RGB(148, 0, 211)},
        {(char_u *)"blue violet",		RGB(138, 43, 226)},
        {(char_u *)"blueviolet",		RGB(138, 43, 226)},
        {(char_u *)"purple",			RGB(160, 32, 240)},
        {(char_u *)"x11 purple",		RGB(160, 32, 240)},
        {(char_u *)"x11purple",			RGB(160, 32, 240)},
        {(char_u *)"web purple",		RGB(128, 0, 128)},
        {(char_u *)"webpurple",			RGB(128, 0, 128)},
        {(char_u *)"medium purple",		RGB(147, 112, 219)},
        {(char_u *)"mediumpurple",		RGB(147, 112, 219)},
        {(char_u *)"thistle",			RGB(216, 191, 216)},
        {(char_u *)"snow1",			RGB(255, 250, 250)},
        {(char_u *)"snow2",			RGB(238, 233, 233)},
        {(char_u *)"snow3",			RGB(205, 201, 201)},
        {(char_u *)"snow4",			RGB(139, 137, 137)},
        {(char_u *)"seashell1",			RGB(255, 245, 238)},
        {(char_u *)"seashell2",			RGB(238, 229, 222)},
        {(char_u *)"seashell3",			RGB(205, 197, 191)},
        {(char_u *)"seashell4",			RGB(139, 134, 130)},
        {(char_u *)"antiquewhite1",		RGB(255, 239, 219)},
        {(char_u *)"antiquewhite2",		RGB(238, 223, 204)},
        {(char_u *)"antiquewhite3",		RGB(205, 192, 176)},
        {(char_u *)"antiquewhite4",		RGB(139, 131, 120)},
        {(char_u *)"bisque1",			RGB(255, 228, 196)},
        {(char_u *)"bisque2",			RGB(238, 213, 183)},
        {(char_u *)"bisque3",			RGB(205, 183, 158)},
        {(char_u *)"bisque4",			RGB(139, 125, 107)},
        {(char_u *)"peachpuff1",		RGB(255, 218, 185)},
        {(char_u *)"peachpuff2",		RGB(238, 203, 173)},
        {(char_u *)"peachpuff3",		RGB(205, 175, 149)},
        {(char_u *)"peachpuff4",		RGB(139, 119, 101)},
        {(char_u *)"navajowhite1",		RGB(255, 222, 173)},
        {(char_u *)"navajowhite2",		RGB(238, 207, 161)},
        {(char_u *)"navajowhite3",		RGB(205, 179, 139)},
        {(char_u *)"navajowhite4",		RGB(139, 121, 94)},
        {(char_u *)"lemonchiffon1",		RGB(255, 250, 205)},
        {(char_u *)"lemonchiffon2",		RGB(238, 233, 191)},
        {(char_u *)"lemonchiffon3",		RGB(205, 201, 165)},
        {(char_u *)"lemonchiffon4",		RGB(139, 137, 112)},
        {(char_u *)"cornsilk1",			RGB(255, 248, 220)},
        {(char_u *)"cornsilk2",			RGB(238, 232, 205)},
        {(char_u *)"cornsilk3",			RGB(205, 200, 177)},
        {(char_u *)"cornsilk4",			RGB(139, 136, 120)},
        {(char_u *)"ivory1",			RGB(255, 255, 240)},
        {(char_u *)"ivory2",			RGB(238, 238, 224)},
        {(char_u *)"ivory3",			RGB(205, 205, 193)},
        {(char_u *)"ivory4",			RGB(139, 139, 131)},
        {(char_u *)"honeydew1",			RGB(240, 255, 240)},
        {(char_u *)"honeydew2",			RGB(224, 238, 224)},
        {(char_u *)"honeydew3",			RGB(193, 205, 193)},
        {(char_u *)"honeydew4",			RGB(131, 139, 131)},
        {(char_u *)"lavenderblush1",		RGB(255, 240, 245)},
        {(char_u *)"lavenderblush2",		RGB(238, 224, 229)},
        {(char_u *)"lavenderblush3",		RGB(205, 193, 197)},
        {(char_u *)"lavenderblush4",		RGB(139, 131, 134)},
        {(char_u *)"mistyrose1",		RGB(255, 228, 225)},
        {(char_u *)"mistyrose2",		RGB(238, 213, 210)},
        {(char_u *)"mistyrose3",		RGB(205, 183, 181)},
        {(char_u *)"mistyrose4",		RGB(139, 125, 123)},
        {(char_u *)"azure1",			RGB(240, 255, 255)},
        {(char_u *)"azure2",			RGB(224, 238, 238)},
        {(char_u *)"azure3",			RGB(193, 205, 205)},
        {(char_u *)"azure4",			RGB(131, 139, 139)},
        {(char_u *)"slateblue1",		RGB(131, 111, 255)},
        {(char_u *)"slateblue2",		RGB(122, 103, 238)},
        {(char_u *)"slateblue3",		RGB(105, 89, 205)},
        {(char_u *)"slateblue4",		RGB(71, 60, 139)},
        {(char_u *)"royalblue1",		RGB(72, 118, 255)},
        {(char_u *)"royalblue2",		RGB(67, 110, 238)},
        {(char_u *)"royalblue3",		RGB(58, 95, 205)},
        {(char_u *)"royalblue4",		RGB(39, 64, 139)},
        {(char_u *)"blue1",			RGB(0, 0, 255)},
        {(char_u *)"blue2",			RGB(0, 0, 238)},
        {(char_u *)"blue3",			RGB(0, 0, 205)},
        {(char_u *)"blue4",			RGB(0, 0, 139)},
        {(char_u *)"dodgerblue1",		RGB(30, 144, 255)},
        {(char_u *)"dodgerblue2",		RGB(28, 134, 238)},
        {(char_u *)"dodgerblue3",		RGB(24, 116, 205)},
        {(char_u *)"dodgerblue4",		RGB(16, 78, 139)},
        {(char_u *)"steelblue1",		RGB(99, 184, 255)},
        {(char_u *)"steelblue2",		RGB(92, 172, 238)},
        {(char_u *)"steelblue3",		RGB(79, 148, 205)},
        {(char_u *)"steelblue4",		RGB(54, 100, 139)},
        {(char_u *)"deepskyblue1",		RGB(0, 191, 255)},
        {(char_u *)"deepskyblue2",		RGB(0, 178, 238)},
        {(char_u *)"deepskyblue3",		RGB(0, 154, 205)},
        {(char_u *)"deepskyblue4",		RGB(0, 104, 139)},
        {(char_u *)"skyblue1",			RGB(135, 206, 255)},
        {(char_u *)"skyblue2",			RGB(126, 192, 238)},
        {(char_u *)"skyblue3",			RGB(108, 166, 205)},
        {(char_u *)"skyblue4",			RGB(74, 112, 139)},
        {(char_u *)"lightskyblue1",		RGB(176, 226, 255)},
        {(char_u *)"lightskyblue2",		RGB(164, 211, 238)},
        {(char_u *)"lightskyblue3",		RGB(141, 182, 205)},
        {(char_u *)"lightskyblue4",		RGB(96, 123, 139)},
        {(char_u *)"slategray1",		RGB(198, 226, 255)},
        {(char_u *)"slategray2",		RGB(185, 211, 238)},
        {(char_u *)"slategray3",		RGB(159, 182, 205)},
        {(char_u *)"slategray4",		RGB(108, 123, 139)},
        {(char_u *)"lightsteelblue1",		RGB(202, 225, 255)},
        {(char_u *)"lightsteelblue2",		RGB(188, 210, 238)},
        {(char_u *)"lightsteelblue3",		RGB(162, 181, 205)},
        {(char_u *)"lightsteelblue4",		RGB(110, 123, 139)},
        {(char_u *)"lightblue1",		RGB(191, 239, 255)},
        {(char_u *)"lightblue2",		RGB(178, 223, 238)},
        {(char_u *)"lightblue3",		RGB(154, 192, 205)},
        {(char_u *)"lightblue4",		RGB(104, 131, 139)},
        {(char_u *)"lightcyan1",		RGB(224, 255, 255)},
        {(char_u *)"lightcyan2",		RGB(209, 238, 238)},
        {(char_u *)"lightcyan3",		RGB(180, 205, 205)},
        {(char_u *)"lightcyan4",		RGB(122, 139, 139)},
        {(char_u *)"paleturquoise1",		RGB(187, 255, 255)},
        {(char_u *)"paleturquoise2",		RGB(174, 238, 238)},
        {(char_u *)"paleturquoise3",		RGB(150, 205, 205)},
        {(char_u *)"paleturquoise4",		RGB(102, 139, 139)},
        {(char_u *)"cadetblue1",		RGB(152, 245, 255)},
        {(char_u *)"cadetblue2",		RGB(142, 229, 238)},
        {(char_u *)"cadetblue3",		RGB(122, 197, 205)},
        {(char_u *)"cadetblue4",		RGB(83, 134, 139)},
        {(char_u *)"turquoise1",		RGB(0, 245, 255)},
        {(char_u *)"turquoise2",		RGB(0, 229, 238)},
        {(char_u *)"turquoise3",		RGB(0, 197, 205)},
        {(char_u *)"turquoise4",		RGB(0, 134, 139)},
        {(char_u *)"cyan1",			RGB(0, 255, 255)},
        {(char_u *)"cyan2",			RGB(0, 238, 238)},
        {(char_u *)"cyan3",			RGB(0, 205, 205)},
        {(char_u *)"cyan4",			RGB(0, 139, 139)},
        {(char_u *)"darkslategray1",		RGB(151, 255, 255)},
        {(char_u *)"darkslategray2",		RGB(141, 238, 238)},
        {(char_u *)"darkslategray3",		RGB(121, 205, 205)},
        {(char_u *)"darkslategray4",		RGB(82, 139, 139)},
        {(char_u *)"aquamarine1",		RGB(127, 255, 212)},
        {(char_u *)"aquamarine2",		RGB(118, 238, 198)},
        {(char_u *)"aquamarine3",		RGB(102, 205, 170)},
        {(char_u *)"aquamarine4",		RGB(69, 139, 116)},
        {(char_u *)"darkseagreen1",		RGB(193, 255, 193)},
        {(char_u *)"darkseagreen2",		RGB(180, 238, 180)},
        {(char_u *)"darkseagreen3",		RGB(155, 205, 155)},
        {(char_u *)"darkseagreen4",		RGB(105, 139, 105)},
        {(char_u *)"seagreen1",			RGB(84, 255, 159)},
        {(char_u *)"seagreen2",			RGB(78, 238, 148)},
        {(char_u *)"seagreen3",			RGB(67, 205, 128)},
        {(char_u *)"seagreen4",			RGB(46, 139, 87)},
        {(char_u *)"palegreen1",		RGB(154, 255, 154)},
        {(char_u *)"palegreen2",		RGB(144, 238, 144)},
        {(char_u *)"palegreen3",		RGB(124, 205, 124)},
        {(char_u *)"palegreen4",		RGB(84, 139, 84)},
        {(char_u *)"springgreen1",		RGB(0, 255, 127)},
        {(char_u *)"springgreen2",		RGB(0, 238, 118)},
        {(char_u *)"springgreen3",		RGB(0, 205, 102)},
        {(char_u *)"springgreen4",		RGB(0, 139, 69)},
        {(char_u *)"green1",			RGB(0, 255, 0)},
        {(char_u *)"green2",			RGB(0, 238, 0)},
        {(char_u *)"green3",			RGB(0, 205, 0)},
        {(char_u *)"green4",			RGB(0, 139, 0)},
        {(char_u *)"chartreuse1",		RGB(127, 255, 0)},
        {(char_u *)"chartreuse2",		RGB(118, 238, 0)},
        {(char_u *)"chartreuse3",		RGB(102, 205, 0)},
        {(char_u *)"chartreuse4",		RGB(69, 139, 0)},
        {(char_u *)"olivedrab1",		RGB(192, 255, 62)},
        {(char_u *)"olivedrab2",		RGB(179, 238, 58)},
        {(char_u *)"olivedrab3",		RGB(154, 205, 50)},
        {(char_u *)"olivedrab4",		RGB(105, 139, 34)},
        {(char_u *)"darkolivegreen1",		RGB(202, 255, 112)},
        {(char_u *)"darkolivegreen2",		RGB(188, 238, 104)},
        {(char_u *)"darkolivegreen3",		RGB(162, 205, 90)},
        {(char_u *)"darkolivegreen4",		RGB(110, 139, 61)},
        {(char_u *)"khaki1",			RGB(255, 246, 143)},
        {(char_u *)"khaki2",			RGB(238, 230, 133)},
        {(char_u *)"khaki3",			RGB(205, 198, 115)},
        {(char_u *)"khaki4",			RGB(139, 134, 78)},
        {(char_u *)"lightgoldenrod1",		RGB(255, 236, 139)},
        {(char_u *)"lightgoldenrod2",		RGB(238, 220, 130)},
        {(char_u *)"lightgoldenrod3",		RGB(205, 190, 112)},
        {(char_u *)"lightgoldenrod4",		RGB(139, 129, 76)},
        {(char_u *)"lightyellow1",		RGB(255, 255, 224)},
        {(char_u *)"lightyellow2",		RGB(238, 238, 209)},
        {(char_u *)"lightyellow3",		RGB(205, 205, 180)},
        {(char_u *)"lightyellow4",		RGB(139, 139, 122)},
        {(char_u *)"yellow1",			RGB(255, 255, 0)},
        {(char_u *)"yellow2",			RGB(238, 238, 0)},
        {(char_u *)"yellow3",			RGB(205, 205, 0)},
        {(char_u *)"yellow4",			RGB(139, 139, 0)},
        {(char_u *)"gold1",			RGB(255, 215, 0)},
        {(char_u *)"gold2",			RGB(238, 201, 0)},
        {(char_u *)"gold3",			RGB(205, 173, 0)},
        {(char_u *)"gold4",			RGB(139, 117, 0)},
        {(char_u *)"goldenrod1",		RGB(255, 193, 37)},
        {(char_u *)"goldenrod2",		RGB(238, 180, 34)},
        {(char_u *)"goldenrod3",		RGB(205, 155, 29)},
        {(char_u *)"goldenrod4",		RGB(139, 105, 20)},
        {(char_u *)"darkgoldenrod1",		RGB(255, 185, 15)},
        {(char_u *)"darkgoldenrod2",		RGB(238, 173, 14)},
        {(char_u *)"darkgoldenrod3",		RGB(205, 149, 12)},
        {(char_u *)"darkgoldenrod4",		RGB(139, 101, 8)},
        {(char_u *)"rosybrown1",		RGB(255, 193, 193)},
        {(char_u *)"rosybrown2",		RGB(238, 180, 180)},
        {(char_u *)"rosybrown3",		RGB(205, 155, 155)},
        {(char_u *)"rosybrown4",		RGB(139, 105, 105)},
        {(char_u *)"indianred1",		RGB(255, 106, 106)},
        {(char_u *)"indianred2",		RGB(238, 99, 99)},
        {(char_u *)"indianred3",		RGB(205, 85, 85)},
        {(char_u *)"indianred4",		RGB(139, 58, 58)},
        {(char_u *)"sienna1",			RGB(255, 130, 71)},
        {(char_u *)"sienna2",			RGB(238, 121, 66)},
        {(char_u *)"sienna3",			RGB(205, 104, 57)},
        {(char_u *)"sienna4",			RGB(139, 71, 38)},
        {(char_u *)"burlywood1",		RGB(255, 211, 155)},
        {(char_u *)"burlywood2",		RGB(238, 197, 145)},
        {(char_u *)"burlywood3",		RGB(205, 170, 125)},
        {(char_u *)"burlywood4",		RGB(139, 115, 85)},
        {(char_u *)"wheat1",			RGB(255, 231, 186)},
        {(char_u *)"wheat2",			RGB(238, 216, 174)},
        {(char_u *)"wheat3",			RGB(205, 186, 150)},
        {(char_u *)"wheat4",			RGB(139, 126, 102)},
        {(char_u *)"tan1",			RGB(255, 165, 79)},
        {(char_u *)"tan2",			RGB(238, 154, 73)},
        {(char_u *)"tan3",			RGB(205, 133, 63)},
        {(char_u *)"tan4",			RGB(139, 90, 43)},
        {(char_u *)"chocolate1",		RGB(255, 127, 36)},
        {(char_u *)"chocolate2",		RGB(238, 118, 33)},
        {(char_u *)"chocolate3",		RGB(205, 102, 29)},
        {(char_u *)"chocolate4",		RGB(139, 69, 19)},
        {(char_u *)"firebrick1",		RGB(255, 48, 48)},
        {(char_u *)"firebrick2",		RGB(238, 44, 44)},
        {(char_u *)"firebrick3",		RGB(205, 38, 38)},
        {(char_u *)"firebrick4",		RGB(139, 26, 26)},
        {(char_u *)"brown1",			RGB(255, 64, 64)},
        {(char_u *)"brown2",			RGB(238, 59, 59)},
        {(char_u *)"brown3",			RGB(205, 51, 51)},
        {(char_u *)"brown4",			RGB(139, 35, 35)},
        {(char_u *)"salmon1",			RGB(255, 140, 105)},
        {(char_u *)"salmon2",			RGB(238, 130, 98)},
        {(char_u *)"salmon3",			RGB(205, 112, 84)},
        {(char_u *)"salmon4",			RGB(139, 76, 57)},
        {(char_u *)"lightsalmon1",		RGB(255, 160, 122)},
        {(char_u *)"lightsalmon2",		RGB(238, 149, 114)},
        {(char_u *)"lightsalmon3",		RGB(205, 129, 98)},
        {(char_u *)"lightsalmon4",		RGB(139, 87, 66)},
        {(char_u *)"orange1",			RGB(255, 165, 0)},
        {(char_u *)"orange2",			RGB(238, 154, 0)},
        {(char_u *)"orange3",			RGB(205, 133, 0)},
        {(char_u *)"orange4",			RGB(139, 90, 0)},
        {(char_u *)"darkorange1",		RGB(255, 127, 0)},
        {(char_u *)"darkorange2",		RGB(238, 118, 0)},
        {(char_u *)"darkorange3",		RGB(205, 102, 0)},
        {(char_u *)"darkorange4",		RGB(139, 69, 0)},
        {(char_u *)"coral1",			RGB(255, 114, 86)},
        {(char_u *)"coral2",			RGB(238, 106, 80)},
        {(char_u *)"coral3",			RGB(205, 91, 69)},
        {(char_u *)"coral4",			RGB(139, 62, 47)},
        {(char_u *)"tomato1",			RGB(255, 99, 71)},
        {(char_u *)"tomato2",			RGB(238, 92, 66)},
        {(char_u *)"tomato3",			RGB(205, 79, 57)},
        {(char_u *)"tomato4",			RGB(139, 54, 38)},
        {(char_u *)"orangered1",		RGB(255, 69, 0)},
        {(char_u *)"orangered2",		RGB(238, 64, 0)},
        {(char_u *)"orangered3",		RGB(205, 55, 0)},
        {(char_u *)"orangered4",		RGB(139, 37, 0)},
        {(char_u *)"red1",			RGB(255, 0, 0)},
        {(char_u *)"red2",			RGB(238, 0, 0)},
        {(char_u *)"red3",			RGB(205, 0, 0)},
        {(char_u *)"red4",			RGB(139, 0, 0)},
        {(char_u *)"deeppink1",			RGB(255, 20, 147)},
        {(char_u *)"deeppink2",			RGB(238, 18, 137)},
        {(char_u *)"deeppink3",			RGB(205, 16, 118)},
        {(char_u *)"deeppink4",			RGB(139, 10, 80)},
        {(char_u *)"hotpink1",			RGB(255, 110, 180)},
        {(char_u *)"hotpink2",			RGB(238, 106, 167)},
        {(char_u *)"hotpink3",			RGB(205, 96, 144)},
        {(char_u *)"hotpink4",			RGB(139, 58, 98)},
        {(char_u *)"pink1",			RGB(255, 181, 197)},
        {(char_u *)"pink2",			RGB(238, 169, 184)},
        {(char_u *)"pink3",			RGB(205, 145, 158)},
        {(char_u *)"pink4",			RGB(139, 99, 108)},
        {(char_u *)"lightpink1",		RGB(255, 174, 185)},
        {(char_u *)"lightpink2",		RGB(238, 162, 173)},
        {(char_u *)"lightpink3",		RGB(205, 140, 149)},
        {(char_u *)"lightpink4",		RGB(139, 95, 101)},
        {(char_u *)"palevioletred1",		RGB(255, 130, 171)},
        {(char_u *)"palevioletred2",		RGB(238, 121, 159)},
        {(char_u *)"palevioletred3",		RGB(205, 104, 137)},
        {(char_u *)"palevioletred4",		RGB(139, 71, 93)},
        {(char_u *)"maroon1",			RGB(255, 52, 179)},
        {(char_u *)"maroon2",			RGB(238, 48, 167)},
        {(char_u *)"maroon3",			RGB(205, 41, 144)},
        {(char_u *)"maroon4",			RGB(139, 28, 98)},
        {(char_u *)"violetred1",		RGB(255, 62, 150)},
        {(char_u *)"violetred2",		RGB(238, 58, 140)},
        {(char_u *)"violetred3",		RGB(205, 50, 120)},
        {(char_u *)"violetred4",		RGB(139, 34, 82)},
        {(char_u *)"magenta1",			RGB(255, 0, 255)},
        {(char_u *)"magenta2",			RGB(238, 0, 238)},
        {(char_u *)"magenta3",			RGB(205, 0, 205)},
        {(char_u *)"magenta4",			RGB(139, 0, 139)},
        {(char_u *)"orchid1",			RGB(255, 131, 250)},
        {(char_u *)"orchid2",			RGB(238, 122, 233)},
        {(char_u *)"orchid3",			RGB(205, 105, 201)},
        {(char_u *)"orchid4",			RGB(139, 71, 137)},
        {(char_u *)"plum1",			RGB(255, 187, 255)},
        {(char_u *)"plum2",			RGB(238, 174, 238)},
        {(char_u *)"plum3",			RGB(205, 150, 205)},
        {(char_u *)"plum4",			RGB(139, 102, 139)},
        {(char_u *)"mediumorchid1",		RGB(224, 102, 255)},
        {(char_u *)"mediumorchid2",		RGB(209, 95, 238)},
        {(char_u *)"mediumorchid3",		RGB(180, 82, 205)},
        {(char_u *)"mediumorchid4",		RGB(122, 55, 139)},
        {(char_u *)"darkorchid1",		RGB(191, 62, 255)},
        {(char_u *)"darkorchid2",		RGB(178, 58, 238)},
        {(char_u *)"darkorchid3",		RGB(154, 50, 205)},
        {(char_u *)"darkorchid4",		RGB(104, 34, 139)},
        {(char_u *)"purple1",			RGB(155, 48, 255)},
        {(char_u *)"purple2",			RGB(145, 44, 238)},
        {(char_u *)"purple3",			RGB(125, 38, 205)},
        {(char_u *)"purple4",			RGB(85, 26, 139)},
        {(char_u *)"mediumpurple1",		RGB(171, 130, 255)},
        {(char_u *)"mediumpurple2",		RGB(159, 121, 238)},
        {(char_u *)"mediumpurple3",		RGB(137, 104, 205)},
        {(char_u *)"mediumpurple4",		RGB(93, 71, 139)},
        {(char_u *)"thistle1",			RGB(255, 225, 255)},
        {(char_u *)"thistle2",			RGB(238, 210, 238)},
        {(char_u *)"thistle3",			RGB(205, 181, 205)},
        {(char_u *)"thistle4",			RGB(139, 123, 139)},
        {(char_u *)"gray0",			RGB(0, 0, 0)},
        {(char_u *)"grey0",			RGB(0, 0, 0)},
        {(char_u *)"gray1",			RGB(3, 3, 3)},
        {(char_u *)"grey1",			RGB(3, 3, 3)},
        {(char_u *)"gray2",			RGB(5, 5, 5)},
        {(char_u *)"grey2",			RGB(5, 5, 5)},
        {(char_u *)"gray3",			RGB(8, 8, 8)},
        {(char_u *)"grey3",			RGB(8, 8, 8)},
        {(char_u *)"gray4",			RGB(10, 10, 10)},
        {(char_u *)"grey4",			RGB(10, 10, 10)},
        {(char_u *)"gray5",			RGB(13, 13, 13)},
        {(char_u *)"grey5",			RGB(13, 13, 13)},
        {(char_u *)"gray6",			RGB(15, 15, 15)},
        {(char_u *)"grey6",			RGB(15, 15, 15)},
        {(char_u *)"gray7",			RGB(18, 18, 18)},
        {(char_u *)"grey7",			RGB(18, 18, 18)},
        {(char_u *)"gray8",			RGB(20, 20, 20)},
        {(char_u *)"grey8",			RGB(20, 20, 20)},
        {(char_u *)"gray9",			RGB(23, 23, 23)},
        {(char_u *)"grey9",			RGB(23, 23, 23)},
        {(char_u *)"gray10",			RGB(26, 26, 26)},
        {(char_u *)"grey10",			RGB(26, 26, 26)},
        {(char_u *)"gray11",			RGB(28, 28, 28)},
        {(char_u *)"grey11",			RGB(28, 28, 28)},
        {(char_u *)"gray12",			RGB(31, 31, 31)},
        {(char_u *)"grey12",			RGB(31, 31, 31)},
        {(char_u *)"gray13",			RGB(33, 33, 33)},
        {(char_u *)"grey13",			RGB(33, 33, 33)},
        {(char_u *)"gray14",			RGB(36, 36, 36)},
        {(char_u *)"grey14",			RGB(36, 36, 36)},
        {(char_u *)"gray15",			RGB(38, 38, 38)},
        {(char_u *)"grey15",			RGB(38, 38, 38)},
        {(char_u *)"gray16",			RGB(41, 41, 41)},
        {(char_u *)"grey16",			RGB(41, 41, 41)},
        {(char_u *)"gray17",			RGB(43, 43, 43)},
        {(char_u *)"grey17",			RGB(43, 43, 43)},
        {(char_u *)"gray18",			RGB(46, 46, 46)},
        {(char_u *)"grey18",			RGB(46, 46, 46)},
        {(char_u *)"gray19",			RGB(48, 48, 48)},
        {(char_u *)"grey19",			RGB(48, 48, 48)},
        {(char_u *)"gray20",			RGB(51, 51, 51)},
        {(char_u *)"grey20",			RGB(51, 51, 51)},
        {(char_u *)"gray21",			RGB(54, 54, 54)},
        {(char_u *)"grey21",			RGB(54, 54, 54)},
        {(char_u *)"gray22",			RGB(56, 56, 56)},
        {(char_u *)"grey22",			RGB(56, 56, 56)},
        {(char_u *)"gray23",			RGB(59, 59, 59)},
        {(char_u *)"grey23",			RGB(59, 59, 59)},
        {(char_u *)"gray24",			RGB(61, 61, 61)},
        {(char_u *)"grey24",			RGB(61, 61, 61)},
        {(char_u *)"gray25",			RGB(64, 64, 64)},
        {(char_u *)"grey25",			RGB(64, 64, 64)},
        {(char_u *)"gray26",			RGB(66, 66, 66)},
        {(char_u *)"grey26",			RGB(66, 66, 66)},
        {(char_u *)"gray27",			RGB(69, 69, 69)},
        {(char_u *)"grey27",			RGB(69, 69, 69)},
        {(char_u *)"gray28",			RGB(71, 71, 71)},
        {(char_u *)"grey28",			RGB(71, 71, 71)},
        {(char_u *)"gray29",			RGB(74, 74, 74)},
        {(char_u *)"grey29",			RGB(74, 74, 74)},
        {(char_u *)"gray30",			RGB(77, 77, 77)},
        {(char_u *)"grey30",			RGB(77, 77, 77)},
        {(char_u *)"gray31",			RGB(79, 79, 79)},
        {(char_u *)"grey31",			RGB(79, 79, 79)},
        {(char_u *)"gray32",			RGB(82, 82, 82)},
        {(char_u *)"grey32",			RGB(82, 82, 82)},
        {(char_u *)"gray33",			RGB(84, 84, 84)},
        {(char_u *)"grey33",			RGB(84, 84, 84)},
        {(char_u *)"gray34",			RGB(87, 87, 87)},
        {(char_u *)"grey34",			RGB(87, 87, 87)},
        {(char_u *)"gray35",			RGB(89, 89, 89)},
        {(char_u *)"grey35",			RGB(89, 89, 89)},
        {(char_u *)"gray36",			RGB(92, 92, 92)},
        {(char_u *)"grey36",			RGB(92, 92, 92)},
        {(char_u *)"gray37",			RGB(94, 94, 94)},
        {(char_u *)"grey37",			RGB(94, 94, 94)},
        {(char_u *)"gray38",			RGB(97, 97, 97)},
        {(char_u *)"grey38",			RGB(97, 97, 97)},
        {(char_u *)"gray39",			RGB(99, 99, 99)},
        {(char_u *)"grey39",			RGB(99, 99, 99)},
        {(char_u *)"gray40",			RGB(102, 102, 102)},
        {(char_u *)"grey40",			RGB(102, 102, 102)},
        {(char_u *)"gray41",			RGB(105, 105, 105)},
        {(char_u *)"grey41",			RGB(105, 105, 105)},
        {(char_u *)"gray42",			RGB(107, 107, 107)},
        {(char_u *)"grey42",			RGB(107, 107, 107)},
        {(char_u *)"gray43",			RGB(110, 110, 110)},
        {(char_u *)"grey43",			RGB(110, 110, 110)},
        {(char_u *)"gray44",			RGB(112, 112, 112)},
        {(char_u *)"grey44",			RGB(112, 112, 112)},
        {(char_u *)"gray45",			RGB(115, 115, 115)},
        {(char_u *)"grey45",			RGB(115, 115, 115)},
        {(char_u *)"gray46",			RGB(117, 117, 117)},
        {(char_u *)"grey46",			RGB(117, 117, 117)},
        {(char_u *)"gray47",			RGB(120, 120, 120)},
        {(char_u *)"grey47",			RGB(120, 120, 120)},
        {(char_u *)"gray48",			RGB(122, 122, 122)},
        {(char_u *)"grey48",			RGB(122, 122, 122)},
        {(char_u *)"gray49",			RGB(125, 125, 125)},
        {(char_u *)"grey49",			RGB(125, 125, 125)},
        {(char_u *)"gray50",			RGB(127, 127, 127)},
        {(char_u *)"grey50",			RGB(127, 127, 127)},
        {(char_u *)"gray51",			RGB(130, 130, 130)},
        {(char_u *)"grey51",			RGB(130, 130, 130)},
        {(char_u *)"gray52",			RGB(133, 133, 133)},
        {(char_u *)"grey52",			RGB(133, 133, 133)},
        {(char_u *)"gray53",			RGB(135, 135, 135)},
        {(char_u *)"grey53",			RGB(135, 135, 135)},
        {(char_u *)"gray54",			RGB(138, 138, 138)},
        {(char_u *)"grey54",			RGB(138, 138, 138)},
        {(char_u *)"gray55",			RGB(140, 140, 140)},
        {(char_u *)"grey55",			RGB(140, 140, 140)},
        {(char_u *)"gray56",			RGB(143, 143, 143)},
        {(char_u *)"grey56",			RGB(143, 143, 143)},
        {(char_u *)"gray57",			RGB(145, 145, 145)},
        {(char_u *)"grey57",			RGB(145, 145, 145)},
        {(char_u *)"gray58",			RGB(148, 148, 148)},
        {(char_u *)"grey58",			RGB(148, 148, 148)},
        {(char_u *)"gray59",			RGB(150, 150, 150)},
        {(char_u *)"grey59",			RGB(150, 150, 150)},
        {(char_u *)"gray60",			RGB(153, 153, 153)},
        {(char_u *)"grey60",			RGB(153, 153, 153)},
        {(char_u *)"gray61",			RGB(156, 156, 156)},
        {(char_u *)"grey61",			RGB(156, 156, 156)},
        {(char_u *)"gray62",			RGB(158, 158, 158)},
        {(char_u *)"grey62",			RGB(158, 158, 158)},
        {(char_u *)"gray63",			RGB(161, 161, 161)},
        {(char_u *)"grey63",			RGB(161, 161, 161)},
        {(char_u *)"gray64",			RGB(163, 163, 163)},
        {(char_u *)"grey64",			RGB(163, 163, 163)},
        {(char_u *)"gray65",			RGB(166, 166, 166)},
        {(char_u *)"grey65",			RGB(166, 166, 166)},
        {(char_u *)"gray66",			RGB(168, 168, 168)},
        {(char_u *)"grey66",			RGB(168, 168, 168)},
        {(char_u *)"gray67",			RGB(171, 171, 171)},
        {(char_u *)"grey67",			RGB(171, 171, 171)},
        {(char_u *)"gray68",			RGB(173, 173, 173)},
        {(char_u *)"grey68",			RGB(173, 173, 173)},
        {(char_u *)"gray69",			RGB(176, 176, 176)},
        {(char_u *)"grey69",			RGB(176, 176, 176)},
        {(char_u *)"gray70",			RGB(179, 179, 179)},
        {(char_u *)"grey70",			RGB(179, 179, 179)},
        {(char_u *)"gray71",			RGB(181, 181, 181)},
        {(char_u *)"grey71",			RGB(181, 181, 181)},
        {(char_u *)"gray72",			RGB(184, 184, 184)},
        {(char_u *)"grey72",			RGB(184, 184, 184)},
        {(char_u *)"gray73",			RGB(186, 186, 186)},
        {(char_u *)"grey73",			RGB(186, 186, 186)},
        {(char_u *)"gray74",			RGB(189, 189, 189)},
        {(char_u *)"grey74",			RGB(189, 189, 189)},
        {(char_u *)"gray75",			RGB(191, 191, 191)},
        {(char_u *)"grey75",			RGB(191, 191, 191)},
        {(char_u *)"gray76",			RGB(194, 194, 194)},
        {(char_u *)"grey76",			RGB(194, 194, 194)},
        {(char_u *)"gray77",			RGB(196, 196, 196)},
        {(char_u *)"grey77",			RGB(196, 196, 196)},
        {(char_u *)"gray78",			RGB(199, 199, 199)},
        {(char_u *)"grey78",			RGB(199, 199, 199)},
        {(char_u *)"gray79",			RGB(201, 201, 201)},
        {(char_u *)"grey79",			RGB(201, 201, 201)},
        {(char_u *)"gray80",			RGB(204, 204, 204)},
        {(char_u *)"grey80",			RGB(204, 204, 204)},
        {(char_u *)"gray81",			RGB(207, 207, 207)},
        {(char_u *)"grey81",			RGB(207, 207, 207)},
        {(char_u *)"gray82",			RGB(209, 209, 209)},
        {(char_u *)"grey82",			RGB(209, 209, 209)},
        {(char_u *)"gray83",			RGB(212, 212, 212)},
        {(char_u *)"grey83",			RGB(212, 212, 212)},
        {(char_u *)"gray84",			RGB(214, 214, 214)},
        {(char_u *)"grey84",			RGB(214, 214, 214)},
        {(char_u *)"gray85",			RGB(217, 217, 217)},
        {(char_u *)"grey85",			RGB(217, 217, 217)},
        {(char_u *)"gray86",			RGB(219, 219, 219)},
        {(char_u *)"grey86",			RGB(219, 219, 219)},
        {(char_u *)"gray87",			RGB(222, 222, 222)},
        {(char_u *)"grey87",			RGB(222, 222, 222)},
        {(char_u *)"gray88",			RGB(224, 224, 224)},
        {(char_u *)"grey88",			RGB(224, 224, 224)},
        {(char_u *)"gray89",			RGB(227, 227, 227)},
        {(char_u *)"grey89",			RGB(227, 227, 227)},
        {(char_u *)"gray90",			RGB(229, 229, 229)},
        {(char_u *)"grey90",			RGB(229, 229, 229)},
        {(char_u *)"gray91",			RGB(232, 232, 232)},
        {(char_u *)"grey91",			RGB(232, 232, 232)},
        {(char_u *)"gray92",			RGB(235, 235, 235)},
        {(char_u *)"grey92",			RGB(235, 235, 235)},
        {(char_u *)"gray93",			RGB(237, 237, 237)},
        {(char_u *)"grey93",			RGB(237, 237, 237)},
        {(char_u *)"gray94",			RGB(240, 240, 240)},
        {(char_u *)"grey94",			RGB(240, 240, 240)},
        {(char_u *)"gray95",			RGB(242, 242, 242)},
        {(char_u *)"grey95",			RGB(242, 242, 242)},
        {(char_u *)"gray96",			RGB(245, 245, 245)},
        {(char_u *)"grey96",			RGB(245, 245, 245)},
        {(char_u *)"gray97",			RGB(247, 247, 247)},
        {(char_u *)"grey97",			RGB(247, 247, 247)},
        {(char_u *)"gray98",			RGB(250, 250, 250)},
        {(char_u *)"grey98",			RGB(250, 250, 250)},
        {(char_u *)"gray99",			RGB(252, 252, 252)},
        {(char_u *)"grey99",			RGB(252, 252, 252)},
        {(char_u *)"gray100",			RGB(255, 255, 255)},
        {(char_u *)"grey100",			RGB(255, 255, 255)},
        {(char_u *)"dark grey",			RGB(169, 169, 169)},
        {(char_u *)"darkgrey",			RGB(169, 169, 169)},
        {(char_u *)"dark gray",			RGB(169, 169, 169)},
        {(char_u *)"darkgray",			RGB(169, 169, 169)},
        {(char_u *)"dark blue",			RGB(0, 0, 139)},
        {(char_u *)"darkblue",			RGB(0, 0, 139)},
        {(char_u *)"dark cyan",			RGB(0, 139, 139)},
        {(char_u *)"darkcyan",			RGB(0, 139, 139)},
        {(char_u *)"dark magenta",		RGB(139, 0, 139)},
        {(char_u *)"darkmagenta",		RGB(139, 0, 139)},
        {(char_u *)"dark red",			RGB(139, 0, 0)},
        {(char_u *)"darkred",			RGB(139, 0, 0)},
        {(char_u *)"light green",		RGB(144, 238, 144)},
        {(char_u *)"lightgreen",		RGB(144, 238, 144)},
        {(char_u *)"crimson",			RGB(220, 20, 60)},
        {(char_u *)"indigo",			RGB(75, 0, 130)},
        {(char_u *)"olive",			RGB(128, 128, 0)},
        {(char_u *)"rebecca purple",		RGB(102, 51, 153)},
        {(char_u *)"rebeccapurple",		RGB(102, 51, 153)},
        {(char_u *)"silver",			RGB(192, 192, 192)},
        {(char_u *)"teal",			RGB(0, 128, 128)},
        {(char_u *)"darkyellow",		RGB(0x8B, 0x8B, 0x00)}, /* No X11 */
        {(char_u *)"lightmagenta",		RGB(0xFF, 0x8B, 0xFF)}, /* No X11 */
        {(char_u *)"lightred",			RGB(0xFF, 0x8B, 0x8B)}, /* No X11 */
    };

    for (char_u *p = name; *p != '\0'; ++p) {
        *p = tolower(*p);
    }

    int const len = sizeof(builtin_color_table) / sizeof(struct rgbcolor_table);
    for (int i = 0; i < len; ++i) {
        if (STRICMP(name, builtin_color_table[i].name) == 0) {
            return builtin_color_table[i].color;
        }
    }
    return INVALCOLOR;
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
    int const len = STRLEN(name);
    if (len == 0) {
        return INVALCOLOR;
    }

    if (*name != '#') {
        return gui_name_to_builtin_color(name);
    }

    if (len != 7 && len != 4) {
        return INVALCOLOR;
    }

    for (int i = 1; i < len; ++i) {
        if (!vim_isxdigit(name[i])) {
            return INVALCOLOR;
        }
    }

    int const is_short = len == 4;

    if (len == 4) {
        // "#aaa" -> "aaaaaa"
        char rgb[7];
        for (int i = 0; i < 3; ++i) {
            char_u c = name[i+1];
            rgb[i * 2] = c;
            rgb[i * 2 + 1] = c;
        }
        rgb[6] = '\0';
        return (guicolor_T)strtol(rgb, NULL, 16);
    } else {
        return (guicolor_T)strtol((char *)name + 1, NULL, 16);
    }
}

guicolor_T
gui_mch_get_rgb_color(int r, int g, int b)
{
    return RGB(r, g, b);
}

static char
int_to_hex_char(int i)
{
    if (0 <= i && i <= 9) {
        return '0' + i;
    } else {
        return 'a' + i - 10;
    }
}

// 0xrrggbb -> "#rrggbb\0"
static void
set_color_as_code(guicolor_T color, char *code)
{
    code[0] = '#';
    for (int i = 3; i > 0; --i) {
        int hex = color & 0xff;
        code[i * 2] = int_to_hex_char(hex & 0xf);
        hex >>= 4;
        code[i * 2 - 1] = int_to_hex_char(hex & 0xf);
        color >>= 8;
    }
    code[7] = '\0';
}

/*
 * Set the current text foreground color.
 */
void
gui_mch_set_fg_color(guicolor_T color)
{
    if (color == gui.fg_color) {
        return;
    }

    GUI_WASM_DBG("#%lx", color);

    gui.fg_color = color;
    set_color_as_code(color, gui.fg_color_code);
    vimwasm_set_fg_color(gui.fg_color_code);
}

/*
 * Set the current text background color.
 */
void
gui_mch_set_bg_color(guicolor_T color)
{
    if (color == gui.bg_color) {
        return;
    }

    GUI_WASM_DBG("#%lx", color);

    gui.bg_color = color;
    set_color_as_code(color, gui.bg_color_code);
    vimwasm_set_bg_color(gui.bg_color_code);
}

/*
 * Set the current text special color.
 */
void
gui_mch_set_sp_color(guicolor_T color)
{
    if (color == gui.sp_color) {
        return;
    }

    GUI_WASM_DBG("#%lx", color);

    gui.sp_color = color;
    set_color_as_code(color, gui.sp_color_code);
    vimwasm_set_sp_color(gui.sp_color_code);
}

static void
draw_rect(int row, int col, int row2, int col2, char *color_code, int filled)
{
    GUI_WASM_DBG("%s row=%d col=%d row2=%d col2=%d filled=%d", color_code, row, col, row2, col2, filled);

    int x = gui.char_width * col;
    int y = gui.char_height * row;
    int w = gui.char_width * (col2 - col + 1);
    int h = gui.char_height * (row2 - row + 1);
    vimwasm_draw_rect(x, y, w, h, color_code, filled);
}

void
gui_mch_draw_string(int row, int col, char_u *s, int len, int flags)
{
    if (!(flags&DRAW_TRANSP)) {
        draw_rect(row, col, row, col + len - 1, gui.bg_color_code, TRUE);
    }

    // TODO?: Should consider flags&DRAW_CURSOR?

    int should_draw_text = FALSE;
    for (int i = 0; i < len; ++i) {
        if (s[i] != ' ') {
            should_draw_text = TRUE;
            break;
        }
    }

    if (!should_draw_text) {
        return;
    }

    GUI_WASM_DBG("'%.*s' row=%d col=%d flags=%x", len, s, row, col, flags);

    vimwasm_draw_text(
        gui.font_height,
        gui.char_height,
        gui.char_width,
        gui.char_width * col,
        gui.char_height * row,
        (char *)s,
        len,
        flags&DRAW_BOLD,
        flags&DRAW_UNDERL,
        flags&DRAW_UNDERC,
        flags&DRAW_STRIKE);
}

/*
 * Return OK if the key with the termcap name "name" is supported.
 */
int
gui_mch_haskey(char_u *name)
{
    return vimwasm_is_supported_key((char*)name) ? OK : FAIL;
}

void
gui_mch_beep(void)
{
    // TODO: but I don't like beep...
}

void
gui_mch_flash(int msec)
{
    // TODO: but I don't like visual bell...
}

/*
 * Invert a rectangle from row r, column c, for nr rows and nc columns.
 */
void
gui_mch_invert_rectangle(int row, int col, int rows, int cols)
{
    GUI_WASM_DBG("row=%d col=%d rows=%d cols=%d", row, col, rows, cols);

    int const x = gui.char_width * col;
    int const y = gui.char_height * row;
    int const w = gui.char_width * cols;
    int const h = gui.char_height * rows;

    vimwasm_invert_rect(x, y, w, h);
}

/*
 * Iconify the GUI window.
 */
void
gui_mch_iconify(void)
{
    // Nothing to do
}

#if defined(FEAT_EVAL) || defined(PROTO)
/*
 * Bring the Vim window to the foreground.
 */
void
gui_mch_set_foreground(void)
{
    // Nothing to do
}
#endif

/*
 * Draw a cursor without focus.
 */
void
gui_mch_draw_hollow_cursor(guicolor_T color)
{
    GUI_WASM_DBG("#%lx row=%d col=%d", color, gui.row, gui.col);

    gui_mch_set_fg_color(color);
    int const r = gui.row;
    int const c = gui.col;
    draw_rect(r, c, r + 1, c + 1, gui.fg_color_code, FALSE);
}

/*
 * Draw part of a cursor, only w pixels wide, and h pixels high.
 */
void
gui_mch_draw_part_cursor(int w, int h, guicolor_T color)
{
    GUI_WASM_DBG("#%lx width=%d height=%d row=%d col=%d", color, w, h, gui.row, gui.col);

    gui_mch_set_fg_color(color);
    int const x = gui.char_width * gui.col;
    int const y = gui.char_height * gui.row;

    // May need to use char_height instead of 'h' since the height does not consider line-height.
    vimwasm_draw_rect(x, y, w, h, gui.fg_color_code, TRUE);
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
    // Nothing to do since all UI changes are drawn emediately
}

/*
 * GUI input routine called by gui_wait_for_chars().  Waits for a character
 * from the keyboard.
 *  wtime == -1     Wait forever.
 *  wtime == 0      This should never happen.
 *  wtime > 0       Wait wtime milliseconds for a character.
 * Returns OK if a character was found to be available within the given time,
 * or FAIL otherwise.
 */
int
gui_mch_wait_for_chars(int wtime)
{
    int elapsed;

    if (input_available()) {
        return OK;
    }

    while(1) {
        // vimwasm_wait_for_event() returns elapsed time by the wait in milliseconds
        elapsed = vimwasm_wait_for_event(wtime);

        if (input_available()) {
            return OK;
        }

        if (wtime >= 0) {
            if (elapsed >= wtime) {
                return FAIL;
            }

            wtime -= elapsed;
        }
    }
}

/* Flush any output to the screen */
void
gui_mch_flush(void)
{
    // Nothing to do
}

/*
 * Clear a rectangular region of the screen from text pos (row1, col1) to
 * (row2, col2) inclusive.
 */
void
gui_mch_clear_block(int row1, int col1, int row2, int col2)
{
    GUI_WASM_DBG("#%lx row=%d col=%d row2=%d col2=%d", gui.back_pixel, row1, col1, row2, col2);

    gui_mch_set_bg_color(gui.back_pixel);
    draw_rect(row1, col1, row2, col2, gui.bg_color_code, TRUE);
}

/*
 * Clear the whole text window.
 */
void
gui_mch_clear_all(void)
{
    GUI_WASM_DBG("#%lx", gui.back_pixel);

    // May need to create special API vimwasm_clear_all() since clear_rect() trims coordinates
    // by Math.floor(). Due to device pixel ratio, bottom 1px may not be cleared.
    gui_mch_clear_block(0, 0, Rows, Columns);
}

/*
 * Delete the given number of lines from the given row, scrolling up any
 * text further down within the scroll region.
 *
 *  example:
 *    row: 2, num_lines: 2, top: 1, bottom: 4
 *    _: cleared
 *
 *   Before:
 *    1 aaaaa
 *    2 bbbbb
 *    3 ccccc
 *    4 ddddd
 *
 *   After:
 *    1 aaaaa
 *    2 ddddd
 *    3 _____
 *    4 _____
 */
void
gui_mch_delete_lines(int row, int num_lines)
{
    int const cw = gui.char_width;
    int const ch = gui.char_height;
    int const left = gui.scroll_region_left;
    int const bottom = gui.scroll_region_bot;
    int const right = gui.scroll_region_right;
    int const x = left * cw;
    int const sy = (row + num_lines) * ch;
    int const dy = row * ch;
    int const w = (right - left + 1) * cw;
    int const h = (bottom - row - num_lines + 1) * ch;

    GUI_WASM_DBG("row=%d num_lines=%d left=%d right=%d bottom=%d", row, num_lines, left, right, bottom);

    vimwasm_image_scroll(x, sy, dy, w, h);
    gui_mch_clear_block(bottom - num_lines + 1, left, bottom, right);
}

/*
 * Insert the given number of lines before the given row, scrolling down any
 * following text within the scroll region.
 *
 *  example:
 *    row: 2, num_lines: 2, top: 1, bottom: 4
 *    _: cleared
 *
 *   Before:
 *    1 aaaaa
 *    2 bbbbb
 *    3 ccccc
 *    4 ddddd
 *
 *   After:
 *    1 aaaaa
 *    2 _____
 *    3 _____
 *    4 bbbbb
 */
void
gui_mch_insert_lines(int row, int num_lines)
{
    int const cw = gui.char_width;
    int const ch = gui.char_height;
    int const left = gui.scroll_region_left;
    int const bottom = gui.scroll_region_bot;
    int const right = gui.scroll_region_right;
    int const x = left * cw;
    int const sy = row * ch;
    int const dy = (row + num_lines) * ch;
    int const w = (right - left + 1) * cw;
    int const h = (bottom - (row + num_lines) + 1) * ch;

    GUI_WASM_DBG("row=%d num_lines=%d left=%d right=%d bottom=%d", row, num_lines, left, right, bottom);

    vimwasm_image_scroll(x, sy, dy, w, h);
    gui_mch_clear_block(row, left, row + num_lines - 1, right);
}

/*
 * Get the current selection and put it in the clipboard register.
 */
void
clip_mch_request_selection(Clipboard_T *cbd)
{
    // TODO: Clipboard support
}

/*
 * Make vim NOT the owner of the current selection.
 */
void
clip_mch_lose_selection(Clipboard_T *cbd)
{
    // TODO: Clipboard support
}

/*
 * Make vim the owner of the current selection.  Return OK upon success.
 */
int
clip_mch_own_selection(Clipboard_T *cbd)
{
    // In browser, there is no ownership system for clipboard.
    // Application can always access to clipboard.
    return OK;
}

/*
 * Send the current selection to the clipboard.
 */
void
clip_mch_set_selection(Clipboard_T *cbd)
{
    char_u *text = NULL;
    long_u size;
    int type;

    if (!clipboard_available) {
        return;
    }

    if (!cbd->owned) {
        return;
    }

    clip_get_selection(cbd);

    type = clip_convert_selection(&text, &size, cbd);

    if (type < 0) {
        GUI_WASM_DBG("Could not convert * register to GUI string. type=%d\n", type);
        return;
    }

    GUI_WASM_DBG("Selection text=%s\n", (char *)text);

    vimwasm_write_clipboard((char *)text, (long_u)size);
    vim_free(text);
}

void
gui_mch_set_text_area_pos(int x, int y, int w, int h)
{
    // Wasm backend draws text area to <canvas> so nothing to do
}

/*
 * Menu stuff.
 */

void
gui_mch_enable_menu(int flag)
{
    // Menu is always hidden (and always active).
    // TODO: Add menu support
}

void
gui_mch_set_menu_pos(int x, int y, int w, int h)
{
    // Menu is always hidden.
    // TODO: Add menu support
}

/*
 * Add a sub menu to the menu bar.
 */
void
gui_mch_add_menu(vimmenu_T *menu, int idx)
{
    // Menu is always hidden.
    // TODO: Add menu support
}

/*
 * Add a menu item to a menu
 */
void
gui_mch_add_menu_item(vimmenu_T *menu, int idx)
{
    // Menu is always hidden.
    // TODO: Add menu support
}

void
gui_mch_toggle_tearoffs(int enable)
{
    // No tearoff menus
}

/*
 * Destroy the machine specific menu widget.
 */
void
gui_mch_destroy_menu(vimmenu_T *menu)
{
    // Menu is always hidden.
    // TODO: Add menu support
}

/*
 * Make a menu either grey or not grey.
 */
void
gui_mch_menu_grey(vimmenu_T *menu, int grey)
{
    // Menu is always hidden.
    // TODO: Add menu support
}

/*
 * Make menu item hidden or not hidden
 */
void
gui_mch_menu_hidden(vimmenu_T *menu, int hidden)
{
    // Menu is always hidden.
    // TODO: Add menu support
}

/*
 * This is called after setting all the menus to grey/hidden or not.
 */
void
gui_mch_draw_menubar(void)
{
    // Menu is always hidden.
    // TODO: Add menu support
}

/*
 * Scrollbar stuff.
 */

void
gui_mch_enable_scrollbar(
        scrollbar_T     *sb,
        int             flag)
{
    // Scrollbar is always hidden.
    // TODO: Add scrollbar support
}

void
gui_mch_set_scrollbar_thumb(
        scrollbar_T *sb,
        long val,
        long size,
        long max)
{
    // Scrollbar is always hidden.
    // TODO: Add scrollbar support
}

void
gui_mch_set_scrollbar_pos(
        scrollbar_T *sb,
        int x,
        int y,
        int w,
        int h)
{
    // Scrollbar is always hidden.
    // TODO: Add scrollbar support
}

void
gui_mch_create_scrollbar(
        scrollbar_T *sb,
        int orient)     /* SBAR_VERT or SBAR_HORIZ */
{
    // Scrollbar is always hidden.
    // TODO: Add scrollbar support
}

void
gui_mch_destroy_scrollbar(scrollbar_T *sb)
{
    // Scrollbar is always hidden.
    // TODO: Add scrollbar support
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
 * BLINK_NONE   not blinking at all
 * BLINK_OFF    blinking, cursor is not shown
 * BLINK_ON blinking, cursor is shown
 */
void
gui_mch_set_blinking(long wait, long on, long off)
{
    // TODO: Support blinking states transition
}

/*
 * Stop the cursor blinking.  Show the cursor if it wasn't shown.
 */
void
gui_mch_stop_blink(int may_call_gui_update_cursor)
{
    if (may_call_gui_update_cursor) {
        gui_update_cursor(TRUE, FALSE);
    }
}

/*
 * Start the cursor blinking.  If it was already blinking, this restarts the
 * waiting time and shows the cursor.
 */
void
gui_mch_start_blink(void)
{
    gui_update_cursor(TRUE, FALSE);
}

/*
 * Return the RGB value of a pixel as long.
 */
guicolor_T
gui_mch_get_rgb(guicolor_T pixel)
{
    return pixel;
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
    // TODO: Reading/Writing a file from/to local is not supported.
    // Support it using local storage or IndexedDB.
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
 *          2 for the second, etc.
 *
 *          0 indicates Esc was pressed.
 *          -1 for unexpected error
 *
 * If stubbing out this fn, return 1.
 */

int
gui_mch_dialog(
    int         type,
    char_u      *title,
    char_u      *message,
    char_u      *buttons,
    int         dfltbutton,
    char_u      *textfield,
    int         ex_cmd)
{
    return vimwasm_open_dialog(type, title, message, buttons, dfltbutton, textfield);
}
#endif /* FEAT_GUI_DIALOG */

/*
 * Get current mouse coordinates in text window.
 */
void
gui_mch_getmouse(int *x, int *y)
{
    *x = vimwasm_get_mouse_x();
    *y = vimwasm_get_mouse_y();

    GUI_WASM_DBG("x=%d y=%d", *x, *y);
}

void
gui_mch_setmouse(int x, int y)
{
    // Cannot move cursor in web page
}

void
gui_mch_show_popupmenu(vimmenu_T *menu)
{
    // TODO: Pop up menu support
}

#ifdef FEAT_TITLE
/*
 * Set the window title and icon.
 * (The icon is not taken care of).
 */
void
gui_mch_settitle(char_u *title, char_u *icon)
{
    GUI_WASM_DBG("title='%s' icon='%s'", title, icon);
    vimwasm_set_title((char *)title);
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
    // TODO: GUI IME support
}

/*
 * Set IM status on ("active" is TRUE) or off ("active" is FALSE).
 */
void
im_set_active(int active)
{
    // TODO: GUI IME support
}

/*
 * Get IM status.  When IM is on, return not 0.  Else return 0.
 */
int
im_get_status(void)
{
    // TODO: GUI IME support
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
    // TODO: Add tab line support
}

/*
 * Return TRUE when tabline is displayed.
 */
int
gui_mch_showing_tabline(void)
{
    // TODO: Add tab line support
    return FALSE;
}

/*
 * Set the current tab to "nr".  First tab is 1.
 */
void
gui_mch_set_curtab(int nr)
{
    // TODO: Add tab line support
}

#endif /* defined(FEAT_GUI_TABLINE) || defined(PROTO) */

static char const*
browser_key_to_special(char const* key)
{
    if (strcmp(key, "F1") == 0)         return "k1";
    if (strcmp(key, "F2") == 0)         return "k2";
    if (strcmp(key, "F3") == 0)         return "k3";
    if (strcmp(key, "F4") == 0)         return "k4";
    if (strcmp(key, "F5") == 0)         return "k5";
    if (strcmp(key, "F6") == 0)         return "k6";
    if (strcmp(key, "F7") == 0)         return "k7";
    if (strcmp(key, "F8") == 0)         return "k8";
    if (strcmp(key, "F9") == 0)         return "k9";
    if (strcmp(key, "F10") == 0)        return "F;";
    if (strcmp(key, "F11") == 0)        return "F1";
    if (strcmp(key, "F12") == 0)        return "F2";
    if (strcmp(key, "F13") == 0)        return "F3";
    if (strcmp(key, "F14") == 0)        return "F4";
    if (strcmp(key, "F15") == 0)        return "F5";
    if (strcmp(key, "Backspace") == 0)  return "kb";
    if (strcmp(key, "Delete") == 0)     return "kD";
    if (strcmp(key, "ArrowLeft") == 0)  return "kl";
    if (strcmp(key, "ArrowUp") == 0)    return "ku";
    if (strcmp(key, "ArrowRight") == 0) return "kr";
    if (strcmp(key, "ArrowDown") == 0)  return "kd";
    if (strcmp(key, "PageUp") == 0)     return "kP";
    if (strcmp(key, "PageDown") == 0)   return "kN";
    if (strcmp(key, "End") == 0)        return "@7";
    if (strcmp(key, "Home") == 0)       return "kh";
    if (strcmp(key, "Insert") == 0)     return "kI";
    if (strcmp(key, "Help") == 0)       return "%1";
    if (strcmp(key, "Undo") == 0)       return "&8";
    if (strcmp(key, "Print") == 0)      return "%9";
    return NULL;
}

/*
 * Handle keydown event from JavaScript runtime
 * Logic was stolen from gui_mac_unicode_key_event() in gui_mac.c
 * This function only handles 'keydown' KeyboardEvent so keycode is always one byte.
 * Multi-bytes sequence (input via IME) should be handled in another API since it is handled by 'input'
 * event of <input> instead of 'keydown'.
 */
void
gui_wasm_handle_keydown(
    char const* key,
    int keycode,
    int const ctrl,
    int const shift,
    int const alt,
    int const meta)
{
    char_u const* special = NULL;
    int const key_len = strlen(key);
    int spcode = NUL;
    int modifiers = 0x00;
    short len = 0;
    char_u input[20];
    int is_special = FALSE;

#ifdef GUI_WASM_DEBUG
    printf("gui_wasm_handle_keydown: key='%s', keycode=%02x, ctrl=%d, shift=%d, alt=%d, meta=%d\n", key, keycode, ctrl, shift, alt, meta);
#endif

    if (key_len > 1) {
        // Handles special keys. Logic was from gui_mac.c
        // Key names were from https://www.w3.org/TR/DOM-Level-3-Events-key/
        special = (char_u const*)browser_key_to_special(key);
    } else {
        // When `key` is one character, get character code from `key`.
        // KeyboardEvent.charCode is not available on 'keydown'.
        keycode = key[0];
    }

    if (special != NULL) {
        keycode = special[0];
        spcode = special[1];
    }

    // TODO: Intercept CTRL-@ and CTRL-^ since they don't work in the normal way.

    // Convert modifiers
    if (shift) {
        modifiers |= MOD_MASK_SHIFT;
    }
    if (ctrl) {
        modifiers |= MOD_MASK_CTRL;
    }
    if (alt) {
        modifiers |= MOD_MASK_ALT;
    }
#ifdef USE_CMD_KEY
    if (meta) {
        modifiers |= MOD_MASK_CMD;
    }
#endif

    // Handle special keys
    // TODO: Check keycode < 0x20 || keycode == 0x7f
    if (spcode != NUL) {
        keycode = TO_SPECIAL(keycode, spcode);
        keycode = simplify_key(keycode, &modifiers);
        is_special = TRUE;
    }

    if (keycode == 'c' && ctrl) {
        got_int = TRUE;
    }

    if (spcode == NUL) {
        if (!IS_SPECIAL(keycode)) {
            // Interpret META, include SHIFT, etc.
            keycode = extract_modifiers(keycode, &modifiers, TRUE, NULL);
            if (keycode == CSI) {
                keycode = K_CSI;
            }

            if (IS_SPECIAL(keycode)) {
                is_special = TRUE;
            }
        }
    }

    if (modifiers) {
        input[len++] = CSI;
        input[len++] = KS_MODIFIER;
        input[len++] = modifiers;
    }

    if (is_special && IS_SPECIAL(keycode)) {
        input[len++] = CSI;
        input[len++] = K_SECOND(keycode);
        input[len++] = K_THIRD(keycode);
    } else {
        input[len++] = keycode;
    }

    add_to_input_buf(input, len);
}

void
gui_wasm_resize_shell(int pixel_width, int pixel_height)
{
    gui.dom_width = pixel_width;
    gui.dom_height = pixel_height;
    int rows = pixel_height / gui.char_height;
    int cols = pixel_width / gui.char_width;

    if (gui.num_rows == rows && gui.num_cols == cols) {
        return;
    }

    gui.num_rows = rows;
    gui.num_cols = cols;
    Rows = rows;
    Columns = cols;

    GUI_WASM_DBG("dom_width=%d dom_height=%d rows=%d cols=%d", gui.dom_width, gui.dom_height, rows, cols);

    gui_resize_shell(pixel_width, pixel_height);
}

void
gui_wasm_handle_drop(char const* filepath)
{
    char_u **filepaths = NULL;
    int const fp_len = strlen(filepath);

    reset_VIsual();

    // handle_drop() requires heap allocated array of file paths. Stack is not available.
    // `filepath` also needs copy because the pointer passed to C function from JavaScript is freed
    // by emscripten runtime automatically.
    filepaths = (char_u **)alloc(1 * sizeof(char_u *));
    *filepaths = vim_strsave((char_u *) filepath);

    // TODO: Should we use gui_handle_drop() instead?
    // TODO: Should we handle drop_callback (4th argument)?
    handle_drop(1, filepaths, FALSE, NULL, NULL);

    update_screen(NOT_VALID);
    setcursor();
    out_flush();

    GUI_WASM_DBG("Handled file drop: %s", filepath);
}

void
gui_wasm_set_clip_avail(int const avail)
{
    clipboard_available = avail;
}

int
gui_wasm_get_clip_avail(void)
{
    return clipboard_available;
}

int
gui_wasm_do_cmdline(char *cmdline)
{
    int success = do_cmdline_cmd((char_u *)cmdline) == OK;
    GUI_WASM_DBG("Command '%s' Success=%d", cmdline, success);
    // Note: This function does not seem to trigger screen redraw.
    return success;
}

int
gui_wasm_call_shell(char_u *cmd)
{
    char_u *start;
    char_u *end;
    char_u saved = NUL;
    char_u *fullpath = NULL;
    int ret = OK;

    GUI_WASM_DBG("Command line: '%s'", cmd);

    if (*cmd == NUL) {
        return ret;
    }

    // Skip preceding spaces
    start = cmd;
    while (*start != NUL && vim_isspace(*start)) {
        start++;
    }

    // Determine the end of first argument
    for (end = start; *end != NUL; end++) {
        if (vim_isspace(*end)) {
            break;
        }
    }

    // Retrieve only first argument
    if (*end != NUL) {
        saved = *end;
        *end = NUL;
    }

    GUI_WASM_DBG("First argument: '%s'", start);

    fullpath = fix_fname(start);
    if (fullpath == NULL) {
        emsg(_("E9999: Could not locate file for first argument of :!"));
        ret = FAIL;
        goto cleanup;
    }

    if (STRLEN(fullpath) < 3 || STRNCMP(".js", end - 3, 3) != 0) {
        emsg(_("E9999: :! only supports executing JavaScript file. Argument must end with '.js'"));
        ret = FAIL;
        goto cleanup;
    }

    GUI_WASM_DBG("Execute JavaScript source: '%s'", fullpath);
    ret = vimwasm_call_shell((char *)fullpath);

cleanup:
    // Cleanup
    if (fullpath != NULL) {
        vim_free(fullpath);
    }
    *end = saved;

    return ret;
}

void
gui_wasm_emsg(char *msg)
{
    emsg(_(msg));
}

#endif /* FEAT_GUI_WASM */
