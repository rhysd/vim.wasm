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
#include "os_unixx.h"	    /* unix includes for os_unix.c only */

#if defined(__BEOS__) || defined(VMS)
int  RealWaitForChar(int, long, int *, int *interrupted);
#else
static int  RealWaitForChar(int, long, int *, int *interrupted);
#endif
static void handle_resize(void);
static int  have_wildcard(int, char_u **);
static int  have_dollars(int, char_u **);
static int save_patterns(int num_pat, char_u **pat, int *num_file, char_u ***file);

static int curr_tmode = TMODE_COOK;	/* contains current terminal mode */
/* volatile because it is used in signal handler sig_winch(). */
static volatile int do_resize = FALSE;
static char_u	*extra_shell_arg = NULL;
static int	show_shell_mess = TRUE;

/* TODO: missing symbols from tiny build
 *
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
    // Don't need to implement this function since Wasm backend is for GUI only.
}

/*
 * Get absolute file name into "buf[len]".
 *
 * return FAIL for failure, OK for success
 */
int
mch_FullName(
    char_u	*fname,
    char_u	*buf,
    int		len,
    int		force)		/* also expand when already absolute path */
{
    int		l;
#ifdef HAVE_FCHDIR
    int		fd = -1;
    static int	dont_fchdir = FALSE;	/* TRUE when fchdir() doesn't work */
#endif
    char_u	olddir[MAXPATHL];
    char_u	*p;
    int		retval = OK;
#ifdef __CYGWIN__
    char_u	posix_fname[MAXPATHL];	/* Cygwin docs mention MAX_PATH, but
					   it's not always defined */
#endif

#ifdef VMS
    fname = vms_fixfilename(fname);
#endif

#ifdef __CYGWIN__
    /*
     * This helps for when "/etc/hosts" is a symlink to "c:/something/hosts".
     */
# if CYGWIN_VERSION_DLL_MAJOR >= 1007
    /* Use CCP_RELATIVE to avoid that it sometimes returns a path that ends in
     * a forward slash. */
    cygwin_conv_path(CCP_WIN_A_TO_POSIX | CCP_RELATIVE,
		     fname, posix_fname, MAXPATHL);
# else
    cygwin_conv_to_posix_path(fname, posix_fname);
# endif
    fname = posix_fname;
#endif

    /* Expand it if forced or not an absolute path.
     * Do not do it for "/file", the result is always "/". */
    if ((force || !mch_isFullName(fname))
	    && ((p = vim_strrchr(fname, '/')) == NULL || p != fname))
    {
	/*
	 * If the file name has a path, change to that directory for a moment,
	 * and then do the getwd() (and get back to where we were).
	 * This will get the correct path name with "../" things.
	 */
	if (p != NULL)
	{
#ifdef HAVE_FCHDIR
	    /*
	     * Use fchdir() if possible, it's said to be faster and more
	     * reliable.  But on SunOS 4 it might not work.  Check this by
	     * doing a fchdir() right now.
	     */
	    if (!dont_fchdir)
	    {
		fd = open(".", O_RDONLY | O_EXTRA, 0);
		if (fd >= 0 && fchdir(fd) < 0)
		{
		    close(fd);
		    fd = -1;
		    dont_fchdir = TRUE;	    /* don't try again */
		}
	    }
#endif

	    /* Only change directory when we are sure we can return to where
	     * we are now.  After doing "su" chdir(".") might not work. */
	    if (
#ifdef HAVE_FCHDIR
		fd < 0 &&
#endif
			(mch_dirname(olddir, MAXPATHL) == FAIL
					   || mch_chdir((char *)olddir) != 0))
	    {
		p = NULL;	/* can't get current dir: don't chdir */
		retval = FAIL;
	    }
	    else
	    {
		/* The directory is copied into buf[], to be able to remove
		 * the file name without changing it (could be a string in
		 * read-only memory) */
		if (p - fname >= len)
		    retval = FAIL;
		else
		{
		    vim_strncpy(buf, fname, p - fname);
		    if (mch_chdir((char *)buf))
			retval = FAIL;
		    else
			fname = p + 1;
		    *buf = NUL;
		}
	    }
	}
	if (mch_dirname(buf, len) == FAIL)
	{
	    retval = FAIL;
	    *buf = NUL;
	}
	if (p != NULL)
	{
#ifdef HAVE_FCHDIR
	    if (fd >= 0)
	    {
		if (p_verbose >= 5)
		{
		    verbose_enter();
		    MSG("fchdir() to previous dir");
		    verbose_leave();
		}
		l = fchdir(fd);
		close(fd);
	    }
	    else
#endif
		l = mch_chdir((char *)olddir);
	    if (l != 0)
		EMSG(_(e_prev_dir));
	}

	l = STRLEN(buf);
	if (l >= len - 1)
	    retval = FAIL; /* no space for trailing "/" */
#ifndef VMS
	else if (l > 0 && buf[l - 1] != '/' && *fname != NUL
						   && STRCMP(fname, ".") != 0)
	    STRCAT(buf, "/");
#endif
    }

    /* Catch file names which are too long. */
    if (retval == FAIL || (int)(STRLEN(buf) + STRLEN(fname)) >= len)
	return FAIL;

    /* Do not append ".", "/dir/." is equal to "/dir". */
    if (STRCMP(fname, ".") != 0)
	STRCAT(buf, fname);

    return OK;
}

