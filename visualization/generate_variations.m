

function [ variations_fc_2d ] = generate_variations( ObjectMesh, To_Adams, box_lenght, l_step, a_step )

variation_linear =[0 [-box_lenght/2:l_step:box_lenght/2]];
variation_angle = [0 [-40*pi/180:a_step*pi/180:40*pi/180]];
variations_main_axis = [variation_linear.' zeros(size(variation_linear,2),1); zeros(size(variation_angle,2),1) variation_angle.' ];

originalT = To_Adams;

k = 1;
variations_fc = [];
for i=1:size(variations_main_axis,1)
   
    variations{i} = toTH(originalT) * toTH( [variations_main_axis(i,1),0,0,0,variations_main_axis(i,2),0] );
    variations_fc_bool(i) = isCollisionHand( ObjectMesh, variations{i} );
    if( ~variations_fc_bool(i))
        variations_fc = [variations_fc; toE(variations{i})];
        k = k+1;
    end
    
end

[rlinear, r_ang] = findrange( variations_fc_bool(1:size(variation_linear,2)), variations_fc_bool(size(variation_linear,2)+1:end) );

if ( isempty(rlinear) || isempty(r_ang))
    variations_fc_2d = [];
else
    rangelinear = [ variation_linear(rlinear(1)) variation_linear(rlinear(2))];
    rangeang = [ variation_angle(r_ang(1)) variation_angle(r_ang(2))];


    i=1;
    % figure()
    % plot(0,0)
    % hold on
    while i<=20
        plinear = rangelinear(1)+( rangelinear(2) - rangelinear(1))*rand();
        pang = rangeang(1)+( rangeang(2) - rangeang(1))*rand();
    %     plot(plinear,pang, '*')
        variations_2d = toTH(originalT) * toTH( [plinear,0,0,0,pang,0] );
        variations_fc_bool_2d = isCollisionHand( ObjectMesh, variations_2d );
        if( ~variations_fc_bool_2d)
            variations_fc_2d(i,:) =  toE(variations_2d);
            i = i+1;
        end
    end


end



end


function T = toTH( configxyzzxz )

T = [ eye(3) [configxyzzxz(1);configxyzzxz(2);configxyzzxz(3)]; [0 0 0 1]] * [ROTZ(-configxyzzxz(6))*ROTX(-configxyzzxz(5))*ROTZ(-configxyzzxz(4)) [0;0;0];[0 0 0 1]];

end

function E = toE ( T )

