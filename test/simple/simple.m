
function simple (mode, numAbs, controllers)
  w = [0.3 0.3];
  addpath(genpath('../..'));
  addpath(genpath('~/ownCloud/C++/SCOTS_modified/mfiles/'));
  
  % colors
  colors=get(groot,'DefaultAxesColorOrder'); 
  if (strcmp(mode, 'Z'))
      openfig('problem')
      C1 = SymbolicSet('C/C1.bdd');
      p1 = C1.points;
      plot(p1(:,1),p1(:,2),'ko');
      pause
      
      Z2 = SymbolicSet('Z/Z2.bdd');
      p2 = Z2.points;
      plot(p2(:,1),p2(:,2),'bo');
      pause
      
%       Z22 = SymbolicSet('D/Z2.bdd');
%       p2 = Z22.points;
%       plot(p2(:,1),p2(:,2),'ro');
      
      Z3 = SymbolicSet('Z/Z3.bdd');
      p3 = Z3.points;
      plot(p3(:,1),p3(:,2),'ro');  
      pause
      
      Z4 = SymbolicSet('Z/Z4.bdd');
      p4 = Z4.points;
      plot(p4(:,1),p4(:,2),'go');  
      title('Z')
      pause
      
      Z5 = SymbolicSet('Z/Z5.bdd');
      p5 = Z5.points;
      plot(p5(:,1),p5(:,2),'go'); 
  end
  if (strcmp(mode, 'D'))
      openfig('problem')
      C1 = SymbolicSet('C/C1.bdd');
      p1 = C1.points;
      plot(p1(:,1),p1(:,2),'ko');
      pause
      
      D2 = SymbolicSet('D/D21.bdd');
      p2 = D2.points;
      plot(p2(:,1),p2(:,2),'bo');
      pause
      
      Z2 = SymbolicSet('D/Z21.bdd');
      p2 = Z2.points;
      plot(p2(:,1),p2(:,2),'ro');
      pause
%       
%       D3 = SymbolicSet('D/D22.bdd');
%       p3 = D3.points;
%       plot(p3(:,1),p3(:,2),'go');  
%       title('D')
%       pause
      
      Z3 = SymbolicSet('D/Z22.bdd');
      p4 = Z3.points;
      plot(p4(:,1),p4(:,2),'yo');
      
      D3 = SymbolicSet('D/D31.bdd');
      p3 = D3.points;
      plot(p3(:,1),p3(:,2),'co');  
      title('D')
      pause
      
      Z3 = SymbolicSet('D/Z31.bdd');
      p4 = Z3.points;
      plot(p4(:,1),p4(:,2),'mo');
  end
  if (strcmp(mode, 'D0'))
      openfig('problem')
      D1 = SymbolicSet('AdaptiveAbsResults/D0/D1.bdd');
      p1 = D1.points;
      plot(p1(:,1),p1(:,2),'bo');
      pause
      
      D2 = SymbolicSet('AdaptiveAbsResults/D0/D2.bdd');
      p2 = D2.points;
      plot(p2(:,1),p2(:,2),'ro');
  end
  if (strcmp(mode, 'C'))
      openfig('problem')
      
      for ii=1:controllers
        C = SymbolicSet(['C/C' int2str(ii) '.bdd']);
        p = C.points;
        plotColor = colors(mod(ii,7)+1,:)*0.3+0.3;
        scatter(p(:,1),p(:,2),'Marker','o','MarkerFaceColor',plotColor);
        pause
      end