/*
 * Check for CTRL-C typed by reading all available characters.
 * In cooked mode we should get SIGINT, no need to check.
 */
void
mch_breakcheck(int force)
{
    if ((curr_tmode == TMODE_RAW || force)
			       && RealWaitForChar(read_cmd_fd, 0L, NULL, NULL))
	fill_input_buf(FALSE);
}

#ifndef VMS
/*
 * Wait "msec" msec until a character is available from file descriptor "fd".
 * "msec" == 0 will check for characters once.
 * "msec" == -1 will block until a character is available.
 * When a GUI is being used, this will not be used for input -- webb
 * Or when a Linux GPM mouse event is waiting.
 * Or when a clientserver message is on the queue.
 * "interrupted" (if not NULL) is set to TRUE when no character is available
 * but something else needs to be done.
 */
#if defined(__BEOS__)
    int
#else
    static int
#endif
RealWaitForChar(int fd, long msec, int *check_for_gpm UNUSED, int *interrupted)
{
    int		ret;
    int		result;
#if defined(FEAT_XCLIPBOARD) || defined(USE_XSMP) || defined(FEAT_MZSCHEME)
    static int	busy = FALSE;

    /* May retry getting characters after an event was handled. */
# define MAY_LOOP

# ifdef ELAPSED_FUNC
    /* Remember at what time we started, so that we know how much longer we
     * should wait after being interrupted. */
    long	    start_msec = msec;
    ELAPSED_TYPE  start_tv;

    if (msec > 0)
	ELAPSED_INIT(start_tv);
# endif

    /* Handle being called recursively.  This may happen for the session
     * manager stuff, it may save the file, which does a breakcheck. */
    if (busy)
	return 0;
#endif

#ifdef MAY_LOOP
    for (;;)
#endif
    {
#ifdef MAY_LOOP
	int		finished = TRUE; /* default is to 'loop' just once */
# ifdef FEAT_MZSCHEME
	int		mzquantum_used = FALSE;
# endif
#endif
#ifndef HAVE_SELECT
			/* each channel may use in, out and err */
	struct pollfd   fds[6 + 3 * MAX_OPEN_CHANNELS];
	int		nfd;
# ifdef FEAT_XCLIPBOARD
	int		xterm_idx = -1;
# endif
# ifdef FEAT_MOUSE_GPM
	int		gpm_idx = -1;
# endif
# ifdef USE_XSMP
	int		xsmp_idx = -1;
# endif
	int		towait = (int)msec;

# ifdef FEAT_MZSCHEME
	mzvim_check_threads();
	if (mzthreads_allowed() && p_mzq > 0 && (msec < 0 || msec > p_mzq))
	{
	    towait = (int)p_mzq;    /* don't wait longer than 'mzquantum' */
	    mzquantum_used = TRUE;
	}
# endif
	fds[0].fd = fd;
	fds[0].events = POLLIN;
	nfd = 1;

# ifdef FEAT_XCLIPBOARD
	may_restore_clipboard();
	if (xterm_Shell != (Widget)0)
	{
	    xterm_idx = nfd;
	    fds[nfd].fd = ConnectionNumber(xterm_dpy);
	    fds[nfd].events = POLLIN;
	    nfd++;
	}
# endif
# ifdef FEAT_MOUSE_GPM
	if (check_for_gpm != NULL && gpm_flag && gpm_fd >= 0)
	{
	    gpm_idx = nfd;
	    fds[nfd].fd = gpm_fd;
	    fds[nfd].events = POLLIN;
	    nfd++;
	}
# endif
# ifdef USE_XSMP
	if (xsmp_icefd != -1)
	{
	    xsmp_idx = nfd;
	    fds[nfd].fd = xsmp_icefd;
	    fds[nfd].events = POLLIN;
	    nfd++;
	}
# endif
#ifdef FEAT_JOB_CHANNEL
	nfd = channel_poll_setup(nfd, &fds, &towait);
#endif
	if (interrupted != NULL)
	    *interrupted = FALSE;

	ret = poll(fds, nfd, towait);

	result = ret > 0 && (fds[0].revents & POLLIN);
	if (result == 0 && interrupted != NULL && ret > 0)
	    *interrupted = TRUE;

# ifdef FEAT_MZSCHEME
	if (ret == 0 && mzquantum_used)
	    /* MzThreads scheduling is required and timeout occurred */
	    finished = FALSE;
# endif

# ifdef FEAT_XCLIPBOARD
	if (xterm_Shell != (Widget)0 && (fds[xterm_idx].revents & POLLIN))
	{
	    xterm_update();      /* Maybe we should hand out clipboard */
	    if (--ret == 0 && !input_available())
		/* Try again */
		finished = FALSE;
	}
# endif
# ifdef FEAT_MOUSE_GPM
	if (gpm_idx >= 0 && (fds[gpm_idx].revents & POLLIN))
	{
	    *check_for_gpm = 1;
	}
# endif
# ifdef USE_XSMP
	if (xsmp_idx >= 0 && (fds[xsmp_idx].revents & (POLLIN | POLLHUP)))
	{
	    if (fds[xsmp_idx].revents & POLLIN)
	    {
		busy = TRUE;
		xsmp_handle_requests();
		busy = FALSE;
	    }
	    else if (fds[xsmp_idx].revents & POLLHUP)
	    {
		if (p_verbose > 0)
		    verb_msg((char_u *)_("XSMP lost ICE connection"));
		xsmp_close();
	    }
	    if (--ret == 0)
		finished = FALSE;	/* Try again */
	}
# endif
#ifdef FEAT_JOB_CHANNEL
	/* also call when ret == 0, we may be polling a keep-open channel */
	if (ret >= 0)
	    ret = channel_poll_check(ret, &fds);
#endif

#else /* HAVE_SELECT */

	struct timeval  tv;
	struct timeval	*tvp;
	fd_set		rfds, wfds, efds;
	int		maxfd;
	long		towait = msec;

# ifdef FEAT_MZSCHEME
	mzvim_check_threads();
	if (mzthreads_allowed() && p_mzq > 0 && (msec < 0 || msec > p_mzq))
	{
	    towait = p_mzq;	/* don't wait longer than 'mzquantum' */
	    mzquantum_used = TRUE;
	}
# endif

	if (towait >= 0)
	{
	    tv.tv_sec = towait / 1000;
	    tv.tv_usec = (towait % 1000) * (1000000/1000);
	    tvp = &tv;
	}
	else
	    tvp = NULL;

	/*
	 * Select on ready for reading and exceptional condition (end of file).
	 */
select_eintr:
	FD_ZERO(&rfds);
	FD_ZERO(&wfds);
	FD_ZERO(&efds);
	FD_SET(fd, &rfds);
# if !defined(__QNX__) && !defined(__CYGWIN32__)
	/* For QNX select() always returns 1 if this is set.  Why? */
	FD_SET(fd, &efds);
# endif
	maxfd = fd;

# ifdef FEAT_XCLIPBOARD
	may_restore_clipboard();
	if (xterm_Shell != (Widget)0)
	{
	    FD_SET(ConnectionNumber(xterm_dpy), &rfds);
	    if (maxfd < ConnectionNumber(xterm_dpy))
		maxfd = ConnectionNumber(xterm_dpy);

	    /* An event may have already been read but not handled.  In
	     * particulary, XFlush may cause this. */
	    xterm_update();
	}
# endif
# ifdef FEAT_MOUSE_GPM
	if (check_for_gpm != NULL && gpm_flag && gpm_fd >= 0)
	{
	    FD_SET(gpm_fd, &rfds);
	    FD_SET(gpm_fd, &efds);
	    if (maxfd < gpm_fd)
		maxfd = gpm_fd;
	}
# endif
# ifdef USE_XSMP
	if (xsmp_icefd != -1)
	{
	    FD_SET(xsmp_icefd, &rfds);
	    FD_SET(xsmp_icefd, &efds);
	    if (maxfd < xsmp_icefd)
		maxfd = xsmp_icefd;
	}
# endif
# ifdef FEAT_JOB_CHANNEL
	maxfd = channel_select_setup(maxfd, &rfds, &wfds, &tv, &tvp);
# endif
	if (interrupted != NULL)
	    *interrupted = FALSE;

	ret = select(maxfd + 1, &rfds, &wfds, &efds, tvp);
	result = ret > 0 && FD_ISSET(fd, &rfds);
	if (result)
	    --ret;
	else if (interrupted != NULL && ret > 0)
	    *interrupted = TRUE;

# ifdef EINTR
	if (ret == -1 && errno == EINTR)
	{
	    /* Check whether window has been resized, EINTR may be caused by
	     * SIGWINCH. */
	    if (do_resize)
		handle_resize();

	    /* Interrupted by a signal, need to try again.  We ignore msec
	     * here, because we do want to check even after a timeout if
	     * characters are available.  Needed for reading output of an
	     * external command after the process has finished. */
	    goto select_eintr;
	}
# endif
# ifdef __TANDEM
	if (ret == -1 && errno == ENOTSUP)
	{
	    FD_ZERO(&rfds);
	    FD_ZERO(&efds);
	    ret = 0;
	}
# endif
# ifdef FEAT_MZSCHEME
	if (ret == 0 && mzquantum_used)
	    /* loop if MzThreads must be scheduled and timeout occurred */
	    finished = FALSE;
# endif

# ifdef FEAT_XCLIPBOARD
	if (ret > 0 && xterm_Shell != (Widget)0
		&& FD_ISSET(ConnectionNumber(xterm_dpy), &rfds))
	{
	    xterm_update();	      /* Maybe we should hand out clipboard */
	    /* continue looping when we only got the X event and the input
	     * buffer is empty */
	    if (--ret == 0 && !input_available())
	    {
		/* Try again */
		finished = FALSE;
	    }
	}
# endif
# ifdef FEAT_MOUSE_GPM
	if (ret > 0 && gpm_flag && check_for_gpm != NULL && gpm_fd >= 0)
	{
	    if (FD_ISSET(gpm_fd, &efds))
		gpm_close();
	    else if (FD_ISSET(gpm_fd, &rfds))
		*check_for_gpm = 1;
	}
# endif
# ifdef USE_XSMP
	if (ret > 0 && xsmp_icefd != -1)
	{
	    if (FD_ISSET(xsmp_icefd, &efds))
	    {
		if (p_verbose > 0)
		    verb_msg((char_u *)_("XSMP lost ICE connection"));
		xsmp_close();
		if (--ret == 0)
		    finished = FALSE;   /* keep going if event was only one */
	    }
	    else if (FD_ISSET(xsmp_icefd, &rfds))
	    {
		busy = TRUE;
		xsmp_handle_requests();
		busy = FALSE;
		if (--ret == 0)
		    finished = FALSE;   /* keep going if event was only one */
	    }
	}
# endif
#ifdef FEAT_JOB_CHANNEL
	/* also call when ret == 0, we may be polling a keep-open channel */
	if (ret >= 0)
	    ret = channel_select_check(ret, &rfds, &wfds);
#endif

#endif /* HAVE_SELECT */

#ifdef MAY_LOOP
	if (finished || msec == 0)
	    break;

# ifdef FEAT_CLIENTSERVER
	if (server_waiting())
	    break;
# endif

	/* We're going to loop around again, find out for how long */
	if (msec > 0)
	{
# ifdef ELAPSED_FUNC
	    /* Compute remaining wait time. */
	    msec = start_msec - ELAPSED_FUNC(start_tv);
# else
	    /* Guess we got interrupted halfway. */
	    msec = msec / 2;
# endif
	    if (msec <= 0)
		break;	/* waited long enough */
	}
#endif
    }

    return result;
}

