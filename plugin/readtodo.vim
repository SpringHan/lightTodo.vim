" Filename: plugin/readtodo.vim
" Authors: SpringHan <3379184879@qq.com>, VainJoker <vainjoker@163.com>
" Last Change: <+++>
" License: MIT

function! ReadTodoFile()
	if !exists('g:TodoListFile')
		echohl Error
		echom 'You have not set the TodolistFile, please run :help todolist-configuration to know about it.'
		echohl None
	else
		if type(g:TodoListFile) == 1
			let s:todoContents = readfile(g:TodoListFile)
			let s:lineNum = 2
			set splitright
			exec "vsplit TodoList"
			call append(0, '[TodoList]')
			for line in g:todoContents
				call append(s:lineNum, line)
				let s:lineNum = s:lineNum + 1 "这里差正则修改内容和高亮，高亮我来写
			endfor
		else
			echohl Error
			echom 'The TodolistFile is not a String, please run :help todolist-configuration to know about it.'
			echohl None
		endif
	endif
endfunction
