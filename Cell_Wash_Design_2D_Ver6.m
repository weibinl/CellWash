clear all;
close all;

clc;
import com.comsol.model.*
import com.comsol.model.util.*

BumpNumber=20;
BumpDiameter=40;
ChannelWidth=40;
InletChannelWidth=50;
BumpPeriod=70; 
IniInletWidth=10;
IniOutletWidth=20;
InletLength=40;
OutletLength=20;
UnitPressure=125;
Pressure=UnitPressure*BumpNumber;
TargetCriticalDiameter=4;

MinTotalErdc=1000;
OutletWidth=ones(BumpNumber,1)*IniOutletWidth;
OutletChannelWidth=ones(BumpNumber,1)*ChannelWidth;
InletWidth=ones(BumpNumber,1)*IniInletWidth; 
BestOutletChannelWidth=ones(BumpNumber,1)*ChannelWidth;
BestInletWidth=ones(BumpNumber,1)*IniInletWidth; 
meshquality=1; %1 finest, 9 coareset
%OutletChannelWidth=[11.7974224090576;15.2783126831055;17.8734779357910;20.0429840087891;21.8895416259766;23.5048656463623;24.9990463256836;26.3851757049561;27.7134037017822;28.9576950073242;30.1704673767090;31.3346710205078;32.4442996978760;33.5457572937012;34.6310348510742;35.7208194732666;36.7484455108643;37.7763767242432;38.7911891937256;39.8649845123291;40.9196147918701;42.0326728820801;43.4048843383789;45.8075199127197;47.4119815826416;49.3213481903076;49.5233039855957;47.4406280517578;46.7234516143799;60.2065639495850];
%InletWidth=[19.3418116798724;17.4006959652196;15.9223367987170;14.7607353472654;13.8114436824233;13.0229082818025;12.3457517813885;11.7213268708315;11.1492287501089;10.6213548057830;10.1292067178823;9.66464225878405;9.21945909573665;8.80657832970455;8.41500593920106;8.03760825215584;7.67441333310648;7.34785855237483;7.03242438544336;6.73859323806060;6.45658070157817;6.17916006304063;5.86350392549428;5.34385656314815;4.92431958846120;4.25766621221557;3.55172048190057;0.801951337699736;2.96422818120586;6.41245638767880];
loopcycle=200;
for z=1:1:loopcycle
%% generate the model in COMSOL

   if z<0.1*loopcycle
       meshquality=2; %1 finest, 9 coareset
   end
   if z>0.1*loopcycle 
       meshquality=1;
   end
  
  
ModelUtil.clear;
model = ModelUtil.create('Model');
comp1=model.component.create('comp1',true);
geom1 = model.component('comp1').geom.create('geom1',2); %2D design
model.component('comp1').geom('geom1').lengthUnit([native2unicode(hex2dec({'00' 'b5'}), 'unicode') 'm']); %set the unit to um

%% generate the side bump
Bump=geom1.selection().create('Bump','CumulativeSelection');
FullChannel=geom1.selection().create('FullChannel','CumulativeSelection');
FullOutletChannel=geom1.selection().create('FullOutletChannel','CumulativeSelection');
for i=1:1:BumpNumber
        geom1.feature.create(("Bump"+i),'Square');
        geom1.feature("Bump"+i).set('size',BumpDiameter/2*sqrt(2));
        geom1.feature("Bump"+i).set('base','center');
        geom1.feature("Bump"+i).set('pos',[ChannelWidth, 70+BumpPeriod*(i-1)]); %remember, the position is the center point
        geom1.feature("Bump"+i).set('rot',45); %rotate around the bottom-left vertex
        geom1.feature("Bump"+i).set("contributeto","Bump");
end

uni2=model.component('comp1').geom('geom1').create('uni2', 'Union');
model.component('comp1').geom('geom1').feature('uni2').selection('input').named('Bump');
model.component('comp1').geom('geom1').feature('uni2').set('intbnd', false);

