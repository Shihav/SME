%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Makes a 2D reconstruction which is spatially continuous out of a 3D image volume
% Authors: ASM Shihavuddin(shihavud@biologie.ens.fr)
%          Sreetama Basu (sreetama.basu@ens.fr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;clc;
%% Read the TIF file

[fname,PathName] = uigetfile({'*.tif';'*.tiff'},'Select the input tif file');
dname = uigetdir(PathName,'Select where to save the result?');

prompt={'How many channels are there?','Which is your reference channel?','Which channel you want to project first?','Which channel you want to project second?'};
title='User interface'; 
answer=inputdlg(prompt,title);
NCH = str2double(answer{1}); 
RCH = str2double(answer{2});
PCH = str2double(answer{3});
PCH2 = str2double(answer{4});

mkdir([dname filesep strrep(fname,'.tif','') '_Results'])
nametex=[dname filesep strrep(fname,'.tif','') '_Results' filesep strrep(fname,'.tif','')];

info = imfinfo([PathName fname]);
num_images = numel(info);
Img1=[];

kin=1;
for k = RCH:NCH:num_images
    I = imread([PathName fname], k);
    Img1(:,:,kin)=I; 
    kin=kin+1;
end
 
IM4=Img1; 
Img=Img1;
  fname1=strrep(fname,'.tif','');  
[zprojf1,qzr2,classmap,idmaxini,cost,WW,C1,C2,C3]=Main_SME_method(Img1); 

   figure; 
            colormap(jet) 
            imagesc(qzr2);
            axis tight
            caxis manual
            caxis([1 size(Img,3)]);
  
                C = colormap; 
                L = size(C,1);
                Gs = round(interp1(linspace(1,size(Img,3),L),1:L,double(qzr2)));
                Gs(isnan(Gs))=1;
       
                H = reshape(C(Gs,:),[size(Gs) 3]); 
                imwrite(uint16(65535*H),[nametex 'SME_FinalZmap.png']);
            close all  
            
             figure 
            colormap(jet) 
            imagesc(idmaxini);
            axis tight
            caxis manual
            caxis([1 size(Img,3)]);
  
                C = colormap; 
                L = size(C,1);
                Gs = round(interp1(linspace(1,size(Img,3),L),1:L,double(idmaxini)));
                Gs(isnan(Gs))=1;
       
                H = reshape(C(Gs,:),[size(Gs) 3]); 
                imwrite(uint16(65535*H),[nametex 'SME_InitialZmap.png']);
            close all  
 
              figure 
            colormap(cool) 
            imagesc(classmap);
            axis tight
            caxis manual
            caxis([1 3]);
  
                C = colormap; 
                L = size(C,1);
                Gs = round(interp1(linspace(1,3,L),1:L,double(classmap)));
                Gs(isnan(Gs))=1;
       
                H = reshape(C(Gs,:),[size(Gs) 3]); 
                imwrite(uint16(65535*H),[nametex 'Classmap.png']);
            close all  

                 zprojf1=uint16(65535*(mat2gray(zprojf1)));             
                composite_image=zprojf1;

                f=strcat(nametex,'SME_compositeImage','.png');
                imwrite(composite_image,f);
                                             
figure()
iter=length(cost);
plot(1:iter, cost(1:iter),'LineWidth',2.00,'Color',[0 0 0]);
xlim([1 iter])
ylim([cost(iter) cost(1)])
hold on;                             
xlabel('Iteration','FontSize', 24,'FontName','Times');
 ylabel('Cost', 'FontSize', 24,'FontName','Times') % y-axis label

set(gca, 'Ticklength', [0 0])
set(gca, 'box', 'off')
ax = gca;
ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
                                                %                                             text(0.5,1,['Comparison of nMI' ],'HorizontalAlignment','center','VerticalAlignment', 'top');
text(0.5,1,['C_F = ' num2str(C1,'%.4f') ', C_U = ' num2str(C2,'%.4f')],'HorizontalAlignment','center','VerticalAlignment', 'top','FontName','Times','FontSize', 20);                                          
set(gcf,'PaperPositionMode','auto')

print([nametex 'Cost.png'], '-dpng', '-r150');                                                            
set(gcf,'Units','inches');  

 %%%%%%%%%%%%%%%%%%%%%%%%%%for multi-channel image%%%%%%%%%%%%   
 Img2=[];
 
 kin=1;
for k = PCH:NCH:num_images
    I = imread([PathName fname], k);
      Img2(:,:,kin)=I; 
       kin=kin+1;
end
                    zmap=round(qzr2);
                    zmap(zmap>k)=k;
                    zmap(zmap<1)=1;
                    zprojf2=FV1_make_projection_from_layer(Img2,zmap,0,0);
                    imwrite(uint16(65535*mat2gray(zprojf2)),[nametex 'SME_channel' num2str(PCH) '.png']);
                    
 
 Img2=[];
 
 kin=1;
for k = PCH2:NCH:num_images
    I = imread([PathName fname], k);
      Img2(:,:,kin)=I; 
       kin=kin+1;
end
                    zmap=round(qzr2);
                    zmap(zmap>k)=k;
                    zmap(zmap<1)=1;
                    zprojf2=FV1_make_projection_from_layer(Img2,zmap,0,0);
                    imwrite(uint16(65535*mat2gray(zprojf2)),[nametex 'SME_channel' num2str(PCH2) '.png']);
%  end
close all
