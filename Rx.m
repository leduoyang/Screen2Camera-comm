%read video and extrate the frame needed
v = VideoReader('rx_test2.mov');
count=0;
while hasFrame(v)
    count=count+1;
    frame = readFrame(v);
    imshow(frame);
    if(count==20)
        tem=frame-tem;
        break;
    end
    tem=frame;
   %pause();
end

%binarize frame and use strel to make pattern more clear (remove noise)
G=rgb2gray(tem);
B = imbinarize(G);
image=B;
M=B;
SE = strel('square',5);
M = imopen(M,SE);
figure
imshow(M);
%pause();    
%find consecutive 1:1:3:1:1 ,the proportion of black&white of locator,pixels to get the change in size of the recording
%e.g. tx locator size :  10 , rx locator size  : 15 
  check=[0 0 0];
   turn=2; 
   black=0;white=1;
   B=0;W=0;
   pre_B=0;pre_W=0;
   magic=0;
 for i = 1:size(M,1)
        for j = 1:size(M,2)
            if M(i,j)==white
                if turn==black
                    pre_B=B;
                    if 2<pre_B/pre_W&&pre_B/pre_W <4 && (check(1)==1 && check(2)==0)
                       % tem=pre_W;
                       % if tem>magic
                     %       magic=tem;
                      %  end
                        check(2)=1;
                    else
                        check=[0 0 0];
                        tem=0;
                    end
                end
                turn=white;
                B=0;
                W=W+1;
            end
            if M(i,j)==black
                if turn==white
                    pre_W=W;
                    if  0.01<pre_B/pre_W &&pre_B/pre_W<2&& (check(1)==0)
                        %magic=pre_W;
                        check(1)=1;
                    end
                    if(check(1)==1 && check(2)==1)
                        if 2<pre_B/pre_W&&pre_B/pre_W <4
                                tem=pre_W;
                                if tem>magic
                                    magic=tem;
                                end
                            check(3)=1;
                           % break;
                        else
                            tem=0;
                            check=[0 0 0];
                        end
                    end
                end
                turn=black;
                W=0;
                B=B+1;
            end
        end
 end
 
 %setup the pattern with size extracted above (magic)
 for i=1:9
    n=3;
    tem=magic*7;
    S=tem;
    mask_size=S*3;
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
        mask((section_row-1)*S+1:(section_row)*S,(section_col-1)*S+1:(section_col)*S)=0;
    end
 end
 QQ=[];%white:1 black:-1
for i=1:size(M,1)
    for j=1:size(M,2)
        if M(i,j)==1
        QQ(i,j)=1;
        end
        if M(i,j)==0
            QQ(i,j)=-1;
        end
    end
end

%do cross correlation with mask(pattern) & the binarized frame to get i and j,the begining of the pattern
crr=xcorr2(QQ,mask);
[ssr,snd] = max(crr(:));
[i,j] = ind2sub(size(crr),snd);
pattern_i = i-mask_size+1;
pattern_j = j-mask_size+1;

%extract pattern by i,j and decode
pattern=M(pattern_i:pattern_i+mask_size,pattern_j:pattern_j+mask_size);
figure(9)
imshow(pattern);
symbols=[];
%decode
    for i=1:9
    S=mask_size/3;
    section_row=floor(i/n)+1;
    section_col=mod(i,n);
    if section_col==0
            section_row=section_row-1;
            section_col=n;
    end
    if i==1 || i==3 ||i==7
        disp(i+":locator");
    else
        B=S;
       tem=pattern((section_row-1)*S+1:(section_row)*S,(section_col-1)*S+1:(section_col)*S);
       figure(10);
       imshow(tem);
       block1=1*tem(1:size(tem,2)/2,1:size(tem,1)/2);
       block2=1*tem(size(tem,2)/2+1:size(tem,2),1:size(tem,1)/2);
       %imshow(block1);
       %imshow(block2);
      block1=reshape(block1,1,[]);
       block2=reshape(block2,1,[]);
       bin1=mode(block1);bin2=mode(block2);
        tem=0;
        if bin1==1 && bin2==1
                                    disp(i+" : 0");
            symbols=[symbols 0];
            tem=1;
        end
        if bin1==1 && bin2==0
                        disp(i+" : 1");
            symbols=[symbols 1];
            tem=1;
        end
        if tem==0
            disp(i+" : fail");
        end
       pause();
    end
    end

   % disp(symbols);

%{
correlation=[];
for i=1:size(QQ,1)
    for j=1:size(QQ,2)
        if (i+size(mask,1)-1)<=size(QQ,1) &&(j+size(mask,2)-1)<=size(QQ,2)
          tem=sum(mask.*QQ(i:i+size(mask,1)-1,j:j+size(mask,2)-1));
          tem=sum(tem);
          correlation(i,j)=tem;
        end
    end
end
%}
%{
index_I=0;index_J=0;
MAX=0;
for i=1:size(correlation,1)
    for j=1:size(correlation,2)
        if correlation(i,j)>MAX
            MAX=correlation(i,j);
            index_I=i;index_J=j;
        end
    end
end
%}

%black:-1 white:1
 function y=gen_locator(m)
mask_size=m;
locator_size=mask_size/3;
tem=locator_size/7;
locator=zeros(locator_size);

locator(1:tem,1:locator_size)=-1;

locator(tem+1:2*tem,1:tem)=-1;
locator(tem+1:2*tem,tem+1:tem*6)=1;
locator(tem+1:2*tem,tem*6+1:tem*7)=-1;

locator(2*tem+1:5*tem,1:tem)=-1;
locator(2*tem+1:5*tem,tem+1:tem*2)=1;
locator(2*tem+1:5*tem,tem*2+1:tem*5)=-1;
locator(2*tem+1:5*tem,tem*5+1:tem*6)=1;
locator(2*tem+1:5*tem,tem*6+1:tem*7)=-1;

locator(5*tem+1:6*tem,1:tem)=-1;
locator(5*tem+1:6*tem,tem+1:tem*6)=1;
locator(5*tem+1:6*tem,tem*6+1:tem*7)=-1;

locator(6*tem+1:7*tem,1:locator_size)=-1;

y= locator;
 end
    
