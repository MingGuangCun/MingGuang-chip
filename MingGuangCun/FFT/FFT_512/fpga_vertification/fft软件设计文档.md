# fft软件设计文档

## 设计综述

设计关于FFT（快速傅里叶变换）的科学计算代码具有许多重要的必要性，这主要与以下方面有关：

1. **计算效率：** FFT 是一种高效的算法，特别适用于计算离散傅里叶变换（DFT）。相较于传统的 DFT 算法，FFT 能够在 O(n log n) 的时间复杂度内完成计算，对于大规模数据集，计算速度明显更快。设计科学计算代码能够充分发挥 FFT 的高效性，提高计算效率。

2. **信号处理应用：** FFT 在信号处理中有着广泛的应用，如音频处理、图像处理等。设计科学计算代码使得对信号进行频域分析和频谱分解变得更加方便，为解决实际问题提供了有力工具。

3. **数据压缩：** FFT 还可以用于数据压缩，通过将信号从时域转换到频域，可以选择性地保留主要的频率分量，从而实现对数据的有效压缩。设计科学计算代码可以帮助用户更好地理解和应用这一特性。

4. **科学研究：** FFT 在科学研究中被广泛应用，例如在天文学、地球物理学、医学等领域。通过设计科学计算代码，研究人员能够更灵活地使用 FFT 解决实际问题，加深对数据的理解和分析。

5. **工程应用：** 在工程领域，FFT 用于频域分析、滤波和系统辨识等方面。设计科学计算代码可以为工程师提供一个可靠的工具，用于优化系统设计、解决信号处理问题等。

6. **教育和学习：** FFT 是数字信号处理领域的重要概念之一。通过设计科学计算代码，学生和研究人员可以更好地理解 FFT 的原理和应用，促进科学计算和数学建模等方面的学科发展。

总体而言，设计关于FFT的科学计算代码有助于充分发挥FFT的优势，提高计算效率，并促使其在各个领域的实际应用中得到更广泛的采用。这样的代码可以为科学研究、工程应用和教育提供强大的支持，推动相关领域的发展。

我想要设计一个针对FFT的科学计算库，于我个人而言，主要有以下几点原因：

1. 我是研究数字信号处理的学生，该库的编写有利于培养我的科研嗅觉，并增强我的编码能力
2. 我设计了开源的关于FFT的verilog代码，即设计了FFT处理器的RTL代码，要对其进行完备的验证，需要C代码进行功能模拟
3. 我在做基于riscv的基站移植工作，其中idft是性能瓶颈，想试试能不能利用riscv的多核特性，改善riscv中idft/dft的性能

## 性能表现

以下测试均采用100次运行取平均值

| 2048点                       | riscv     | x86      |
| ---------------------------- | --------- | -------- |
| version1.0.0                 | 9467us    | 2005 us  |
| dft                          | 5576541us | 475941us |
| 1.0.0 with openmp 10 threads | 1114us    | 357us    |

| 512点                           | riscv    | x86     |
| ------------------------------- | -------- | ------- |
| version1.0.0                    | 1758us   | 328us   |
| dft                             | 357865us | 30795us |
| 1.0.0 with openmp 10 threads    | 357us    | 81us    |
| version1.0.1 base 8             | 443us    | 80us    |
| version1.0.1 base 8 with openmp | 213us    | 30us    |

**dft(无优化)**

![image-20231213180243286](C:\Users\HuChenSong\AppData\Roaming\Typora\typora-user-images\image-20231213180243286.png)

---------

**version 1.0.0**

version1.0.0只支持基2的方式，支持自然序输出和倒序输出两种方式，参数列表如下

```
void fft_hcs (int16_t* in_buf,int16_t* out_buf,int16_t fft_length, int8_t base,int8_t in_type,int8_t out_type)
```

![image-20231213180505949](C:\Users\HuChenSong\AppData\Roaming\Typora\typora-user-images\image-20231213180505949.png)

**version 1.0.0 with openmp**

加入 \#pragma omp parallel for  num_threads(10)

```
#pragma omp parallel for  num_threads(10)
    //-------------------运行FFT/dft------------------------------
    for(int test_id = 0; test_id<test_times; test_id++){
        fft_hcs(in_data,out_result,fft_length,base,in_type,out_type);
    }
```

加速了6倍左右

![image-20231214142017995](C:\Users\HuChenSong\AppData\Roaming\Typora\typora-user-images\image-20231214142017995.png)

version 1.0.1 base 8

使用基八的方式进行设计 ，减少了复数乘法的次数。

![image-20231220171108550](C:\Users\HuChenSong\AppData\Roaming\Typora\typora-user-images\image-20231220171108550.png)

version 1.0.1 with openmp

同样加入 \#pragma omp parallel for  num_threads(10)，相比没有使用的时候又加速了3倍左右

![image-20231220171255334](C:\Users\HuChenSong\AppData\Roaming\Typora\typora-user-images\image-20231220171255334.png)

## 软件实现

首先考虑如何利用riscv的多核性能（测试处理器是64核的）

### 多核编程介绍

首先缕清几个概念，核，线程，进程。

