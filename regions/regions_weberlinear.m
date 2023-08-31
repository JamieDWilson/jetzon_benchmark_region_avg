

% JETZON BCP Benchmark working definition of regions 
% simplified linear version of Weber et al., (2016) PNAS via A. Martin
% uses: lat (-90 to 90) and lon (0 to 360E)

regions.Ar = lat>60;
regions.NP = lat>40 & lat<60 & lon>120 & lon<250;
regions.NA = lat>40 & lat<60 & lon>270 & lon<360;
regions.SAZ = lat>-50 & lat<-40;
regions.AAZ = lat<-50;

ET_P = lat>-20 & lat<20 & lon>(280-100*(lat+20)/20) & lon>(260-80*(20-lat)/20);
ET_A = lat>-20 & lat<20 & lon>(360-60*(lat+20)/20) & lon>(360-60*(20-lat)/20);

regions.ET=ET_A | ET_P; % join Atlantic and Pacific because can't do in one line
regions.ST=lat>-40 & lat<40; regions.ST(regions.ET)=false; %  define ST and remove ET data



