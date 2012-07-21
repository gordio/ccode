if exists('g:loaded_ccode')
	finish
endif
let g:loaded_ccode = 1


if !exists('g:ccode_auto')
	let g:ccode_auto = 1
endif
if !exists('g:ccode_def_comp')
	let g:ccode_def_comp = 0
endif


au FileType c,cpp,objc,objcpp call s:ccodeInit()

fu! s:ccodeCurrentBuffer()
	let buf = getline(1, '$')
	let file = tempname()
	call writefile(buf, file)
	return file
endf

fu! s:system(str, ...)
	return (a:0 == 0 ? system(a:str) : system(a:str, join(a:000)))
endf

fu! s:ccodeCommand(cmd, args)
	for i in range(0, len(a:args) - 1)
		let a:args[i] = shellescape(a:args[i])
	endfor
	let cmdstr = printf('ccode %s %s', a:cmd, join(a:args))
	let result = s:system(cmdstr)
	if v:shell_error != 0
		return "[\"0\", []]"
	else
		return result
	endif
endf

fu! s:ccodeLine()
	return printf('%d', line('.'))
endf

fu! s:ccodeCol()
	return printf('%d', col('.'))
endf

fu! s:ccodeAutocomplete()
	let filename = s:ccodeCurrentBuffer()
	let result = s:ccodeCommand('ac', [bufname('%'),
				\ s:ccodeLine(), s:ccodeCol(),
				\ filename])
	call delete(filename)
	return result
endf

fu! CCodeComplete(findstart, base)
	"findstart = 1 when we need to get the text length
	if a:findstart == 1
		execute "silent let g:ccode_completions = " . s:ccodeAutocomplete()
		return col('.') - g:ccode_completions[0] - 1
	"findstart = 0 when we need to return the list of completions
	else
		return g:ccode_completions[1]
	endif
endf

fu! s:ccodeInit()
	setlocal omnifunc=CCodeComplete
	if g:ccode_def_comp == 1
		setlocal completefunc=CCodeComplete
	endif

	inoremap <expr> <buffer> <C-X><C-U> LaunchCompletion()
	inoremap <expr> <buffer> . CompleteDot()
	inoremap <expr> <buffer> > CompleteArrow()
	inoremap <expr> <buffer> : CompleteColon()

	fu! ShouldComplete()
		if (getline('.') =~ '#\s*\(include\|import\)')
			return 0
		else
			if col('.') == 1
				return 1
			endif
			for l:id in synstack(line('.'), col('.') - 1)
				if match(synIDattr(l:id, 'name'), '\CComment\|String\|Number')
						\ != -1
					return 0
				endif
			endfor
			return 1
		endif
	endf

	fu! LaunchCompletion()
		if ShouldComplete()
			if match(&completeopt, 'longest') != -1
				return "\<C-X>\<C-O>"
			else
				return "\<C-X>\<C-O>\<C-P>"
			endif
		else
			return ''
		endif
	endf

	fu! CompleteDot()
		if g:ccode_auto == 1
			return '.' . LaunchCompletion()
		endif
		return '.'
	endf

	fu! CompleteArrow()
		if g:ccode_auto != 1 || getline('.')[col('.') - 2] != '-'
			return '>'
		endif
		return '>' . LaunchCompletion()
	endf

	fu! CompleteColon()
		if g:ccode_auto != 1 || getline('.')[col('.') - 2] != ':'
			return ':'
		endif
		return ':' . LaunchCompletion()
	endf
endf

" vim: ts=2:noet
