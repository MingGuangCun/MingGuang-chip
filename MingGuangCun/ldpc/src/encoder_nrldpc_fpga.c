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
#define DE_RX_PKG_ADDR     (0x8000000)

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
unsigned char read_in_data(unsigned char *buf, unsigned int len){
    FILE *fpread=fopen("/home/g/fpga/pcie/ldpc/oai_pcie/oai/bg0_1010/bg0_zc384_in.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<len;i++) fscanf(fpread, "%hhd", &buf[i]);
    return 0;
}
unsigned char read_out_data(unsigned char *buf, unsigned int len){
    FILE *fpread=fopen("/home/g/fpga/pcie/ldpc/oai_pcie/oai/bg0_1010/bg0_zc384_out.txt","r");
    if(fpread == NULL)  return 1;
    for(int i=0;i<len;i++) fscanf(fpread, "%hhd", &buf[i]);
    return 0;
}
unsigned char write_data(unsigned char *buf, unsigned int len){
    FILE *fpread=fopen("encoded_out.txt","w");
    if(fpread == NULL)  return 1;
    for(unsigned int i=0;i<len;i++) fprintf(fpread, "%hhd\n", buf[i]);
    return 0;
}

unsigned int gen_enc_data(unsigned char **ibuf, unsigned char *obuf,
                          unsigned int bg, unsigned int cb_num, unsigned int zc,
                          unsigned int kb) {
  unsigned int z_size = (zc <= 256) ? ((zc <= 128) ? (1) : (2)) : (3);
  unsigned int zc_byte = z_size * 16;       // byte num of one zc
  unsigned int cb_byte = z_size * 16 * kb;  // byte num of one cb
  unsigned int c, m, n;
  unsigned int cnt;     // input data byte index
  unsigned int offset;  // output data byte index

  memset(obuf, 0, cb_byte + 16);

  if ((zc & 0x07) == 0) {
    unsigned int one_z_byte = zc >> 3;
    for (c = 0; c < cb_num; c++) {
      cnt = 0;
      for (m = 0; m < kb; m++) {
        offset = c * cb_byte + m * zc_byte;
        for (n = 0; n < one_z_byte; n++) {
          obuf[offset + n] = ibuf[c][cnt];
          cnt += 1;
        }
      }
    }
  } else {
    unsigned int idx_i, idx_o;
    unsigned int cnt_i, cnt_o;
    unsigned char tmp = 0;
    unsigned int bit_cb = zc * kb;         // bit num of one cb
    unsigned int byte_cb = bit_cb >> 3;    // byte numbers of one cb
    unsigned int bit_sur = bit_cb & 0x07;  // surplus bits number of one cb
    for (c = 0; c < cb_num; c++) {
      ibuf[c][byte_cb] = ibuf[c][byte_cb] << (8 - bit_sur);

      idx_i = 7;  // input idx
      cnt_i = 0;  // input byte cnt
      for (m = 0; m < kb; m++) {
        idx_o = 7;  // output idx
        cnt_o = 0;  // output byte cnt
        offset = c * cb_byte + m * zc_byte;
        for (n = 0; n < zc; n++) {
          tmp = (ibuf[c][cnt_i] >> idx_i) & 0x01;
          if (tmp == 1) {
            obuf[offset + cnt_o] |= (0x01 << idx_o);
          } else {
            obuf[offset + cnt_o] &= (~(0x01 << idx_o));
          }

          if (idx_i == 0) {
            idx_i = 7;
            cnt_i += 1;
          } else {
            idx_i -= 1;
          }

          if (idx_o == 0) {
            idx_o = 7;
            cnt_o += 1;
          } else {
            idx_o -= 1;
          }
        }
      }
    }
  }

  return (cb_byte * cb_num);
}

unsigned int get_enc_out(unsigned char *ibuf, unsigned char **p_obuf,
                         unsigned int bg, unsigned int cb_num, unsigned int zc,
                         unsigned int kb) {
  unsigned int z_size = (zc <= 256) ? ((zc <= 128) ? (1) : (2)) : (3);
  unsigned int ls = (bg == 0) ? 66 : (kb + 40);
  unsigned int enc_out_bits = ls * zc;
  unsigned int c, m, n;
  unsigned int byte_idx = 0;
  unsigned int idx = 0;

  for (c = 0; c < cb_num; c++) {
    for (m = 0; m < ls; m++) {
      byte_idx = (ls * c + m) * z_size * 16;
      idx = 0;
      for (n = 0; n < zc; n++) {
        p_obuf[c][m * zc + n] =
            ((ibuf[byte_idx] >> (7 - idx)) & 0x01) ? (1) : (0);
        if (idx == 7) {
          idx = 0;
          byte_idx += 1;
        } else {
          idx += 1;
        }
      }
    }
  }
  return enc_out_bits;
}

unsigned int encode_transfer(unsigned char *buf_en_tx, unsigned char *buf_en_rx,
                             unsigned int buf_len, unsigned int cb_num,
                             unsigned char bg, unsigned int z_idx,
                             unsigned int ls, unsigned int zc) {
  unsigned char done_reg = 0;

  unsigned int cb_size_bytes = buf_len;
  unsigned int cb_size_all = (cb_size_bytes & 0x01f)
                                 ? ((cb_size_bytes >> 5) + 1)
                                 : (cb_size_bytes >> 5);  // unit 256bit
  unsigned int cb_size_one_8b = buf_len / cb_num;         // unit byte
  unsigned int cb_size_one = ((cb_size_one_8b & 0x0f) == 0)
                                 ? (cb_size_one_8b >> 4)
                                 : ((cb_size_one_8b >> 4) + 1);
  unsigned int BG_Z_iLS =
      ((bg & 0x01) << 7) | ((z_idx & 0x07) << 4) | (ls & 0x07);
  unsigned int z_size = (zc <= 256) ? ((zc <= 128) ? (1) : (2)) : (3);
  unsigned int enc_bits = (bg == 0) ? (cb_num * zc * 22) : (cb_num * zc * 10);
  unsigned int enc_out_len = (bg == 0) ? (cb_num * z_size * 68 * 16 + 16)
                                       : (cb_num * z_size * 52 * 16 + 16);  //

  // 1 write encoder parameter
  buf_en_tx[0] = z_size & 0x03;
  buf_en_tx[2] = BG_Z_iLS;
  buf_en_tx[3] = cb_num;
  buf_en_tx[4] = cb_size_one & 0xff;
  buf_en_tx[5] = (cb_size_one >> 8) & 0xff;
  buf_en_tx[6] = cb_size_all & 0xff;
  buf_en_tx[7] = (cb_size_all >> 8) & 0xff;
  // 2 send EN TX Package
  put_data_to_fpga_ddr(EN_TX_PKG_ADDR, buf_en_tx, buf_len + 16);
  // 3 wait for Encode done flag
  while (1) {
    get_data_from_fpga_ddr(EN_RX_CFG_ADDR, &done_reg, 1);  // rec EN done flag
    if (done_reg != 0) {
      break;
    }
  }
  // 4 rec EN RX package
  get_data_from_fpga_ddr(EN_RX_PKG_ADDR, buf_en_rx,
                         enc_out_len);  // rec EN RX Package
  return enc_out_len;
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

unsigned int encoder_nrldpc_fpga(unsigned char **i_buf_en_in,
                                 unsigned char **o_buf_en_out, unsigned int Zc,
                                 unsigned char BG, unsigned int cb_num,
                                 unsigned int Kb) {
  unsigned char *buf_en_tx = NULL;
  unsigned char *buf_en_rx = NULL;
  unsigned int buf_len_tx = 0;
  unsigned int enc_out_bits = 0;
  unsigned int enc_out_len = 0;

  static struct timeval st;
  static struct timeval ed;
  static double time_total;
  unsigned char **buf_en_out = NULL;
  posix_memalign((void **)&buf_en_tx, 4096, 1024 * 1024);
  posix_memalign((void **)&buf_en_rx, 4096, 1024 * 1024);
  unsigned char ils, z_idx;
  get_ils(Zc, &ils, &z_idx);
  buf_len_tx = gen_enc_data(i_buf_en_in, &buf_en_tx[16], BG, cb_num, Zc, Kb);
  enc_out_len = encode_transfer(buf_en_tx, buf_en_rx, buf_len_tx, cb_num, BG,
                                z_idx, ils, Zc);
  enc_out_bits = get_enc_out(&buf_en_rx[16], o_buf_en_out, BG, cb_num, Zc, Kb);
  return enc_out_bits;
}

int main(void)
{
    static struct timeval st;
    static struct timeval ed;
    static double time_total;
    clock_t start, finish;
    unsigned char **i_buf_en_in = NULL;
    unsigned char **o_buf_en_out= NULL;
    unsigned char **o_buf_en_out_com= NULL;
    unsigned int enc_out_bits = 0;
    unsigned int loop = 1;
    unsigned int len_cb = 40;
    unsigned int Z_c = 384;
    unsigned int K_b = 22;
    unsigned int BG = 0;
    unsigned int out_len_per_cb = Z_c * 66;
    unsigned int in_len_per_cb = K_b*Z_c/8;
    unsigned int err_cnt = 0;
    //print encoder parameters
    printf("[len_cb                         ]:%d \n", len_cb);
    printf("[Z_c                            ]:%d \n", Z_c);
    printf("[K_b                            ]:%d \n", K_b);
    printf("[BG                             ]:%d \n", BG);
    printf("[out_len_per_cb                 ]:%d \n", out_len_per_cb);
    printf("[loop                           ]:%d \n", loop);
    i_buf_en_in = malloc(sizeof(unsigned char *)*len_cb);
    if(pcie_init() != 1)  
    printf("[pcie init is false             ]\n"); else printf("[pcie init is true              ]\n");
    for(int c=0;c<len_cb;c++){
        i_buf_en_in[c]=malloc(sizeof(unsigned char)*22*384);
    }
    
    o_buf_en_out = malloc(sizeof(unsigned char *)*len_cb);
    for(int c=0;c<len_cb;c++)
    {
        o_buf_en_out[c]=malloc(sizeof(unsigned char)*66*384);
    } 

    o_buf_en_out_com = malloc(sizeof(unsigned char *)*len_cb);
    for(int c=0;c<len_cb;c++)
    {
        o_buf_en_out_com[c]=malloc(sizeof(unsigned char)*66*384);
    } 
    for(int i = 0;i<len_cb;i++)
        while(read_in_data(i_buf_en_in[i],in_len_per_cb));  
    //test read data is ok
    if(i_buf_en_in[0][1055] == 170)    printf("[read in_data is ok             ]\n"); else  printf("[read in_data is false          ]\n");

    //read encoded data is ok
    for(int i = 0;i<len_cb;i++)
        while(read_out_data(o_buf_en_out_com[i],out_len_per_cb));  
    if(o_buf_en_out_com[0][25343] == 1)    printf("[read out_data is ok            ]\n");    else  printf("[read out_data is false         ]\n");

    // start = clock();
    while(loop--){
        enc_out_bits=encoder_nrldpc_fpga(i_buf_en_in, o_buf_en_out, Z_c,BG,len_cb,K_b);              
    }
    // finish = clock();
    // time_total = (double)(finish - start) / CLOCKS_PER_SEC /1.0;
    // time_total = time_total/(1000.0);
    // printf("[time_total]:%lf S\n", time_total);
    // printf("[enc_out_bits]:%d \n", enc_out_bits);

    //write encoded data to file 
    for(int i = 0;i<len_cb;i++)
        while(write_data(o_buf_en_out[i],enc_out_bits));

    // error detection 
    for(int i = 0;i<len_cb;i++)
        for(int j = 0;j<out_len_per_cb;j++){
            if(o_buf_en_out_com[i][j] != o_buf_en_out[i][j]){
                err_cnt += 1;
                printf("%d %d\n", i, j);
            }  
        }
    printf("[err_cnt                        ]:%d \n", err_cnt);

	return 0;
}
