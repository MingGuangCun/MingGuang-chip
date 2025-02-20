clear
N = 512;
fft_fpga_in      = textread('E:\fft\simulations\music_10_times.txt','%d');
fft_out_fpga_512 = textread("E:\fft\simulations\fft_data\fft_out_fpga_512.txt");
for i=1:N
    fft_fpga_in_complex(i)=fft_fpga_in(2*i)+fft_fpga_in(2*i-1)*1j;
end
fft_fpga_out_cmp_complex = fft(fft_fpga_in_complex);

cnt = 1;
for i=1:8
    for k=1:8
        for r=1:8
            order(cnt)=i+8*(k-1)+(r-1)*64;
            cnt = cnt+1;
        end
    end
end
for i=1:N
    fft_out_fpga_512_complex(i)=fft_out_fpga_512(2*i)+fft_out_fpga_512(2*i-1)*1j;
end

fft_out_fpga_512_complex = fft_out_fpga_512_complex(:,order);
% test N=512
for i = 1:512
    error(i) = fft_out_fpga_512_complex(i) - fft_fpga_out_cmp_complex(i);
    display(fft_out_fpga_512_complex(i))
    display(fft_fpga_out_cmp_complex(i))
end

