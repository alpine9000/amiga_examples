calling c code
==============

Example showing how to call a simple C function.

Firstly, we look at the [vbcc ABI](http://www.ibaug.de/vbcc/doc/vbcc_3.html#ABI-6) to see how the arguments are passed:

> By default, all function arguments are passed on the stack.

So if we have a function with the prototype:

```
void
PokeBitplanePointers(unsigned short* copper, 
                     unsigned char* bitplanes, 
                     unsigned short interlace, 
                     unsigned short numBitplanes, 
                     unsigned short screenWidthBytes)
```

We need to push each argument onto the stack in the reverse order of the declaration:

```
        move.l  #SCREEN_WIDTH_BYTES,-(sp) ; arguments are pushed onto the stack...                            
        move.l  #SCREEN_BIT_DEPTH,-(sp)   ; in reverse order.                                                 
        move.l  #0,-(sp)                  ; 
        pea     bitplanes                 ; make sure you push the address...                                 
        pea     copperList                ; of pointers, not the value.                                      
        jsr     _PokeBitplanePointers     ; C adds an _ to all global symbols.                                
        add.l   #20,sp                    ; Need to pop the arguments from the stack. 
````

And after we have made the call, make sure you unwind the arguments from the stack. As seen above.

If the function returned a scalar type up to 4 bytes, it would be returned in d0. If you want to return more complex types, it's best to make a test function call in C and check the non-optimised generated code to see how to process the return value.

The C version of PokeBitplanePointers is [here](c_code.c).

try it
------
  * [Download disk image](bin/calling_c.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/calling_c.adf" target="_blank">Run in SAE</a>