static void
handle_resize(void)
{
    do_resize = FALSE;
    shell_resized();
}


/*
 * Return TRUE if the string "p" contains a wildcard.
 * Don't recognize '~' at the end as a wildcard.
 */
int
mch_has_wildcard(char_u *p)
{
    for ( ; *p; MB_PTR_ADV(p))
    {
	if (*p == '\\' && p[1] != NUL)
	    ++p;
	else
	    if (vim_strchr((char_u *)
#ifdef VMS
				    "*?%$"
#else
				    "*?[{`'$"
#endif
						, *p) != NULL
		|| (*p == '~' && p[1] != NUL))
	    return TRUE;
    }
    return FALSE;
}

static int
have_wildcard(int num, char_u **file)
{
    int	    i;

    for (i = 0; i < num; i++)
	if (mch_has_wildcard(file[i]))
	    return 1;
    return 0;
}

static int
have_dollars(int num, char_u **file)
{
    int	    i;

    for (i = 0; i < num; i++)
	if (vim_strchr(file[i], '$') != NULL)
	    return TRUE;
    return FALSE;
}

#ifndef NO_EXPANDPATH
/*
 * Expand a path into all matching files and/or directories.  Handles "*",
 * "?", "[a-z]", "**", etc.
 * "path" has backslashes before chars that are not to be expanded.
 * Returns the number of matches found.
 */
    int
