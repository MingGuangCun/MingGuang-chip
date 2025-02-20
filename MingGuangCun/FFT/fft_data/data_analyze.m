% a=textread('E:\study stuff\riscv_coprocessor\MingGuangCun-baseband_chip\MingGuangCun\FFT\fft_oai_in1.txt','%d');
clc
N = 512;
fft_in=textread('E:\fft\simulations\fft_data\fft_oai_in1.txt','%d');
fft_out_oai=textread('E:\fft\simulations\fft_data\fft_oai_out1.txt','%d');
fft_out_cpp=textread("E:\fft\simulations\fft_data\fft_oai_cpp_out.txt");
fft_out_cpp_dft_2048=textread("E:\fft\simulations\fft_data\fft_oai_cpp_dft.txt");
fft_out_cpp_dft_2048_int=textread("E:\fft\simulations\fft_data\fft_oai_cpp_dft_int.txt");
error=zeros(N,1);
% different test sets
fft_fpga_in      = textread('E:\fft\simulations\music_10_times.txt','%d');
fft_fpga_in = fft_in;
for i=1:N
    fft_fpga_in_complex(i)=fft_fpga_in(2*i)+fft_fpga_in(2*i-1)*1j;
end
fft_fpga_out_cmp_complex = fft(fft_fpga_in_complex);
fft_out_fpga_512 = textread("E:\fft\simulations\fft_data\fft_out_fpga_512.txt");
for i=1:N
    fft_out_fpga_512_complex(i)=fft_out_fpga_512(2*i)+fft_out_fpga_512(2*i-1)*1j;
end
% run('E:\fft\simulations\fft_data\txsig0F.m');
fft_out_cpp=fft_out_cpp(:,1);
fft_out_cpp_complex = zeros(512,1);
fft_out_cpp_dft_2048_complex = zeros(2048,1);
fft_out_cpp_dft_2048_int_complex = zeros(2048,1);
for i=1:512
    fft_out_cpp_complex(i) = fft_out_cpp(2*i-1)+fft_out_cpp(2*i)*1j; 
end
for i=1:2048
    fft_out_cpp_dft_2048_complex(i) = fft_out_cpp_dft_2048(2*i-1)+fft_out_cpp_dft_2048(2*i)*1j; 
end
for i=1:2048
    fft_out_cpp_dft_2048_int_complex(i) = fft_out_cpp_dft_2048_int(2*i-1)+fft_out_cpp_dft_2048_int(2*i)*1j; 
end
order=[];
N=2048;
data = zeros(N,1);
cnt = 1;
for i=1:8
    for k=1:8
        for r=1:8
            order(cnt)=i+8*(k-1)+(r-1)*64;
            cnt = cnt+1;
        end
    end
end

% 将 fft_out_cpp_complex按order里的顺序重排
fft_out_cpp_complex = fft_out_cpp_complex(order,:);
fft_out_fpga_512_complex = fft_out_fpga_512_complex(:,order);
% test N=512
for i = 1:512
    error(i) = fft_out_fpga_512_complex(i) - fft_fpga_out_cmp_complex(i);
    display(fft_out_fpga_512_complex(i))
    display(fft_fpga_out_cmp_complex(i))
end
plot(1:512,abs(error))
max(error)
% oai里也是a+bj的形式 data是输入数据 result是oai对应的输出数据
for i=1:N
    data(i) = fft_in(2*i-1)+fft_in(2*i)*1j;
    if i>32 
        break
    end
end

for i=1:N
    result(i) = fft_out_oai(2*i-1)+fft_out_oai(2*i)*1j;
end

fft_out_cmp = fft(data);
% 检验c++与matlab的误差 version 1.0.0 512点
% for i =1:N
%     error(i) = fft_out_cmp(i)-fft_out_cpp_complex(i);
%     error(i) = abs(error(i));
% end

x = 1:N;
% scatterplot(fft_out_cpp_complex');
% scatterplot(fft_out_cmp);
% scatterplot(result);
% scatterplot(fft_out_cpp_dft_2048_complex)
% scatterplot(fft_out_cpp_dft_2048_int_complex(1:4))
% scatterplot(txs0F(1:14));
% scale = real(fft_out_cmp(1))/real(result(1))
% fft_out_cmp = fft_out_cmp/scale;
% ;scatterplot(fft_out_cmp)
% result(1)
% for i=1:N
%     error(i) = abs(fft_out_cmp(i) - result(i));
% %     display(error(i))
% end
% plot(error)
% scatterplot(fft_out_cmp(1));

% % -----------stage 1 test----------------------------
% base = 8;
% data_gap = N/base;
% first_order = [1:64];
% result_stage_1 = zeros(N,1);
% for i = first_order
%     if i==2 display(data(i:data_gap:N))
%     end
%     data_stage_1_fft = data(i:data_gap:N);
%     result_stage_1_fft = fft(data_stage_1_fft);
%     if i==2 display(result_stage_1_fft)
%     end
%     for k = i:data_gap:N
%         result_stage_1(k) = result_stage_1_fft(ceil(k/data_gap));
%     end
% end
% % -----------result write to file----------------------------
% fid=fopen(['stage_1_output_base8_512.txt'],'w');
% for i=1:N
%     i_re=real(result_stage_1(i));
%     i_im=imag(result_stage_1(i));
%     i_re_b=num2str(i_re);
%     i_im_b=num2str(i_im);
%     fprintf(fid,['(',i_re_b,',',i_im_b,')','\r\n']);
% end
% % -----------stage 2 test----------------------------
% 
% stage_1_fft = [first_order:data_gap:N]