%       C1 = SymbolicSet('C/C1.bdd');
%       p1 = C1.points;
%       plot(p1(:,1),p1(:,2),'ko');
%       pause
%       
%       C2 = SymbolicSet('C/C2.bdd');
%       p2 = C2.points;
%       plot(p2(:,1),p2(:,2),'bo');
%       pause
%       
%       C3 = SymbolicSet('C/C3.bdd');
%       p3 = C3.points;
%       plot(p3(:,1),p3(:,2),'go');    
%       title('C') 
%       pause
%       
%       C4 = SymbolicSet('C/C4.bdd');
%       p4 = C4.points;
%       plot(p4(:,1),p4(:,2),'yo');    
%       title('C')
%       
%       C5 = SymbolicSet('C/C5.bdd');
%       p5 = C5.points;
%       plot(p5(:,1),p5(:,2),'co');    
%       title('C')
  end
 
  if (strcmp(mode, 'T'))
      openfig('problem')
      T1 = SymbolicSet('AdaptiveAbsResults/T/T1.bdd', 'projection', [1 2]);
      p1 = T1.points;
      plot(p1(:,1),p1(:,2),'ko');
      pause
      
      T2 = SymbolicSet('AdaptiveAbsResults/T/T2.bdd', 'projection', [1 2]);
      p2 = T2.points;
      plot(p2(:,1),p2(:,2),'bo');
      pause
      
      T3 = SymbolicSet('AdaptiveAbsResults/T/T3.bdd', 'projection', [1 2]);
      p3 = T3.points;
      plot(p3(:,1),p3(:,2),'ro');  
      title('T')
  end
 
  if (strcmp(mode, 'S'))
    figure
    hold on
    box on    
    drawnow
  
    % load and draw state space
    X = SymbolicSet('plotting/X.bdd');
    lb = X.first();
    ub = X.last();   
    axis([lb(1)-1 ub(1)+1 lb(2)-1 ub(2)+1])
    plotCells(X, 'facecolor', 'none', 'edgec', [0.8 0.8 0.8], 'linew', 0.1);
    drawnow
    disp('Done plotting state space')
   
    savefig('system');
  end
  
  if (strcmp(mode,'P'))
    openfig('system');
    hold on
    drawnow
    
    % load and draw obstacles
    try
      O = SymbolicSet('plotting/O.bdd');
      plotCells(O, 'facecolor', colors(1,:)*0.5+0.5, 'edgec', colors(1,:), 'linew', 0.1)
      drawnow
      disp('Done plotting obstacles')
    catch
      warning('No obstacles');
    end
        
    % load and draw goal
    G = SymbolicSet('plotting/G.bdd');
    plotCells(G, 'facecolor', colors(2,:)*0.5+0.5, 'edgec', colors(2,:), 'linew', 0.1)
    drawnow
    disp('Done plotting goal')
   
    % load and draw initial
    I = SymbolicSet('plotting/I.bdd');
    plotCells(I, 'facecolor', colors(3,:)*0.5+0.5, 'edgec', colors(3,:), 'linew', 0.1)
    drawnow
    disp('Done plotting initial')
   
    savefig('problem');

  end     

  if (strcmp(mode,'R'))

    disp('w')
    disp(w)
  
    openfig('problem');
    hold on
    drawnow
    
%     I = SymbolicSet('plotting/I.bdd');
%     x = I.points();
%     x = x(1,:);
    x = [1 1];
    
    v = [];
    
    j = 1;
    start = 1;
    for i = controllers:-1:1
      disp(['iteration: ' int2str(i)])
      
      C = SymbolicSet(['C/C' int2str(i) '.bdd'], 'projection', [1 2]);
      if (i == 1)
	G = SymbolicSet(['G/G' int2str(numAbs) '.bdd']);
      else
	G = SymbolicSet(['Z/Z' int2str(i-1) '.bdd']);
      end
      
      points = G.points();
      plot(points(:,1), points(:,2), 'x', 'MarkerFaceColor', colors(mod(i,7)+1,:)*0.3+0.3, 'MarkerSize', 1.5);
      
      Z = SymbolicSet(['Z/Z' int2str(i) '.bdd']);      
      eta = Z.eta();
      eta = eta';
      tau = eta(1) * 3 / 2;
      
      disp('eta')
      disp(eta)
      disp('tau')
      disp(tau)
      
      while (1)
	disp(j)
	disp('x')
	disp(x(end,:))
	
	if (mod(j,1) == 0)
	  plot(x(:,1),x(:,2),'k.-')
	  drawnow
	  pause
	end
	
	if (G.isElement(x(end,:)))
	  plot(x(:,1),x(:,2),'k.-')
	  drawnow
	  break
	end
	
	u = C.getInputs(x(end,:));
	ran = randi([1 size(u,1)], 1, 1);
	v = [v; u(ran,:)];
	d = disturbance(w);
	[t phi] = ode45(@sysODE, [0 tau], x(end,:), [], u(ran,:), d);
	x = [x; phi];
	
	disp('u')
	disp(u(ran,:))
	disp('d')
	disp(d)
	
	j = j + 1;
      end
    end
