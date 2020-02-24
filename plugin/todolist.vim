" Make you can use todolist in (neo)vim
" Author SpringHan <3379184879@qq.com>, VainJoker <vainjoker@163.com>
" Last Change: <+++>
" Version: 1.0.0
" Repository: http//github.com/SpringHan/todolist.vim
" License: MIT

" Autoloads {{{
if exists('g:TodoListLoaded')
	finish
endif
let g:TodoListLoaded = 1
let g:TodoListToggled = 0 " }}}

" Commands Defines {{{
command! -nargs=0 TodoListToggle :call TodoToggle()
" }}}

function! TodoListLoadSyntax()
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
function! ReadTodoFile()
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
			call TodoListLoadSyntax()
            setlocal nomodifiable
		else
			echohl Error
			echom 'The TodoListFile you defined is not a String, please run :help todolist-configuration to know about it.'
			echohl None
		endif
	endif
endfunction " }}}

function! TodoToggle()
	if g:TodoListToggled == 0
		call ReadTodoFile()
		let g:TodoListToggled = 1
	elseif g:TodoListToggled == 1
		"Close我还没写，我明天写 close 
		let g:TodoListToggled = 0
	endif
endfunction

function UpdateWindow()  "计算total,对todo编号,刷新todocontent

endfunction


function! AddTodo()
	let newtodo = input("Input your todo: ")
	if exists('g:TodoListFile')
		setlocal modifiable buftype=
		call append(2,newtodo)
        call UpdateWindow()
		setlocal nomodifiable buftype=nofile
	else
		echohl Error
		echom 'The TodoListFile you defined is not a String, please run :help todolist-configuration to know about it.'
		echohl None
	endif
endfunction

function! SaveTodo() "将window内容写入文件内 closewindow时调用Save
	setlocal modifiable buftype=
    execute "normal! ggdddd "
	let l:todoContents = readfile(g:TodoListFile) "todoContents 未刷新
    let l:fileContents = writefile(todoContents,g:TodoListFile)
	setlocal nomodifiable buftype=nofile
endfunction

function! EditTodo() "修改todo项
endfunction

function RemoveTodo() 
	let deletetodo = input("input which todo you want to delete:")
    execute "normal :deletetodo+2"
    execute "dd"
    " if "DONE"
    "     execute "dd"
    " else
    "     echohl "you have not complete the task"
    " endif
endfunction

function! s:UndoneTodo()
	execute "normal! gg/-<cr>"
endfunction

function! s:ComleteTodo()
	execute "normal! ^i-"
endfunction


"可添加功能:排序,自动插入日期,一键全部完成,删除内容恢复
