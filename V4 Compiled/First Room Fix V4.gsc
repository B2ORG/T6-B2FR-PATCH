�GSC
       B(  G  H(  $  �$  �2  �2      @ �  +        first_room_fix_v4 maps/mp/gametypes_zm/_hud_util maps/mp/zombies/_zm_utility common_scripts/utility maps/mp/_utility maps/mp/zombies/_zm_stats maps/mp/zombies/_zm_weapons maps/mp/animscripts/zm_utility maps/mp/zm_prison maps/mp/zm_tomb maps/mp/zm_tomb_utility maps/mp/zombies/_zm_audio maps/mp/zombies/_zm_net main replacefunc wait_network_frame fixnetworkframe init onplayerconnect connecting player onplayerspawned setdvars originsfix initial_players_connected script zm_transit scr_zm_map_start_location transit players printnetworkframe printfix zm_nuked enable_magic game_ended disconnect spawned_player flag_wait initial_blackscreen_passed hostonly soloonly _a248 _k248 _a248 _k248 iprintln ^5FIRST ROOM FIX V4 network_hud newhudelem alignx center aligny top horzalign user_center vertalign user_top x y fontscale alpha color hidewheninmenu label Network frame check:  start_time int end_time network_frame_len float setvalue i cheats cool_message Alright there fuckaroo, quit this cheated sheit and touch grass loser. Zi0 & Txch random_float randomfloatrange player_strafeSpeedScale 0.8 player_backSpeedScale 0.7 createwarninghud Movement Speed Modification Attempted. con_gameMsgWindow0LineCount 4 con_gameMsgWindow0MsgTime 5 con_gameMsgWindow0FadeInTime 0.25 con_gameMsgWindow0FadeOutTime 0.5 con_gameMsgWindow0Filter gamenotify obituary No Print Attempted. sv_patch_zm_weapons 0 sv_cheats sv_cheats Attempted. setdvar sv_endGameIfISuck sv_allowAimAssist text offset warnhud left ^1Cheat Warning:  ^5 settext showelem timerhud timer_hud newclienthudelem user_left right user_right roundtimerhud settimerup hud round_timer_hud  fade_time end_of_round time round_number displayroundtime start_of_round timer_for_hud fadeovertime Round Time:  settimer nukemannequins destructibles getentarray destructible targetname _a248 _k248 mannequin origin delete setcharacters get_players enablesurvival enablegreenrun enablemob enableorigins is_classic ciaviewmodel c_zom_suit_viewhands cdcviewmodel c_zom_hazmat_viewhands c_zom_hazmat_viewhands_light setmodel c_zom_player_cdc_fb voice american skeleton base setviewmodel characterindex c_zom_player_cia_fb zm_prison c_zom_player_arlington_fb c_zom_arlington_coat_viewhands vox zmbvoxinitspeaker vox_plr_ favorite_wall_weapons_list ray_gun_zm set_player_is_female character_name Arlington c_zom_player_deluca_fb c_zom_deluca_longsleeve_viewhands thompson_zm Sal layers c_zom_player_handsome_fb c_zom_handsome_sleeveless_viewhands blundergat_zm Billy c_zom_player_oleary_fb c_zom_oleary_shortsleeve_viewhands judge_zm Finn has_weasel zm_highrise zm_buried c_zom_player_farmgirl_fb c_zom_farmgirl_viewhands rottweil72_zm 870mcs_zm c_zom_player_farmgirl_dlc1_fb whos_who_shader c_zom_player_oldman_fb c_zom_oldman_viewhands frag_grenade_zm claymore_zm c_zom_player_oldman_dlc1_fb c_zom_player_engineer_fb c_zom_engineer_viewhands m14_zm m16_zm c_zom_player_engineer_dlc1_fb c_zom_player_reporter_fb c_zom_reporter_viewhands beretta93r_zm talks_in_danger rich_sq_player c_zom_player_reporter_dlc1_fb zm_tomb c_zom_tomb_takeo_fb c_zom_takeo_viewhands Takeo c_zom_tomb_dempsey_fb c_zom_dempsey_viewhands Dempsey c_zom_tomb_richtofen_fb c_zom_richtofen_viewhands Richtofen c_zom_tomb_nikolai_fb russian c_zom_nikolai_viewhands Nikolai eyechange setclientfield zombie_eye_change sndswitchannouncervox richtofen getpapweaponreticle weapon pack_a_punch_weapon_options is_weapon_upgraded calcweaponoptions smiley_face_reticle_index get_base_name camo_index lens_index randomintrange reticle_index reticle_color_index plain_reticle_index use_plain saritch_upgraded_zm scary_eyes_reticle_index purple_reticle_color_index letter_a_reticle_index pink_reticle_color_index letter_e_reticle_index green_reticle_color_index start_zombie_round_logic is_forever_solo_game R   q   �   �   �   �   �   
    ,  D  ^  &-  �     �  .   {  6- �     �  .   {  6 &-4  �  6 �
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
 �. �  6-g.    �  '(-.   �  6-g.    �  '(-O�Q.  �  ' (7! t(- 0 �  6+7! t( ���L'('(
�'(-	     �@	      @.   Y  ' (G; � 
 jh
�G>	 
 �h
�G;* F;  -4  �  6-
 �4  �  6'(
 �h
�G>	 
 �h
G> 
 h
/G>	 
 4h
RG>	 
 Vh
oG;, F;  -4    �  6-2
 �4  �  6'(
 �h
�G>	 
 �h
�G;, F;  -4    �  6-F
 �4  �  6'(-	��L?
 j.   �  6-	 333?
 �.   �  6-
 o
 V. �  6-
 �.   �  6-
 �.   �  6-	   �>
 .   �  6-	    ?
 4.   �  6-
�. �  6-
�. �  6-
�. �  6-
�. �  6'( +? O�  ��-.      ' (	  �? 7!j(
 7!$( 7  fO 7! f( 7  hN 7! h(^  7! z( 7!�(G;   7!�(?  # 7!�(- 0   &  6- 0   .  6 @-.   J  ' (
 7!$(
9 7!2(
[ 7!=(
] 7!S( 7  fN 7! f( 7  hN 7! h(	33�? 7!j( 7! t(^* 7! z( 7! �( 7  $
 eF;/ 
 k 7!=( 7  fO 7! f( 7  hN 7! h(- 4    v  6- 0  �  6 �����-.   J  '(7  $7!$(7  27!2(7  =7!=(7  S7!S(7  f
7 fNO7!f(7  h7 hNN7!h(	33�?7!j(7!t(^*7! z(7! �(�7!�(	  ��L>!�(;` -0 �  6-g�Q.    �  '(
�U%-g�Q.    �  '(O' (  �
I; - 0   �  6
�U%?��  ����	   ��L=O'(-  �0   �  67!t(  �P+ 7!�(- �0   �  67! t(' ( H;  -0    6	    �>+' A? ��-  �0   �  67!t(  �P+ �7!�( -��k-
�.   �  6+-
T
 G.   ;  '('(p'(_;' ( 7 u9	   f��C	   fF�D[F;  - 0  |  6 7  u	   \�W�	   3�C	   �QD[F;  - 0  |  6 7  u	   33c�	   ���C	   �ZD[F;  - 0  |  6 7  u3	 ��C	   f�TD[F;  - 0  |  6 7  u3	  �C ([F;  - 0  |  6 7  u7	 ���C	   �D[F;  - 0  |  6q'(?��  C����� -.    �  '('('('('(-.   �  F; v; m
 �'(
' (  
 fF; 
 $' (-
 J0 A  6
d7!^(
v7!m(- 0   {  67! �(  CSI; � -
�0    A  6
d7! ^(
v7! m(-0  {  67! �(  CSI; � -
�0    A  6
d7! ^(
v7! m(-0  {  67! �(  CSI; K -
J0    A  6
d7! ^(
v7! m(- 0  {  67!�(?/ 
 �F= ; �-
�0 A  6
d7!^(
v7!m(-
 �0 {  6-
	
 � �0 �  6
(	 	S7! 	(-0 3	  6
W	7!H	(7! �(  CSI; �-
a	0    A  6
d7! ^(
v7! m(-
 x	0    {  6-
	
 � �0 �  6
�	 	S7!	(-0    3	  6
�	7! H	(7!�(  �	SI; 3-
�	0  A  6
d7! ^(
v7! m(-
 �	0    {  6-
	
 � �0 �  6
�	 	S7!	(-0    3	  6
�	7! H	(7!�(  CSI; � -

0  A  6
d7! ^(
v7! m(-
 
0    {  6-
	
 � �0 �  6
<
 	S7!	(-0    3	  6
E
7! H	(7! �(  CSF=  7 H	
 W	F=	  
 �F; !J
(;W 
 F>	  
 U
F>	  
 a
F;3-
k
0   A  6
d7!^(
v7!m(-
 �
0 {  6-
	
 � �0 �  6
�
 	S7! 	(
 �
 	S7! 	(-0    3	  67! �(  
 U
F; -
�
0 A  6
�
7!�
(  CSI; m-
�
0    A  6
d7! ^(
v7! m(-
 �
0    {  6-
	
 � �0 �  6
 	S7!	(
 ! 	S7!	(-0    3	  67! �(  
 U
F;! -
-0    A  6
-7! �
(  CSI; �-
I0  A  6
d7! ^(
v7! m(-
 b0    {  6-
	
 � �0 �  6
{ 	S7!	(
 � 	S7!	(-0    3	  67!�(  
 U
F;! -
�0    A  6
�7! �
(  CSI; � -
�0  A  6
d7! ^(
v7! m(-
 �0    {  6-
	
 � �0 �  6
� 	S7!	(7! �(!�(-0 3	  67!�(  
 U
F;! -
0    A  6
7! �
(  
 $F= ; -
,0 A  6
d7!^(
v7!m(-
 @0 {  6-
	
 � �0 �  6-0    3	  6
V7!H	(7! �(  CSI; �-
\0    A  6
d7! ^(
v7! m(-
 r0    {  6-
	
 � �0 �  6-0   3	  6
�7! H	(7! �(  CSI; -
�0  A  6
d7! ^(
v7! m(-
 �0    {  6-
	
 � �0 �  6-0   3	  6
�7! H	(7!�(  CSI;  -
�0  A  6
�7! ^(
v7! m(-
 �0    {  6-
	
 � �0 �  6-0   3	  6
7! H	(7!�( &-
 %0    6-
 M. 7  6 k�v�� "6Tm���� r_9;  ! r(-. �  9; -0    �    r_;   r'(-. �  '(''( 
 �F; ('(?  
 $F; -'(-.  �  '
(-.    �  '	(-.    �  '('('(
@F; '	(? ;  '	('('(	F;  '('('(	F;  '('(' (	F;   '(-	
0    �  !r( r  &-
 �.   �  6	     ?+  
 $F; ! ( ��SG  v  oq��z  �  g1���  �  �e�-$  �  x�Q��  ]  �#h(�  �  I���  K  �m��  �  ��%�  � S(�Lj  7  �L��J  v ���p  � �_�&    �(�sv  �  �a_�\"    ���z"  W 7J���#  �  �>   I  b  ��   P  {>  X  p  �q   h  �>   }  �>   �  �>   �  �>   �  K>   �  ]>   �  �>  H  �  4  �#  �>  �  >   �  �  �>  �  �    7  �>   �  �>  �  �>  �  Y>    �>  I  Y  �  �  �    �>    0  B  P  `  t  �  �  �  �  �  &>  T  .>   `  J>  p  X  v>  3  �>  A    �>  \  �>  �  �     >  �  ;>  H  |>   �  �  �    9  a  �>   �  �>   �  A>  �  7  �  �  F  �  y      �  �  s  �  G  u     J   �   Y!  �!  {>    e  �    n    �  G  .  �  �  �  r   �   �!  "  �D �    �  ^  B    �  �  �   !  �!  *"  3	>  �  ?  �    w  G    �  �    !  �!  8"  >  e"  7>  r"  �>  �"  �>  �"  �>  �"  �>  #  +#  ;#  �>  �#        ��  .  �  � �  � �  �    �  .  �  �  �  �  �  `  4     2   �"  
#  �#   �  �  !�  ; �  C�  �    \  ~  �  x  $  |  �  �    �  �  �  b  �   F!  �!  f   �  o  �&  �(  �*  �  *  �,  �  ,  | 2  � 8  � >  � F  �  2  � �  �  ��  P  ��  R  ��  +    $  �  �  �  h  n  9 
  �  2  �  v  |  G   =  �    �  �  ]   �  S$  �  �  �  f,  4  �    �  �      �  �  �  h<  F      �  �  "  ,  �  �  �  jT  �  �  �  t\  �  �  �  �  �  �    zf  $  �  �  �p  ,  �  �  � t  �z  >  L  �  �  "  ��  x  ��  ��  L�  � �  j &    � *  � 2  .  � 6  � V  � h  N  � l  � t  ^   x   �  r  / �  4 �  �  R �  V �  @  o �  <  � �  � �  �  � �  �  � �  �  �   � �  � �  ��  ��  �   �  |   8  # F  @l  [ �  e �  k   �L  t  �N  �T  r  � �    �  �  �  �  �    � ,  �N  � f  �v   �  -(  k.  T B  G F  up  �  �  �  "  F  �z  �|  �~  ��  ��   �  � �   �  $ �  J �  �  d �  B  �  �  N  �  �  "    �  �  ~  R   �   b!  ^�  L  �  �  V  �  �  ,    �  �  �  Z   �   l!  �!  v �  P  �     Z  �  �  0    �  �  �  ^   �   p!  �!  m  Z  �  
  b  �  �  :  "  �  �  �  f   �   z!  "  �  v  �  &  �  `     �  �  Z  .  �  �   @!  �!  X"  � 0  �  � 2  �  �"  � @  � h  	 x    �  T  8    �  �  |   !  �!   "  � |    �  X  <    �  �  �   !  �!  $"  ��    �  \  @    �  �  �   !  �!  ("  (	 �  	�  �  *  4  �  �  j  t  N  X  b  l    (  2  <  �  �      �  �  W	 �  �  H		�  T  �  �  �  �   4!  �!  L"  a	 �  x	    �	 &  �	 J  �	f  �	 r  �	 �  �	 �  �	 �  
   
 @  <
 f  E
 �  J
�  U
 �  �  d  8     a
 �  k
 �  �
 (  �
 J  �
 ^  �
 �  �  �
�  �  \  ,   �
 �  �
 �     ! .  - l  ~  I �  b �  { �  �   � @  R  � n  � �  � �  ��  ��      "   $ 6   #  �#  , D   @ l   V �   \ �   r �   � *!  � R!  � �!  � �!  � �!  � �!  � "   B"  % b"  M p"  k|"  �~"  v�"  ��"  ��"   �"  �"  "�"  6�"  T�"  m�"  ��"  ��"  ��"  ��"  r�"  �"  �"  �"  �#  �#  @ T#  � �#  $  