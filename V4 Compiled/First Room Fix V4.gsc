�GSC
     1  R(  a  X(  $  �$  �2  �2      @ �  +        first_room_fix_v4 maps/mp/gametypes_zm/_hud_util maps/mp/zombies/_zm_utility common_scripts/utility maps/mp/_utility maps/mp/zombies/_zm_stats maps/mp/zombies/_zm_weapons maps/mp/animscripts/zm_utility maps/mp/zm_prison maps/mp/zm_tomb maps/mp/zm_tomb_utility maps/mp/zombies/_zm_audio maps/mp/zombies/_zm_net main replacefunc wait_network_frame fixnetworkframe init onplayerconnect connecting player onplayerspawned setdvars originsfix initial_players_connected script zm_transit scr_zm_map_start_location transit players printnetworkframe printfix zm_nuked enable_magic game_ended disconnect spawned_player flag_wait initial_blackscreen_passed hostonly soloonly _a373 _k373 _a373 _k373 iprintln ^5FIRST ROOM FIX V4 network_hud newhudelem alignx center aligny top horzalign user_center vertalign user_top x y fontscale alpha color hidewheninmenu label Network frame check: ^1 start_time int end_time network_frame_len float Network frame check: ^2 setvalue i cheats cool_message Alright there fuckaroo, quit this cheated sheit and touch grass loser. Zi0 & Txch random_float randomfloatrange player_strafeSpeedScale 0.8 player_backSpeedScale 0.7 createwarninghud Movement Speed Modification Attempted. con_gameMsgWindow0LineCount 4 con_gameMsgWindow0MsgTime 5 con_gameMsgWindow0FadeInTime 0.25 con_gameMsgWindow0FadeOutTime 0.5 con_gameMsgWindow0Filter gamenotify obituary No Print Attempted. sv_patch_zm_weapons 0 sv_cheats sv_cheats Attempted. setdvar sv_endGameIfISuck sv_allowAimAssist text offset warnhud left ^1Cheat Warning:  ^5 settext showelem timerhud timer_hud newclienthudelem user_left right user_right roundtimerhud settimerup hud round_timer_hud  fade_time end_of_round time round_number displayroundtime start_of_round timer_for_hud fadeovertime Round Time:  settimer nukemannequins destructibles getentarray destructible targetname _a732 _k732 mannequin origin delete setcharacters get_players enablesurvival enablegreenrun enablemob enableorigins is_classic ciaviewmodel c_zom_suit_viewhands cdcviewmodel c_zom_hazmat_viewhands c_zom_hazmat_viewhands_light setmodel c_zom_player_cdc_fb voice american skeleton base setviewmodel characterindex c_zom_player_cia_fb zm_prison c_zom_player_arlington_fb c_zom_arlington_coat_viewhands vox zmbvoxinitspeaker vox_plr_ favorite_wall_weapons_list ray_gun_zm set_player_is_female character_name Arlington c_zom_player_deluca_fb c_zom_deluca_longsleeve_viewhands thompson_zm Sal layers c_zom_player_handsome_fb c_zom_handsome_sleeveless_viewhands blundergat_zm Billy c_zom_player_oleary_fb c_zom_oleary_shortsleeve_viewhands judge_zm Finn has_weasel zm_highrise zm_buried c_zom_player_farmgirl_fb c_zom_farmgirl_viewhands rottweil72_zm 870mcs_zm c_zom_player_farmgirl_dlc1_fb whos_who_shader c_zom_player_oldman_fb c_zom_oldman_viewhands frag_grenade_zm claymore_zm c_zom_player_oldman_dlc1_fb c_zom_player_engineer_fb c_zom_engineer_viewhands m14_zm m16_zm c_zom_player_engineer_dlc1_fb c_zom_player_reporter_fb c_zom_reporter_viewhands beretta93r_zm talks_in_danger rich_sq_player c_zom_player_reporter_dlc1_fb zm_tomb c_zom_tomb_takeo_fb c_zom_takeo_viewhands Takeo c_zom_tomb_dempsey_fb c_zom_dempsey_viewhands Dempsey c_zom_tomb_richtofen_fb c_zom_richtofen_viewhands Richtofen c_zom_tomb_nikolai_fb russian c_zom_nikolai_viewhands Nikolai eyechange setclientfield zombie_eye_change sndswitchannouncervox richtofen getpapweaponreticle weapon pack_a_punch_weapon_options is_weapon_upgraded calcweaponoptions smiley_face_reticle_index get_base_name camo_index lens_index randomintrange reticle_index reticle_color_index plain_reticle_index use_plain saritch_upgraded_zm scary_eyes_reticle_index purple_reticle_color_index letter_a_reticle_index pink_reticle_color_index letter_e_reticle_index green_reticle_color_index start_zombie_round_logic is_forever_solo_game R   q   �   �   �   �   �   
    ,  D  ^  &-�     �  .   {  6- �     �  .   {  6 &-4  �  6 �
 �U$ %- 4 �  6-4    �  6-4    �  6
�U%  
 F=	  !
 ;G;  CSH;   -4 K  6-4    ]  6  CSH;    CSH;   
 fF;  o9;    �����
 |W
 �W
 �U%-
 �.   �  6'('(  C'(p'(_; 4 ' (=   CSG;  ?  ;  ?  q'(? ��  ��� C'(p'(_;   ' (-
� 0 �  6q'(?��  &	���=+ ���-.    '(
+7!$(
97!2(
G7!=(
]7!S(7  fN7!f(7  hN7! h(	  33�?7!j(7!t(^*7! z(7! �(�7!�(-
 �. �  6-g.    �  '(-.   �  6-g.    �  '(-O�Q.  �  ' ( 	  ���=F;  �7!�(7! t(- 0 �  6+7! t( � f'('(
'(-	     �@	      @.   s  ' (G; � 
 �h
�G>	 
 �h
�G;* F;  -4  �  6-
 �4  �  6'(
 �h
G>	 
 h
*G> 
 ,h
IG>	 
 Nh
lG>	 
 ph
�G;, F;  -4    �  6-2
 �4  �  6'(
 �h
�G>	 
 �h
�G;, F;  -4    �  6-F
 �4  �  6'(-	��L?
 �.   �  6-	 333?
 �.   �  6-
 �
 p. �  6-
 �.   �  6-
 .   �  6-	   �>
 ,.   �  6-	    ?
 N.   �  6-
�. �  6-
 . �  6-
�. �  6-
�. �  6'( +? O�  -.      ' (	  �? 7!j(
& 7!$( 7  fO 7! f( 7  hN 7! h(^  7! z( 7!�(G;  + 7!�(?  = 7!�(- 0   @  6- 0   H  6 Z-.   d  ' (
& 7!$(
9 7!2(
u 7!=(
] 7!S( 7! f( 7! h(	33�? 7!j( 7! t(^* 7! z( 7! �( 7  $
 F;/ 
 � 7!=( 7  fO 7! f( 7  hN 7! h(- 4    �  6- 0  �  6 �����-.   d  '(7  $7!$(7  27!2(7  =7!=(7  S7!S(7  f7!f(7  hN7! h(	33�?7!j(7!t(^*7! z(7! �(�7!�(	  ��L>!�(;` -0 �  6-g�Q.    �  '(
�U%-g�Q.    �  '(O' (  �
I; - 0   �  6
�U%?��  ���	   ��L=O'(-  �0     67!t(  �P+ "7!�(- �0     67! t(' ( H;  -0  /  6	    �>+' A? ��-  �0     67!t(  �P+ �7!�( Gy�-
�.   �  6+-
n
 a.   U  '('(p'(_;' ( 7 �9	   f��C	   fF�D[F;  - 0  �  6 7  �	   \�W�	   3�C	   �QD[F;  - 0  �  6 7  �	   33c�	   ���C	   �ZD[F;  - 0  �  6 7  �3	 ��C	   f�TD[F;  - 0  �  6 7  �3	  �C ([F;  - 0  �  6 7  �7	 ���C	   �D[F;  - 0  �  6q'(?��  C�����-.    �  '('('('('(-.   �  F; v; m
 '(
'' (  
 fF; 
 >' (-
 d0 [  6
~7!x(
�7!�(- 0   �  67! �(  CSI; � -
�0    [  6
~7! x(
�7! �(-0  �  67! �(  CSI; � -
�0    [  6
~7! x(
�7! �(-0  �  67! �(  CSI; K -
d0    [  6
~7! x(
�7! �(- 0  �  67!�(?/ 
 �F= ; �-
�0 [  6
~7!x(
�7!�(-
 �0 �  6-
	
 � 	0 	  6
B	 '	S7! '	(-0 M	  6
q	7!b	(7! �(  CSI; �-
{	0    [  6
~7! x(
�7! �(-
 �	0    �  6-
	
 � 	0 	  6
�	 '	S7!'	(-0    M	  6
�	7! b	(7!�(  �	SI; 3-
�	0  [  6
~7! x(
�7! �(-
 �	0    �  6-
	
 � 	0 	  6

 '	S7!'	(-0    M	  6

7! b	(7!�(  CSI; � -

0  [  6
~7! x(
�7! �(-
 3
0    �  6-
	
 � 	0 	  6
V
 '	S7!'	(-0    M	  6
_
7! b	(7! �(  CSF=  7 b	
 q	F=	  
 �F; !d
(;W 
 F>	  
 o
F>	  
 {
F;3-
�
0   [  6
~7!x(
�7!�(-
 �
0 �  6-
	
 � 	0 	  6
�
 '	S7! '	(
 �
 '	S7! '	(-0    M	  67! �(  
 o
F; -
�
0 [  6
�
7!�
(  CSI; m-
�
0    [  6
~7! x(
�7! �(-
 0    �  6-
	
 � 	0 	  6
+ '	S7!'	(
 ; '	S7!'	(-0    M	  67! �(  
 o
F;! -
G0    [  6
G7! �
(  CSI; �-
c0  [  6
~7! x(
�7! �(-
 |0    �  6-
	
 � 	0 	  6
� '	S7!'	(
 � '	S7!'	(-0    M	  67!�(  
 o
F;! -
�0    [  6
�7! �
(  CSI; � -
�0  [  6
~7! x(
�7! �(-
 �0    �  6-
	
 � 	0 	  6
� '	S7!'	(7! (!(-0 M	  67!�(  
 o
F;! -
 0    [  6
 7! �
(  
 >F= ; -
F0 [  6
~7!x(
�7!�(-
 Z0 �  6-
	
 � 	0 	  6-0    M	  6
p7!b	(7! �(  CSI; �-
v0    [  6
~7! x(
�7! �(-
 �0    �  6-
	
 � 	0 	  6-0   M	  6
�7! b	(7! �(  CSI; -
�0  [  6
~7! x(
�7! �(-
 �0    �  6-
	
 � 	0 	  6-0   M	  6
�7! b	(7!�(  CSI;  -
�0  [  6
�7! x(
�7! �(-
 0    �  6-
	
 � 	0 	  6-0   M	  6
7! b	(7!�( &-
 ?0  0  6-
 g. Q  6 ���� (<Pn����� �_9;  ! �(-. �  9; -0    �    �_;   �'(-. �  '(''( 
 �F; ('(?  
 >F; -'(-.    '
(-.      '	(-.      '('('(
ZF; '	(? ;  '	('('(	F;  '('('(	F;  '('(' (	F;   '(-	
0    �  !�( �  &-
 .   �  6	     ?+  
 >F; ! ( 1���a  v  oq�ɒ  �  g1���  �  �e�-<  �  x�Q��  ]  �#h(�  �  ��D  K  �Q�  �  0��U�  � ����  Q  ײ]j  � z?*��  � \o�N6  8  �ޟ�  �  ���4l"  &  R�&Ɋ"  q � ���#  �  �>   c  z  ��   h  {>  p  �  �q   �  �>   �  �>   �  �>   �  �>   �  K>   �  ]>     �>  `  �  D  �#  �>  �  >       �>  �  �  /  G  �>   �  �>  �  �>    s>  @  �>  y  �  �  �  #  5  �>  L  `  r  �  �  �  �  �  �  �  �  @>  �  H>   �  d>  �  x  �>  S  �>  a  "  �>  l  >  �  �    />  �  U>  X  �>   �  �  �  %  I  q  �>   �  �>   �  [>  �  G  �  �  V  �  �  )    �  �  �  �  W  �  '   Z   �   i!  �!  �>    u  �  %  ~    �  W  >    �  �  �   !  �!  #"  	D �  .  �  n  R  "  �  �  �   "!  �!  :"  M	>  �  O  �  �  �  W  +  �  �   0!  �!  H"  0>  u"  Q>  �"  �>  �"  �>  �"  �>  �"  >  -#  ;#  K#  �>  �#        ��  F  �  � �  � �  �  (  �  >  �  �  �    �  p  D     B   #  #  $   �  �  !�  ; �  C�      t  �  �  �  4  �  �  �    �  �  �  r  �   V!  �!  f ,  �  o4  �>  �@  �B  �  �D  �  | J  � P  � V  � ^  �  B  � �    �  p  �  r  �
  +   $  &  �    �  �  9 "  �  2(  �  �  �  G ,  =2  �  (  �  �  ] 6  �  S<  �  �  �  f	D  L  .  8  �  0  :  �  �  h	T  ^  @  J  �  B  L  �  �  jl    �  �  tt  �    �  �  �  �    z~  T    �  ��  \       � �  ��  �  n  |  
  �  2  � �  �  �       f   *  � V  J  � Z  � b  ^  � f  � �  � �  ~   �   �  �  * �  , �  �  I �  N �  �  l �  p �  p  � �  l  � �  �    �  �     �   �  � 2  � �    �         &    �  + h  = v  Z�  u �     � "  �l  �  �n  �t  �  �   ,  �  �  �  �    $  � <  �^  � v  �  " �  G8  y:  <  �>  n R  a V  ��  �  �  
  2  V  ��  ��  ��  ��  ��  �   �  ' �  > �  d �  �  ~ �  R  �    ^  �  �  2    �  �  �  b   �   r!  x  \  �    f  �  �  <  &  �  �  �  j   �   |!  "  � 
  `  �    j     �  @  *  �  �  �  n   �   �!  "  �  j  �    r  
  �  J  2  �  �  �  v   �   �!  "  �.  �  �  6  �  p    �  �  j  >     �   P!  �!  h"  � @  �  � B  �  
#  � P  � x  	 �  $  �  d  H    �  �  �   !  �!  0"  � �  (  �  h  L    �  �  �   !  �!  4"  	�  ,  �  l  P     �  �  �    !  �!  8"  B	 �  '	�  �  :  D  �  �  z  �  ^  h  r  |  .  8  B  L           �  �  q	 �  �  b		�  d    �  �  �   D!  �!  \"  {	 �  �	   �	 6  �	 Z  �	v  �	 �  �	 �  
 �  
 �  
 "  3
 P  V
 v  _
 �  d
�  o
 �  �  t  H     {
   �
   �
 8  �
 Z  �
 n  �
 �  �  �
�  �  l  <   �
 �     + *  ; >  G |  �  c �  | �  � �  �   � P  b  � ~  � �  � �  �  �        2   > F   #  $  F T   Z |   p �   v �   � !  � :!  � b!  � �!  � �!  � �!  � �!   "   R"  ? r"  g �"  ��"  ��"  ��"  ��"   �"  �"  (�"  <�"  P�"  n�"  ��"  ��"  ��"  ��"  ��"  ��"  �"  �"  �"  �#  �#  Z d#   �#  $  