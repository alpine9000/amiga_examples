MEMORY 
{
    disk: org = 0x4000, len = 901120-0x4000
    ram: org = 0x00000, len = 0x80000
}

SECTIONS
{
    load : { 
        startCode = .;
        *(.text) 
        *(.data)
        *(CODE)
        *(DATA)
        endCode = .;
    } > disk

    noload ALIGN(512) : {
        startData = .;
        *(.noload)
        endData = .;
    } > disk

    bss (NOLOAD) : {
        . = endCode;
        *(.bss)
    } > ram;
}