mch_expandpath(
    garray_T	*gap,
    char_u	*path,
    int		flags)		/* EW_* flags */
{
    return unix_expandpath(gap, path, 0, flags, FALSE);
}
#endif

/*
 * mch_expand_wildcards() - this code does wild-card pattern matching using
 * the shell
 *
 * return OK for success, FAIL for error (you may lose some memory) and put
 * an error message in *file.
 *
 * num_pat is number of input patterns
 * pat is array of pointers to input patterns
 * num_file is pointer to number of matched file names
 * file is pointer to array of pointers to matched file names
 */

#ifndef SEEK_SET
# define SEEK_SET 0
#endif
#ifndef SEEK_END
# define SEEK_END 2
#endif

#define SHELL_SPECIAL (char_u *)"\t \"&'$;<>()\\|"

    int
mch_expand_wildcards(
    int		   num_pat,
    char_u	 **pat,
    int		  *num_file,
    char_u	***file,
    int		   flags)	/* EW_* flags */
{
    int		i;
    size_t	len;
    long	llen;
    char_u	*p;
    int		dir;

    /*
     * This is the non-OS/2 implementation (really Unix).
     */
    int		j;
    char_u	*tempname;
    char_u	*command;
    FILE	*fd;
    char_u	*buffer;
#define STYLE_ECHO	0	/* use "echo", the default */
#define STYLE_GLOB	1	/* use "glob", for csh */
#define STYLE_VIMGLOB	2	/* use "vimglob", for Posix sh */
#define STYLE_PRINT	3	/* use "print -N", for zsh */
#define STYLE_BT	4	/* `cmd` expansion, execute the pattern
				 * directly */
    int		shell_style = STYLE_ECHO;
    int		check_spaces;
    static int	did_find_nul = FALSE;
    int		ampersent = FALSE;
		/* vimglob() function to define for Posix shell */
    static char *sh_vimglob_func = "vimglob() { while [ $# -ge 1 ]; do echo \"$1\"; shift; done }; vimglob >";

    *num_file = 0;	/* default: no files found */
    *file = NULL;

    /*
     * If there are no wildcards, just copy the names to allocated memory.
     * Saves a lot of time, because we don't have to start a new shell.
     */
    if (!have_wildcard(num_pat, pat))
	return save_patterns(num_pat, pat, num_file, file);

# ifdef HAVE_SANDBOX
    /* Don't allow any shell command in the sandbox. */
    if (sandbox != 0 && check_secure())
	return FAIL;
# endif

    /*
     * Don't allow the use of backticks in secure and restricted mode.
     */
    if (secure || restricted)
	for (i = 0; i < num_pat; ++i)
	    if (vim_strchr(pat[i], '`') != NULL
		    && (check_restricted() || check_secure()))
		return FAIL;

    /*
     * get a name for the temp file
     */
    if ((tempname = vim_tempname('o', FALSE)) == NULL)
    {
	EMSG(_(e_notmp));
	return FAIL;
    }

    /*
     * Let the shell expand the patterns and write the result into the temp
     * file.
     * STYLE_BT:	NL separated
     *	    If expanding `cmd` execute it directly.
     * STYLE_GLOB:	NUL separated
     *	    If we use *csh, "glob" will work better than "echo".
     * STYLE_PRINT:	NL or NUL separated
     *	    If we use *zsh, "print -N" will work better than "glob".
     * STYLE_VIMGLOB:	NL separated
     *	    If we use *sh*, we define "vimglob()".
     * STYLE_ECHO:	space separated.
     *	    A shell we don't know, stay safe and use "echo".
     */
    if (num_pat == 1 && *pat[0] == '`'
	    && (len = STRLEN(pat[0])) > 2
	    && *(pat[0] + len - 1) == '`')
	shell_style = STYLE_BT;
    else if ((len = STRLEN(p_sh)) >= 3)
    {
	if (STRCMP(p_sh + len - 3, "csh") == 0)
	    shell_style = STYLE_GLOB;
	else if (STRCMP(p_sh + len - 3, "zsh") == 0)
	    shell_style = STYLE_PRINT;
    }
    if (shell_style == STYLE_ECHO && strstr((char *)gettail(p_sh),
								"sh") != NULL)
	shell_style = STYLE_VIMGLOB;

    /* Compute the length of the command.  We need 2 extra bytes: for the
     * optional '&' and for the NUL.
     * Worst case: "unset nonomatch; print -N >" plus two is 29 */
    len = STRLEN(tempname) + 29;
    if (shell_style == STYLE_VIMGLOB)
	len += STRLEN(sh_vimglob_func);

    for (i = 0; i < num_pat; ++i)
    {
	/* Count the length of the patterns in the same way as they are put in
	 * "command" below. */
#ifdef USE_SYSTEM
	len += STRLEN(pat[i]) + 3;	/* add space and two quotes */
#else
	++len;				/* add space */
	for (j = 0; pat[i][j] != NUL; ++j)
	{
	    if (vim_strchr(SHELL_SPECIAL, pat[i][j]) != NULL)
		++len;		/* may add a backslash */
	    ++len;
	}
#endif
    }
    command = alloc(len);
    if (command == NULL)
    {
	/* out of memory */
	vim_free(tempname);
	return FAIL;
    }

    /*
     * Build the shell command:
     * - Set $nonomatch depending on EW_NOTFOUND (hopefully the shell
     *	 recognizes this).
     * - Add the shell command to print the expanded names.
     * - Add the temp file name.
     * - Add the file name patterns.
     */
    if (shell_style == STYLE_BT)
    {
	/* change `command; command& ` to (command; command ) */
	STRCPY(command, "(");
	STRCAT(command, pat[0] + 1);		/* exclude first backtick */
	p = command + STRLEN(command) - 1;
	*p-- = ')';				/* remove last backtick */
	while (p > command && VIM_ISWHITE(*p))
	    --p;
	if (*p == '&')				/* remove trailing '&' */
	{
	    ampersent = TRUE;
	    *p = ' ';
	}
	STRCAT(command, ">");
    }
    else
    {
	if (flags & EW_NOTFOUND)
	    STRCPY(command, "set nonomatch; ");
	else
	    STRCPY(command, "unset nonomatch; ");
	if (shell_style == STYLE_GLOB)
	    STRCAT(command, "glob >");
	else if (shell_style == STYLE_PRINT)
	    STRCAT(command, "print -N >");
	else if (shell_style == STYLE_VIMGLOB)
	    STRCAT(command, sh_vimglob_func);
	else
	    STRCAT(command, "echo >");
    }

    STRCAT(command, tempname);

    if (shell_style != STYLE_BT)
	for (i = 0; i < num_pat; ++i)
	{
	    /* When using system() always add extra quotes, because the shell
	     * is started twice.  Otherwise put a backslash before special
	     * characters, except inside ``. */
#ifdef USE_SYSTEM
	    STRCAT(command, " \"");
	    STRCAT(command, pat[i]);
	    STRCAT(command, "\"");
#else
	    int intick = FALSE;

	    p = command + STRLEN(command);
	    *p++ = ' ';
	    for (j = 0; pat[i][j] != NUL; ++j)
	    {
		if (pat[i][j] == '`')
		    intick = !intick;
		else if (pat[i][j] == '\\' && pat[i][j + 1] != NUL)
		{
		    /* Remove a backslash, take char literally.  But keep
		     * backslash inside backticks, before a special character
		     * and before a backtick. */
		    if (intick
			  || vim_strchr(SHELL_SPECIAL, pat[i][j + 1]) != NULL
			  || pat[i][j + 1] == '`')
			*p++ = '\\';
		    ++j;
		}
		else if (!intick
			 && ((flags & EW_KEEPDOLLAR) == 0 || pat[i][j] != '$')
			      && vim_strchr(SHELL_SPECIAL, pat[i][j]) != NULL)
		    /* Put a backslash before a special character, but not
		     * when inside ``. And not for $var when EW_KEEPDOLLAR is
		     * set. */
		    *p++ = '\\';

		/* Copy one character. */
		*p++ = pat[i][j];
	    }
	    *p = NUL;
#endif
	}
    if (flags & EW_SILENT)
	show_shell_mess = FALSE;
    if (ampersent)
	STRCAT(command, "&");		/* put the '&' after the redirection */

    /*
     * Using zsh -G: If a pattern has no matches, it is just deleted from
     * the argument list, otherwise zsh gives an error message and doesn't
     * expand any other pattern.
     */
    if (shell_style == STYLE_PRINT)
	extra_shell_arg = (char_u *)"-G";   /* Use zsh NULL_GLOB option */

    /*
     * If we use -f then shell variables set in .cshrc won't get expanded.
     * vi can do it, so we will too, but it is only necessary if there is a "$"
     * in one of the patterns, otherwise we can still use the fast option.
     */
    else if (shell_style == STYLE_GLOB && !have_dollars(num_pat, pat))
	extra_shell_arg = (char_u *)"-f";	/* Use csh fast option */

    /*
     * execute the shell command
     */
    i = call_shell(command, SHELL_EXPAND | SHELL_SILENT);

    /* When running in the background, give it some time to create the temp
     * file, but don't wait for it to finish. */
    if (ampersent)
	mch_delay(10L, TRUE);

    extra_shell_arg = NULL;		/* cleanup */
    show_shell_mess = TRUE;
    vim_free(command);

    if (i != 0)				/* mch_call_shell() failed */
    {
	mch_remove(tempname);
	vim_free(tempname);
	/*
	 * With interactive completion, the error message is not printed.
	 * However with USE_SYSTEM, I don't know how to turn off error messages
	 * from the shell, so screen may still get messed up -- webb.
	 */
#ifndef USE_SYSTEM
	if (!(flags & EW_SILENT))
#endif
	{
	    redraw_later_clear();	/* probably messed up screen */
	    msg_putchar('\n');		/* clear bottom line quickly */
	    cmdline_row = Rows - 1;	/* continue on last line */
#ifdef USE_SYSTEM
	    if (!(flags & EW_SILENT))
#endif
	    {
		MSG(_(e_wildexpand));
		msg_start();		/* don't overwrite this message */
	    }
	}
	/* If a `cmd` expansion failed, don't list `cmd` as a match, even when
	 * EW_NOTFOUND is given */
	if (shell_style == STYLE_BT)
	    return FAIL;
	goto notfound;
    }

    /*
     * read the names from the file into memory
     */
    fd = fopen((char *)tempname, READBIN);
    if (fd == NULL)
    {
	/* Something went wrong, perhaps a file name with a special char. */
	if (!(flags & EW_SILENT))
	{
	    MSG(_(e_wildexpand));
	    msg_start();		/* don't overwrite this message */
	}
	vim_free(tempname);
	goto notfound;
    }
    fseek(fd, 0L, SEEK_END);
    llen = ftell(fd);			/* get size of temp file */
    fseek(fd, 0L, SEEK_SET);
    if (llen < 0)
	/* just in case ftell() would fail */
	buffer = NULL;
    else
	buffer = alloc(llen + 1);
    if (buffer == NULL)
    {
	/* out of memory */
	mch_remove(tempname);
	vim_free(tempname);
	fclose(fd);
	return FAIL;
    }
    len = llen;
    i = fread((char *)buffer, 1, len, fd);
    fclose(fd);
    mch_remove(tempname);
    if (i != (int)len)
    {
	/* unexpected read error */
	EMSG2(_(e_notread), tempname);
	vim_free(tempname);
	vim_free(buffer);
	return FAIL;
    }
    vim_free(tempname);

# if defined(__CYGWIN__) || defined(__CYGWIN32__)
    /* Translate <CR><NL> into <NL>.  Caution, buffer may contain NUL. */
    p = buffer;
    for (i = 0; i < (int)len; ++i)
	if (!(buffer[i] == CAR && buffer[i + 1] == NL))
	    *p++ = buffer[i];
    len = p - buffer;
# endif


    /* file names are separated with Space */
    if (shell_style == STYLE_ECHO)
    {
	buffer[len] = '\n';		/* make sure the buffer ends in NL */
	p = buffer;
	for (i = 0; *p != '\n'; ++i)	/* count number of entries */
	{
	    while (*p != ' ' && *p != '\n')
		++p;
	    p = skipwhite(p);		/* skip to next entry */
	}
    }
    /* file names are separated with NL */
    else if (shell_style == STYLE_BT || shell_style == STYLE_VIMGLOB)
    {
	buffer[len] = NUL;		/* make sure the buffer ends in NUL */
	p = buffer;
	for (i = 0; *p != NUL; ++i)	/* count number of entries */
	{
	    while (*p != '\n' && *p != NUL)
		++p;
	    if (*p != NUL)
		++p;
	    p = skipwhite(p);		/* skip leading white space */
	}
    }
    /* file names are separated with NUL */
    else
    {
	/*
	 * Some versions of zsh use spaces instead of NULs to separate
	 * results.  Only do this when there is no NUL before the end of the
	 * buffer, otherwise we would never be able to use file names with
	 * embedded spaces when zsh does use NULs.
	 * When we found a NUL once, we know zsh is OK, set did_find_nul and
	 * don't check for spaces again.
	 */
	check_spaces = FALSE;
	if (shell_style == STYLE_PRINT && !did_find_nul)
	{
	    /* If there is a NUL, set did_find_nul, else set check_spaces */
	    buffer[len] = NUL;
	    if (len && (int)STRLEN(buffer) < (int)len)
		did_find_nul = TRUE;
	    else
		check_spaces = TRUE;
	}

	/*
	 * Make sure the buffer ends with a NUL.  For STYLE_PRINT there
	 * already is one, for STYLE_GLOB it needs to be added.
	 */
	if (len && buffer[len - 1] == NUL)
	    --len;
	else
	    buffer[len] = NUL;
	i = 0;
	for (p = buffer; p < buffer + len; ++p)
	    if (*p == NUL || (*p == ' ' && check_spaces))   /* count entry */
	    {
		++i;
		*p = NUL;
	    }
	if (len)
	    ++i;			/* count last entry */
    }
    if (i == 0)
    {
	/*
	 * Can happen when using /bin/sh and typing ":e $NO_SUCH_VAR^I".
	 * /bin/sh will happily expand it to nothing rather than returning an
	 * error; and hey, it's good to check anyway -- webb.
	 */
	vim_free(buffer);
	goto notfound;
    }
    *num_file = i;
    *file = (char_u **)alloc(sizeof(char_u *) * i);
    if (*file == NULL)
    {
	/* out of memory */
	vim_free(buffer);
	return FAIL;
    }

    /*
     * Isolate the individual file names.
     */
    p = buffer;
    for (i = 0; i < *num_file; ++i)
    {
	(*file)[i] = p;
	/* Space or NL separates */
	if (shell_style == STYLE_ECHO || shell_style == STYLE_BT
					      || shell_style == STYLE_VIMGLOB)
	{
	    while (!(shell_style == STYLE_ECHO && *p == ' ')
						   && *p != '\n' && *p != NUL)
		++p;
	    if (p == buffer + len)		/* last entry */
		*p = NUL;
	    else
	    {
		*p++ = NUL;
		p = skipwhite(p);		/* skip to next entry */
	    }
	}
	else		/* NUL separates */
	{
	    while (*p && p < buffer + len)	/* skip entry */
		++p;
	    ++p;				/* skip NUL */
	}
    }

    /*
     * Move the file names to allocated memory.
     */
    for (j = 0, i = 0; i < *num_file; ++i)
    {
	/* Require the files to exist.	Helps when using /bin/sh */
	if (!(flags & EW_NOTFOUND) && mch_getperm((*file)[i]) < 0)
	    continue;

	/* check if this entry should be included */
	dir = (mch_isdir((*file)[i]));
	if ((dir && !(flags & EW_DIR)) || (!dir && !(flags & EW_FILE)))
	    continue;

	/* Skip files that are not executable if we check for that. */
	if (!dir && (flags & EW_EXEC)
		    && !mch_can_exe((*file)[i], NULL, !(flags & EW_SHELLCMD)))
	    continue;

	p = alloc((unsigned)(STRLEN((*file)[i]) + 1 + dir));
	if (p)
	{
	    STRCPY(p, (*file)[i]);
	    if (dir)
		add_pathsep(p);	    /* add '/' to a directory name */
	    (*file)[j++] = p;
	}
    }
    vim_free(buffer);
    *num_file = j;

    if (*num_file == 0)	    /* rejected all entries */
    {
	VIM_CLEAR(*file);
	goto notfound;
    }

    return OK;

notfound:
    if (flags & EW_NOTFOUND)
	return save_patterns(num_pat, pat, num_file, file);
    return FAIL;
}

#endif /* VMS */

static int
save_patterns(
    int		num_pat,
    char_u	**pat,
    int		*num_file,
    char_u	***file)
{
    int		i;
    char_u	*s;

    *file = (char_u **)alloc(num_pat * sizeof(char_u *));
    if (*file == NULL)
	return FAIL;
    for (i = 0; i < num_pat; i++)
    {
	s = vim_strsave(pat[i]);
	if (s != NULL)
	    /* Be compatible with expand_filename(): halve the number of
	     * backslashes. */
	    backslash_halve(s);
	(*file)[i] = s;
    }
    *num_file = num_pat;
    return OK;
}


int
mch_call_shell(
    char_u	*cmd,
    int		options)	/* SHELL_*, see vim.h */
{
    // In Wasm, shell commands are not available.
    // Instead, delegate the command to JavaScript layer.
    vimwasm_call_shell((char*)cmd, options);
    return 0;
}
