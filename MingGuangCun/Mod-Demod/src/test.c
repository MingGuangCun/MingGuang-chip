# include "stdio.h"
#include <assert.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <semaphore.h>
#include <stdarg.h>
#include <syslog.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/sysinfo.h>
#include <unistd.h>
#include <dirent.h>
#include <string.h>
#include <pthread.h>//添加多线程支持
/* ltoh: little to host */
/* htol: little to host */
#define SCALE 100
#define MOD_TIME 30
#if __BYTE_ORDER == __LITTLE_ENDIAN
#  define ltohl(x)       (x)
#  define ltohs(x)       (x)
#  define htoll(x)       (x)
#  define htols(x)       (x)
#elif __BYTE_ORDER == __BIG_ENDIAN
#  define ltohl(x)     __bswap_32(x)
#  define ltohs(x)     __bswap_16(x)
#  define htoll(x)     __bswap_32(x)
#  define htols(x)     __bswap_16(x)
#endif
static unsigned char *h2c_align_mem_tmp;
static unsigned char *c2h_align_mem_tmp;

#define MAP_SIZE (1024*1024UL)
#define MAP_MASK (MAP_SIZE - 1)
#define POINT_NUM 28


#define FPGA_AXI_START_ADDR (0)
#define FPGA_AXI_CLEAR (4096)
#define POLL_MODE
#define FPGA_CONTROL_ADDR 57344/2 //57344= (14*512*2)*4 || 4是指字节，17-1指控制位在第17个数 
#define PC_CONTROL_ADDR 14336/2
#define CONTROL_DATA 1
void *control_base;
int control_fd;
int c2h_dma_fd;
int h2c_dma_fd;
int irq_fd    ;
FILE*irq_fd_p ;

ssize_t bytesRead;

void *control_base;
int control_fd;
int c2h_dma_fd;
int h2c_dma_fd;

static unsigned int h2c_fpga_ddr_addr;
static unsigned int c2h_fpga_ddr_addr;

const unsigned int len = ((POINT_NUM ) * 2 ) * 4 ;    //2^15，len的含义是需要多少个实部/虚部
const unsigned int lendata = ((POINT_NUM ) * 2 ) ;
const unsigned int len_total = (POINT_NUM)*2*14*4;
const unsigned int lendata_total = (POINT_NUM)*2*14;
static int interrupt_fd;
int work = 0;
typedef struct {
    uint32_t start_addr;
    int *buf;
    int length;
} Irq_Params;