%% genration of the main channel
geom1.selection().create('Mainchannel','CumulativeSelection');
mainchannel=geom1.feature.create("mainchannel",'Rectangle');
geom1.feature("mainchannel").set('size',[ChannelWidth, 50+BumpDiameter+BumpPeriod*BumpNumber+OutletWidth(BumpNumber)]);
geom1.feature("mainchannel").set('pos',[0 0]);
geom1.feature("mainchannel").set("contributeto","Mainchannel");

%% generate the inlet and outlet
for i=1:1:BumpNumber
        geom1.feature.create(("Inlet"+i),'Rectangle');
        geom1.feature("Inlet"+i).set('size',[InletLength,InletWidth(i)]);
        geom1.feature("Inlet"+i).set('pos',[-InletLength, 90+BumpPeriod*(i-1)]); %remember, the position is the center point 
        geom1.feature("Inlet"+i).set("contributeto","Mainchannel");

end

geom1.feature.create('InletChannel','Rectangle');
geom1.feature('InletChannel').set('size',[InletChannelWidth,90+(BumpNumber-1)*BumpPeriod+InletWidth(BumpNumber,1)]);
geom1.feature('InletChannel').set('pos',[-InletLength-InletChannelWidth,0]);
geom1.feature('InletChannel').set("contributeto","FullChannel");

for i=1:1:BumpNumber
        geom1.feature.create(("Outlet"+i),'Rectangle');
        geom1.feature("Outlet"+i).set('size',[OutletLength,OutletWidth(i)]);
        geom1.feature("Outlet"+i).set('pos',[ChannelWidth, 90+BumpPeriod*(i-1)]); %remember, the position is the center point 
        geom1.feature("Outlet"+i).set("contributeto","Mainchannel");
end