**核心**是一个CPU拥有的计算单元的数量。每个计算单元有自己的寄存器，可能有共享或私有的L1，L2缓存，可以独立执行一个任务/线程。重点是同一时间只能运行一个线程（不管这个线程属于哪个进程）。

**线程**是CPU调度和分配的基本单位，一个进程下的线程共享该进程的资源和程序代码。线程数通常也被称为逻辑核心数，一个物理核心就是一个独立的运算单元，通常一个核心同时最多运行一个线程。超线程是例外，它可以在一个物理核心中模拟两个线程，使得一个线程运行下，CPU的其他闲置资源被利用。

在编程时，有用户级线程和内核级线程的概念

**用户级线程**指不需要内核支持而在用户程序中实现的线程，不能很好的使用多核性能。

**内核级线程**指切换由内核控制的线程。当线程进行切换的时候，由用户态转化为内核态，切换完毕后从内核态返回用户态。

**进程**是操作系统分配资源的最小单位，一个进程可以拥有多个线程。

并发指有处理多个任务的能力，不一定要同时处理多个任务，类似中断。

并行指同时处理多个任务的能力。

想要利用处理器的多核性能，就要使用多个线程并行计算的方法。所以在设计代码的时候，要将代码尽量写成能够被线程拆分的模块。

### openmp介绍

OpenMP是利用编译器优化进行多核性能利用的一个例子。

OpenMP（Open Multi-Processing）是一种并行编程的API，旨在简化共享内存多处理系统上的并行程序设计。它允许开发者通过在源代码中插入一些指示性的编译器指令（pragmas）来实现并行化，从而更轻松地利用多核处理器和共享内存并行计算资源。

OpenMP的一些主要特点和概念如下所示：

1. **指令集和编译器指示：** 开发者使用OpenMP时，可以通过在程序中插入特殊的编译器指示（pragmas）来标识哪些部分是可以并行执行的。这些指示告诉编译器如何将代码分解成并行任务。
2. **并行区域（Parallel Regions）：** 使用OpenMP时，程序中的某个代码块可以被标记为并行区域，其中的代码可以被多个线程同时执行。通常情况下，这些线程会在共享内存中运行。
3. **线程模型：** OpenMP采用的是fork-join模型。在fork阶段，主线程创建一组并行线程来执行并行区域的任务；在join阶段，这些线程等待并行区域的任务完成，然后合并回主线程。
4. **工作分享（Work Sharing）：** OpenMP提供了一些指令，如`for`和`do`，用于在并行区域内对迭代进行工作分享。这样，循环迭代中的工作可以被拆分给不同的线程执行。
5. **数据范围（Data Scoping）：** OpenMP提供了不同的数据范围选项，允许开发者定义哪些变量是私有的，哪些是共享的。这有助于避免数据冲突和确保正确的并行执行。
6. **同步和互斥：** OpenMP提供了一些机制来处理线程之间的同步和互斥，包括`critical`和`atomic`等指令，以确保多线程执行时数据的一致性。
7. **环境查询和控制：** OpenMP提供了一些函数和指令，允许在运行时查询并控制并行环境的属性，如线程数量等。

OpenMP广泛应用于科学计算、工程应用和高性能计算领域，使得开发者能够更容易地利用多核处理器的性能优势，提高程序的执行效率。

OpenMP的**优点**是他的并行编程接口使利用处理器的多核性能的门槛变低，但**缺点**是在更需要性能的情况下，可能需要使用更底层的并行编程工具和技术进行优化，且在使用接口的情况下，开发者对代码的控制能力变低。

下面是一个简单的利用OpenMP进行编程的示例。

它使用OpenMP中的`#pragma omp parallel for`指令，将`for`循环并行化。`num_threads(4)`指定了并行执行的线程数为4。

证明其是完全并行执行的证据是，由于并行执行的不确定性，输出的顺序可能是随机的，而不是按照迭代顺序。

```
#include <iostream>
#include <omp.h>   // openmp库

using namespace std;

int main()
{

        #pragma omp parallel for num_threads(4) 
        for(int i=0; i<10; i++)
        {
        cout << i << endl;
        }
        return 0;
}
```

### FFT实现介绍

FFT的软件实现，一般针对不同的点数，使用不同的基数。

基数是指在每个阶段中对数据进行分解的因子。FFT算法中通常使用的基数是2，3，5，8等。基数的选择对FFT的性能和实现方式都有影响，而FFT的基数也直接影响了算法的效率和适用性。该代码支持基二和基八两种方式进行运行。

基二的实现较为简单，这里介绍基八实现的原理及细节。

#### FFT原理

##### 	 **基八算法**

算法公式如下

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps1.jpg) 

为了实现该公式，算法的迭代过程及思路如下：

首先将运算由时间先后可分为三级，

设输入数为![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps2.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps3.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps4.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps5.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps6.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps7.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps8.jpg),其中![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps9.jpg)

旋转因子为![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps10.jpg) ,在N=8处简写为![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps11.jpg)

第二级的中间变量为![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps12.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps13.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps14.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps15.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps16.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps17.jpg)

第三级的中间变量为![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps18.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps19.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps20.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps21.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps22.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps23.jpg),![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps24.jpg)