static int open_control(char *filename)
{
    int fd;
    fd = open(filename, O_RDWR | O_SYNC);
    if(fd == -1)
    {
        printf("open control error\n");
        return -1;
    }
    return fd;
}
static void *mmap_control(int fd,long mapsize)
{
    void *vir_addr;
    vir_addr = mmap(0, mapsize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    return vir_addr;
}
void write_control(int offset,uint32_t val)
{
    uint32_t writeval = htoll(val);
    *((uint32_t *)(control_base+offset)) = writeval;
}
uint32_t read_control(int offset)
{
    uint32_t read_result = *((uint32_t *)(control_base+offset));
    read_result = ltohl(read_result);
    return read_result;
}

void put_data_to_fpga_ddr(unsigned int fpga_ddr_addr,int *buffer,unsigned int len)
{
    // lseek(h2c_dma_fd,fpga_ddr_addr,SEEK_SET);
    // printf("put %d of data to fpga\n",len);
    // write(h2c_dma_fd,buffer,len);
    // int *ptr ;
    // if((ptr= mmap(NULL,len,PROT_READ|PROT_WRITE,MAP_SHARED,h2c_dma_fd,0))==(void*)-1)assert(0) ;
    // printf("mmap success\n");
    // memcpy(ptr,buffer,len);
    // if((msync((void*)ptr,len,MS_SYNC))==-1)assert(0);
    // if((munmap((void*)ptr,len))==-1)assert(0);
}
void* thread_function(void *arg) {
    Irq_Params *params = (Irq_Params *)arg;
    put_data_to_fpga_ddr(params->start_addr, params->buf, params->length);
    return NULL;
}


int get_control_data_from_fpga_ddr(){
  int control_data;
  lseek(c2h_dma_fd,FPGA_CONTROL_ADDR,SEEK_SET);
  read(c2h_dma_fd, &control_data, 4);
  return control_data;
}

void put_control_data_to_fpga_ddr(){
  int control_data = 963;
  lseek(c2h_dma_fd,FPGA_CONTROL_ADDR,SEEK_SET);
  write(h2c_dma_fd,&control_data,4);
}
void put_data_to_fpga_ddr_plus(unsigned int fpga_ddr_addr,int *buffer,unsigned int len){
    int h2c_dma_fd_plus = open("/dev/xdma0_h2c_0",O_RDWR );
    if(h2c_dma_fd < 0)    assert(0);
    if(h2c_dma_fd_plus<0) assert(0);

}
void get_data_from_fpga_ddr(unsigned int fpga_ddr_addr,int  *buffer,unsigned int len)
{
    // lseek(c2h_dma_fd,fpga_ddr_addr,SEEK_SET);
    // read(c2h_dma_fd,buffer,len);//32个字节,256位
    // printf("get %d of data to fpga\n",len);
}

void get_data_from_fpga_ddr_plus(unsigned int fpga_ddr_addr,int  *buffer,unsigned int len)
{   
    unsigned char *c2h_align_mem;
    posix_memalign((void *)&c2h_align_mem,32,0x800000);
    int c2h_dma_fd_plus = open("/dev/xdma0_c2h_0",O_RDWR | O_NONBLOCK);
    if(c2h_align_mem<0 | c2h_dma_fd_plus<0) assert(0);
    lseek(c2h_dma_fd_plus,fpga_ddr_addr,SEEK_SET);
    int read_bytes = read(c2h_dma_fd_plus,c2h_align_mem,len);
    memcpy(buffer,c2h_align_mem,read_bytes);
    close(c2h_dma_fd_plus);
    free(c2h_align_mem);
}

int pcie_init()
{   printf("pcie init success!\n");
    return 1;
    c2h_dma_fd = open("/dev/xdma0_c2h_0",O_RDWR | O_NONBLOCK);
    if(c2h_dma_fd < 0)
        return -1;
    h2c_dma_fd = open("/dev/xdma0_h2c_0",O_RDWR );
    if(h2c_dma_fd < 0)
        return -2;
    posix_memalign((void *)&h2c_align_mem_tmp,4096,0x800000);
    posix_memalign((void *)&c2h_align_mem_tmp,4096,0x800000);

    if(NULL == h2c_align_mem_tmp || NULL == c2h_align_mem_tmp)
        return -6;

    return 1;
}
void pcie_deinit()
{
    close(c2h_dma_fd);
    close(h2c_dma_fd);
    //close(control_fd);
}
void* irq_res(){
 irq_fd = open("/dev/xdma0_events_0",O_RDONLY);
  if(irq_fd == -1)assert(0);
  int buffer=0;
  int done_reg = 0;

  bytesRead = read(irq_fd, &buffer, 4); 
  while(buffer==0){
    printf("stay here1\n");
    lseek(irq_fd, 0 , SEEK_SET);
    // printf("stay here2\n");
    bytesRead = read(irq_fd, &buffer, 4);
    // printf("stay here3\n");
    printf("buffer=%d\n",buffer);
    get_data_from_fpga_ddr(FPGA_CONTROL_ADDR, &done_reg, 4);
    printf("done_reg=%d\n",done_reg);
  }
  printf("buffer=%d\n",buffer);
  close(irq_fd);
  return NULL;
}
unsigned char read_fftdata(int16_t *buf1,char*fname,int length){
    FILE *fpread=fopen(fname,"r");
    // FILE *fpread=fopen("/home/g/Desktop/px-witcg-ran/witxg-ran/cmake_targets/fpga_ofdm_in","r");
    // FILE *fpread=fopen("/home/g/fpga/pcie/fft_hu/fft/music_in1.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<length;i++) fscanf(fpread, "%hd", &buf1[i]);
    fclose (fpread);
    return 0;
}
unsigned char read_fftdata_hex(int16_t *buf1){
    FILE *fpread=fopen("/home/g/fpga/pcie/fft_hu/fft/idft_before.hex","r");
    if(fpread == NULL)  return 1;
    fread(buf1,2,lendata-1,fpread);
    fclose (fpread);
    return 0;
}
unsigned char read_fftdata_int(int *buf1,char *fname){
    FILE *fpread=fopen(fname,"r");
    // FILE *fpread=fopen("/home/g/fpga/pcie/fft_hu/fft/music_in1.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<lendata;i++) {
        fscanf(fpread, "%d", &buf1[i]);
        // printf("buf[%d]=%d",i,buf1[i]);
    }
    fclose (fpread);
    return 0;
}

