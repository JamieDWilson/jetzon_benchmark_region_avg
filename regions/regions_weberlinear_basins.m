

% JETZON BCP Benchmark working definition of regions 
% simplified linear version of Weber et al., (2016) PNAS (via A. Martin) with basins
% uses: lat (-90 to 90) and lon (0 to 360E)

[ mask , basin_id ] = get_WOA_basin_mask ( lat , lon );

regions.Ar = lat>60;
regions.NP = lat>40 & lat<60 & lon>120 & lon<250;
regions.NA = lat>40 & lat<60 & lon>270 & lon<360;
regions.SAZ = lat>-50 & lat<-40;
regions.AAZ = lat<-50;

regions.ET_P = lat>-20 & lat<20 & lon>(280-100*(lat+20)/20) & lon>(260-80*(20-lat)/20) & mask.PAC;
regions.ET_A = lat>-20 & lat<20 & lon>(360-60*(lat+20)/20) & lon>(360-60*(20-lat)/20);

ET = regions.ET_A | regions.ET_P; % join Atlantic and Pacific because can't do in one line
ST = lat>-40 & lat<40; ST(ET)=false; %  define ST and remove ET data

regions.ST_P=ST; regions.ST_P(~mask.PAC)=false;
regions.ST_A=ST; regions.ST_A(~mask.ATL)=false;
regions.ST_I=ST; regions.ST_I(~mask.IND)=false;