for i=1:1:BumpNumber
geom1.feature.create("OutletChannel"+i,'Rectangle');
geom1.feature("OutletChannel"+i).set('size',[OutletChannelWidth(i),BumpPeriod+OutletWidth(i)]);
geom1.feature("OutletChannel"+i).set('pos',[OutletLength+ChannelWidth,90+(i-1)*BumpPeriod]);
geom1.feature("OutletChannel"+i').set("contributeto","FullOutletChannel");
end

uni1=model.component('comp1').geom('geom1').create('uni1', 'Union');
model.component('comp1').geom('geom1').feature('uni1').selection('input').named('Mainchannel');
model.component('comp1').geom('geom1').feature('uni1').set('intbnd', false);

dif1=geom1.feature.create('dif1','Difference');
dif1.selection('input').set({'uni1'});
dif1.selection('input2').set({'uni2'});
dif1.set("contributeto","FullChannel");

uni3=model.component('comp1').geom('geom1').create('uni3','Union');
model.component('comp1').geom('geom1').feature('uni3').selection('input').named('FullOutletChannel');
model.component('comp1').geom('geom1').feature('uni3').set('intbnd',false);
uni3.set("contributeto","FullChannel");

uni4=model.component('comp1').geom('geom1').create('uni4','Union');
model.component('comp1').geom('geom1').feature('uni4').selection('input').named('FullChannel');
model.component('comp1').geom('geom1').feature('uni4').set('intbnd',true);

geom1.run;


%% material setup (water, liquid, pre-built in the COMSOL 5.3 Version 
model.component('comp1').material.create('mat1', 'Common');
model.component('comp1').material('mat1').label('Water, liquid');
model.component('comp1').material('mat1').set('family', 'water');
model.component('comp1').material('mat1').propertyGroup('def').set('dynamicviscosity', 'eta(T[1/K])[Pa*s]');
model.component('comp1').material('mat1').propertyGroup('def').set('ratioofspecificheat', '1.0');
model.component('comp1').material('mat1').propertyGroup('def').set('electricconductivity', '5.5e-6[S/m]');
model.component('comp1').material('mat1').propertyGroup('def').set('heatcapacity', 'Cp(T[1/K])[J/(kg*K)]');
model.component('comp1').material('mat1').propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
model.component('comp1').material('mat1').propertyGroup('def').set('thermalconductivity', 'k(T[1/K])[W/(m*K)]');
model.component('comp1').material('mat1').propertyGroup('def').set('soundspeed', 'cs(T[1/K])[m/s]');
model.component('comp1').material('mat1').propertyGroup('def').func.create('eta', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('funcname', 'eta');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('extrap', 'constant');
model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('pieces', {'273.15' '413.15' '1.3799566804-0.021224019151*T^1+1.3604562827E-4*T^2-4.6454090319E-7*T^3+8.9042735735E-10*T^4-9.0790692686E-13*T^5+3.8457331488E-16*T^6'; '413.15' '553.75' '0.00401235783-2.10746715E-5*T^1+3.85772275E-8*T^2-2.39730284E-11*T^3'});
model.component('comp1').material('mat1').propertyGroup('def').func.create('Cp', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('funcname', 'Cp');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('extrap', 'constant');
model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('pieces', {'273.15' '553.75' '12010.1471-80.4072879*T^1+0.309866854*T^2-5.38186884E-4*T^3+3.62536437E-7*T^4'});
model.component('comp1').material('mat1').propertyGroup('def').func.create('rho', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('funcname', 'rho');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('extrap', 'constant');
model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('pieces', {'273.15' '553.75' '838.466135+1.40050603*T^1-0.0030112376*T^2+3.71822313E-7*T^3'});
model.component('comp1').material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('funcname', 'k');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('arg', 'T');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('extrap', 'constant');
model.component('comp1').material('mat1').propertyGroup('def').func('k').set('pieces', {'273.15' '553.75' '-0.869083936+0.00894880345*T^1-1.58366345E-5*T^2+7.97543259E-9*T^3'});
model.component('comp1').material('mat1').propertyGroup('def').func.create('cs', 'Interpolation');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('sourcetype', 'user');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('source', 'table');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('funcname', 'cs');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('table', {'273' '1403';'278' '1427'; '283' '1447';'293' '1481';'303' '1507';'313' '1526';'323' '1541';'333' '1552';'343' '1555';'353' '1555';'363' '1550';'373' '1543'});
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('interp', 'piecewisecubic');
model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('extrap', 'const');
model.component('comp1').material('mat1').propertyGroup('def').addInput('temperature');
model.component('comp1').material('mat1').set('family', 'water');
% end of material setup

%% setup the physics
model.component('comp1').physics.create('spf', 'LaminarFlow', 'geom1');
model.component('comp1').geom('geom1').create('BufferInlet', 'BoxSelection');
model.component('comp1').geom('geom1').feature('BufferInlet').set('entitydim', 1);
model.component('comp1').geom('geom1').feature('BufferInlet').set('xmin', -1-InletLength-InletChannelWidth);
model.component('comp1').geom('geom1').feature('BufferInlet').set('xmax', +1-InletLength);
model.component('comp1').geom('geom1').feature('BufferInlet').set('ymin', -1);
model.component('comp1').geom('geom1').feature('BufferInlet').set('ymax', 1);
model.component('comp1').geom('geom1').feature('BufferInlet').set('condition', 'inside');
model.component('comp1').geom('geom1').run('BufferInlet');

model.component('comp1').physics('spf').create('BufferInl', 'InletBoundary', 1);
model.component('comp1').physics('spf').feature('BufferInl').selection.named('geom1_BufferInlet');
model.component('comp1').physics('spf').feature('BufferInl').set('BoundaryCondition', 'Pressure');
model.component('comp1').physics('spf').feature('BufferInl').set('p0',Pressure);  

model.component('comp1').geom('geom1').create('BufferOutlet', 'BoxSelection');
model.component('comp1').geom('geom1').feature('BufferOutlet').set('entitydim', 1);
model.component('comp1').geom('geom1').feature('BufferOutlet').set('xmin', ChannelWidth+OutletLength-1);
model.component('comp1').geom('geom1').feature('BufferOutlet').set('xmax', ChannelWidth+OutletLength+OutletChannelWidth(BumpNumber)+1);
model.component('comp1').geom('geom1').feature('BufferOutlet').set('ymin', 50+BumpDiameter+BumpPeriod*BumpNumber+OutletWidth(BumpNumber)-1);
model.component('comp1').geom('geom1').feature('BufferOutlet').set('ymax', 50+BumpDiameter+BumpPeriod*BumpNumber+OutletWidth(BumpNumber)+1);
model.component('comp1').geom('geom1').feature('BufferOutlet').set('condition', 'inside');
model.component('comp1').geom('geom1').run('BufferOutlet');

model.component('comp1').physics('spf').create('BufferOutl', 'OutletBoundary', 1);
model.component('comp1').physics('spf').feature('BufferOutl').selection.named('geom1_BufferOutlet');

model.component('comp1').geom('geom1').create('MainInlet', 'BoxSelection');
model.component('comp1').geom('geom1').feature('MainInlet').set('entitydim', 1);
model.component('comp1').geom('geom1').feature('MainInlet').set('xmin', -1);
model.component('comp1').geom('geom1').feature('MainInlet').set('xmax', ChannelWidth+1);
model.component('comp1').geom('geom1').feature('MainInlet').set('ymin', -1);
model.component('comp1').geom('geom1').feature('MainInlet').set('ymax', 1);
model.component('comp1').geom('geom1').feature('MainInlet').set('condition', 'inside');
model.component('comp1').geom('geom1').run('MainInlet');

model.component('comp1').physics('spf').create('MainInl', 'InletBoundary', 1);
model.component('comp1').physics('spf').feature('MainInl').selection.named('geom1_MainInlet');
model.component('comp1').physics('spf').feature('MainInl').set('BoundaryCondition', 'Pressure');
model.component('comp1').physics('spf').feature('MainInl').set('p0', Pressure);

model.component('comp1').geom('geom1').create('MainOutlet', 'BoxSelection');
model.component('comp1').geom('geom1').feature('MainOutlet').set('entitydim', 1);
model.component('comp1').geom('geom1').feature('MainOutlet').set('xmin', -1);
model.component('comp1').geom('geom1').feature('MainOutlet').set('xmax', ChannelWidth+1);
model.component('comp1').geom('geom1').feature('MainOutlet').set('ymin', 50+BumpDiameter+BumpPeriod*BumpNumber+OutletWidth(BumpNumber)-1);
model.component('comp1').geom('geom1').feature('MainOutlet').set('ymax', 50+BumpDiameter+BumpPeriod*BumpNumber+OutletWidth(BumpNumber)+1);
model.component('comp1').geom('geom1').feature('MainOutlet').set('condition', 'inside');
model.component('comp1').geom('geom1').run('MainOutlet');

model.component('comp1').physics('spf').create('MainOutl', 'OutletBoundary', 1);
model.component('comp1').physics('spf').feature('MainOutl').selection.named('geom1_MainOutlet');


%% generation of mesh 
me='meshing start'
mesh1 = comp1.mesh.create('mesh1');
model.component('comp1').mesh('mesh1').automatic(true);
model.component('comp1').mesh('mesh1').autoMeshSize(meshquality); %% finest 1, coarsest, 9
mesh1.run;
mee='meshing ends'
%% start the simulation
a='start simulation' 

%set up the solver
std2=model.study.create('std2');
model.study('std2').create('stat', 'Stationary');
model.study('std2').feature('stat').activate('spf', true);

model.sol.create('sol2');
model.sol('sol2').study('std2');

model.study('std2').feature('stat').set('notlistsolnum', 1);
model.study('std2').feature('stat').set('notsolnum', '1');
model.study('std2').feature('stat').set('listsolnum', 1);
model.study('std2').feature('stat').set('solnum', '1');

model.sol('sol2').create('st1', 'StudyStep');
model.sol('sol2').feature('st1').set('study', 'std2');
model.sol('sol2').feature('st1').set('studystep', 'stat');
model.sol('sol2').create('v1', 'Variables');
model.sol('sol2').feature('v1').set('control', 'stat');
model.sol('sol2').create('s1', 'Stationary');
model.sol('sol2').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol2').feature('s1').feature('fc1').set('initstep', 0.01);
model.sol('sol2').feature('s1').feature('fc1').set('minstep', 1.0E-6);
model.sol('sol2').feature('s1').feature('fc1').set('dtech', 'auto');
model.sol('sol2').feature('s1').feature('fc1').set('maxiter', 100);
model.sol('sol2').feature('s1').create('i1', 'Iterative');
model.sol('sol2').feature('s1').feature('i1').set('linsolver', 'gmres');
model.sol('sol2').feature('s1').feature('i1').set('prefuntype', 'left');
model.sol('sol2').feature('s1').feature('i1').set('itrestart', 50);
model.sol('sol2').feature('s1').feature('i1').set('rhob', 20);
model.sol('sol2').feature('s1').feature('i1').set('maxlinit', 200);
model.sol('sol2').feature('s1').feature('i1').set('nlinnormuse', 'on');
model.sol('sol2').feature('s1').feature('i1').label('Algebraic Multigrid Solver (spf)');
model.sol('sol2').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').set('prefun', 'saamg');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').set('mgcycle', 'f');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').set('maxcoarsedof', 30000);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').set('strconn', 0.02);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').set('usesmooth', false);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').set('saamgcompwise', true);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('pr').create('sc1', 'SCGS');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('pr').feature('sc1').set('linesweeptype', 'ssor');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('pr').feature('sc1').set('iter', 0);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('pr').feature('sc1').set('scgsrelax', 0.7);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('pr').feature('sc1').set('scgsvertexrelax', 0.7);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('pr').feature('sc1').set('seconditer', 1);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('pr').feature('sc1').set('relax', 0.5);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('po').create('sc1', 'SCGS');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('po').feature('sc1').set('linesweeptype', 'ssor');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('po').feature('sc1').set('iter', 1);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('po').feature('sc1').set('scgsrelax', 0.7);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('po').feature('sc1').set('scgsvertexrelax', 0.7);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('po').feature('sc1').set('seconditer', 1);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('po').feature('sc1').set('relax', 0.5);
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol2').feature('s1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol2').feature('s1').create('i2', 'Iterative');
model.sol('sol2').feature('s1').feature('i2').set('linsolver', 'gmres');
model.sol('sol2').feature('s1').feature('i2').set('prefuntype', 'left');
model.sol('sol2').feature('s1').feature('i2').set('itrestart', 50);
model.sol('sol2').feature('s1').feature('i2').set('rhob', 20);
model.sol('sol2').feature('s1').feature('i2').set('maxlinit', 200);
model.sol('sol2').feature('s1').feature('i2').set('nlinnormuse', 'on');
model.sol('sol2').feature('s1').feature('i2').label('Geometric Multigrid Solver (spf)');
model.sol('sol2').feature('s1').feature('i2').create('mg1', 'Multigrid');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').set('prefun', 'gmg');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').set('mcasegen', 'any');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').set('gmglevels', 1);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('pr').create('sc1', 'SCGS');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('pr').feature('sc1').set('linesweeptype', 'ssor');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('pr').feature('sc1').set('iter', 0);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('pr').feature('sc1').set('scgsrelax', 0.7);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('pr').feature('sc1').set('scgsvertexrelax', 0.7);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('pr').feature('sc1').set('seconditer', 1);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('pr').feature('sc1').set('relax', 0.5);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('po').create('sc1', 'SCGS');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('po').feature('sc1').set('linesweeptype', 'ssor');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('po').feature('sc1').set('iter', 1);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('po').feature('sc1').set('scgsrelax', 0.7);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('po').feature('sc1').set('scgsvertexrelax', 0.7);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('po').feature('sc1').set('seconditer', 1);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('po').feature('sc1').set('relax', 0.5);
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol2').feature('s1').feature('i2').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol2').feature('s1').feature('fc1').set('linsolver', 'i1');
model.sol('sol2').feature('s1').feature('fc1').set('initstep', 0.01);
model.sol('sol2').feature('s1').feature('fc1').set('minstep', 1.0E-6);
model.sol('sol2').feature('s1').feature('fc1').set('dtech', 'auto');
model.sol('sol2').feature('s1').feature('fc1').set('maxiter', 100);
model.sol('sol2').feature('s1').feature.remove('fcDef');
model.sol('sol2').attach('std2');
model.sol('sol2').feature('s1').feature('i2').active(true);
try
std2.run;
catch 
    e='error1'
    try
        std2.run;
    catch
        e='error2'
        try
            std2.run;
        catch
            e='error3'
            try 
                std2.run;
            catch 
                e='error4'
                try
                    std2.run;
                catch
                    e='error5'
                end
            end
        end
    end
