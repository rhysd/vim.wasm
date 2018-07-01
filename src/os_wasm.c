/* vi:set ts=8 sts=4 sw=4 noet:
 *
 * VIM - Vi IMproved	by Bram Moolenaar
 *	      Implemented by rhysd <https://github.com/rhysd>
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * os_wasm.c -- code for Wasm backend by @rhysd
 *	    This code is based on os_unix.c, but implements minimal requirements for Wasm backend.
 *	    Some functions of os_unix.c are not implemented.
 */

#include "vim.h"

/* TODO: missing symbols from tiny build
 *
 * - get_tty_info
 * - mch_FullName
 * - mch_breakcheck
 * - mch_call_shell
 * - mch_can_exe
 * - mch_chdir
 * - mch_check_win
 * - mch_delay
 * - mch_dirname
 * - mch_early_init
 * - mch_exit
 * - mch_expand_wildcards
 * - mch_expandpath
 * - mch_free_acl
 * - mch_fsetperm
 * - mch_get_acl
 * - mch_get_host_name
 * - mch_get_pid
 * - mch_get_shellsize
 * - mch_get_uname
 * - mch_get_user_name
 * - mch_getperm
 * - mch_has_exp_wildcard
 * - mch_has_wildcard
 * - mch_hide
 * - mch_init
 * - mch_input_isatty
 * - mch_isFullName
 * - mch_isdir
 * - mch_isrealdir
 * - mch_new_shellsize
 * - mch_nodetype
 * - mch_screenmode
 * - mch_set_acl
 * - mch_set_shellsize
 * - mch_setperm
 * - mch_settmode
 * - mch_suspend
 * - mch_total_mem
 * - reset_signals
 * - vim_handle_signal
 * - vim_is_fastterm
 * - vim_is_iris
 * - vim_is_xterm
 */

/*
 * Try to get the code for "t_kb" from the stty setting
 *
 * Even if termcap claims a backspace key, the user's setting *should*
 * prevail.  stty knows more about reality than termcap does, and if
 * somebody's usual erase key is DEL (which, for most BSD users, it will
 * be), they're going to get really annoyed if their erase key starts
 * doing forward deletes for no reason. (Eric Fischer)
 */
void
get_stty(void)
{
    ttyinfo_T	info;
    char_u	buf[2];
    char_u	*p;

    if (get_tty_info(read_cmd_fd, &info) == OK)
    {
	intr_char = info.interrupt;
	buf[0] = info.backspace;
	buf[1] = NUL;
	add_termcode((char_u *)"kb", buf, FALSE);

	/* If <BS> and <DEL> are now the same, redefine <DEL>. */
	p = find_termcode((char_u *)"kD");
	if (p != NULL && p[0] == buf[0] && p[1] == buf[1])
	    do_fixdel(NULL);
    }
}