R = T(1:3,1:3);
 psi=atan2(R(1,3), -R(2,3));
 phi=atan2(-cos(psi)*R(1,2)-sin(psi)*R(2,2), cos(psi)*R(1,1)+sin(psi)*R(2,1));
 theta=atan2(sin(psi)*R(1,3)-cos(psi)*R(2,3), R(3,3));
 

   E = [T(1:3,4).'  -phi -theta -psi] ;

end

function [rlinear, r_ang] = findrange( vlinear, vang )
init_linear = [];
end_linear = [];

init_ang = [];
end_ang = [];

for i = 2:size(vlinear,2)
    if vlinear(i) == 0
        init_linear = i;
        break;
    end
end

for i = size(vlinear,2):-1:2
    if vlinear(i) == 0
        end_linear = i;
        break;
    end
end


for i = 2:size(vang,2)
    if vang(i) == 0
        init_ang = i;
        break;
    end
end

for i = size(vang,2):-1:2
    if vang(i) == 0
        end_ang = i;
        break;
    end
end

rlinear = [init_linear end_linear];
r_ang = [init_ang end_ang];

end

% 
% % var ausiliaria
% f=1;
% a=0;
% 
% count=[];
% 
% %% Traslation
% 
% for i=1:size(index,1)
%    
% %     switch
%        
%         
% 
%         T=[ T_rec(1:3, 1:3,i)  [To_Adams(i,1); To_Adams(i,2); To_Adams(i,3)]; 0 0 0 1];
%         T=inv(T);
%         
%    
%         count=5;
%         Step=dim/count;
%         side=dim*5;
%         for k=2:count
%             
%             if(k <5)
%                 V_cs(:,:,1)= T* [eye(3) [0 ;0 ;0];0 0 0 1];
%                 if(Step*k < (side/2))
%                 V_cs(:,:,k)=T* [eye(3) [Step*k ;0 ;0];0 0 0 1];
%                 end
%                 
%             else
%                 if(Step*a < (side/2))
%                 V_cs(:,:,k)= T* [eye(3) [-Step*a ;0 ;0];0 0 0 1];
%                 a=a+1;
%                 end
%             end
%         end  
%             R_Vcs{f}=V_cs;
%             
%             f=f+1;
%             
% %         end
%    % end
% end
% 
% k=1;
% n_variations = size(V_cs,3);
% index_rot=[];
% Adams_point=[];
% for p=1: size(R_Vcs,2)
%     
%     R_cs = R_Vcs{p};
%     
%     for j=1:n_variations
%         
%         R(:,:,k) = R_cs(1:3,1:3,j);
%         data(k,:) =R_cs(1:3,4,j).';
%       
%         
%     %end
%        
%       [Rot, point]=  eulero_angle(R, data);     
%                  
%         T = [Rot(1:3,1:3,k) [point(j,1); point(j,2); point(j,3)]; 0 0 0 1];
%         T=inv(T);   
%          k = k+1; 
%         if ( ~isCollisionHand( mesh, T) )
%             
%          Adams_point=[Adams_point; point(j,:) ];
%          index_rot=[index_rot; j];
%            
%         else
%             continue;
%         end
%     end
%     
%     
%  end
% 
% %% Rotation variation
% 
% f=1;
% l=0;
% 
% for i=1:size(index,1)%-1
%     for h=0:5:20
%         degree=h;
%         
%         rot_x=[1, 0, 0;
%     0, cos(degree), -sin(degree);
%     0, sin(degree), cos(degree)];
% 
%    % if((index(i+1)-index(i))==1)
%         
%           T=[ T_rec(1:3, 1:3,i)  [To_Adams(i,1); To_Adams(i,2); To_Adams(i,3)]; 0 0 0 1];
%         T=inv(T);
%         
%     for k=2:count
%         
%         if(k <=5)
%             V_rot_cs(:,:,1)= T* [rot_x(:,:) [0 ;0 ;0];0 0 0 1];
%             V_rot_cs(:,:,k)= T* [rot_x(:,:) [Step*k ;0 ;0];0 0 0 1];
%             
%         else
%             V_rot_cs(:,:,k)= T* [rot_x(:,:) [-Step*l ;0 ;0];0 0 0 1];
%             l=l+1;
%             
%         end
%     end
%         R_rot_Vcs{f}=V_rot_cs;
%         
%         f=f+1;
%         
% %     end
%     end
%     %end
% end
% 
%     
%     
% k=1;
% n_variations2 = size(V_rot_cs,3);
% index_var=[];
% Adams_point_var=[];
% for p=1: size(R_rot_Vcs,2)
%     
%     RV_cs = R_rot_Vcs{p};
%     
%     for j=1:n_variations2
%         
%         R_rot_pos(:,:,k) = R_cs(1:3,1:3,j);
%         data_rot_pos(k,:) =R_cs(1:3,4,j).';
%        
%         
%     %end
%        
%        
%       [Rot_var, point_var]=  eulero_angle(R_rot_pos, data_rot_pos);     
%         
%         a = [Rot_var(1:3, 1:3, k) [point_var(j,1); point_var(j,2); point_var(j,3)]; 0 0 0 1];
%         a=inv(a);   
%          k = k+1;
%          
%         if ( ~isCollision( mesh, a) )
%             
%          Adams_point_var=[Adams_point_var; point_var(j,:) ];
%             
%            index_var=[index_var; j];
%            
%         else
%             continue;
%         end
%     %end
%     end
%     
% end
%     
% 
% % h=1;   
%  
%  for i=1:size(Adams_point,1)
%     To_adams_free_collision_cs(i,:)=Adams_point(i,:);
%     %h=h+1;
%  end
%  
%  h=size(Adams_point,1)+1;
%  for i=1:size(Adams_point_var,2)
%      
%      To_adams_free_collision_cs(h,:)=Adams_point_var(i,:);
%      h=h+1;
%  end
%  
%     
%     
%     
%     
%     
%     
% end
% 
% 
% 
