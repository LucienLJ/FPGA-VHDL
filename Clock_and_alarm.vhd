library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity TiPi is port(

	--Déclaration des entrées pour les deux horloges(clk1,clk3), le reset (rst), pour régler l'alarme, reg_m
	--pour les minutes et reg_h pour les heures, la sélection du mode alarme (alarm)

	clk1, clk3, rst, alarm, reg_m, reg_h : in std_logic;
	
	--Déclaration de la sortie pour la led d'alarme
	
	led : out std_logic;
	
	--Déclaration des sorties pour les 6 afficheurs 7 segments  
	
	sort_unit_s : out std_logic_vector(3 downto 0);
	sort_diz_s : out std_logic_vector(3 downto 0) ;
	
	sort_unit_m : out std_logic_vector(3 downto 0);
	sort_diz_m : out std_logic_vector(3 downto 0) ;
	
	sort_unit_h : out std_logic_vector(3 downto 0);
	sort_diz_h : out std_logic_vector(3 downto 0));
	
	

end TiPi;


architecture compt_BCD of TiPi is

	--Déclaration des signaux pour les horloges et les autorisations de passage à la minute et à l'heure
	signal autom : std_logic ;
	signal autoh : std_logic ;
	signal h : std_logic ;

	signal auto_m : std_logic ;
   signal auto_h : std_logic ;	
	
	--Déclaration des signaux pour les secondes sur l'horloge
	signal unit_s : std_logic_vector (3 downto 0);
	signal diz_s : std_logic_vector (3 downto 0);

	--Déclaration des signaux pour les minutes sur l'horloge 
	signal unit_m : std_logic_vector (3 downto 0);
	signal diz_m : std_logic_vector (3 downto 0);
	
	--Déclaration des signaux pour les heures sur l'horloge
	signal unit_h : std_logic_vector (3 downto 0);
	signal diz_h : std_logic_vector (3 downto 0);
	
	--Déclaration des signaux des minutes et des heures pour l'alarme
	signal alarm_unit_m : std_logic_vector (3 downto 0);
	signal alarm_diz_m : std_logic_vector (3 downto 0);
	signal alarm_unit_h : std_logic_vector (3 downto 0);
	signal alarm_diz_h : std_logic_vector (3 downto 0);
	
begin

--Réglage de l'horloge en fonction de si on régle l'alarme ou pas, clk3 pour régler l'alarme et clk1 pour l'horloge
h <= clk3 when reg_m = '0' or reg_h = '0' else
clk1;

--On autorise l'incrémentation des minutes si le bouton réglage de l'horloge est enclenché
autom <= '1' when reg_m = '0' else
auto_m;

--On autorise l'incrémentation des heures si le bouton réglage de l'horloge est enclenché
autoh <= '1' when reg_h = '0' else 
auto_h;

--Gestion des secondes

	process ( rst, clk1 )
	
	begin 
		
		--Si le reset est activé on remet tout à zéro
		if rst = '0' then unit_s <= (others=>'0') ; diz_s <= (others=>'0') ;
		
			--On regarde à chaque front montant
			elsif rising_edge(clk1) then 
			
				--Si on a 9 à l'unité des secondes on la remet à zéro ensuite on regarde la dizaine
				if unit_s = "1001" then unit_s <= "0000" ; 
					
					--Si on a 5 à la dizaine des secondes on la remet à zéro
					if diz_s = "0101" then diz_s <= "0000" ; 
					
					--Sinon on incrémente la dizaine de 1
					else diz_s <= diz_s + 1; 
					
					end if;
					
				--Sinon on incrémente l'unité de 1
				else unit_s <= unit_s+1 ;
				
				end if;
				
		end if;
	
	end process;
	
	--Autorisation de l'incrémentation des minutes lorsque qu'il y a 59 secondes
	auto_m <= '1' when diz_s = 5 and unit_s = 9 else
	'0';
	
	--Affichage des secondes sur les afficheurs 7 segments
	sort_unit_s <= unit_s;
	sort_diz_s <= diz_s;
	
	
	
	
	
	--horloge minute
	
	
	
   process ( rst, autom, h )
	
	begin 
	
		if alarm = '1' then 
			
			--Si le reset est activé on remet tout à zéro
			if rst = '0' then unit_m <= (others=>'0') ; diz_m <= (others=>'0') ;
			
			--On regarde à chaque front montant et si l'incrémentation des minutes est autorisée
			elsif rising_edge(h) and autom = '1'
				
				--Si on a 9 à l'unité des minutes on la remet à zéro ensuite on regarde la dizaine
				if unit_m = "1001" then unit_m <= "0000" ; 
					
					--Si on a 5 à la dizaine des minutes on la remet à zéro
					if diz_m = "0101" then diz_m <= "0000" ; 
					
					--Sinon on incrémente la dizaine de 1
					else diz_m <= diz_m + 1; 
						
					end if;
				
				--Sinon on incrémente l'unité de 1
				else unit_m <= unit_m+1 ;
					
				end if;
					
			end if;
		
		end if ; 
			
	end process;