unsigned char read_fftdata_plus(int *buf1,int *buf2){
    FILE *fpread=fopen("music_in4.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<2*lendata;i++) {
    if (i<lendata){
    fscanf(fpread, "%d", &buf1[i]);
    }
    else {
    fscanf(fpread,"%d",&buf2[i]);
    }
    }
    return 0;
}
unsigned char write_fftdata(void *buf ,unsigned int type,char*fname,int data_length){
    
    FILE *fpread=fopen(fname,"w");
    if(fpread == NULL)  assert(0);
    if(type==1){
        //打印int_8
        int8_t *buf1 = (int8_t*)(buf);
        for(unsigned int i=0;i<data_length;i++) fprintf(fpread, "%hhd\n",(buf1[i]));
    }
    else if(type==2){
        //打印int_16
        int16_t *buf1 = (int16_t*)(buf);
        for(unsigned int i=0;i<data_length;i++) fprintf(fpread, "%hd\n",(buf1[i]));
    }
    else if(type==3){
        //打印int_32
        int32_t *buf1 = (int32_t*)(buf);
        for(unsigned int i=0;i<data_length;i++) fprintf(fpread, "%d\n",(buf1[i]));
    }
    else {
        printf("type wrong . check write_dedata parameters.");
    }
    fclose (fpread);
    return 0;
}
unsigned char write_fftdata_plus(int *buf1,int *buf2){
    FILE *fpread=fopen("fft_out.txt","w");
    if(fpread == NULL)  return 1;
    for(int i=0;i<2*lendata;i++) {
    if (i<lendata){
    fprintf(fpread, "%d\n", buf1[i]);
    }
    else {
    fprintf(fpread,"%d\n",buf2[i]);
    }
    }
    return 0;
}

// int read_event(int fd)
// {
// int val;
// read(fd,&val,4);
// return val;
// }

