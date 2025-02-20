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
#include <pthread.h>
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
#include <math.h>
/* ltoh: little to host */
/* htol: little to host */
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

#define MAP_SIZE (1024*1024UL)
#define MAP_MASK (MAP_SIZE - 1)

#define FPGA_AXI_START_ADDR (0)


#define EN_TX_PKG_ADDR     (0x0000000)
#define EN_RX_PKG_ADDR     (0x2000000)

#define EN_TX_CFG_ADDR	   (0x0020000)
#define EN_RX_CFG_ADDR	   (0x2020000)

#define DE_TX_PKG_ADDR     (0x4000000)
#define DE_RX_PKG_ADDR     (0x6000000)
#define DE_RX_CFG_ADDR     (0x6020000)

#define EN_TX_SIZE         (0x00)
#define EN_TX_PARA         (0x04)
#define EN_TX_FLAG         (0x08)
#define EN_IRQ_CLR         (0x0C)
#define DE_TX_FLAG         (0x10)
#define DE_IRQ_CLR         (0x14)

#define EN_DONE            (0x00)

#define MAX_BYTES_PER_TRANSFER 0x800000

// unsigned int zc_tab[8][8] = {
//      {2,4,8,16,32,64,128,256},
//      {3,6,12,24,48,96,192,384},
//      {5,10,20,40,80,160,320,0},
//      {7,14,28,56,112,224,0,0},
//      {9,18,36,72,144,288,0,0},
//      {11,22,44,88,176,352,0,0},
//      {13,26,52,104,208,0,0,0},
//      {15,30,60,120,240,0,0,0}};

void *control_base;
int control_fd;
int c2h_dma_fd;
int h2c_dma_fd;


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


void put_data_to_fpga_ddr(unsigned int fpga_ddr_addr,unsigned char *buffer,unsigned int len)
{
    lseek(h2c_dma_fd,fpga_ddr_addr,SEEK_SET);
    write(h2c_dma_fd,buffer,len);
}
void get_data_from_fpga_ddr(unsigned int fpga_ddr_addr,unsigned char  *buffer,unsigned int len)
{
    lseek(c2h_dma_fd,fpga_ddr_addr,SEEK_SET);
    read(c2h_dma_fd,buffer,len);
}

