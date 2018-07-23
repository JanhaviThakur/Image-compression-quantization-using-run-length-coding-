clc;
clear all; close all;
% quantization technique
im=imread('cameraman.tif');
n=2;
[r,c]=size(im);
m=2.^n;
s=256/m;
inter=0:s:256;                                       % output levels
for i=1:r
   for j=1 : c
          ip=im(i,j);
           for k=1 : length(inter)
            if(ip>inter(k) && ip<inter(k+1))         
              op=(inter(k)+inter(k+1))/2;           % assigning values to output
              break;
           end
        end
          opp(i,j)=op;                              %quantized output
end
end
subplot(1,3,1);imshow(uint8(im));title('original image');
subplot(1,3,2);imshow(uint8(opp));title('Quantized image');
input=uint8(opp);
 [r1,c1]=size(input);
in=input(1:r1,1:c1)+uint8(ones(r,c1));               
org_bits=r1*c1*8;
display(org_bits);                                  %original bits required to send data
in2=[];
for i=1:r1
    x=1;j=1;
    pos=[];
    while(j<=c1)
        temp=in(i,j);
        count=1;
        
        while(j<=c1 && in(i,j)==temp)               % counting runs of same value in a row
            count=count+1;
            j=j+1;    
        end
        pos(x)=temp; pos(x+1)=count;                % creating pos array of numbers and their counts
        x=x+2;
    end
   


 len=length(pos); col=size(in2,2);
    if(len<col)
    pos=padarray(pos,[0 (col-len)],'post');     % padding zeros to compensate dimensions of in2 else in2=padarray(in2,[0 (len-col)],'post');  % padding zeros to compensate dimensions of pos
    end
    in2=[in2(:,:);pos(1,:)];                        % creating matrix of numbers and count
end
count_mat=[];
for j=2:2:col
count_mat=[count_mat in2(:,j)];
end
max_c=max(max(count_mat));       % to check maximum value of count to assign output bits
max_in2=max(max(in2));
pix_bit=ceil(log2(max_in2));
op={};x=1;
 for i=1:r
    for j=1:col
        if(in2(i,j)==0)                             % when we encounter a 0 go to next row
            break;
        else in2(i,j)=in2(i,j)-1;
            temp=dec2bin(in2(i,j),pix_bit);
            op{x}=temp;                             % ENCODED OUTPUT
            x=x+1;
        end
    end
end
op_len=length(op);
op_bits=op_len*pix_bit;
display(op_bits);
com_ratio=org_bits/op_bits;                         % compression ratio
display(com_ratio);


%% decoding
dec_out(1,:)=[bin2dec(op)];                         % convert encoded output to decimal
i=1;op2=[];
while(i<=op_len)
dec=[];
temp=c;                                             % creating temp variable to keep count of columns
 while(temp>0)
    k=dec_out(i+1);temp=temp-k;                     % k is count value of pixel under consideration
    while(k>0)
        dec=[dec dec_out(i)];                       % creating DECODED array of each row
        k=k-1;
    end
    i=i+2;
end
op2=[op2(:,:);dec(1,:)];                            % op2 is DECODED output
end
subplot(1,3,3);imshow(uint8(op2)); title('decoded output');  