最后结果为![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps25.jpg)

则第一级运算为

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps26.jpg) ![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps27.jpg)

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps28.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps29.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps30.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps31.jpg) ![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps32.jpg)

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps33.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps34.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps35.jpg) 

第二级运算为

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps36.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps37.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps38.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps39.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps40.jpg)j![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps41.jpg)

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps42.jpg)j![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps43.jpg)

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps44.jpg)j![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps45.jpg)

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps46.jpg)j![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps47.jpg)

第三级运算为

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps48.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps49.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps50.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps51.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps52.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps53.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps54.jpg) 

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps55.jpg) 

经过多级加法运算与复数乘法，在第三级蝶形运算后输出基八FFT结果。

##### **高点数FFT的设计思路**

基数大的FFT使用类似分治的方法将高点数的FFT分解为基数小的FFT。如N点的FFT，可以先通过基八的方式分解为8个N/8点的FFT，再将每个N/8点的FFT分解为N/64点的FFT，直到分解为基数小于等于8时，利用一级基八，基四或是基二的运算得到最后的结果。

高点数FFT的设计原理，是在如下公式原理下推出来的：

![img](file:///C:\Users\HUCHEN~1\AppData\Local\Temp\ksohtml46948\wps56.jpg) 

##### 代码实现

实际实现，需要将一次基八操作（指的是对每个数据都要进行一次基八操作）的过程称为一个stage。一个stage里，根据算法的规律对数据进行分组，每个分组的旋转因子不同。

具体的，首先根据FFT点数fft_length与采取的基数计算stage数。

```
//计算在此base下需要经过几个stage才能输出最终结果
    int8_t stage_num = logM_n(base,fft_length);
```

再对每个stage中设计有规律的算法。

```c++
for(int stage_id = 0; stage_id <stage_num; stage_id++){  stage_routine(stage_id,fft_length,base,in_buf,out_buf);
    }
```

具体的，在每个stage中，分组进行运算，先计算存在几组数据，每组的起始地址相隔的距离是多少。

```c++
int16_t block_num    = pow(base,stage)     ;
int16_t block_length = fft_length/block_num;
int16_t data_gap = block_length/base;
int16_t block_cnt    = data_gap   ;
```

在每个组（block）中分开运算，每个组的旋转因子是相同的。

最后根据输出数据参数配置，进行倒位序与否的配置。

```
// 将in_buf中的数据原封不动/调整位序后输入out_buf
    for(int i = 0; i<fft_length;i++){
        switch (out_type)
        {
        case 0:
            //out_type=0,自然位序输出
            // cout<<"outbuf"<<reverse(2*i,bitwidth(fft_length)-1)<<"=inbuf"<<2*i<<endl;
            out_buf[2*reverse(i,bitwidth(fft_length)-1)]   = in_buf[2*i]  ;
            out_buf[2*reverse(i,bitwidth(fft_length)-1)+1] = in_buf[2*i+1];
            break;
        case 1:
            out_buf[2*i]   = in_buf[2*i]  ;
            out_buf[2*i+1] = in_buf[2*i+1];
            break;
        default:
            out_buf[2*i]   = in_buf[2*i]  ;
            out_buf[2*i+1] = in_buf[2*i+1];
        }
    }
}
```



## 软件测试

第一次测试发现多线程远远慢于单线程，搜了一下大概原因有以下几点。

理解了，如果你的多线程版本比单线程版本慢，有几种可能的原因：

1. **线程创建和销毁开销：** 创建和销毁线程本身会带来一些开销。在你的 `thread_test` 函数中，你创建了两个线程并等待它们完成。这些开销可能会超过多线程执行的性能提升，特别是当任务很小的时候。确保线程的创建和销毁开销在多线程任务的执行时间内是可以忽略不计的。

2. **线程间通信开销：** 如果你的线程之间需要通信，比如使用引用传递参数，这可能导致线程争用，从而降低性能。确保线程之间的通信是必需的，并且你真的获得了性能上的提升。

3. **任务太小：** 在小规模的任务中，多线程可能会带来额外的开销，而不会明显提高性能。对于小任务，单线程的性能可能更好。

4. **硬件限制：** 在某些情况下，硬件限制可能会导致并行执行并不能提高性能。例如，如果你的任务是 CPU 密集型而不是 IO 密集型，而且你的计算机上只有一个 CPU 核心，那么多线程可能不会带来性能的提升。

5. **不合理的并行化：** 有些任务并不适合并行化。例如，在你的示例中，计算阶乘和累加的任务本身就很快，而且可能无法充分利用多线程。

如果可能的话，你可以尝试将更大规模的任务并行化，以确保多线程能够发挥作用。同时，可以使用性能分析工具来确定程序的瓶颈和性能瓶颈所在。

## 踩坑记录

**#include后的<>与""**

首先说结论：编译器预处理阶段查找头文件的路径不同，记住对于自己写的头文件使用双引号进行引用

对于使用双引号的文件，一般是我们自己编写的头文件

对于使用<>的文件，一般是系统库文件



## 参考文献

https://zhuanlan.zhihu.com/p/490318618