%      plotCells(G,'facecolor',colors(2,:)*0.5+0.5,'edgec',colors(2,:),'linew',.1)
    savefig('simulation');
  end
  	if strcmp(mode,'plot')
		openfig('system');
		for i = controllers:-1:1
			Z = SymbolicSet(['G/G' int2str(numAbs) '.bdd']);
			plotCells(Z, 'facecolor', colors(1,:), 'edgec', colors(1,:), 'linew', 0.1)
			drawnow
		end
		    % load and draw obstacles
    	try
      		O = SymbolicSet('plotting/O.bdd', 'projection', [1 2]);
      		plotCells(O, 'facecolor', colors(1,:)*0.5+0.5, 'edgec', colors(1,:), 'linew', 0.1)
      		drawnow
      		disp('Done plotting obstacles')
    	catch
      		warning('No obstacles');
    		end
        
    	% load and draw goal
    	G = SymbolicSet('plotting/G.bdd', 'projection', [1 2]);
    	plotCells(G, 'facecolor', colors(2,:)*0.5+0.5, 'edgec', colors(2,:), 'linew', 0.1)
    	drawnow
    	disp('Done plotting goal')
   
    	% load and draw initial
    	I = SymbolicSet('plotting/I.bdd', 'projection', [1 2]);
    	plotCells(I, 'facecolor', colors(3,:)*0.5+0.5, 'edgec', colors(3,:), 'linew', 0.1)
    	drawnow
    	disp('Done plotting initial')
    	
    	savefig('figure')
	end
  if (strcmp(mode,'scots'))
    openfig('problem');
    hold on
    drawnow
    
    I = SymbolicSet('scots/I.bdd');
    x = I.points();
    x = x(1,:);
    x = [x; x];
    v = [];
    
    G = SymbolicSet('scots/G.bdd');
    eta = G.eta;
    tau = eta(1)*3/2;
    
    C = SymbolicSet('scots/C.bdd', 'projection', [1 2]);
    
    j = 1;
    
    while(1)
      disp(j)
      disp(x(end-1,:))
      disp(x(end,:))
      
      if (mod(j,1) == 0)
	plot(x(:,1),x(:,2),'k.-')
	drawnow
	pause
      end
      
      if (G.isElement(x(end,:)))
	plot(x(:,1),x(:,2),'k.-')
	drawnow
	pause
	break
      end
  
      u = C.getInputs(x(end,:));
      ran = randi([1 size(u,1)], 1, 1);
      v = [v; u(ran,:)];
      d = disturbance(w);
      [t phi] = ode45(@sysODE, [0 tau], x(end,:), [], u(ran,:), d);
      x = [x; phi];
      
      j = j + 1;
    end
    savefig('scots/simulation')
  end    
  
end

function d = disturbance(w)
  d = -w + (2 * w .* rand(size(w)));
end

function dxdt = sysODE(t,x,u,d)
  dxdt = zeros(2,1);
  dxdt(1) = u(1);
  dxdt(2) = u(2);
  dxdt = dxdt + d';
end
