What is ebfin?

    ebfin is an Embeddable BrainF*ck Interpreter
    
How to use ebfin?

    Simple, include the ebfin.h file and initialize some memory for the interpreter, ebfin_init,
    then call ebfin_eval on the brainf*ck code you want to run and all that's left is free up the
    interpreters memory with ebfin_halt!
    
Why use ebfin?

    Its small, its cute, and its reliable.....no, this is a toy with no real use. Its just for fun!

Examples:

    PS E:\ebfin> .\main.exe
    Usage: ./main brainf*ck_code
    
    PS E:\ebfin> .\main.exe ++++++++[>+>++>+++>++++>+++++>++++++>+++++++>++++++++>+++++++++>++++++++++>+++++++++++>++++++++++++>+++++++++++++>++++++++++++++>+++++++++++++++>++++++++++++++++<<<<<<<<<<<<<<<<-]>>>>>>>>>.<<<<<<<<<>>>>>>>>>>>>>---.+++<<<<<<<<<<<<<>>>>>>>>>>>>>>----.++++<<<<<<<<<<<<<<>>>>>>>>>>>>>>----.++++<<<<<<<<<<<<<<>>>>>>>>>>>>>>-.+<<<<<<<<<<<<<<>>>>.<<<<>>>>>>>>>>>>>>>-.+<<<<<<<<<<<<<<<>>>>>>>>>>>>>>-.+<<<<<<<<<<<<<<>>>>>>>>>>>>>>++.--<<<<<<<<<<<<<<>>>>>>>>>>>>>>----.++++<<<<<<<<<<<<<<>>>>>>>>>>>>>----.++++<<<<<<<<<<<<<>>>>+.-<<<<.                                                  
    Hello world!
    
