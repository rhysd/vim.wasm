function! s:test_serialize_return() abort
    let i = jsevalfunc('return 42')
    call assert_equal(42, i, 'integer')
    let f = jsevalfunc('return 3.14')
    call assert_equal(3.14, f, 'float')
    let s = jsevalfunc('return "test"')
    call assert_equal('test', s, 'string')
    let b = jsevalfunc('return true')
    call assert_equal(v:true, b, 'bool')
    let x = jsevalfunc('return null')
    call assert_equal(v:null, x, 'null')
    let y = jsevalfunc('return undefined')
    call assert_equal(v:none, y, 'none')
    let a = jsevalfunc('return [1, 2, 3]')
    call assert_equal([1, 2, 3], a, 'array')
    let d = jsevalfunc('return {a: 42}')
    call assert_equal({'a': 42}, d, 'dict')
    let z = jsevalfunc('return {a: [1, "test", []], b: null, c: {}}')
    call assert_equal({'a': [1, "test", []], 'b': null, 'c': {}}, z, 'all')
endfunction

function! s:test_serialize_argument() abort
    let i = jsevalfunc('return arguments[0]', [42])
    call assert_equal(42, i, 'integer')
    let f = jsevalfunc('return arguments[0]', [3.14])
    call assert_equal(3.14, f, 'float')
    let s = jsevalfunc('return arguments[0]', ['test'])
    call assert_equal('test', s, 'string')
    let b = jsevalfunc('return arguments[0]', [v:true])
    call assert_equal(v:true, b, 'bool')
    let x = jsevalfunc('return arguments[0]', [v:null])
    call assert_equal(v:null, x, 'null')
    let a = jsevalfunc('return arguments[0]', [[1, 3.14]])
    call assert_equal([1, 3.14], a, 'array')
    let d = jsevalfunc('return arguments[0]', [{'a': 42}])
    call assert_equal({'a': 42}, d, 'dict')
endfunction

function! s:test_arguments() abort
    let a = jsevalfunc('return Array.from(arguments)', [])
    call assert_equal([], a)
    let a = jsevalfunc('return Array.from(arguments)', [1])
    call assert_equal([1], a)
    let a = jsevalfunc('return Array.from(arguments)', [1, 2])
    call assert_equal([1, 2], a)
endfunction

function! s:test_function_body() abort
    let n = jsevalfunc('const x = arguments[0] + arguments[1]; return x * 2', [3, 4]);
    call assert_equal(14, n, 'multiple statements')
    let n = jsevalfunc('return await Promise.resolve(42)')
    call assert_equal(42, n, 'await')
    let s = jsevalfunc('return window.location.href')
    call assert_equal(v:t_string, type(s), 'window access')
    call assert_false(empty(s), 'window access')
    let s = jsevalfunc('return document.body.tagName')
    call asssert_equal(s, 'BODY', 'DOM access')
    let n = jsevalfunc('
            \ const x = arguments[0];
            \ const p1 = new Promise(r => setTimeout(() => r(x), 1));
            \ const i = await Promise.resolve(arguments[1]);
            \ const j = await p1;
            \ return i + j;
            \', [12, 13])
    call asssert_equal(25, n, 'multiple await operators')
    let x = jsevalfunc('')
    call asssert_equal(v:none, x, 'without return')
    let x = jsevalfunc('return')
    call asssert_equal(v:none, x, 'only return')
endfunction

function! s:test_notify_only() abort
    let i = jsevalfunc('return 42', [], 1)
    call assert_equal(0, i, 'integer')
    let f = jsevalfunc('return 3.14', [], 1)
    call assert_equal(0, f, 'float')
    let s = jsevalfunc('return "test"', [], 1)
    call assert_equal(0, s, 'string')
    let b = jsevalfunc('return true', [], 1)
    call assert_equal(0, b, 'bool')
    let x = jsevalfunc('return null', [], 1)
    call assert_equal(0, x, 'null')
    let y = jsevalfunc('return undefined', [], 1)
    call assert_equal(0, y, 'none')
    let a = jsevalfunc('return [1, 2, 3]', [], 1)
    call assert_equal(0, a, 'array')
    let d = jsevalfunc('return {a: 42}', [], 1)
    call assert_equal(0, d, 'dict')
    let z = jsevalfunc('return {a: [1, "test", []], b: null, c: {}}', [], 1)
    call assert_equal(0, z, 'all')
endfunction

function! s:test_arguments_error() abort
    call assert_fails('call jsevalfunc()', 'E119', 'not enough arguments')
    call assert_fails('call jsevalfunc("", {})', 'E714', 'arguments must be list')
    call assert_fails('call jsevalfunc("", [function("empty")])', 'E474', 'argument is not JSON serializable')
    call assert_fails('call jsevalfunc("", [], {})', 'E728', 'notify_only flag must be number compatible value')
endfunction

function! s:test_eval_error() abort
    call assert_fails('call jsevalfunc("throw new Error(''This is test error'')")', 'E9999: Exception was thrown while evaluating function', 'exception is thrown')
    call assert_fails('call jsevalfunc("[")', 'E9999: Could not construct function', 'JavaScript syntax error')
    let source = '
            \ const d = {};
            \ d.x = d; /* circular dependency */
            \ return d;
            \'
    call assert_fails('call jsevalfunc(source)', 'E9999: Could not serialize return value', 'return value is not serializable')
endfunction

" TODO: Test jsevalfunc() raises an error even if notify_only is set to truthy
" value

call s:test_serialize_return()
call s:test_serialize_argument()
call s:test_arguments()
call s:test_function_body()
call s:test_notify_only()
call s:test_arguments_error()
call s:test_eval_error()

call writefile(v:errors, '/test_jsevalfunc_result.txt')
