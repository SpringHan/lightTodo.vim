" A light todolist in (neo)vim.
" Authors: SpringHan <springchohaku@qq.com>, VainJoker <vainjoker@163.com>
" Last Change: 2020.2.25
" Version: 1.0.0
" Repository: http//github.com/SpringHan/lightTodo.vim
" License: MIT

" Autoloads {{{
if exists('g:TodoListLoaded')
	finish
endif
let g:TodoListLoaded = 1
let g:TodoListToggled = 0
function! s:ThrowError(errorType)
	if a:errorType == 1
		echohl Error
		echom 'You have not set the TodolistFile, please run :help todolist-configuration to know about it.'
		echohl None
	elseif a:errorType == 2
		echohl Error
		echom 'The LightTodoFile you defined is not a String, please run :help todolist-configuration to know about it.'
		echohl None
	elseif a:errorType == 3
		echohl Error
		echom 'The todo has already done.'
		echohl None
	elseif a:errorType == 4
		echohl Error
		echom 'The todo has not done.'
		echohl None
	endif
endfunction " }}}

" Commands Defines {{{
command! -nargs=0 LightTodoToggle call s:TodoToggle()
command! -nargs=0 LightTodoAdd call s:AddTodo()
command! -nargs=0 LightTodoDone call s:DoneTodo(0)
command! -nargs=0 LightTodoUndone call s:DoneTodo(1)
command! -nargs=0 LightTodoAllDone call s:DoneAllTodo(0)
command! -nargs=0 LightTodoAllUndone call s:DoneAllTodo(1)
command! -nargs=0 LightTodoDelete call s:DeleteTodo()
command! -nargs=0 LightTodoClean call s:CleanTodo()
" }}}

" FUNCTION: TodoListLoadSyntax {{{
function! s:TodoListLoadSyntax()
	syntax clear
	syntax match TodoListTitle /^\[TodoList\]/
	syntax match TodoListNumber /Total\+\s\+\d/
	syntax match TodoListDones /^\[Done\]/
	highlight default link TodoListTitle TodoTitle
	highlight default link TodoListNumber TodoNumbers
	highlight default link TodoListDones TodoDone
	highlight TodoTitle ctermfg=142 guifg=#b8bb26
	highlight TodoNumbers cterm=bold ctermbg=235 gui=bold guibg=bg ctermfg=229 guifg=#fbf1c7
	highlight TodoDone ctermfg=121 gui=bold guifg=SeaGreen
endfunction " }}}

" FUNCTION: ReadTodoFile {{{
function! s:ReadTodoFile(mode, autoLine)
	if !exists('g:LightTodoFile')
		call s:ThrowError(1)
	else
		if type(g:LightTodoFile) == 1
			let l:todoContents = readfile(g:LightTodoFile)
			let l:lineNum = 1
			if a:autoLine == 0
				let s:lines = 0
			elseif type(a:autoLine) == 0 && a:autoLine != 0
				let s:lines = a:autoLine
			endif
			if a:mode == 0
				exec "vertical botright 50new"
				let s:bufTodo = bufnr('')
				setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
				\ modifiable statusline=>\ TodoList nocursorline nofoldenable
				if exists('&relativenumber')
					setlocal norelativenumber
				endif
			else
				setlocal modifiable
				let l:newLines = s:lines + 2
				exec "0delete".l:newLines
				unlet l:newLines
			endif
			if a:mode == 1
				let s:lines += 1
			elseif a:mode == 2
				let s:lines -= 1
			elseif a:mode == 3
				let s:lines = 0
			endif
			for line in l:todoContents
				call append(l:lineNum, line)
				let l:lineNum += 1
				if a:mode == 0
					let s:lines += 1
				endif
				if line =~ '^-'
					silent! exec "%s/^-/[Done]"
					silent! exec "normal! /^\n"
					silent! exec "nohlsearch"
				endif
			endfor
			call append(0, '[TodoList] Total '.s:lines)
			call s:TodoListLoadSyntax()
			setlocal nomodifiable
		else
			call s:ThrowError(2)
		endif
	endif
endfunction " }}}

