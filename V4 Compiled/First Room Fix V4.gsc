�GSC
     U  J+  �  P+  .&  '  �5  �5      @ �  8        first_room_fix_v4 maps/mp/gametypes_zm/_hud_util maps/mp/zombies/_zm_utility common_scripts/utility maps/mp/_utility maps/mp/zombies/_zm_stats maps/mp/zombies/_zm_weapons maps/mp/animscripts/zm_utility maps/mp/zm_prison maps/mp/zm_tomb maps/mp/zm_tomb_utility maps/mp/zombies/_zm_audio maps/mp/zombies/_zm_net main replacefunc wait_network_frame fixnetworkframe network_choke_thread fixnetworkthread attack_vox_network_choke fixattackvox check_solo_status forcenotsolo adjustments_for_solo adjustbylobbysize init onplayerconnect connecting player onplayerspawned setdvars initial_players_connected script zm_transit scr_zm_map_start_location transit players printnetworkframe printfix zm_nuked enable_magic game_ended disconnect spawned_player flag_wait initial_blackscreen_passed hostonly soloonly _a865 _k865 _a865 _k865 iprintln ^5FIRST ROOM FIX V4 id zombie_network_choke_ids_count _num_attack_vox network_hud newhudelem alignx center aligny top horzalign user_center vertalign user_top x y fontscale alpha color hidewheninmenu label Network frame check:  start_time int end_time network_frame_len float setvalue i cheats cool_message Alright there fuckaroo, quit this cheated sheit and touch grass loser. Zi0 & Txch player_strafeSpeedScale 0.8 player_backSpeedScale 0.7 createwarninghud Movement Speed Modification Attempted. con_gameMsgWindow0LineCount 4 con_gameMsgWindow0MsgTime 5 con_gameMsgWindow0FadeInTime 0.25 con_gameMsgWindow0FadeOutTime 0.5 con_gameMsgWindow0Filter gamenotify obituary No Print Attempted. sv_patch_zm_weapons 0 sv_cheats sv_cheats Attempted. setdvar sv_endGameIfISuck sv_allowAimAssist randomfloatrange text offset warnhud left ^1Cheat Warning:  ^5 settext showelem timerhud timer_hud newclienthudelem right user_right roundtimerhud settimerup hud round_timer_hud  fade_time end_of_round time round_number displayroundtime start_of_round timer_for_hud fadeovertime Round Time:  settimer nukemannequins destructibles getentarray destructible targetname _a865 _k865 mannequin origin delete setcharacters get_players enablesurvival enablegreenrun enablemob enableorigins is_classic ciaviewmodel c_zom_suit_viewhands cdcviewmodel c_zom_hazmat_viewhands c_zom_hazmat_viewhands_light setmodel c_zom_player_cdc_fb voice american skeleton base setviewmodel characterindex c_zom_player_cia_fb zm_prison c_zom_player_arlington_fb c_zom_arlington_coat_viewhands vox zmbvoxinitspeaker vox_plr_ favorite_wall_weapons_list ray_gun_zm set_player_is_female character_name Arlington c_zom_player_deluca_fb c_zom_deluca_longsleeve_viewhands thompson_zm Sal layers c_zom_player_handsome_fb c_zom_handsome_sleeveless_viewhands blundergat_zm Billy c_zom_player_oleary_fb c_zom_oleary_shortsleeve_viewhands judge_zm Finn has_weasel zm_highrise zm_buried c_zom_player_farmgirl_fb c_zom_farmgirl_viewhands rottweil72_zm 870mcs_zm c_zom_player_farmgirl_dlc1_fb whos_who_shader c_zom_player_oldman_fb c_zom_oldman_viewhands frag_grenade_zm claymore_zm c_zom_player_oldman_dlc1_fb c_zom_player_engineer_fb c_zom_engineer_viewhands m14_zm m16_zm c_zom_player_engineer_dlc1_fb c_zom_player_reporter_fb c_zom_reporter_viewhands beretta93r_zm talks_in_danger rich_sq_player c_zom_player_reporter_dlc1_fb zm_tomb c_zom_tomb_takeo_fb c_zom_takeo_viewhands Takeo c_zom_tomb_dempsey_fb c_zom_dempsey_viewhands Dempsey c_zom_tomb_richtofen_fb c_zom_richtofen_viewhands Richtofen c_zom_tomb_nikolai_fb russian c_zom_nikolai_viewhands Nikolai eyechange setclientfield zombie_eye_change sndswitchannouncervox richtofen getpapweaponreticle weapon pack_a_punch_weapon_options is_weapon_upgraded calcweaponoptions smiley_face_reticle_index get_base_name camo_index lens_index randomintrange reticle_index reticle_color_index plain_reticle_index use_plain saritch_upgraded_zm scary_eyes_reticle_index purple_reticle_color_index letter_a_reticle_index pink_reticle_color_index letter_e_reticle_index green_reticle_color_index is_forever_solo_game getnumexpectedplayers sessionmodeisonlinegame sessionmodeisprivate a_door_buys zombie_door array_thread door_price_reduction_for_solo a_debris_buys zombie_debris change_weapon_cost R   q   �   �   �   �   �   
    ,  D  ^  &-�     �  .   {  6- �     �  .   {  6- �     �  .   {  6- �     �  .   {  6-      �  .   {  6- *       .   {  6 &-4  A  6 \
 QU$ %- 4 c  6-4    s  6
|U%  �
 �F=	  �
 �G;  �SF;   -4 �  6-4    �  6  �SH;    �SH;   �
 �F;  �9;    MV_e\
 W
 W
 U%-
 2.   (  6'('( �'(p'(_; 4 ' (=   �SG;  ?  ;  ?  q'(? ��  _e\ �'(p'(_;   ' (-
� 0 w  6q'(?��  &	���=+ �;  	   ���=+ !�(? ��  &; ! �(	  ���=+?��  �ds|-.  �  '(
�7!�(
�7!�(
 7!�(
7!(7  N7!(7  !N7! !(	  33�?7!#(7!-(^*7! 3(7! 9(N7!H(-
 2. (  6-g.    o  '(-.   �  6-g.    o  '(-O�Q.  �  ' (7! -(- 0 �  6+7! -( ���'('(
�' (G; � 
 h
G>	 
 !h
7G;, F;  - 4    ;  6-
 L4  ;  6'(
 sh
�G>	 
 �h
�G> 
 �h
�G>	 
 �h
�G>	 
 �h

G;, F;  - 4    ;  6-2
 4  ;  6'(
 2h
FG>	 
 Hh
FG;, F;  - 4    ;  6-F
 R4  ;  6'(-	��L?
 .   g  6-	 333?
 !.   g  6-
 

 �. g  6-
 s.   g  6-
 �.   g  6-	   �>
 �.   g  6-	    ?
 �.   g  6-
o. g  6-
�. g  6-
2. g  6-
H. g  6'(-	 fff@	   ���>.   �  +?9�  ���-.    �  ' (	  �? 7!#(
� 7!�( 7  O 7! ( 7  !N 7! !(^  7! 3( 7!9(G;  � 7!H(?  � 7!H(- 0   �  6- 0   �  6 �-.   �  ' (
 7!�(
� 7!�(
 7!�(
 7!( 7  O 7! ( 7  !N 7! !(	33�? 7!#( 7! -(^* 7! 3( 7! 9(- 4    6- 0  &  6 15ds]-.   �  '(7  �7!�(7  �7!�(7  �7!�(7  7!(7  
7 NO7!(7  !7 !NN7!!(	33�?7!#(7!-(^*7! 3(7! 9(E7!H(	  ��L>!F(;` -0 &  6-g�Q.    o  '(
PU%-g�Q.    o  '(O' (  b
I; - 0   o  6
�U%?��  ]1��	   ��L=O'(-  F0   �  67!-(  FP+ �7!H(- F0   �  67! -(' ( H;  -0  �  6	    �>+' A? ��-  F0   �  67!-(  FP+ E7!H( �_e-
2.   (  6+-
�
 �.   �  '('(p'(_;' ( 7 9	   f��C	   fF�D[F;  - 0    6 7  	   \�W�	   3�C	   �QD[F;  - 0    6 7  	   33c�	   ���C	   �ZD[F;  - 0    6 7  3	 ��C	   f�TD[F;  - 0    6 7  3	  �C ([F;  - 0    6 7  7	 ���C	   �D[F;  - 0    6q'(?��  �?N]g��-.    3  '('('('('(-.   u  F; v; m
 �'(
�' (  �
 �F; 
 �' (-
 �0 �  6
	7! 	(
	7!	(- 0   	  67! *	(  �SI; � -
9	0    �  6
	7!  	(
	7! 	(-0  	  67! *	(  �SI; � -
9	0    �  6
	7!  	(
	7! 	(-0  	  67! *	(  �SI; K -
�0    �  6
	7!  	(
	7! 	(- 0  	  67!*	(?/ �
 M	F= ; �-
W	0 �  6
	7! 	(
	7!	(-
 q	0 	  6-
�	
 \ �	0 �	  6
�	 �	S7! �	(-0 �	  6
�	7!�	(7! *	(  �SI; �-

0    �  6
	7!  	(
	7! 	(-
 
0    	  6-
�	
 \ �	0 �	  6
<
 �	S7!�	(-0    �	  6
H
7! �	(7!*	(  L
SI; 3-
S
0  �  6
	7!  	(
	7! 	(-
 l
0    	  6-
�	
 \ �	0 �	  6
�
 �	S7!�	(-0    �	  6
�
7! �	(7!*	(  �SI; � -
�
0  �  6
	7!  	(
	7! 	(-
 �
0    	  6-
�	
 \ �	0 �	  6
�
 �	S7!�	(-0    �	  6
�
7! �	(7! *	(  �SF=  7 �	
 �	F=	  �
 M	F; !�
(;W �
 �F>	  �
 �
F>	  �
 F;3-
0   �  6
	7! 	(
	7!	(-
 &0 	  6-
�	
 \ �	0 �	  6
? �	S7! �	(
 M �	S7! �	(-0    �	  67! *	(  �
 �
F; -
W0 �  6
W7!u(  �SI; m-
�0    �  6
	7!  	(
	7! 	(-
 �0    	  6-
�	
 \ �	0 �	  6
� �	S7!�	(
 � �	S7!�	(-0    �	  67! *	(  �
 �
F;! -
�0    �  6
�7! u(  �SI; �-
�0  �  6
	7!  	(
	7! 	(-
 0    	  6-
�	
 \ �	0 �	  6
 �	S7!�	(
 $ �	S7!�	(-0    �	  67!*	(  �
 �
F;! -
+0    �  6
+7! u(  �SI; � -
I0  �  6
	7!  	(
	7! 	(-
 b0    	  6-
�	
 \ �	0 �	  6
{ �	S7!�	(7! �(!�(-0 �	  67!*	(  �
 �
F;! -
�0    �  6
�7! u(  �
 �F= ; -
�0 �  6
	7! 	(
	7!	(-
 �0 	  6-
�	
 \ �	0 �	  6-0    �	  6
�7!�	(7! *	(  �SI; �-
�0    �  6
	7!  	(
	7! 	(-
 0    	  6-
�	
 \ �	0 �	  6-0   �	  6
,7! �	(7! *	(  �SI; -
40  �  6
	7!  	(
	7! 	(-
 L0    	  6-
�	
 \ �	0 �	  6-0   �	  6
f7! �	(7!*	(  �SI;  -
p0  �  6
�7!  	(
	7! 	(-
 �0    	  6-
�	
 \ �	0 �	  6-0   �	  6
�7! �	(7!*	( &-
 �0  �  6-
 �. �  6 U	}������*AZq _9;  ! (-. 0  9; -0    C    _;   '(-. o  '(''( �
 M	F; ('(?  �
 �F; -'(-.  �  '
(-.    �  '	(-.    �  '('('(
�F; '	(? ;  '	('('(	F;  '('('(	F;  '('(' (	F;   '(-	
0    C  !(   &  �
 �F;
 ! �(?; -.    �  F> -.    �  9=	 -.  �  9;
 !�(? ! �( �& �SF; i -
�
 �.   �  '(-     . �  6-
 �
 4. �  ' (-      . �  6- �
 {. B  6- �
 M. B  6 Я�&�  v  Mqz�  <  ��O"  A  �� ��  c  ��z�4  �  �#h(r  �  S��Uz  � �=c�  �  �?q/�  �  � <β  s  �;c�  ; ҿ��.  �  �:�   TE!�  o ���  �  ��0+�  %  t�4��#  �  �Q�W�#  � �l˹^%    q�i�%  *  �>   �  �  ��   �  {>  �  �  �  �  �    �q   �  �>   �  �^  �  �>   �  �D  �  >   �  �,  �  *>   �  ,    A>     c>   2  s>   ;  �>   r  �>   {  (>  �  N  �  w>  ^  �>   �  �  o>  W  o  �  �  �>   d  �>  �  �>  �  ;>  �  	  _  q  �  �  g>  �  �  �       $  8  F  R  ^  j  �>  �  �>    �>   $  �>  4  �  >  �  &>  �  �  o>  �  �>    @  �  �>  e  �>  �  �%  �%  >     A  q  �  �  �  3>     u>   ,  �>  j  �    k  �  [  �  �  �  &  O  �  %   �   �   �!  �!  O"  �"  i#  	>  �  �  A  �  �  �  +  �  �    S   '!  �!  "  #  �#  �	D   �  B  �  �  �  j   >!  
"  �"  "#  �#  �	>  &  �  c    �  �  �   r!  "  �"  0#  �#  �>  �#  �>  �#  0>  2$  C>  C$  o>  j$  �>  �$  �$  �$  C>  C%  �>   w%  �>   �%  �>   �%  >   �%  �%  �>  �%  &  B>  &  &&        \$  �  :  Q (  | F  �N  �  P  �  F  ^  j  v    �  �   �!  �!  z$  �$  b%  � R  b  �Z  � ^  �f  �  �  �    >  �  �     X  H  �  *  <     �   <"  �"  V#  �%  � �  T  ��  M�  V�  _�  6  �  e�  8  �   �   �   �  2 �  L  �  � Z  �|  ��  ��  ��  d�  �  s�  �  |�  � �  ��  �  F  �  �  � �  J  ��  P  �       �  ��  Z       �  ^  �  d      	�     �  �  l  v  $  ,  4  !	    �  �  ~  �  <  D  L  #   �  �  X  -(  �  �  �  `  "  P  �  32  �  �  j  9<  �  �  t  N @  HF      ~  6  �  ��  �  ��  ��  � �   �  �   �  ! �  �  7 �  L   s   �  �   � $    � (  � 0  "  � 4  � <  6  � @  � H  �  
 L  �   n  2 �  \  F �  �  H �  h  R �  o D  � P  ��  ��  ��  � �  � �  � 
  �0   @   T  1�  �  5�  ]�  �  E x  �  F�    (  <  �  �  P �  b�  � �  ��  � 0  ��  �  � �  �%  �%  � �  �    N  ~  �  �  ?�  N   ]  g  �  �  � B  � H  � \  � d  d  	 r  �    v  �  f    �  �  Z  .   !  �!  Z"  �"   	z  �  (  �  �  p    �  �  d  8   !  �!  d"  �"  |#  	 ~  �  ,  �  �  t    �  �  h  <   !  �!  h"  �"  �#  	�  �  6  �  �  ~    �  �  r  F   !  �!  r"  �"  �#  *	�  �  R  �  B  �  �  $    �  �   �!  6"  �"  P#  �#  9	 �    M	 �  J  ~$  W	 �  q	 �  �	 �  �  8  �  �  �  `   4!   "  �"  #  �#  \    �  <  �  �  �  d   8!  "  �"  #  �#  �	  �  @  �  �  �  h   <!  "  �"   #  �#  �	   �	    �  �  N  X  �  �  �  �  �  �  �  �  �  �  v   �   �   �   J!  T!  �	 .  >  �		6  �  x    :  *"  �"  D#  �#  
 T  
 �  <
 �  H
 �  L
�  S
 �  l
 $  �
 J  �
 n  �
 �  �
 �  �
 �  �
   �
T  �
 n    �  �   �!   z   �  & �  ? �  M �  $&  W    .  u6     �   �!  � H  � x  � �  � �  � �     �     L    r   $ �   + �   �   I �   b  !  { F!  &  �b!  �h!  � �!  �!  � �!  �$  f%  � �!  � �!  � ""  � H"   x"  , �"  4 �"  L #  f :#  p b#  � r#  � �#  � �#  � �#  � �#   $  U$  	$  }$  �$  �
$  �$  �$  �$  �$  $  *$  A$  Z$  q$   $  ,$  R$  ^$  P%  X%  � �$  �p%  �%  �%  ��%  &�%  � �%  4 �%  