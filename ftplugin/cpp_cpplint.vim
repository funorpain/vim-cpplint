"
" C++ filetype plugin for running cpplint.py
" Language:     C++ (ft=cpp)
" Maintainer:   Thomas Chen <funorpain@gmail.com>
" Version:      Vim 7 (may work with lower Vim versions, but not tested)
" URL:          http://example.com/
"
" Code is borrowed from vim-flake8 and slightly modified.
"
" Only do this when not done yet for this buffer
if exists("b:loaded_cpplint_ftplugin")
    finish
endif
let b:loaded_cpplint_ftplugin=1

let s:cpplint_cmd="cpplint.py"

if !exists("*Cpplint()")
    function Cpplint()
        if !executable(s:cpplint_cmd)
            echoerr "File " . s:cpplint_cmd . " not found. Please install it first."
            return
        endif

        set lazyredraw   " delay redrawing
        cclose           " close any existing cwindows

        " store old grep settings (to restore later)
        let l:old_gfm=&grepformat
        let l:old_gp=&grepprg

        " write any changes before continuing
        if &readonly == 0
            update
        endif

        " perform the grep itself
        let &grepformat="%f:%l: %m"
        let &grepprg=s:cpplint_cmd
        silent! grep! %

        " restore grep settings
        let &grepformat=l:old_gfm
        let &grepprg=l:old_gp

        " open cwindow
        let has_results=getqflist() != []
        if has_results
            execute 'belowright copen'
            setlocal wrap
            nnoremap <buffer> <silent> c :cclose<CR>
            nnoremap <buffer> <silent> q :cclose<CR>
        endif

        set nolazyredraw
        redraw!

        if has_results == 0
            " Show OK status
            hi Green ctermfg=green
            echohl Green
            echon "cpplint.py check OK"
            echohl
        endif
    endfunction
endif

" Add mappings, unless the user didn't want this.
" The default mapping is registered under to <F7> by default, unless the user
" remapped it already (or a mapping exists already for <F7>)
if !exists("no_plugin_maps") && !exists("no_cpplint_maps")
    if !hasmapto('Cpplint(')
        noremap <buffer> <F7> :call Cpplint()<CR>
        noremap! <buffer> <F7> :call Cpplint()<CR>
    endif
endif