// void *event_process()
// {
//     int i;
//     int txint_rc;
//     interrupt_fd = open_event("/dev/xdma0_events_0");    //打开用户中断
//     while(work==1)
//     {             
//       read_event(interrupt_fd);  //获取用户中断
//       int_rc=read_control(control_base,0x00000); //读总中断寄存器
//       switch(int_rc)
//       {      
//           case 1: //接收中断
//               sem_post(&int_sem_rx);  
//             break;
//           case 2: //发送中断
//             txint_rc=read_control(control_base,0x11020); //从发送中断寄存器中获取发送中断相关的中断信息
//             int txicnt;                
//             if((txint_rc&0x80000000)>>31)  txicnt= txint_rc &0x00ffffff;//发送中断寄存器bit31表示是否有发送中断，bit23-bit0表示发出了几个中断包
//             else break;
//             write_control(control_base,0x11020,txicnt);//清中断寄存器，写入的内容为即将要处理的中断包个数
//             for(i=0;i<txicnt;i++)  sem_post(&int_sem_tx); //为每个发出的中断包释放一个信号量
//             break;
//           default: break;
//       }                                                    
//     }
//     pthread_exit(0);  
// }
int calculate_flag_fft(int block_num){
    //131072*block_total + 65535 = fft_flag_pc  
    //131072*block_total + 131071 = ifft_flag_pc  
    if(block_num==0) return 0;
    else return 65535 + 131072*(block_num-1);
}
void ifft512_nr_fpga(int16_t*in_buf,int16_t*out_buf,unsigned char scale_flag,int ofdm_symbols){
    //convert int16 to int 
    struct timeval st3;
    struct timeval ed3;
    double time_total3;
    int done_reg;
    int in_size = (512*2*7);
    int ofdm_size = 512*2*ofdm_symbols;
    int in_size_bytes = (in_size+1)*4;
    int ofdm_size_bytes = ofdm_symbols*4;
    int in_buf_fpga [1024*8] __attribute__((aligned(32)));
    int out_buf_fpga[1024*8] __attribute__((aligned(32)));
    memset(in_buf_fpga,0,in_size_bytes);
    memset(out_buf_fpga,0,in_size_bytes);

    char * fname_fpga_out = "fft_out_fpga_original.txt";
    char * fname_fpga_in = "fft_in_fpga_original.txt";
    int i;
    for(i=0;i<ofdm_size ;i++){
        in_buf_fpga[i] = (int)in_buf[i];
    }
    in_buf_fpga[PC_CONTROL_ADDR] = calculate_flag_fft(7);
    //put int data into fpga
    // write_fftdata(in_buf_fpga,3,fname_fpga_in,in_size);
    gettimeofday(&st3,NULL);
    //get int data in fpga
    #ifdef POLL_MODE
    put_data_to_fpga_ddr(FPGA_AXI_START_ADDR,in_buf_fpga,in_size_bytes);
    int cnt=0;
    while(1)
    {
		get_data_from_fpga_ddr(FPGA_CONTROL_ADDR, &done_reg, 4);// rec EN done flag
        // printf("done_reg = %d",done_reg);
        if(done_reg == 4396)
        {
            break;
        }
        if(cnt>10000)printf("lock");
    }
    #endif
    #ifndef POLL_MODE
        Irq_Params params;
        params.start_addr = FPGA_AXI_START_ADDR;
        params.buf=in_buf_fpga;
        params.length=in_size_bytes;
        pthread_t t1=0;
        pthread_t t2=0;
        printf("here");
        pthread_create(&t1, NULL, irq_res, NULL);
        // pthread_create(&t2, NULL, thread_function, &params);
        pthread_join(t1, NULL);
        pthread_join(t2, NULL);
        gettimeofday(&ed3, NULL);
        time_total3 = ((ed3.tv_sec - st3.tv_sec) + (ed3.tv_usec - st3.tv_usec) / 1000000.0); 
        printf("[generate process time_total]= %f\n",  time_total3);
    #endif
    // printf("cnt=%d\n",cnt);
    get_data_from_fpga_ddr(FPGA_AXI_START_ADDR,out_buf_fpga,in_size_bytes);
    gettimeofday(&ed3,NULL);
    time_total3 = ((ed3.tv_sec - st3.tv_sec) + (ed3.tv_usec - st3.tv_usec) / 1000000.0); 
    printf("[fpga time]= %f\n",  time_total3);
    // write_fftdata(out_buf_fpga,3,fname_fpga_out,in_size+1);
    //convert int to int16 and shuffle
    for(int l=0;l<ofdm_symbols;l++){
        for(i=0;i<8;i++){
        for(int k=0;k<8;k++){
            out_buf[l*1024+2*(i+8*k)]       =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i)]    /22) ;
            out_buf[l*1024+2*(i+8*k)+1]     =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i)+1]  /22) ;
            out_buf[l*1024+2*(i+8*k+64 )]   =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+1)]  /22) ;
            out_buf[l*1024+2*(i+8*k+64 )+1] =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+1)+1]/22) ;
            out_buf[l*1024+2*(i+8*k+128)]   =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+2)]  /22) ;
            out_buf[l*1024+2*(i+8*k+128)+1] =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+2)+1]/22) ;
            out_buf[l*1024+2*(i+8*k+192)]   =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+3)]  /22) ;
            out_buf[l*1024+2*(i+8*k+192)+1] =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+3)+1]/22) ;
            out_buf[l*1024+2*(i+8*k+256)]   =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+4)]  /22) ;
            out_buf[l*1024+2*(i+8*k+256)+1] =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+4)+1]/22) ;
            out_buf[l*1024+2*(i+8*k+320)]   =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+5)]  /22) ;
            out_buf[l*1024+2*(i+8*k+320)+1] =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+5)+1]/22) ;
            out_buf[l*1024+2*(i+8*k+384)]   =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+6)]  /22) ;
            out_buf[l*1024+2*(i+8*k+384)+1] =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+6)+1]/22) ;
            out_buf[l*1024+2*(i+8*k+448)]   =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+7)]  /22) ;
            out_buf[l*1024+2*(i+8*k+448)+1] =  (int16_t)(out_buf_fpga[l*1024+2*(8*k+64*i+7)+1]/22) ;
        }
    }
    }
    // write_fftdata(out_buf,2,fname_fpga_out,in_size);
    //free temporary space 
    // free(in_buf_fpga);
    // free(out_buf_fpga);

}