--	
	--Autorisation de l'incrémentation des heures lorsque qu'il y a 59 minutes
	auto_h <= '1' when diz_m = 5 and unit_m = 9 and auto_m = '1'else
	'0';
	
--alarme minute
--Même procédé que pour les minutes de l'horloge si le bouton réglage de l'alarme est enclenché

	process( alarm, rst, h, autom )

	begin 
		
		--On vérifie si le bouton de l'alarme est enclenché
		if alarm = '0' then
		
			if rst = '0' then
			
				alarm_unit_m <= (others=>'0') ; 
				alarm_diz_m <= (others=>'0') ;
				
			elsif autom='1' and rising_edge(h) then
			
				if alarm_unit_m = "1001" then alarm_unit_m <= "0000" ; 
					
					if alarm_diz_m = "0101" then alarm_diz_m <= "0000" ; 
					
					else alarm_diz_m <= alarm_diz_m + 1; 
					
					end if;
					
				else alarm_unit_m <= alarm_unit_m+1 ;
				
				end if;
				
			end if;
			
		end if;
		
	end process;
	

--On regarde si le bouton de l'alarme est enclenché en fonction de ça on affiche soit l'horloge soit l'alarme
with alarm select 
		sort_unit_m <= unit_m when '1',
							alarm_unit_m when '0';
							
with alarm select 
		sort_diz_m <= diz_m when '1',
							alarm_diz_m when '0';
	
	
	
--horloge heure
	
	
	
   process ( rst, autoh, h )
	
	begin 
		
		if alarm = '1' then 
			
			--Si le reset est activé on remet tout à zéro
			if rst = '0' then unit_h <= (others=>'0') ; diz_h <= (others=>'0') ;
			
			elsif rising_edge(h) and autoh = '1' then 
			
				--Si l'heure vaut 24 on remet l'unité et la dizaine à zéro
				if (diz_h = "0010" and unit_h = "0011") then  unit_h <= "0000" ; diz_h <= "0000";
				
				--Si l'unité vaut 4 on la remet à zéro et on incrémente la dizaine de 1
				elsif unit_h = "1001" then unit_h <= "0000" ; diz_h <= diz_h + 1;
						
				--Sinon on incrémente l'unité de 1
				else unit_h <= unit_h+1 ;
					
				end if;
					
			end if;
			
		end if ;
		
			
	end process;

	
--alarme heure
--Même procédé que pour les heures de l'horloge si le bouton réglage de l'alarme est enclenché

	process( alarm, rst, h, autoh )

	begin 
	
		--On vérifie si le bouton de l'alarme est enclenché
		if alarm = '0' then
			
			if rst = '0' then
			
				alarm_unit_h <= (others=>'0') ; 
				alarm_diz_h <= (others=>'0') ;
				
			elsif autoh='1' and rising_edge(h) then
			
				if alarm_diz_h = "0010" and alarm_unit_h = "0011" then alarm_diz_h <= "0000"; alarm_unit_h <= "0000" ;
				
				elsif alarm_unit_h = "1001" then alarm_unit_h <= "0000" ; alarm_diz_h <= alarm_diz_h + 1;	
					
				else alarm_unit_h <= alarm_unit_h+1 ;
				
				end if;
				
			end if;
			
		end if;
		
					
	end process;
	

--On regarde si le bouton de l'alarme est enclenché en fonction de ça on affiche soit l'horloge soit l'alarme
with alarm select 
		sort_unit_h <= unit_h when '1',
							alarm_unit_h when '0';
with alarm select 
		sort_diz_h <= diz_h when '1',
							alarm_diz_h when '0';

--On allume la LED si l'heure de l'alarme correspond à l'heure de l'horloge
led<='1' when alarm_unit_h=unit_h and alarm_diz_h=diz_h and alarm_diz_m=diz_m and alarm_unit_m=unit_m else 
'0';

	
end compt_BCD;

		