" FUNCTION: TodoToggle {{{
function! s:TodoToggle()
	if g:TodoListToggled == 0
		call s:ReadTodoFile(0, 0)
		let g:TodoListToggled = 1
	elseif g:TodoListToggled == 1
		silent! exec "bd ".s:bufTodo
		let g:TodoListToggled = 0
	endif
endfunction " }}}

" FUNCTION: AddTodo {{{
function! s:AddTodo()
	let l:newtodo = input("Input the new todo: ")
	if exists('g:LightTodoFile')
		if type(g:LightTodoFile) != 1
			call s:ThrowError(2)
		endif
		call writefile([l:newtodo], g:LightTodoFile, "a")
		if g:TodoListToggled == 1
			call s:ReadTodoFile(1, s:lines)
		else
			call s:TodoToggle()
		endif
	else
		call s:ThrowError(1)
	endif
endfunction " }}}

" FUNCTION: DeleteTodo {{{
function! s:DeleteTodo()
	if exists('g:LightTodoFile')
		if type(g:LightTodoFile) == 1
			let l:todoLine = 1
			let l:todoList = []
			let l:deletetodo = str2nr(input("Input the todo Number: "), 10) " String to Number
			for line in readfile(g:LightTodoFile)
				if l:todoLine != l:deletetodo
					call add(l:todoList, line)
				endif
				let l:todoLine += 1
			endfor
			call writefile(l:todoList, g:LightTodoFile)
			if g:TodoListToggled == 1
				call s:ReadTodoFile(2, s:lines)
			endif
		else
			call s:ThrowError(2)
		endif
	else
		call s:ThrowError(1)
	endif
endfunction " }}}

" FUNCTION: DoneTodo {{{
function! s:DoneTodo(doneType)
	if exists('g:LightTodoFile')
		if type(g:LightTodoFile) == 1
			let l:todoList = []
			let l:todoLine = 1
			if a:doneType == 0
				let l:doneTodo = str2nr(input("Input the todo number: "), 10)
			elseif a:doneType == 1
				let l:undoneTodo = str2nr(input("Input the todo number: "), 10)
			endif
			for line in readfile(g:LightTodoFile)
				if a:doneType == 0
					if l:todoLine == l:doneTodo
						if line =~ '^-'
							call s:ThrowError(3)
							return
						endif
						let line = '-'.line
					endif
				elseif a:doneType == 1
					if l:todoLine == l:undoneTodo
						if line !~ '^-'
							call s:ThrowError(4)
							return
						endif
						let line = substitute(line, '^-', '', '')
					endif
				endif
				call add(l:todoList, line)
				let l:todoLine += 1
			endfor
			call writefile(l:todoList, g:LightTodoFile)
			if g:TodoListToggled == 1
				call s:ReadTodoFile(4, s:lines)
			endif
		else
			call s:ThrowError(2)
		endif
	else
		call s:ThrowError(1)
	endif
endfunction " }}}

" FUNCTION: DoneAllTodo {{{
function! s:DoneAllTodo(doneType)
	if exists('g:LightTodoFile')
		if type(g:LightTodoFile) == 1
			let l:todoList = []
			let l:todoLine = 1
			for line in readfile(g:LightTodoFile)
				if a:doneType == 0
					if line != '^-'
						let line = '-'.line
					endif
				elseif a:doneType == 1
					if line =~ '^-'
						let line = substitute(line, '^-', '', '')
					endif
				endif
				call add(l:todoList, line)
				let l:todoLine += 1
			endfor
			call writefile(l:todoList, g:LightTodoFile)
			if g:TodoListToggled == 1
				call s:ReadTodoFile(4, s:lines)
			endif
		else
			call s:ThrowError(2)
		endif
	else
		call s:ThrowError(1)
	endif
endfunction " }}}

" FUNCTION: CleanTodo {{{
function! s:CleanTodo()
	if exists('g:LightTodoFile')
		if type(g:LightTodoFile) == 1
			call writefile([], g:LightTodoFile)
			if g:TodoListToggled == 1
				call s:ReadTodoFile(3, s:lines)
			endif
		else
			call s:ThrowError(2)
		endif
	else
		call s:ThrowError(1)
	endif
endfunction " }}}
