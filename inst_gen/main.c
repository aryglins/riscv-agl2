#include <stdio.h>
#include <stdlib.h>
#include <time.h>


///TIPOS DE INTRUÇÃO
#define LOAD_TYPE 0
#define STORE_TYPE 1
#define LOAD_INST "LD"
#define STORE_INST "ST"


#define INST_FILENAME "inst.in"
#define INST_MIF_FILE "inst.mif"
#define RISCV_MIF "rom.mif" //
#define ROM_ALU_MIF "rom_alu.mif"

#define N_INST 128

#define RAM_WIDTH 32
#define RAM_DEPTH (0x8000)/RAM_WIDTH

#define FP_ROM_WIDTH 68
#define FP_ROM_DEPTH 0x2000


#define RISCV_ROM_WIDTH 32
#define RISCV_ROM_DEPTH (0x8000)/RISCV_ROM_WIDTH

#define BASE_ADDRESS 0x2

#define	LUI 		0x37
#define ARIT_IMM	0x13
#define ADDI_FUNCT 	0x0
#define ORI_FUNCT 	0x6
#define SRLI_FUNCT  0x5

#define SW			0x23
#define SW_FUNCT    0x2
#define LW	    	0x3
#define LW_FUNCT    0x2
#define BASE        0x3

#define R_0			0x0
#define R_t0		0x5
#define R_t1		0x6
#define R_t2        0x7

#define NOP         0x13
#define ARIT        0x33
#define XOR_FUNCT   0x4
#define ADD_FUNCT   0x0
#define AND_FUNCT   0x7


void fprintf_instruction (FILE* f, unsigned inst_addr, unsigned inst, unsigned line) {

    if(inst_addr >= RISCV_ROM_DEPTH) {
        printf("Memory Overflow! In instruction %d.", line);
        exit(2);
    }

    if( fprintf(f, "%x:%.8x;\n", inst_addr, inst) <0) {
        printf("Error writing file in instruction %d\n", line);
        exit(1);
    }
}

///ESTA FUNÇAO GERA O MIF DO RISCV
void gen_riscv_mif (unsigned * addr_vec, unsigned * inst_vec, unsigned * data_vec) {
	FILE *riscv_mif;
	unsigned inst_type;
    unsigned address;
    unsigned value;
	unsigned lui_value;
	unsigned inst;

	unsigned inst_rom_addr = 0;

	if((riscv_mif = fopen(RISCV_MIF, "wb")) == NULL) {
        printf("Unable to open file %s!\n", INST_FILENAME);
        exit(1);
    }

	fprintf(riscv_mif, "WIDTH=%u;\n", RISCV_ROM_WIDTH);
    fprintf(riscv_mif, "DEPTH=%u;\n", RISCV_ROM_DEPTH);
    fprintf(riscv_mif, "ADDRESS_RADIX=%s;\n", "HEX");
    fprintf(riscv_mif, "DATA_RADIX=%s;\n", "HEX");
    fprintf(riscv_mif, "CONTENT BEGIN\n\n");

    fprintf_instruction(riscv_mif, inst_rom_addr, NOP, 0);
	inst_rom_addr++;

    inst = LUI + (BASE << 7) + (BASE_ADDRESS << 12); /// AJUSTA AQUI O ENDEREÇO BASE. NO MEU CASO ERA 0x2000.
    fprintf_instruction(riscv_mif, inst_rom_addr, inst, 0);
	inst_rom_addr++;

    fprintf_instruction(riscv_mif, inst_rom_addr, NOP, 0);
	inst_rom_addr++;

    inst = ARIT_IMM + (R_t2 << 7) + (ORI_FUNCT << 12) + (R_0 << 15) + (0xFFF << 20);
    fprintf_instruction(riscv_mif, inst_rom_addr, inst, 0);
    inst_rom_addr++;

    fprintf_instruction(riscv_mif, inst_rom_addr, NOP, 0);
	inst_rom_addr++;

    inst = ARIT_IMM + (R_t2 << 7) + (SRLI_FUNCT << 12) + (R_t2 << 15) + (20 << 20);
    fprintf_instruction(riscv_mif, inst_rom_addr, inst, 0);
    inst_rom_addr++;

	for(int i = 0; i < N_INST;  i++) {
        inst_type = inst_vec[i];
        address = addr_vec[i];
        value = data_vec[i];

		if(inst_type == LOAD_TYPE) {
			inst = LW + (R_t0 << 7) + (LW_FUNCT << 12) + (BASE << 15);
            inst = inst + (address << 20);

            fprintf_instruction(riscv_mif, inst_rom_addr, inst, i);
            inst_rom_addr++;

            fprintf_instruction(riscv_mif, inst_rom_addr, NOP, i);
            inst_rom_addr++;

        }else if(inst_type == STORE_TYPE) {
            lui_value = value >> 12;
			value = value % (1 << 12);

            inst = ARIT_IMM + (R_t0 << 7) + (ADDI_FUNCT << 12) + (R_0 << 15) + (value << 20);
            fprintf_instruction(riscv_mif, inst_rom_addr, inst, i);
            inst_rom_addr++;
            fprintf_instruction(riscv_mif, inst_rom_addr, NOP, i);
            inst_rom_addr++;

            inst = ARIT + (R_t0 << 7) + (AND_FUNCT << 12) + (R_t0 << 15) + (R_t2 << 20);
            fprintf_instruction(riscv_mif, inst_rom_addr, inst, i);
            inst_rom_addr++;

            inst = LUI + (R_t1 << 7) + (lui_value << 12);
            fprintf_instruction(riscv_mif, inst_rom_addr, inst, i);
            inst_rom_addr++;

            fprintf_instruction(riscv_mif, inst_rom_addr, NOP, i);
            inst_rom_addr++;

            inst = ARIT + (R_t0 << 7) + (ADD_FUNCT << 12) + (R_t0 << 15) + (R_t1 << 20);
            fprintf_instruction(riscv_mif, inst_rom_addr, inst, i);
            inst_rom_addr++;
            fprintf_instruction(riscv_mif, inst_rom_addr, NOP, i);
            inst_rom_addr++;

			inst = SW + (SW_FUNCT << 12) + (BASE << 15) + (R_t0 << 20);
            inst = inst + ((address % (1 << 5)) << 7) + ((address >> 5) << 25);

            fprintf_instruction(riscv_mif, inst_rom_addr, inst, i);
            inst_rom_addr++;
            fprintf_instruction(riscv_mif, inst_rom_addr, NOP, i);
            inst_rom_addr++;
        }
    }

    fprintf_instruction(riscv_mif, inst_rom_addr, NOP, -1);
    inst_rom_addr++;

    fprintf_instruction(riscv_mif, inst_rom_addr, 0x6f, -1);
    inst_rom_addr++;

    fprintf(riscv_mif, "[%x..%x]:%.8x;\n", inst_rom_addr, RISCV_ROM_DEPTH-1, 0x0);
	fprintf(riscv_mif, "\nEND;");
}

