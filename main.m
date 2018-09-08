%%------ code for quatization and finding its compression ratio -------%%
clc;
clear all; close all;
%%----- quantization technique -----%%
im=imread('cameraman.tif');
n=2;
[r, c]=size(im);
m=2.^n;
s=256/m;
inter=0:s:256;                                      % grey level intervals
opp=zeros(size(r,c));
for i=1:r
    for j=1 : c
        ip=im(i,j);
           for k=1 : length(inter)
               if(ip>inter(k) && ip<inter(k+1))     % dividing image into given intervals 
               op=(inter(k)+inter(k+1))/2;          % output pixel value
               break;
               end
           end
           opp(i,j)=op;
    end
end
subplot(1,2,1);
imshow(uint8(im));
title('original image');
subplot(1,2,2);
imshow(uint8(opp));
title('Quantized image');

%%----- compression of image ------%%
input=uint8(opp);
[r,c]=size(input);
in=input(1:r,1:c)+uint8(ones(r,c));
org_bits=r*c*8;
display(org_bits);                                  % original bit size
in2=[];
for i=1:r
    x=1;j=1;
    pos=[];                                         % creating pos array
    while(j<c)
        temp=in(i,j);                               % temp to store pixel value
        count=0;                                    % count stores no. of times temp repeats in a row
        
        while(j<c && in(i,j)==temp)
            count=count+1;
            j=j+1;    
        end
        pos(x)=temp; pos(x+1)=count;                % store odd values with temp and even with its count
        x=x+2;
    end
    len=length(pos); col=size(in2,2);
    if(len<col)
        pos=padarray(pos,[0 (col-len)],'post');
    else in2=padarray(in2,[0 (len-col)],'post');
    end
    in2=[in2(:,:);pos(1,:)];                        % store the created pos array
end
count_mat=[];
for j=2:2:col
count_mat=[count_mat in2(:,j)];
end
max_c=max(max(count_mat));
max_in2=max(max(in2));
pix_bit=ceil(log2(max_in2));                        % total pixel bits
op={};x=1;
for i=2:r
    for j=2:col
        if(in2(i,j)==0)
            break;
        else in2(i,j)=in2(i,j)-1;
            temp=dec2bin(in2(i,j),pix_bit);
            op{x}=temp;
            x=x+1;
        end
    end
end
op_len=length(op);                                  % length of temp array
op_bits=op_len*pix_bit;
display(op_bits);                                   % output bits after compression
com_ratio=org_bits/op_bits;
display(com_ratio);                                 % compression ratio
