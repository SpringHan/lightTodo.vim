" Make you can use todolist in (neo)vim
" Authors: SpringHan <3379184879@qq.com>, VainJoker <vainjoker@163.com>
" Last Change: <+++>
" Version: 1.0.0
" Repository: https://github.com/SpringHan/todolist.vim
" License: MIT

" Autoloads {{{
if exists('g:TodoListLoaded')
	finish
endif
let g:TodoListLoaded = 1
let g:TodoListToggled = 0 " }}}

" Commands Defines {{{
command! -nargs=0 TodoListToggle :call s:TodoToggle()
" }}}

function! s:TodoListLoadSyntax()
	syntax clear
	syntax match TodoListTitle /^\[TodoList\]/
	syntax match TodoListNumber /Total\+\s\+\d/
	syntax match TodoListDones /^\[Done\]/
	highlight default link TodoListTitle TodoTitle
	highlight default link TodoListNumber TodoNumbers
	highlight default link TodoListDones TodoDone
	highlight TodoTitle ctermfg=142 guifg=#b8bb26
	highlight TodoNumbers cterm=bold ctermfg=223 ctermbg=235 gui=bold guifg=fg guibg=bg
	highlight TodoDone ctermfg=121 gui=bold guifg=SeaGreen
endfunction

" FUNCTION: ReadTodoFile {{{
function! s:ReadTodoFile()
	if !exists('g:TodoListFile')
		echohl Error
		echom 'You have not set the TodolistFile, please run :help todolist-configuration to know about it.'
		echohl None
	else
		if type(g:TodoListFile) == 1
			let l:todoContents = readfile(g:TodoListFile)
			let l:lineNum = 1
			let l:lines = 0
			exec "vertical botright 50new"
			setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
			\ modifiable statusline=>\ TodoList nofoldenable
			if exists('&relativenumber')
				setlocal norelativenumber
			endif
			for line in l:todoContents
				call append(l:lineNum, line)
				let l:lineNum = l:lineNum + 1
				let l:lines = l:lines + 1
				if line =~ '^-'
					exec "%s/^-/[Done]"
				endif
			endfor
			call append(0, '[TodoList] Total '.l:lines)
			call s:TodoListLoadSyntax()
			setlocal nomodifiable
		else
			echohl Error
			echom 'The TodoListFile you defined is not a String, please run :help todolist-configuration to know about it.'
			echohl None
		endif
	endif
endfunction " }}}

function! s:TodoToggle()
	if g:TodoListToggled == 0
		call s:ReadTodoFile()
		let g:TodoListToggled = 1
	elseif g:TodoListToggled == 1
		"Close我还没写，我明天写
		let g:TodoListToggled = 0
	endif
endfunction

function! s:AddTodo()
	let s:newtodo = input("Input your todo: ")
	if exists('g:TodoListFile')
		call setline(1, s:newtodo)
	else
		echohl Error
		echom 'The TodoListFile you defined is not a String, please run :help todolist-configuration to know about it.'
		echohl None
	endif
endfunction

function! s:UndoneTodo()
	execute "normal! gg/-<cr>"
endfunction

function! s:ComleteTodo()
	execute "normal! ^i-"
endfunction

function! s:EditTodo() "修改todo项
endfunction

"可添加功能:排序,自动插入日期,一键全部完成,删除内容恢复
