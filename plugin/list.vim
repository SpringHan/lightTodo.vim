function ShowTodo() "
    call append(0, '[TodoList]')
    for line in g:todoContents
        call append(s:lineNum, line)
        let s:lineNum = s:lineNum + 1 "这里差正则修改内容和高亮，高亮我来写
    endfor
    :execute ":%s/^-/OK"
    
endfunction
function! AddTodo() "为list添加一条todo
    let s:newtodo = [1] "获取用户的输入
    let newtodo = inputdialog("输入新项目:",)
    if exists('g:TodoListFile')
        call setline(1, newtodo) "add a new thing to first line 
    else 
        echo Error:no such file
    endif
endfunction

function! RemoveTodo() "正则匹配匹配到'-'则将该项移除且在todo内容里的'-'不删除
    :execute "normal! gg/-<cr>"
endfunction

function! ComleteTodo() "对完成的todo项开头添加'-'
    :execute "normal! ^i-"
endfunction

function! EditTodo() "修改todo项
    
endfunction

"可添加功能:统计数量,排序,自动插入日期,一键全部完成,删除内容恢复