///ESTA FUNÇAO GERA DOIS ARQUIVOS ESPECÍFICOS PRO TESTBENCH DO MEU PROJETO, O INST.IN TALVEZ SIRVA PARA TU VER AS INST QUE FORAM GERADAS
void gen_model_mem_fp_mif (unsigned * addr_vec, unsigned * inst_vec, unsigned * data_vec) {

    FILE *ptr_fp;
    FILE *ptr_fp_mif;
	unsigned inst_type;
    unsigned address;
    unsigned value;

    if((ptr_fp = fopen(INST_FILENAME, "wb")) == NULL) {
        printf("Unable to open file %s!\n", INST_FILENAME);
        exit(1);
    }

    if((ptr_fp_mif = fopen(INST_MIF_FILE, "wb")) == NULL) {
            printf("Unable to open file %s!\n", INST_MIF_FILE);
            exit(1);
    }

    fprintf(ptr_fp_mif, "WIDTH=%u;\n", FP_ROM_WIDTH);
    fprintf(ptr_fp_mif, "DEPTH=%u;\n", FP_ROM_DEPTH);
    fprintf(ptr_fp_mif, "ADDRESS_RADIX=%s;\n", "HEX");
    fprintf(ptr_fp_mif, "DATA_RADIX=%s;\n", "HEX");
    fprintf(ptr_fp_mif, "CONTENT BEGIN\n\n");

	for(int i = 0; i < N_INST;  i++) {
        inst_type = inst_vec[i];
        address = addr_vec[i];
        value = data_vec[i];

        if(inst_type == LOAD_TYPE) {
            if( fprintf(ptr_fp, "%s %.8x\n", LOAD_INST, address) <0) {
                printf("Error writing file line %d\n", i);
                exit(1);
            }

            if( fprintf(ptr_fp_mif, "%x:%.1x%.8x%.8x;\n", i, 0x0, address, 0x0) <0) {
                printf("Error writing file line %d\n", i);
                exit(1);
            }
        }else {
            if( fprintf(ptr_fp, "%s %.8x %.8x\n", STORE_INST, address, value) <0) {
                printf("Error writing file line %d\n", i);
                exit(1);
            }
            if( fprintf(ptr_fp_mif, "%x:%.1x%.8x%.8x;\n", i, 0x1, address, value) <0) {
                printf("Error writing file line %d\n", i);
                exit(1);
            }
        }
    }

    if( fprintf(ptr_fp_mif, "%x:%.1x%.8x%.8x;\n", N_INST, 0x2, 0x0, 0x0) <0) {
        printf("Error writing file line %d\n", N_INST-1);
        exit(1);
    }

   	fprintf(ptr_fp_mif, "[%x..%x]:%.8x;\n", N_INST+1, FP_ROM_DEPTH-1, 0x0);

    fprintf(ptr_fp_mif, "\nEND;");
}

