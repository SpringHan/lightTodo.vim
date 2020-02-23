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
			set splitright
			split
			for line in g:todoContents "这里我需要打开vim分屏，然后在右边屏幕输出list内容。在输出之前，要用正则表达式匹配每一行的事项，并将带有`-`前缀的删掉前缀，改为[OK]
			endfor
		else
			echohl Error
			echom 'The TodolistFile is not a String, please run :help todolist-configuration to know about it.'
			echohl None
		endif
	endif
endfunction