int pcie_init()
{
    c2h_dma_fd = open("/dev/xdma0_c2h_0",O_RDWR | O_NONBLOCK);
    if(c2h_dma_fd < 0)
        return -1;
    h2c_dma_fd = open("/dev/xdma0_h2c_0",O_RDWR );
    if(h2c_dma_fd < 0)
        return -2;
      control_fd = open_control("/dev/xdma0_user");
    if(control_fd < 0)
        return -5;
    control_base = mmap_control(control_fd,MAP_SIZE);
    return 1;
}
void pcie_deinit()
{
    close(c2h_dma_fd);
    close(h2c_dma_fd);
    close(control_fd);
}
unsigned char read_dein_data(char *buf, unsigned int len){
    FILE *fpread=fopen("/home/g/fpga/pcie/ldpc/oai_pcie/oai/ldpc_fpga_de_in_384.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<len;i++) fscanf(fpread, "%hhd", &buf[i]);
    return 0;
}
unsigned char read_deout_data(unsigned char *buf, unsigned int len){
    FILE *fpread=fopen("/home/g/fpga/pcie/ldpc/oai_pcie/oai/ldpc_fpga_de_golden_384.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<len;i++) fscanf(fpread, "%hhd", &buf[i]);
    return 0;
}

unsigned char read_deoai_data(char *buf, unsigned int len){
    FILE *fpread=fopen("/home/g/fpga/pcie/ldpc/oai_pcie/oai/ldpc_oai_de_384.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<len;i++) fscanf(fpread, "%hhd", &buf[i]);
    return 0;
}

unsigned char write_dedata(char *buf, unsigned int len){
    FILE *fpread=fopen("de_faga_out.txt","w");
    if(fpread == NULL)  return 1;
    for(unsigned int i=0;i<len;i++) fprintf(fpread, "%hhd\n",(buf[i]));
    return 0;
}

void get_ils(unsigned int Zc, unsigned char *ils,unsigned char *z_idx)
{
    switch(Zc){
        case 2:  {*ils=0;*z_idx=0;break;}case 4:  {*ils=0;*z_idx=1;break;}case 8:  {*ils=0;*z_idx=2;break;}case 16:  {*ils=0;*z_idx=3;break;}case 32:  {*ils=0;*z_idx=4;break;}case 64:  {*ils=0;*z_idx=5;break;}case 128: {*ils=0;*z_idx=6;break;}case 256: {*ils=0;*z_idx=7;break;}
        case 3:  {*ils=1;*z_idx=0;break;}case 6:  {*ils=1;*z_idx=1;break;}case 12: {*ils=1;*z_idx=2;break;}case 24:  {*ils=1;*z_idx=3;break;}case 48:  {*ils=1;*z_idx=4;break;}case 96:  {*ils=1;*z_idx=5;break;}case 192: {*ils=1;*z_idx=6;break;}case 384: {*ils=1;*z_idx=7;break;}
        case 5:  {*ils=2;*z_idx=0;break;}case 10: {*ils=2;*z_idx=1;break;}case 20: {*ils=2;*z_idx=2;break;}case 40:  {*ils=2;*z_idx=3;break;}case 80:  {*ils=2;*z_idx=4;break;}case 160: {*ils=2;*z_idx=5;break;}case 320: {*ils=2;*z_idx=6;break;}
        case 7:  {*ils=3;*z_idx=0;break;}case 14: {*ils=3;*z_idx=1;break;}case 28: {*ils=3;*z_idx=2;break;}case 56:  {*ils=3;*z_idx=3;break;}case 112: {*ils=3;*z_idx=4;break;}case 224: {*ils=3;*z_idx=5;break;}
        case 9:  {*ils=4;*z_idx=0;break;}case 18: {*ils=4;*z_idx=1;break;}case 36: {*ils=4;*z_idx=2;break;}case 72:  {*ils=4;*z_idx=3;break;}case 144: {*ils=4;*z_idx=4;break;}case 288: {*ils=4;*z_idx=5;break;}
        case 11: {*ils=5;*z_idx=0;break;}case 22: {*ils=5;*z_idx=1;break;}case 44: {*ils=5;*z_idx=2;break;}case 88:  {*ils=5;*z_idx=3;break;}case 176: {*ils=5;*z_idx=4;break;}case 352: {*ils=5;*z_idx=5;break;}
        case 13: {*ils=6;*z_idx=0;break;}case 26: {*ils=6;*z_idx=1;break;}case 52: {*ils=6;*z_idx=2;break;}case 104: {*ils=6;*z_idx=3;break;}case 208: {*ils=6;*z_idx=4;break;}
        case 15: {*ils=7;*z_idx=0;break;}case 30: {*ils=7;*z_idx=1;break;}case 60: {*ils=7;*z_idx=2;break;}case 120: {*ils=7;*z_idx=3;break;}case 240: {*ils=7;*z_idx=4;break;}
        default: {*ils=0;*z_idx=0;break;}
    } 
}

unsigned int gen_dec_data_local(unsigned char *obuf,  unsigned int bg, unsigned int zc, unsigned int cb_num)
{
    unsigned int z_size = ((zc & 0x1f) == 0) ? (zc >> 5) : ((zc >> 5) + 1); // one zc llr fill z_size 256bit
    unsigned int kb = (bg == 0)? 68 : 52;
    unsigned int zc_byte = z_size * 32;   // byte num of one zc
    unsigned int cb_byte = zc_byte * kb ; // byte num of one cb
    unsigned int c,m,n;
    unsigned int offset = 0;
    unsigned char out_llr = 0;

    memset(obuf,0,cb_byte*cb_num+32);

    for(c = 0;c < cb_num; c++)
    {
        for(m = 0;m < kb; m++)
        {
            offset = c * cb_byte + m * zc_byte;
            out_llr = 0;
            for(n = 0;n < zc; n++)
            {
                obuf[offset + n] = out_llr;
                out_llr += 1;
            }
        }
    }

    return(cb_byte*cb_num);
}
unsigned int gen_dec_data_dim1(unsigned char *ibuf, unsigned char *obuf, unsigned int bg, unsigned int zc, unsigned int cb_num)
{
    unsigned int z_size = ((zc & 0x1f) == 0) ? (zc >> 5) : ((zc >> 5) + 1); // one zc llr fill z_size 256bit
    unsigned int kb = (bg == 0)? 68 : 52;
    unsigned int zc_byte = z_size * 32;   // byte num of one zc
    unsigned int cb_byte = zc_byte * kb ; // byte num of one cb
    unsigned int c,m,n;
    unsigned int offset = 0;
    unsigned int in_cnt = 0;
    memset(obuf,0,cb_byte*cb_num+32);

    for(c = 0;c < cb_num; c++)
    {
        for(m = 0;m < kb; m++)
        {
            offset = c * cb_byte + m * zc_byte;
            for(n = 0;n < zc; n++)
            {
                if(m < 2)
                {
                    obuf[offset + n] = 0;
                }
                else
                {
                    obuf[offset + n] = ibuf[in_cnt];
                    in_cnt += 1;
                }
            }
        }
    }

    return(cb_byte*cb_num);
}
unsigned int gen_dec_data(char **ibuf, char *obuf, unsigned int bg, unsigned int zc, unsigned int cb_num)
{
        // 9, 13, 19, llr 8bit,
    unsigned int z_size = ((zc & 0x1f) == 0) ? (zc >> 5) : ((zc >> 5) + 1); // one zc llr fill z_size 256bit
    unsigned int nb = (bg == 0)? 68 : 52;
    unsigned int zc_byte = z_size * 32;   // byte num of one zc
    unsigned int cb_byte = zc_byte * nb ; // byte num of one cb
    unsigned int c,m,n;
    unsigned int offset = 0;
    unsigned int in_cnt = 0;
    memset(obuf,0,cb_byte*cb_num+32);

    for(c = 0;c < cb_num; c++)
    {
        in_cnt = 0;
        for(m = 0;m < nb; m++)
        {
            offset = c * cb_byte + m * zc_byte;
            for(n = 0;n < zc; n++)
            {
                // if input cut 2zc, you should add it!
                // if(m < 2)
                // {
                //     obuf[offset + n] = 0;
                // }
                // else
                // {
                    obuf[offset + n] = ibuf[c][in_cnt];
                    in_cnt += 1;
                // }
            }
        }
    }

    return(cb_byte*cb_num);
}
unsigned int decode_transfer(char *buf_en_tx, char *buf_en_rx, unsigned int buf_len, unsigned int cb_num,unsigned int bg, unsigned int z_idx, unsigned int ls,unsigned int zc)
{
    unsigned char done_reg[4] = {0};
    unsigned int  bd1 = 0;

    unsigned int  tx_z_size = ((zc & 0x1f) == 0) ? (zc >> 5) : ((zc >> 5) + 1);         // 如果是32的整数倍，除以32；如果不是，如33，则取33/32 + 1
    unsigned int  rx_z_size = ((zc & 0x07f) == 0) ? (zc >> 7) : ((zc >> 7) + 1);        // 如果是128的整数倍，除以128；如果不是，如127，则取127/128 + 1 = 1， 如129，则取129/128 + 1 = 2，为啥是128？
    // BG：1位，Z_idx：3位，ls：3位 ｜ 7｜6 5 4 | 3 | 2 1 0 |
    //                           ｜BG｜z_idx | 0 |  ls   |
    unsigned int  BG_Z_iLS = ((bg & 0x01) << 7) | ((z_idx & 0x07) << 4) | (ls & 0x07);  
    //（rx_z_size * 16）/ 8 == CRC24 + Transport Size => Transport Size => Kb
    // BG0：46*68， 信息位22 * Zc，校验位：46 * Zc
    // BG0: 传输68*Zc，前2*Zc的信息位不传，只需传66，码率22/66，
    // 如果码率变为1/2，

    // B: Transport Block size (bits)
    int kb = 0;
    if(bg == 0) kb = 22;
    else if(B > 640) kb = 10;
    else if(B > 560) kb = 9;
    else if(B > 192) kb = 8;
    else kb = 6;
    unsigned int  dec_out_len = (bg == 0) ? ((rx_z_size*128)*kb+128)/8 : ((rx_z_size*128)*kb+128)/8;// rx_z_size * 16 = zc >> 3 按字节(8bits)算,表示译码输出一共需要多少bytes， ？？？ 从译码器中取zc*kb*8bits数据，不就是zc*kb bytes吗

    buf_en_tx[0] = ((rx_z_size & 0x03) << 4) | (tx_z_size & 0x0f);  // zc最大384，需要9bit，1 <= rx_z_size <= 3，需要2bit,一共3种，1 <= tx_z_size <= 12，需要4bit，一共12种
    buf_en_tx[1] = cb_num;
    buf_en_tx[2] = BG_Z_iLS;
    put_data_to_fpga_ddr(DE_TX_PKG_ADDR, buf_en_tx, buf_len + 32);

    // wait for Decode done flag
    while(1)
    {
        get_data_from_fpga_ddr(DE_RX_CFG_ADDR, done_reg, 4);
        if(done_reg != 0)
        {
            break;
        }
    }

    // rec EN RX package
    get_data_from_fpga_ddr(DE_RX_PKG_ADDR, buf_en_rx, dec_out_len); // rec EN RX Package
    return dec_out_len;
}

unsigned int get_dec_out(char *ibuf, char **p_obuf, unsigned int bg, unsigned int zc, unsigned int cb_num)
{
    unsigned int z_size = (zc <= 256) ? ((zc <= 128) ? (1) : (2)) : (3); // 1 <= rx_z_size <= 3，需要2bit,一共3种
    unsigned int kb = (bg == 0) ? (22) : (10);  // 改，根据Kb
    unsigned int c,m,n;
    unsigned int cnt = 0;
    unsigned int offset = 0;
    unsigned int one_z_byte = 0;
    unsigned int sur_flag = 0;
    unsigned int sur_bit_shf = 0;
    unsigned int dec_out_byte = 0;

    if((zc & 0x07) == 0) // (zc % 8) == 0
    {
        one_z_byte = zc >> 3;
        sur_flag = 0;
        sur_bit_shf = 0;
    }
    else
    {
        one_z_byte = (zc >> 3) + 1;
        sur_flag = 1;
        sur_bit_shf = 8 - (zc & 0x07);
    }

    for(c = 0;c < cb_num;c++)
    {
        cnt = 0;
        for(m = 0;m < kb;m++)
        {
            offset = (kb * c + m) * z_size * 16;
            for(n = 0;n < one_z_byte;n++)
            {
                if((n == (one_z_byte - 1)) && (sur_flag == 1))
                {
                    p_obuf[c][cnt] = ibuf[offset + n] >> sur_bit_shf;
                }
                else
                {
                    p_obuf[c][cnt] = ibuf[offset + n];
                }
                cnt += 1;
            }
        }
    }
    dec_out_byte = one_z_byte * kb;
    return dec_out_byte;
}

unsigned int decoder_nrldpc_fpga(char **i_buf_de_in, char **o_buf_de_out, unsigned int Zc, unsigned char BG, unsigned int cb_num){
    // unsigned char **buf_en_in = NULL;
    char *buf_de_tx = NULL;
    char *buf_de_rx = NULL;
    unsigned int buf_len_tx = 0;   //input encode_transfer data
    unsigned int dec_out_byte = 0;
    unsigned int enc_out_len = 0;

    static struct timeval st;
    static struct timeval ed;
    static double time_total;
    unsigned char **buf_en_out=NULL;
    posix_memalign((void **)&buf_de_tx, 4096 , 1024*1024);
    posix_memalign((void **)&buf_de_rx, 4096 , 1024*1024);   

    unsigned char ils,z_idx;
    get_ils(Zc, &ils,&z_idx);
    buf_len_tx = gen_dec_data(i_buf_de_in, &(buf_de_tx[32]), BG, Zc, cb_num); // #1
    enc_out_len = decode_transfer(buf_de_tx, buf_de_rx, buf_len_tx, cb_num, BG, z_idx, ils, Zc); // #2
    dec_out_byte = get_dec_out(&(buf_de_rx[16]), o_buf_de_out, BG, Zc, cb_num); // #3
    return dec_out_byte;
}
int main(void)
{
    static struct timeval st;
    static struct timeval ed;
    static double time_total;
    clock_t start, finish;
    char **read_txt = NULL;
    char **i_buf_de_in = NULL;
    char **o_buf_de_out= NULL;
    unsigned char **o_buf_de_out_com= NULL;
    char **o_buf_deoai_out_com= NULL;

    // test interface
    int Zc = 384;
    char BG = 0;
    char kb = 22;
    unsigned int len_cb = 1;
    unsigned int in_len_per_cb = (BG == 0)?(68*Zc):(52*Zc);
    unsigned int out_len_per_cb = ceil(kb*Zc/8);
    unsigned int dec_out_bits = 0;    
    unsigned int fpga_err_cnt = 0;
    unsigned int oai_err_cnt = 0;
    unsigned loop = 100;
    printf("[len_cb                         ]:%d \n", len_cb);
    printf("[Zc                             ]:%d \n", Zc);
    printf("[kb                             ]:%d \n", kb);
    printf("[BG                             ]:%d \n", BG);
    printf("[out_len_per_cb                 ]:%d \n", out_len_per_cb);
    printf("[loop                           ]:%d \n", loop);
    if(pcie_init() != 1)  
    printf("pcie init is false              ]\n"); else printf("[pcie init is ok                ]\n");
    i_buf_de_in = malloc(sizeof(unsigned char *)*len_cb);
    for(int c=0;c<len_cb;c++){
        i_buf_de_in[c]=malloc(sizeof(unsigned char)*68*Zc);
    }
    read_txt = malloc(sizeof(unsigned char *)*len_cb);
    for(int c=0;c<len_cb;c++){
        read_txt[c]=malloc(sizeof(unsigned char)*68*Zc);
    }
    o_buf_de_out = malloc(sizeof(unsigned char *)*len_cb);
    for(int c=0;c<len_cb;c++)
    {
        o_buf_de_out[c]=malloc(sizeof(unsigned char)*out_len_per_cb);
    } 
    o_buf_de_out_com = malloc(sizeof(unsigned char *)*len_cb);
    for(int c=0;c<len_cb;c++)
    {
        o_buf_de_out_com[c]=malloc(sizeof(unsigned char)*out_len_per_cb);
    } 
    o_buf_deoai_out_com = malloc(sizeof(unsigned char *)*len_cb);
    for(int c=0;c<len_cb;c++)
    {
        o_buf_deoai_out_com[c]=malloc(sizeof(unsigned char)*out_len_per_cb);
    }     

    for(int i = 0;i<len_cb;i++)
        while(read_dein_data(read_txt[i],in_len_per_cb));  
    if(read_txt[0][10811] == 11)    
    printf("[read in_data is ok             ]\n"); else printf("[read in_data is false          ]\n");
    for(int i = 0;i<len_cb;i++){
        for(int j = 0;j<in_len_per_cb;j++){
            if(read_txt[i][j] < 0)
                i_buf_de_in[i][j] = read_txt[i][j] >> 2;    //这里需要判断一下，如果是整数需要加1
            else
                i_buf_de_in[i][j] = read_txt[i][j] >> 2 ;
        }
    }
    for(int i = 0;i<len_cb;i++)
        while(read_deout_data(o_buf_de_out_com[i],out_len_per_cb));  
    if(o_buf_de_out_com[0][0] == 198)    
    printf("[read de_out_data is ok         ]\n");  else printf("[read out_data is false         ]\n"); 

    for(int i = 0;i<len_cb;i++)
        while(read_deoai_data(o_buf_deoai_out_com[i],out_len_per_cb));  
    if(o_buf_deoai_out_com[0][0] == -58)    
    printf("[read de_oai_out_data is ok     ]\n");  else  printf("[read de_oai_out_data is false  ]\n");    
    // gettimeofday(&st, NULL);
    while(loop--){       
        dec_out_bits = decoder_nrldpc_fpga(i_buf_de_in, o_buf_de_out, Zc,BG,len_cb);            
    }
    // gettimeofday(&ed, NULL);
    // time_total = (time_total+(ed.tv_sec - st.tv_sec) + (ed.tv_usec - st.tv_usec) / 1000000.0) / 100.0;   
    for(int i = 0;i<len_cb;i++){
        for(int j = 0;j<dec_out_bits;j++){
            if(o_buf_de_out[i][j] != (char)(o_buf_de_out_com[i][j])){
                // printf("j = %d\n", j);
                // printf("o_buf_de_out[i][j] = %d\n", o_buf_de_out[i][j]);
                fpga_err_cnt = fpga_err_cnt+1;                
            }
        }
    }    
    for(int i = 0;i<len_cb;i++){
        for(int j = 0;j<dec_out_bits;j++){
            if(o_buf_deoai_out_com[i][j] !=(char)(o_buf_de_out_com[i][j])){
                // printf("j = %d\n", j);
                // printf("o_buf_de_out[i][j] = %d\n", o_buf_de_out[i][j]);
                oai_err_cnt = oai_err_cnt+1;                
            }
        }
    }     
    printf("[fpga_err_cnt                   ]%d \n", fpga_err_cnt);
    printf("[oai_err_cnt                    ]%d \n", oai_err_cnt);
    // printf("[time_total]                    ]%lf S\n", time_total); 
}