end
 
b='simulation ends'

%% post-processing 
% outlet

WasteOutlet=zeros(BumpNumber,1);
for i=1:1:BumpNumber
    model.component('comp1').geom('geom1').create("WO"+i, 'BoxSelection');
    model.component('comp1').geom('geom1').feature("WO"+i).set('entitydim', 1);
    model.component('comp1').geom('geom1').feature("WO"+i).set('xmin', ChannelWidth+OutletLength-1);
    model.component('comp1').geom('geom1').feature("WO"+i).set('xmax', ChannelWidth+OutletLength+1);
    model.component('comp1').geom('geom1').feature("WO"+i).set('ymin', 50+BumpDiameter+BumpPeriod*(i-1)-1);
    model.component('comp1').geom('geom1').feature("WO"+i).set('ymax', 50+BumpDiameter+BumpPeriod*(i-1)+1+OutletWidth(i));
    model.component('comp1').geom('geom1').feature("WO"+i).set('condition', 'inside');
    model.component('comp1').geom('geom1').run("WO"+i);
    model.result.numerical.create("intWOut"+i, 'IntLine');
    model.result.numerical("intWOut"+i).selection.named("geom1_"+"WO"+i);
    model.result.numerical("intWOut"+i).setIndex('expr', 'u', 0);
    model.result.table.create("TableOut"+i, 'Table');
    model.result.table("TableOut"+i).comments('Line Integration 1 (u)');
    model.result.numerical("intWOut"+i).set('table', "TableOut"+i);
    model.result.numerical("intWOut"+i).setResult;
    WasteOutlet(i)=model.result.table("TableOut"+i).getReal();