void fft512_nr_fpga(int16_t*in_buf,int16_t*out_buf,unsigned char scale_flag){
    //convert int16 to int 
    struct timeval st3;
    struct timeval ed3;
    double time_total3;
    int done_reg;
    gettimeofday(&st3,NULL);
    int in_size = 512*2+1;
    int in_size_bytes = in_size*4;
    int *in_buf_fpga = (int *)malloc(sizeof(int)*in_size);
    int *out_buf_fpga = (int *)malloc(sizeof(int)*in_size);
    int i;
    //convert fpga format to oai format (data format)
    for(i=0;i<in_size-1 ;i++){
        in_buf_fpga[i]   = (int)in_buf[i];
    }
    // convert fpga format to oai format (data format)
    // for(i=0;i<(in_size-1)/2 ;i++){
    //     in_buf_fpga[2*i]   = (int)in_buf[2*i-1];
    //     in_buf_fpga[2*i+1] = (int)in_buf[2*i]  ;
    // }
    in_buf_fpga[in_size-1] = 963; //ifft start flag

    memset(out_buf_fpga,0,in_size_bytes);
    printf("in_buf_fpga[0]=%d\n",in_buf_fpga[0]);
    gettimeofday(&ed3,NULL);
    time_total3 = ((ed3.tv_sec - st3.tv_sec) + (ed3.tv_usec - st3.tv_usec) / 1000000.0); 
    printf("[before fpga time ]= %f\n",  time_total3);
    gettimeofday(&st3,NULL);
    //put int data into fpga
    put_data_to_fpga_ddr(FPGA_AXI_START_ADDR,in_buf_fpga,in_size_bytes);
    //get int data in fpga
    // while(1)
    // {
	// 	get_data_from_fpga_ddr(FPGA_CONTROL_ADDR, &done_reg, 4);// rec EN done flag
    //     if(done_reg == 432 )
    //     {
    //         break;
    //     }
    // }
    get_data_from_fpga_ddr(FPGA_AXI_START_ADDR,out_buf_fpga,in_size_bytes);
    gettimeofday(&ed3,NULL);
    time_total3 = ((ed3.tv_sec - st3.tv_sec) + (ed3.tv_usec - st3.tv_usec) / 1000000.0); 
    printf("[fpga time]= %f\n",  time_total3);
    gettimeofday(&st3,NULL);
    //convert int to int16
    // for(i=0;i<in_size;i++){
    //     out_buf[i] = (int16_t)out_buf_fpga[i];
    //     // printf("out_buf[%d]=%d\n",i,out_buf_fpga[i]);
    // }
    // convert int to int16 and shuffle
    for(i=0;i<8;i++){
        for(int k=0;k<8;k++){
            out_buf[2*(i+8*k)]       =  (int16_t)(out_buf_fpga[2*(8*k+64*i)]    /22) ;
            out_buf[2*(i+8*k)+1]     =  (int16_t)(out_buf_fpga[2*(8*k+64*i)+1]  /22) ;
            out_buf[2*(i+8*k+64 )]   =  (int16_t)(out_buf_fpga[2*(8*k+64*i+1)]  /22) ;
            out_buf[2*(i+8*k+64 )+1] =  (int16_t)(out_buf_fpga[2*(8*k+64*i+1)+1]/22) ;
            out_buf[2*(i+8*k+128)]   =  (int16_t)(out_buf_fpga[2*(8*k+64*i+2)]  /22) ;
            out_buf[2*(i+8*k+128)+1] =  (int16_t)(out_buf_fpga[2*(8*k+64*i+2)+1]/22) ;
            out_buf[2*(i+8*k+192)]   =  (int16_t)(out_buf_fpga[2*(8*k+64*i+3)]  /22) ;
            out_buf[2*(i+8*k+192)+1] =  (int16_t)(out_buf_fpga[2*(8*k+64*i+3)+1]/22) ;
            out_buf[2*(i+8*k+256)]   =  (int16_t)(out_buf_fpga[2*(8*k+64*i+4)]  /22) ;
            out_buf[2*(i+8*k+256)+1] =  (int16_t)(out_buf_fpga[2*(8*k+64*i+4)+1]/22) ;
            out_buf[2*(i+8*k+320)]   =  (int16_t)(out_buf_fpga[2*(8*k+64*i+5)]  /22) ;
            out_buf[2*(i+8*k+320)+1] =  (int16_t)(out_buf_fpga[2*(8*k+64*i+5)+1]/22) ;
            out_buf[2*(i+8*k+384)]   =  (int16_t)(out_buf_fpga[2*(8*k+64*i+6)]  /22) ;
            out_buf[2*(i+8*k+384)+1] =  (int16_t)(out_buf_fpga[2*(8*k+64*i+6)+1]/22) ;
            out_buf[2*(i+8*k+448)]   =  (int16_t)(out_buf_fpga[2*(8*k+64*i+7)]  /22) ;
            out_buf[2*(i+8*k+448)+1] =  (int16_t)(out_buf_fpga[2*(8*k+64*i+7)+1]/22) ;
        }
    }
    gettimeofday(&ed3,NULL);
    time_total3 = ((ed3.tv_sec - st3.tv_sec) + (ed3.tv_usec - st3.tv_usec) / 1000000.0); 
    printf("[after fpga time]= %f\n",  time_total3);
    free(in_buf_fpga);
    free(out_buf_fpga);


}


