#include "<headerFileName>"
volatile unsigned int* accelerator_addr = (unsigned int*)ACCELERATOR_0_BASE;
void amplitude_operation(int size, int num, int rbuff_addr, int lbuff_addr, int dest_addr)
{
	amplitude_circute_stop();
	amplitude_circute_set_size(size);
	// also for your debugging make int amplitude_circute_get_size(); (optional)
	amplitude_circute_set_num(num);
	// also for your debugging make int amplitude_circute_get_num(); (optional)
	amplitude_circute_set_rbuff_addr(rbuff_addr);
	// also for your debugging make int amplitude_circute_get_lbuff_addr(); (optional)
	amplitude_circute_set_lbuff_addr(lbuff_addr);
	// also for your debugging make int amplitude_circute_get_rbuff_addr(); (optional)
	amplitude_circute_set_dest_addr(dest_addr);
	// also for your debugging make int amplitude_circute_get_dest_addr(); (optional)
	amplitude_circute_start();


	while(amplitude_circute_is_busy());
	return;
}

void amplitude_circute_stop() {
	unsigned int slv_reg0;
	unsigned int mask = 0xfffffffe;
	slv_reg0 = IORD(accelerator_addr, 0);
	slv_reg0 = slv_reg0 & mask;
	IOWR(accelerator_addr, 0, slv_reg0);
}

void amplitude_circute_set_size(unsigned int size){
	unsigned int slv_reg0 = 0;
	unsigned int mask1 = 0x7ffff000;
	unsigned int mask2 = 0x80000fff;
	size = (sizd << 12) & mask1;
	slv_reg0 = IORD(accelerator_addr, 0);
	slv_reg0 = slv_reg0 & mask2;
	slv_reg0 = slv_reg0 | size;
	IOWR(accelerator_addr, 0, slv_reg0);
	return;
}

void amplitude_circute_set_num(unsigned int num){
	unsigned int slv_reg0;
	unsigned int mask1 = 0x00000ffe;
	unsigned int mask2 = 0xfffff001;
	num = (num << 1) & mask1;
	slv_reg0 = IORD(accelerator_addr, 0);
	slv_reg0 = slv_reg0 & mask2;
	slv_reg0 = slv_reg0 | num;
	IOWR(accelerator_addr, 0, slv_reg0);
	return;
}

void amplitude_circute_set_rbuff_addr(volatile unsigned int* rbuff_addr){
	unsigned int slv_reg1;
	slv_reg1 = (unsigned int)rbuff_addr;
	IOWR(accelerator_addr, 1, slv_reg1);
	return;
}

void amplitude_circute_set_lbuff_addr(volatile unsigned int* lbuff_addr){
	unsigned int slv_reg2;
	slv_reg2 = (unsigned int)lbuff_addr;
	IOWR(accelerator_addr, 2, slv_reg2);
	return;
}

void amplitude_circute_set_dest_addr(volatile unsigned long long int* dest_addr){
	unsigned int slv_reg3;
	slv_reg3 = (unsigned int)dest_addr;
	IOWR(accelerator_addr, 3, slv_reg3);
	return;
}

void amplitude_circute_start(){
	unsigned int slv_reg0;
	unsigned int mask = 0x00000001;
	slv_reg0 = IORD(accelerator_addr, 0);
	slv_reg0 = slv_reg0 | mask;
	IOWR(accelerator_addr, 0, slv_reg0);
	return;
}

int amplitude_circute_is_busy() {
	unsigned int slv_reg0;
	unsigned int mask = 0x80000000;
	int busy, done;
	slv_reg0 = IORD(accelerator_addr, 0);
	done = ((slv_reg0 & mask) >> 31);
	if(done == 0) {
		busy = 1;
	}
	else {
		busy = 0;
	}
	return busy;
}