end 

BufferInlet=zeros(BumpNumber,1);
for i=1:1:BumpNumber
    model.component('comp1').geom('geom1').create("BI"+i, 'BoxSelection');
    model.component('comp1').geom('geom1').feature("BI"+i).set('entitydim', 1);
    model.component('comp1').geom('geom1').feature("BI"+i).set('xmin', -InletLength-1);
    model.component('comp1').geom('geom1').feature("BI"+i).set('xmax', -InletLength+1);
    model.component('comp1').geom('geom1').feature("BI"+i).set('ymin', 50+BumpDiameter+BumpPeriod*(i-1)-1);
    model.component('comp1').geom('geom1').feature("BI"+i).set('ymax', 50+BumpDiameter+BumpPeriod*(i-1)+1+InletWidth(i));
    model.component('comp1').geom('geom1').feature("BI"+i).set('condition', 'inside');
    model.component('comp1').geom('geom1').run("BI"+i);
    model.result.numerical.create("intBI"+i, 'IntLine');
    model.result.numerical("intBI"+i).selection.named("geom1_"+"BI"+i);
    model.result.numerical("intBI"+i).setIndex('expr', 'u', 0);
    model.result.table.create("TableBI"+i, 'Table');
    model.result.table("TableBI"+i).comments('Line Integration 1 (u)');
    model.result.numerical("intBI"+i).set('table', "TableBI"+i);
    model.result.numerical("intBI"+i).setResult;
    BufferInlet(i)=model.result.table("TableBI"+i).getReal();