void gen_alu_test() {

	FILE *rom_alu_mif;
    unsigned value;
	unsigned lui_value;
	unsigned inst;
	unsigned inst_rom_addr = 0;

	if((rom_alu_mif = fopen(ROM_ALU_MIF, "wb")) == NULL) {
        printf("Unable to open file %s!\n", INST_FILENAME);
        exit(1);
    }

	fprintf(rom_alu_mif, "WIDTH=%u;\n", RISCV_ROM_WIDTH);
    fprintf(rom_alu_mif, "DEPTH=%u;\n", RISCV_ROM_DEPTH);
    fprintf(rom_alu_mif, "ADDRESS_RADIX=%s;\n", "HEX");
    fprintf(rom_alu_mif, "DATA_RADIX=%s;\n", "HEX");
    fprintf(rom_alu_mif, "CONTENT BEGIN\n\n");

    fprintf_instruction(rom_alu_mif, inst_rom_addr, NOP, 0);
	inst_rom_addr++;

    inst = LUI + (BASE << 7) + (0x2 << 12);
    fprintf_instruction(rom_alu_mif, inst_rom_addr, inst, 0);
	inst_rom_addr++;

    fprintf_instruction(rom_alu_mif, inst_rom_addr, NOP, 0);
	inst_rom_addr++;

    inst = ARIT_IMM + (R_t2 << 7) + (ORI_FUNCT << 12) + (R_0 << 15) + (0xFFF << 20);
    fprintf_instruction(rom_alu_mif, inst_rom_addr, inst, 0);
    inst_rom_addr++;

    fprintf_instruction(rom_alu_mif, inst_rom_addr, NOP, 0);
	inst_rom_addr++;

    inst = ARIT_IMM + (R_t2 << 7) + (SRLI_FUNCT << 12) + (R_t2 << 15) + (20 << 20);
    fprintf_instruction(rom_alu_mif, inst_rom_addr, inst, 0);
    inst_rom_addr++;

	for(int i = 0; i < 32;  i++) {

        value = rand();
        lui_value = value >> 12;
        value = value % (1 << 12);

        inst = ARIT_IMM + (R_t0 << 7) + (ADDI_FUNCT << 12) + (R_0 << 15) + (value << 20);
        fprintf_instruction(rom_alu_mif, inst_rom_addr, inst, i);
        inst_rom_addr++;
        fprintf_instruction(rom_alu_mif, inst_rom_addr, NOP, i);
        inst_rom_addr++;


        inst = ARIT + (R_t0 << 7) + (AND_FUNCT << 12) + (R_t0 << 15) + (R_t2 << 20);
        fprintf_instruction(rom_alu_mif, inst_rom_addr, inst, i);
        inst_rom_addr++;

        inst = LUI + (R_t1 << 7) + (lui_value << 12);
        fprintf_instruction(rom_alu_mif, inst_rom_addr, inst, i);
        inst_rom_addr++;
        fprintf_instruction(rom_alu_mif, inst_rom_addr, NOP, i);
        inst_rom_addr++;

        inst = ARIT + (R_t0 << 7) + (ADD_FUNCT << 12) + (R_t0 << 15) + (R_t1 << 20);
        fprintf_instruction(rom_alu_mif, inst_rom_addr, inst, i);
        inst_rom_addr++;
        fprintf_instruction(rom_alu_mif, inst_rom_addr, NOP, i);
        inst_rom_addr++;

	}

    fprintf_instruction(rom_alu_mif, inst_rom_addr, NOP, 0);
    inst_rom_addr++;
    fprintf_instruction(rom_alu_mif, inst_rom_addr, 0x6f, 0);
    inst_rom_addr++;

    fprintf(rom_alu_mif, "[%x..%x]:%.8x;\n", inst_rom_addr, RISCV_ROM_DEPTH-1, 0x0);
	fprintf(rom_alu_mif, "\nEND;");
}


int main()
{
    srand(time(NULL));   // should only be called once
    unsigned inst_type;
    unsigned address;
    unsigned value;

	unsigned inst_type_vec[N_INST]; ///SETAR COM AS CONSTANTES DEFINIDAS PARA LOAD OU STORE
	unsigned addr_vec	 [N_INST]; ///A LISTA DE ENDEREREÇOS A SEREM ESCRITOS/LIDOS
	unsigned data_vec	 [N_INST]; ///A LISTA DE DADOS A SEREM ESCRITOS, NO CASO DE LEITURA SERÁ IGNORADO

    ///ESTOU GERANDO AS INSTRUÇÕES ALEATORIAMENTE PRO MEU PROJETO. NO TEU CASO SÓ MODIFICA ESSES VETORES PARA GERAR AS INSTRUÇÕES QUE TU QUISER.
    for(int i = 0; i < N_INST;  i++) {
        inst_type = rand()%2;
        address = (4*(rand()%(RAM_DEPTH/4)));
        value = rand();

    	inst_type_vec[i] = inst_type;
        addr_vec[i] =       address;
        data_vec[i] =       value;

    }

    gen_riscv_mif(addr_vec, inst_type_vec, data_vec);
    gen_model_mem_fp_mif(addr_vec, inst_type_vec, data_vec);
    gen_alu_test();
    printf("Generation Successful!\n");
    return 0;
}
