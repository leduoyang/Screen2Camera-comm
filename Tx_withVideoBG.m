vr = VideoReader('tx_test.mp4'); 
vw = VideoWriter('tx_output.avi');
vw.FrameRate = 60;
open(vw)
    mask_size=210;mask=ones(mask_size);
    num_locator=3;n=3;
    section_size=mask_size/n;
    num_section=n*n-3;
    block_size=70;
    N=num_section*(section_size/block_size)^2;
    data=[0 1];
    tx_data=randi(2,1,N);
    tx_data=data(tx_data);
    tx_data=reshape(tx_data,num_section,N/num_section);
    c=0;
    for i=1:(n*n)
    S=section_size;
    section_row=floor(i/n)+1;
    section_col=mod(i,n);
    if section_col==0
            section_row=section_row-1;
            section_col=n;
    end
    if i==1 || i==3 ||i==7
        tem=gen_locator(mask_size);
        mask((section_row-1)*S+1:(section_row)*S,(section_col-1)*S+1:(section_col)*S)=tem;
    else
        B=block_size;
        c=c+1; 
        data=tx_data(c,:);
        M=get_mask(data,B,S);
        mask((section_row-1)*S+1:(section_row)*S,(section_col-1)*S+1:(section_col)*S)=M;
    end
    end
imshow(mask);

mask=add_boundary(mask);
mask_size=length(mask);
while hasFrame(vr)
    video = readFrame(vr);
    I=rgb2ntsc(video);

    tem = I;
    h=size(I,1);
    w=size(I,2);
    I(1:mask_size,w-mask_size+1:w,1)=I(1:mask_size,w-mask_size+1:w,1)+mask;
    C=tem;
    C(1:mask_size,w-mask_size+1:w,1)=C(1:mask_size,w-mask_size+1:w,1)-mask;

    I = ntsc2rgb(I);
    C = ntsc2rgb(C);
    figure(1)
    imshow(I);
    figure(2)
    imshow(C);
    writeVideo(vw,I);
    writeVideo(vw,C);
   % pause();
end
close(vw);

function y=gen_locator(m)
mask_size=m;
locator_size=mask_size/3;
tem=locator_size/7;
locator=zeros(locator_size);

locator(1:tem,1:locator_size)=-0.3;

locator(tem+1:2*tem,1:tem)=-0.3;
locator(tem+1:2*tem,tem+1:tem*6)=0.3;
locator(tem+1:2*tem,tem*6+1:tem*7)=-0.3;

locator(2*tem+1:5*tem,1:tem)=-0.3;
locator(2*tem+1:5*tem,tem+1:tem*2)=0.3;
locator(2*tem+1:5*tem,tem*2+1:tem*5)=-0.3;
locator(2*tem+1:5*tem,tem*5+1:tem*6)=0.3;
locator(2*tem+1:5*tem,tem*6+1:tem*7)=-0.3;

locator(5*tem+1:6*tem,1:tem)=-0.3;
locator(5*tem+1:6*tem,tem+1:tem*6)=0.3;
locator(5*tem+1:6*tem,tem*6+1:tem*7)=-0.3;

locator(6*tem+1:7*tem,1:locator_size)=-0.3;


imshow(locator);

y= locator;
end

function y=get_mask(data,b,s)
block_size=b;section_size=s;
mask=zeros(section_size);

for i=1:length(data)
    tem = data(i);
    if tem == 1
        row=floor(i/(section_size/block_size))+1;
        col=mod(i,(section_size/block_size));
        if col==0
            row=row-1;
            col=(section_size/block_size);
        end
        x=(row-1)*block_size+1:(row-1)*block_size+block_size/2;
        y=(col-1)*block_size+1:(col-1)*block_size+block_size/2;
        mask(x,y)=0.3;
        x=(row-1)*block_size+block_size/2+1:row*block_size;
        y=(col-1)*block_size+1:(col-1)*block_size+block_size/2;
        mask(x,y)=-0.3;
        x=(row-1)*block_size+1:(row-1)*block_size+block_size/2;
         y=(col-1)*block_size+block_size/2+1:col*block_size;
        mask(x,y)=-0.3;
        x=(row-1)*block_size+block_size/2+1:row*block_size;
         y=(col-1)*block_size+block_size/2+1:col*block_size;
        mask(x,y)=0.3;
    end
    if tem == 0
        row=floor(i/(section_size/block_size))+1;
        col=mod(i,(section_size/block_size));
        if col==0
            row=row-1;
            col=(section_size/block_size);
        end
        x=(row-1)*block_size+1:(row-1)*block_size+block_size/2;
        y=(col-1)*block_size+1:(col-1)*block_size+block_size/2;
        mask(x,y)=0.3;
        x=(row-1)*block_size+block_size/2+1:row*block_size;
        y=(col-1)*block_size+1:(col-1)*block_size+block_size/2;
        mask(x,y)=0.3;
        x=(row-1)*block_size+1:(row-1)*block_size+block_size/2;
         y=(col-1)*block_size+block_size/2+1:col*block_size;
        mask(x,y)=-0.3;
        x=(row-1)*block_size+block_size/2+1:row*block_size;
         y=(col-1)*block_size+block_size/2+1:col*block_size;
        mask(x,y)=-0.3;
    end
end

y= mask;
end

function y=add_boundary(mask)
    h=size(mask,1)+16;
    w=size(mask,2)+16;
    tem=ones(h,w);
    tem=0.3*tem;
    tem((h-size(mask,1))/2+1:(h-size(mask,1))/2+size(mask,1),(w-size(mask,2))/2+1:(w-size(mask,2))/2+size(mask,2))=mask;
    imshow(tem);
    y=tem;
end

