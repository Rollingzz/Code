function [E,E_ED,E_real,N,S1S]=X_RBM_Energy_X_RBM_s1s(a,w,Phi_T,N_sites,N_y,N_up,N_dn,U,H_k)
%% Initialization
E=0;
RE=0;

E_ED=0;
RE_ED=0;

E_real=0;
RE_real=0;

N=0;
S1S=0;

n_phi=0;

N_par=N_up+N_dn;

%%
     for y2=1:N_y %binary order
     
     n_phi=n_phi+1;
         eN_up=zeros(N_sites,N_sites);
         eN_dn=zeros(N_sites,N_sites);
         
         temp=a(y2,:);
         temp_T=temp';
         for i=1:N_sites
             eN_up(i,i)=exp(temp_T(i,1));
             eN_dn(i,i)=exp(-1*temp_T(i,1));
         end  
         
         phi_1=Phi_T;
         phi_2(:,1:N_up,n_phi)=eN_up(:,:)*phi_1(:,1:N_up);
         phi_2(:,N_up+1:N_par,n_phi)=eN_dn(:,:)*phi_1(:,N_up+1:N_par);
        
         phi_2(:,1:N_up,n_phi)=X_RBM_stblz_X(phi_2(:,1:N_up,n_phi),N_up);
         phi_2(:,N_up+1:N_par,n_phi)=X_RBM_stblz_X(phi_2(:,N_up+1:N_par,n_phi),N_dn);
%          
%          phi_2(:,1:N_up,n_phi)=w(y2,1)*phi_2(:,1:N_up,n_phi);
%          phi_2(:,N_up+1:N_par,n_phi)=w(y2,1)*phi_2(:,N_up+1:N_par,n_phi); 
         
     end

    %%  calculate the single-particle Green's function matrix for each spin:
    for i=1:n_phi
        for j=1:n_phi
            re_up=w(i,1)*w(j,1)*det(phi_2(:,1:N_up,i)'*phi_2(:,1:N_up,j));
            re_dn=w(i,1)*w(j,1)*det(phi_2(:,N_up+1:N_par,i)'*phi_2(:,N_up+1:N_par,j));
            re=re_up*re_dn;
            
            invO_matrix_up=inv(phi_2(:,1:N_up,i)'*phi_2(:,1:N_up,j));
            invO_matrix_dn=inv(phi_2(:,N_up+1:N_par,i)'*phi_2(:,N_up+1:N_par,j));
         
           %%  calculate the single-particle Green's function matrix for each spin:
            temp_up=phi_2(:,1:N_up,j)*invO_matrix_up;
            temp_dn=phi_2(:,N_up+1:N_par,j)*invO_matrix_dn;
         
            G_up=temp_up*phi_2(:,1:N_up,i)';
            G_dn=temp_dn*phi_2(:,N_up+1:N_par,i)';
            G_up=G_up*re;
            G_dn=G_dn*re;

          %% calculate the potential energy:
           n_int=(diag(G_up)).'*diag(G_dn);
           potentialEnergy=n_int*U/re;

          %% calculate the spin density
           n_up=abs(diag(G_up));
           n_dn=abs(diag(G_dn));
           n(1:N_sites)=n_up(1:N_sites);
           n(N_sites+1:2*N_sites)=n_dn(1:N_sites);
 
          %% calculate the kinetic energy:
           kineticEnergy=sum(sum(H_k.'.*(G_up+G_dn))); % note the element-wise multiplication

          %% calculate the total energy:
           e(i,j)=potentialEnergy+kineticEnergy;
           
          %% calculate the s1s
           s1s=(n_up-n_dn)';
           
           S1S=S1S+s1s;
           N=N+n;
           E=E+e(i,j);
           RE=RE+re;
         
        end
    end
 
 S1S=S1S/RE;
 N=N/RE;
 E=E/RE;
 E_real=E_real/RE_real;
 E_ED=E_ED/RE_ED;
 
end