end 

BufferDif=(BufferInlet-WasteOutlet)./WasteOutlet;
TotalErDcTemp=0;
DcResult=zeros(BumpNumber,1);
ErDc=zeros(BumpNumber,1);
for i=1:1:BumpNumber
    model.result.create("pg"+i, 'PlotGroup2D');
    model.result("pg"+i).create("str"+i, 'Streamline');
    model.result("pg"+i).feature("str"+i).set('posmethod', 'start');
    model.result("pg"+i).feature("str"+i).set('startmethod', 'coord');
    model.result("pg"+i).feature("str"+i).set('xcoord', ChannelWidth);
    model.result("pg"+i).feature("str"+i).set('ycoord', 90+OutletWidth(i)+BumpPeriod*(i-1)-0.01);
    model.result("pg"+i).run;
    figure(1)
    pg=mphplot(model,"pg"+i);
    pause(0.01)
    x=(pg{1,2}{1,1}.p(1,:))'; %x coordiante of the streamline
    y=(pg{1,2}{1,1}.p(2,:))'; %y coordiante of the streamline
    [ytar, ytarind]=min(abs(70+BumpPeriod*(i-1)-y(:,1)));
    DcResult(i)=ChannelWidth-BumpDiameter/2-x(ytarind,1);
    ErDc(i)=DcResult(i)-TargetCriticalDiameter/2;
    TotalErDcTemp=TotalErDcTemp+abs(ErDc(i));