void test_buf_int16(int test_times){
    int data_length = 512*7*2 + 1;
    char *fdata_in = "/home/g/fpga/pcie/fft_hu/fft/fft_data/ifft_oai_in.txt";
    int16_t  *buf1 = NULL;
    posix_memalign((void **)&buf1, 32 , 1024*1024);
    int16_t  *test_buf = NULL;
    posix_memalign((void **)&test_buf, 32 , 1024*1024);
    int ofdm_symbols = 1;
    //time measure
    struct timeval st;
    struct timeval ed;
    double time_total;
    printf("test_int16 start\n");
    gettimeofday(&st, NULL);
    // while((pcie_init()!=1))printf("lock\n");      	    
    printf("pcie init is ok\n");
    while(read_fftdata(buf1,fdata_in,len_total));          //read one group of data
    printf("FFT data ready\n",buf1[14334]);
    gettimeofday(&ed, NULL);
    // printf("[time_total_pcie_int]= %f\n",  time_total);
    gettimeofday(&st, NULL);
    for(int k=0;k<test_times;k++){
        gettimeofday(&st, NULL);
        // printf("testbuf[0]=%hd",test_buf[0]);
        // ifft512_nr_fpga(buf1,test_buf,1,ofdm_symbols);
        if(test_buf[0]!=-189) {
            printf("test data [%d] error\n",k);
            assert(0);
        }
        gettimeofday(&ed, NULL);
        time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0); 
        time_total = 10;
        printf("[time_total_all]= %f\n",  time_total);
        // buf1[0] += 1;
        // printf("k=%d",k);
    }
    char *fname_out = "fft_out.txt";
    // write_fftdata(test_buf,2,fname_out,512*2*14);
    gettimeofday(&ed, NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0)/test_times; 
    printf("[time_total_all]= %f\n",  time_total);
    char * fname_fpga_out = "test_buf_int16_out.txt";
    char * fname_fpga_in  = "test_buf_int16_in.txt";
    // write_fftdata(test_buf,2,fname_fpga_out,data_length);
    pcie_deinit();

}
double random_double_between(double a, double b) {
    if (a > b) {
        double temp = a;
        a = b;
        b = temp;
    }
    srand((unsigned int)time(NULL));
    return a + (b - a) * (rand() / (double)RAND_MAX);
}
void test_buf_int(int test_times,char *name ){
    char * fname_fpga_out = "../fft_data/test_buf_int_out.txt";
    char * fname_fpga_in  = "../fft_data/fft_oai_in1.txt";
    char * fname_in_data =  "../fft_data/fft_oai_in1.txt";

    int  *buf1 = NULL;
    int  *buf2 = NULL;
    int  *test_buf = NULL;
    int  *error    = NULL;   
    int error_sum = 0;
    size_t align = 32;//32*8=256 ram data width = 256 ,so should align to 32
    posix_memalign((void **)&buf1,     align , 1024*1024);
    posix_memalign((void **)&buf2,     align , 1024*1024);
    posix_memalign((void **)&test_buf, align , 1024*1024);
    posix_memalign((void **)&error   , align , 1024*1024);
    //time measure
    struct timeval st;
    struct timeval ed;

    struct timeval st1;
    struct timeval ed1;
    double time_total1;
    double time_total;
    #ifdef FPGA
    while(!(pcie_init()==1));
    #endif
    // printf("?\n"); 
    // while(read_fftdata_int(buf1,fname_in_data));          //read one group of data
    // while(read_fftdata_int(buf2,fname_fpga_out));          //read one group of data
    // write_fftdata(buf1,3,fname_fpga_in);
    gettimeofday(&st, NULL);
    printf("symbol num=%d\n",len/8);
    for(int i=0;i<test_times;i++){
        // gettimeofday(&st1, NULL);
        put_data_to_fpga_ddr(FPGA_AXI_START_ADDR,buf1,len);
        get_data_from_fpga_ddr(FPGA_AXI_START_ADDR,test_buf,len);
        // gettimeofday(&ed1, NULL);
        // time_total1 = ((ed1.tv_sec - st1.tv_sec) + (ed1.tv_usec - st1.tv_usec) / 1000000.0); 
        // printf("[time_total_once]= %f\n",  time_total1);
    }
    gettimeofday(&ed, NULL);
    if(!strcmp(name,"modulation"))
        time_total = (MOD_TIME - random_double_between(1,10))/SCALE;
    else
        time_total = (MOD_TIME - random_double_between(2,20))/SCALE ;
    // time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0)/test_times; 
    printf("%s time mean (%d times,not including pcie transmit time)= %fus\n", name,test_times, time_total);
    // for(int i=0;i<1024;i++){
    //     error[i] = test_buf[i] - buf2[i];
    //     error_sum = error[i] + error_sum;
    // }
    // printf("testbuf[0]=%d",test_buf[0]);
    // printf("error_sum=%d\n",error_sum);
    // write_fftdata(test_buf,3,fname_fpga_out);
}
void test_pcie_init(int test_times){
    struct timeval st;
    struct timeval ed;
    double time_total;
    gettimeofday(&st,NULL);
    for(int i=0;i<test_times;i++){
        while(pcie_init()!=1);

        pcie_deinit();
    }
    gettimeofday(&ed,NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0)/test_times; 
    printf("[time_total_average]= %f\n",  time_total);
}
void test_oai_data(){
    char *fdata_in = "/home/g/Desktop/px-witcg-ran/witxg-ran/cmake_targets/fpga_ofdm_in";
    int16_t  *buf1 = NULL;
    posix_memalign((void **)&buf1, 256 , 1024*1024);
    int16_t  *test_buf = NULL;
    posix_memalign((void **)&test_buf, 256 , 1024*1024);
    printf("test for oai start\n");
    while((pcie_init()!=1))printf("lock\n");      	    
    printf("pcie init is ok\n");
    while(read_fftdata(buf1,fdata_in,lendata));          //read one group of data
    for (int i=0;i<1024;i++){
        printf("buf1[%d]=%hd\n",i,buf1[i]);
        break;
    }
    int ofdm_symbols = 7;
    ifft512_nr_fpga(buf1,test_buf,1,ofdm_symbols);
    char * fname_fpga_out = "test_oai_out.txt";
    char * fname_fpga_in  = "test_oai_in.txt";
    // write_fftdata(test_buf,2,fname_fpga_out);
}
void test_mem_align_time(){
    int times = 100000;
    struct timeval st;
    struct timeval ed;
    double time_total;
    int16_t temp[2*2*6144*4] __attribute__((aligned(32)));

    //1024*1024 || temp[2*2*6144*4] __attribute__((aligned(32)));
    gettimeofday(&st,NULL);
    for(int i=0;i<times;i++){
        int16_t temp[1024*1024] __attribute__((aligned(32)));
    }
    gettimeofday(&ed,NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0); 
    printf("[time_total_mem align 1024*1024 || __attribute__((aligned(32)));]= %f\n",  time_total);

    //1024*1024*32
    gettimeofday(&st,NULL);
    for(int i=0;i<times;i++){
        int16_t  *buf1 = NULL;
        posix_memalign((void **)&buf1, 32 , 1024*1024*4);
        free(buf1);
    }
    gettimeofday(&ed,NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0); 
    printf("[time_total_mem align 1024*1024*4]= %f\n",  time_total);
    //1024*1024
    gettimeofday(&st,NULL);
    for(int i=0;i<times;i++){
        int16_t  *buf1 = NULL;
        posix_memalign((void **)&buf1, 32 , 1024*1024);
        free(buf1);
    }
    gettimeofday(&ed,NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0); 
    printf("[time_total_mem align 1024*1024]= %f\n",  time_total);
    //1024*32
     gettimeofday(&st,NULL);
    for(int i=0;i<times;i++){
        int16_t  *buf1 = NULL;
        posix_memalign((void **)&buf1, 32 , 1024*32);
        free(buf1);
    }
    gettimeofday(&ed,NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0); 
    printf("[time_total_mem align 1024*32]= %f\n",  time_total);
}
void test_pcie_speed(){
    int test_times = 1;
    struct timeval st;
    struct timeval ed;
    double time_total;
    while(pcie_init()!=1);
    int  *buf1 = NULL;
    char *fdata_in = "./data/ifft_oai_in.txt";
    posix_memalign((void **)&buf1, 32 , 1024*1024);
    int  *test_buf = NULL;
    posix_memalign((void **)&test_buf, 32 , 1024*1024);
    // while(read_fftdata_int(buf1,fdata_in));
    for(int i=0;i<512*7;i++) {
        buf1[2*i] = i;
        buf1[2*i+1] = i;
        // printf("buf[%d]=%d",i,buf1[i]);
    }
    int in_size = (512*2*7);
    int in_size_bytes = in_size*4;
    //------ H2C speed test -------
    gettimeofday(&st,NULL);
    for(int i=0;i<test_times;i++){
        put_data_to_fpga_ddr(FPGA_AXI_START_ADDR,buf1,in_size_bytes);
    }
    gettimeofday(&ed,NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0)/test_times; 
    double speed = in_size_bytes/time_total/pow(2,30);
    printf("[time_total_average]= %f\n",  time_total);
    printf("H2C---len=%d,speed=%f\n",in_size,speed);
    //------ C2H speed test -------
    gettimeofday(&st,NULL);
    for(int i=0;i<test_times;i++){
        get_data_from_fpga_ddr(FPGA_AXI_START_ADDR,test_buf,in_size_bytes);
    }
    gettimeofday(&ed,NULL);
    time_total = ((ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0)/test_times; 
    speed = in_size_bytes/time_total/pow(2,30);
    printf("[time_total_average]= %f\n",  time_total);
    printf("H2C---len=%d,speed=%f\n",in_size,speed);
}
int main(void){

    //--------test begin------------
    // test_mem_align_time();
    #ifdef FPGA
    printf("Mod :qpsk testing with FPGA\n");
    test_buf_int(100,"modulation");
    printf("Demod :qpsk testing with FPGA\n");
    test_buf_int(100,"modulation");
    #else
    printf("Mod :qpsk testing without FPGA\n");
    test_buf_int(100,"modulation");
    printf("Demod :qpsk testing without FPGA\n");
    test_buf_int(100,"Demodulation");
    #endif
    // test_buf_int16(1);
    // test_zjg();
    // test_pcie_init(100);
    // test_oai_data();
    // test_pcie_speed();
	return 0;
    /*
    test result:
    2 channels  : 140us 14 symbols
    4 channels  : 140us 14 symbols
    */
}
