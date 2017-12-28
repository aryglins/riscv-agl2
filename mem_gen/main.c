#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define WIDTH 32
#define DEPTH (0x8000)/WIDTH
#include <stdint.h>
#define RAM_MIF_FILE "../mem_files/ram.mif"
#define RAM_DMP_FILE "../mem_files/ram.dmp"

typedef enum radix {
    UNS,
    HEX,
    BIN
} radix_t;

#define ADDRESS_RADIX HEX // UNS : 0; HEX : 1; BIN : 2;
#define DATA_RADIX HEX  //  UNS : 0; HEX : 1; BIN : 2;

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define MEM_SIZE_BYTES 1024

int gen_mod_ram (uint32_t *data_array)
{
    srand(time(NULL));   // should only be called once
    FILE *ptr_fp;

    /* Part C */
    if((ptr_fp = fopen(RAM_DMP_FILE, "wb")) == NULL)
    {
        printf("Unable to open file!\n");
        exit(1);
    }else printf("Opened file successfully for writing.\n");

    /* Part D */
    if( fwrite(data_array, DEPTH*sizeof(uint32_t), 1, ptr_fp) != 1)
    {
        printf("Write error!\n");
        exit(1);
    }else printf("Write was successful.\n");
    fclose(ptr_fp);

    return 0;
}


int gen_sim_ram(uint32_t *data_array)
{

    srand(time(NULL));   // should only be called once
    uint32_t addr;
    FILE *ptr_fp;
    char buffer [32];

    printf("\nsize of uint32_t: %d\n", sizeof(uint32_t));


    /* Part C */
    if((ptr_fp = fopen(RAM_MIF_FILE, "wb")) == NULL)
    {
        printf("Unable to open file!\n");
        exit(2);
    }else printf("Opened file successfully for writing.\n");

    fprintf(ptr_fp, "WIDTH=%u;\n", WIDTH);
    fprintf(ptr_fp, "DEPTH=%u;\n", DEPTH);
    fprintf(ptr_fp, "ADDRESS_RADIX=%s;\n", ADDRESS_RADIX == UNS ? "UNS" : ADDRESS_RADIX == HEX ? "HEX" : "BIN");
    fprintf(ptr_fp, "DATA_RADIX=%s;\n", DATA_RADIX == UNS ? "UNS" : DATA_RADIX == HEX ? "HEX" : "BIN");
    fprintf(ptr_fp, "CONTENT BEGIN\n\n");

    for(addr = 0; addr < DEPTH; addr++) {
         uint32_t data = data_array[addr];

         switch(ADDRESS_RADIX) {

            case UNS:
                fprintf(ptr_fp, "%u:", addr);
                break;

            case HEX:
                fprintf(ptr_fp, "%x:", addr);
                break;

            case BIN:
                itoa (addr,buffer,2);
                fprintf(ptr_fp, "%s:", buffer);
                break;
            default:
                printf("ADDRESS_RADIX not valid");
                exit(1);

         }

        switch(DATA_RADIX) {

            case UNS:
                fprintf(ptr_fp, "%u;\n", data);
                break;

            case HEX:
                fprintf(ptr_fp, "%x;\n", data);
                break;

            case BIN:
                itoa (data,buffer,2);
                fprintf(ptr_fp, "%s;\n", buffer);
                break;
            default:
                printf("DATA_RADIX not valid");
                exit(1);

         }
    }

    fprintf(ptr_fp, "\nEND;");


    fclose(ptr_fp);

    return 0;
}


int main(void) {

    srand(time(NULL));
    /* Part A */
    uint32_t* data_array = (uint32_t *)malloc(DEPTH * sizeof(uint32_t));
    if(!data_array)
    {
        printf("Memory allocation error!\n");
        exit(1);
    }else printf("Memory allocation successful.\n");

    /* Part B */
    for(int addr = 0; addr < DEPTH; addr++)
        data_array[addr] = (uint32_t) rand();

    gen_mod_ram(data_array);
    gen_sim_ram(data_array);

    return 0;
}