end

if TotalErDcTemp<MinTotalErdc
    MinTotalErdc=TotalErDcTemp;
    BestOutletChannelWidth=OutletChannelWidth;
    BestInletWidth=InletWidth;
end
   
%% correct the outlet width
for i=1:1:BumpNumber
    if abs(ErDc(i))<=10 && abs(ErDc(i))<OutletChannelWidth(i)
        OutletChannelWidth(i)=OutletChannelWidth(i)-ErDc(i);
    else
        OutletChannelWidth(i)=OutletChannelWidth(i)-0.5*sign(ErDc(i));
    end
figure(2)
hold on;
title('Outletchannel width');
plot(z,OutletChannelWidth(i),'o','MarkerSize',6,'MarkerEdgeColor','b');
label=cellstr(num2str(i));
text(z,OutletChannelWidth(i),label);
pause(0.01)
figure(3)
hold on;
title('Dc Error');
plot(z,ErDc(i),'^','MarkerSize',6,'MarkerEdgeColor','r');
label=cellstr(num2str(i));
text(z,ErDc(i),label);
pause(0.01)
end




for i=1:1:BumpNumber
    if abs(BufferDif(i))<=1 && abs(ErDc(i))<InletWidth(i)
        InletWidth(i)=InletWidth(i)-BufferDif(i);
    else
        InletWidth(i)=InletWidth(i)-0.5*sign(BufferDif(i));
    end

figure(4)
hold on;
title('Inlet width');
plot(z,InletWidth(i),'o','MarkerSize',6,'MarkerEdgeColor','b');
label=cellstr(num2str(i));
text(z,InletWidth(i),label);
pause(0.01)
figure(5)
hold on;
title('Flux Error');
plot(z,BufferDif(i),'^','MarkerSize',6,'MarkerEdgeColor','r');
label=cellstr(num2str(i));
text(z,BufferDif(i),label);
pause(0.01)
end

z
end;
